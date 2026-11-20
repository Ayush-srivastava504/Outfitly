import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/prefs/app_prefs.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../outfit_creator/outfit_creator_screen.dart';
import 'avatar_painter.dart';

/// Where each kind of garment sits on the avatar by default (normalised to the avatar box).
({Offset center, double width, int z}) defaultPlacement(ClothingCategory c) => switch (c) {
  ClothingCategory.bottoms => (center: const Offset(0.5, 0.70), width: 0.44, z: 1),
  ClothingCategory.shoes => (center: const Offset(0.5, 0.93), width: 0.40, z: 2),
  ClothingCategory.dresses => (center: const Offset(0.5, 0.45), width: 0.56, z: 3),
  ClothingCategory.tops => (center: const Offset(0.5, 0.35), width: 0.60, z: 4),
  ClothingCategory.outerwear => (center: const Offset(0.5, 0.38), width: 0.68, z: 5),
  ClothingCategory.bags => (center: const Offset(0.80, 0.52), width: 0.28, z: 6),
  ClothingCategory.accessories => (center: const Offset(0.5, 0.20), width: 0.24, z: 7),
};

class TryOnLayer {
  TryOnLayer(this.item) {
    final d = defaultPlacement(item.categoryEnum);
    center = d.center;
    width = d.width;
    z = d.z;
  }
  ClothingItem item;
  late Offset center;
  late double width;
  late int z;
  double rotation = 0;

  void reset() {
    final d = defaultPlacement(item.categoryEnum);
    center = d.center;
    width = d.width;
    rotation = 0;
  }
}

class TryOnView extends ConsumerStatefulWidget {
  const TryOnView({super.key, this.initialItemIds = const []});
  final List<String> initialItemIds;

  @override
  ConsumerState<TryOnView> createState() => _TryOnViewState();
}

class _TryOnViewState extends ConsumerState<TryOnView> with AutomaticKeepAliveClientMixin {
  final Map<ClothingCategory, TryOnLayer> _layers = {};
  final _canvasKey = GlobalKey();
  ClothingCategory _category = ClothingCategory.tops;
  ClothingCategory? _selected;
  final Set<String> _processing = {};

