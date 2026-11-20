import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../community/community_screens.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  const OutfitDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  final _shareKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share(OutfitWithItems o) async {
    setState(() => _sharing = true);
    try {
      final boundary = _shareKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'outfit_${o.outfit.id.substring(0, 8)}.png'));
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: '${o.outfit.name} — planned with Outfitly',
        ),
      );
    } catch (e) {
      if (mounted) showSnack(context, 'Couldn\'t share: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _schedule(OutfitWithItems o) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
      helpText: 'Plan this outfit for',
    );
    if (d == null) return;
    await ref.read(calendarRepoProvider).assign(d, o.outfit.id);
    if (mounted) showSnack(context, 'Added to your calendar');
  }

  Future<void> _wearToday(OutfitWithItems o) async {
    await ref.read(calendarRepoProvider).wearOn(DateTime.now(), o.outfit.id);
    if (mounted) showSnack(context, 'Marked as worn today');
  }

  Future<void> _delete(OutfitWithItems o) async {
    final ok = await confirm(
      context,
      title: 'Delete "${o.outfit.name}"?',
      message: 'Your clothes stay in your wardrobe. Calendar plans for this outfit will be hidden.',
    );
    if (!ok || !mounted) return;
    final repo = ref.read(outfitRepoProvider);
    await repo.softDelete(o.outfit.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${o.outfit.name}"'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'Undo', onPressed: () => repo.restore(o.outfit.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = ref.watch(outfitProvider(widget.id));
    final t = Theme.of(context);
    return o.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorView(e)),
      data: (v) {
        if (v == null || v.outfit.deletedAt != null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.search_off, title: 'Outfit not found', message: 'It may have been deleted.'),
          );
        }
        final occasions = occasionsOf(v.outfit.occasions);
        final seasons = seasonsOf(v.outfit.seasons);
        return Scaffold(
          appBar: AppBar(
            title: Text(v.outfit.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: v.outfit.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                icon: Icon(v.outfit.isFavorite ? Icons.favorite : Icons.favorite_border, color: v.outfit.isFavorite ? Colors.redAccent : null),
                onPressed: () => ref.read(outfitRepoProvider).toggleFavorite(v.outfit),
              ),
              PopupMenuButton<String>(
                onSelected: (a) async {
                  switch (a) {
                    case 'edit':
                      context.push('/outfit/${v.outfit.id}/edit');
                    case 'dup':
                      final id = await ref.read(outfitRepoProvider).duplicate(v.outfit.id);
                      if (context.mounted) context.pushReplacement('/outfit/$id');
                    case 'community':
                      if (context.mounted) await showShareToCommunity(context, ref, outfit: v);
                    case 'delete':
                      _delete(v);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                  PopupMenuItem(value: 'community', child: Text('Share to community')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              RepaintBoundary(
                key: _shareKey,
                child: Container(
                  color: t.scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: OutfitCollage(v.items)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text(v.outfit.name, style: t.textTheme.titleMedium)),
                          Text(
                            'Outfitly',
                            style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary, fontFamily: 'serif'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (v.outfit.description != null) ...[const SizedBox(height: 12), Text(v.outfit.description!, style: t.textTheme.bodyLarge)],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final x in occasions) Chip(label: Text(x.label)),
                  for (final x in seasons) Chip(label: Text(x.label)),
                  if (ClothingStyle.tryParse(v.outfit.style) != null) Chip(label: Text(ClothingStyle.tryParse(v.outfit.style)!.label)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(onPressed: () => _wearToday(v), icon: const Icon(Icons.check_circle_outline), label: const Text('Wear today')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _schedule(v),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
                      icon: const Icon(Icons.event),
                      label: const Text('Plan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.outlined(
                    tooltip: 'Share as image',
                    onPressed: _sharing ? null : () => _share(v),
                    icon: _sharing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.ios_share),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Pieces', style: t.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final ClothingItem i in v.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(width: 52, height: 52, child: ItemImage(i, borderRadius: BorderRadius.circular(10))),
                  title: Text(i.name),
                  subtitle: Text('${i.colorName} · ${i.categoryEnum.label}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/wardrobe/item/${i.id}'),
                ),
              if (v.items.isEmpty) const Text('All pieces in this outfit were deleted.'),
            ],
          ),
        );
      },
    );
  }
}