  // Gesture baselines.
  double _startWidth = 0, _startRotation = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    for (final id in widget.initialItemIds) {
      final it = await ref.read(wardrobeRepoProvider).getItem(id);
      if (it != null && mounted) _wear(it);
    }
  }

  BodyShape get _shape {
    final n = ref.read(sharedPrefsProvider).getString('tryOnShape');
    return BodyShape.values.firstWhere((s) => s.name == n, orElse: () => BodyShape.regular);
  }

  Color get _skin => kSkinTones[(ref.read(sharedPrefsProvider).getInt('tryOnSkin') ?? 1).clamp(0, kSkinTones.length - 1)];

  void _wear(ClothingItem it) {
    setState(() {
      final c = it.categoryEnum;
      // A dress replaces top + bottom and vice versa.
      if (c == ClothingCategory.dresses) {
        _layers.remove(ClothingCategory.tops);
        _layers.remove(ClothingCategory.bottoms);
      } else if (c == ClothingCategory.tops || c == ClothingCategory.bottoms) {
        _layers.remove(ClothingCategory.dresses);
      }
      _layers[c] = TryOnLayer(it);
      _selected = c;
    });
    _ensureCutout(it);
  }

  Future<void> _ensureCutout(ClothingItem it, {bool force = false}) async {
    if ((it.cutoutPath != null && !force) || _processing.contains(it.id)) return;
    setState(() => _processing.add(it.id));
    try {
      final updated = await ref.read(cutoutServiceProvider).ensureCutout(it, force: force);
      if (!mounted) return;
      final layer = _layers[it.categoryEnum];
      if (updated != null && layer != null && layer.item.id == it.id) setState(() => layer.item = updated);
      if (updated?.cutoutPath == null) {
        showSnack(context, 'Couldn\'t separate "${it.name}" from its background. Try a photo on a plain background.');
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Background removal failed: $e');
    } finally {
      if (mounted) setState(() => _processing.remove(it.id));
    }
  }

  Future<void> _share() async {
    try {
      final boundary = _canvasKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'tryon_${DateTime.now().millisecondsSinceEpoch}.png'));
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'My look — styled with Outfitly',
        ),
      );
    } catch (e) {
      if (mounted) showSnack(context, 'Couldn\'t share: $e');
    }
  }

  Future<void> _saveOutfit() async {
    if (_layers.isEmpty) return;
    final ordered = _layers.values.toList()..sort((a, b) => a.z.compareTo(b.z));
    final draft = await showOutfitDetailsSheet(context, OutfitDraft(name: '', itemIds: ordered.map((l) => l.item.id).toList()));
    if (draft == null || !mounted) return;
    final id = await ref.read(outfitRepoProvider).save(draft);
    if (mounted) showSnack(context, 'Outfit saved', actionLabel: 'View', onAction: () => context.push('/outfit/$id'));
  }

  void _openAvatarSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) {
          final sp = ref.read(sharedPrefsProvider);
          final t = Theme.of(c);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avatar', style: t.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Body shape', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<BodyShape>(
                    segments: [for (final s in BodyShape.values) ButtonSegment(value: s, label: Text(s.label))],
                    selected: {_shape},
                    onSelectionChanged: (s) async {
                      await sp.setString('tryOnShape', s.first.name);
                      setS(() {});
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Skin tone', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      for (final (i, tone) in kSkinTones.indexed)
                        Semantics(
                          button: true,
                          label: 'Skin tone ${i + 1}',
                          selected: _skin == tone,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              await sp.setInt('tryOnSkin', i);
                              setS(() {});
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tone,
                                shape: BoxShape.circle,
                                border: Border.all(color: _skin == tone ? t.colorScheme.primary : t.colorScheme.outlineVariant, width: _skin == tone ? 3 : 1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = Theme.of(context);
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final canvas = _canvas(t);
    final controls = _controls(t);
    return landscape
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: canvas),
              const VerticalDivider(width: 1),
              SizedBox(width: MediaQuery.sizeOf(context).width * 0.45, child: controls),
            ],
          )
        : Column(
            children: [
              Expanded(child: canvas),
              const Divider(height: 1),
              controls,
            ],
          );
  }

  Widget _canvas(ThemeData t) => LayoutBuilder(
    builder: (context, c) {
      // Fit a 1:2 avatar box inside the available space.
      final h = (c.maxHeight - 16).clamp(120.0, double.infinity);
      final w = (h / 2).clamp(60.0, c.maxWidth - 16);
      final box = Size(w, w * 2);
      final layers = _layers.values.toList()..sort((a, b) => a.z.compareTo(b.z));
      return Stack(
        children: [
          Center(
            child: RepaintBoundary(
              key: _canvasKey,
              child: Container(
                width: box.width,
                height: box.height,
                decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = null),
                        child: CustomPaint(
                          painter: AvatarPainter(skin: _skin, shape: _shape, outline: t.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    for (final l in layers) _layerWidget(l, box, t),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Column(
              children: [
                IconButton.filledTonal(tooltip: 'Avatar settings', onPressed: _openAvatarSettings, icon: const Icon(Icons.accessibility_new)),
                IconButton.filledTonal(tooltip: 'Share look', onPressed: _layers.isEmpty ? null : _share, icon: const Icon(Icons.ios_share)),
                IconButton.filledTonal(
                  tooltip: 'Save as outfit',
                  onPressed: _layers.isEmpty ? null : _saveOutfit,
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
              ],
            ),
          ),
          if (_layers.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Text(
                'Pick clothes below to dress the avatar. Drag to move, pinch to resize and rotate.',
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      );
    },
  );

  Widget _layerWidget(TryOnLayer l, Size box, ThemeData t) {
    final store = ref.read(imageStoreProvider);
    final cat = l.item.categoryEnum;
    final selected = _selected == cat;
    final pxW = l.width * box.width;
    final img = l.item.cutoutPath != null
        ? Image.file(File(store.resolve(l.item.cutoutPath!)), width: pxW, fit: BoxFit.contain, gaplessPlayback: true)
        : Opacity(
            opacity: 0.92,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(store.resolve(l.item.thumbPath)),
                width: pxW,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => SizedBox(width: pxW, height: pxW),
              ),
            ),
          );
    return Positioned(
      left: l.center.dx * box.width - pxW / 2,
      top: l.center.dy * box.height - pxW / 2,
      width: pxW,
      height: pxW,
      child: GestureDetector(
        onTap: () => setState(() => _selected = cat),
        onScaleStart: (_) {
          _selected = cat;
          _startWidth = l.width;
          _startRotation = l.rotation;
        },
        onScaleUpdate: (d) => setState(() {
          l.center = Offset(
            (l.center.dx + d.focalPointDelta.dx / box.width).clamp(0.0, 1.0),
            (l.center.dy + d.focalPointDelta.dy / box.height).clamp(0.0, 1.0),
          );
          if (d.pointerCount > 1) {
            l.width = (_startWidth * d.scale).clamp(0.08, 1.2);
            l.rotation = _startRotation + d.rotation;
          }
        }),
        child: Transform.rotate(
          angle: l.rotation,
          child: Container(
            decoration: selected
                ? BoxDecoration(
                    border: Border.all(color: t.colorScheme.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                img,
                if (_processing.contains(l.item.id)) const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls(ThemeData t) {
    final items = ref.watch(itemsProvider(ItemFilter(category: _category)));
    final sel = _selected == null ? null : _layers[_selected];
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(sel.item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.labelLarge),
                  ),
                  IconButton(
                    tooltip: 'Remove background again',
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    onPressed: _processing.contains(sel.item.id) ? null : () => _ensureCutout(sel.item, force: true),
                  ),
                  IconButton(tooltip: 'Reset position', icon: const Icon(Icons.center_focus_strong_outlined), onPressed: () => setState(sel.reset)),
                  IconButton(
                    tooltip: 'Take off',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() {
                      _layers.remove(_selected);
                      _selected = null;
                    }),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final c in ClothingCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(c.label), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 112,
            child: items.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'No ${_category.label.toLowerCase()} yet — add some in the Wardrobe tab.',
                          textAlign: TextAlign.center,
                          style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => SizedBox(
                        width: 84,
                        child: ItemCard(item: list[i], heroPrefix: 'tryon', selected: _layers[_category]?.item.id == list[i].id, onTap: () => _wear(list[i])),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen route used from item detail ("Try it on").
class TryOnScreen extends StatelessWidget {
  const TryOnScreen({super.key, this.initialItemIds = const []});
  final List<String> initialItemIds;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Try on')),
    body: TryOnView(initialItemIds: initialItemIds),
  );
}
