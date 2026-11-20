import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ads/ad_service.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../premium/premium_screen.dart';
import '../try_on/try_on_screen.dart';
import 'outfits_list.dart';

enum OutfitSlot {
  outerwear('Outerwear', Icons.dry_cleaning_outlined, ClothingCategory.outerwear),
  top('Top', Icons.checkroom_outlined, ClothingCategory.tops),
  dress('Dress', Icons.woman_outlined, ClothingCategory.dresses),
  bottom('Bottom', Icons.straighten, ClothingCategory.bottoms),
  shoes('Shoes', Icons.ice_skating_outlined, ClothingCategory.shoes),
  accessory('Accessory', Icons.watch_outlined, ClothingCategory.accessories),
  bag('Bag', Icons.shopping_bag_outlined, ClothingCategory.bags);

  const OutfitSlot(this.label, this.icon, this.category);
  final String label;
  final IconData icon;
  final ClothingCategory category;

  static OutfitSlot forCategory(ClothingCategory c) => OutfitSlot.values.firstWhere((s) => s.category == c);
}

/// Create tab: builder + saved outfits.
class CreateTab extends StatelessWidget {
  const CreateTab({super.key, this.initialItemIds = const []});
  final List<String> initialItemIds;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Create'),
            Tab(text: 'Try on'),
            Tab(text: 'My outfits'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          OutfitBuilder(key: ValueKey(initialItemIds.join()), initialItemIds: initialItemIds),
          const TryOnView(),
          const OutfitsList(),
        ],
      ),
    ),
  );
}

/// Full-screen editor for an existing outfit.
class EditOutfitScreen extends ConsumerWidget {
  const EditOutfitScreen({super.key, required this.outfitId});
  final String outfitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(outfitProvider(outfitId));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit outfit')),
      body: AsyncBody(o, data: (OutfitWithItems? v) => v == null ? const ErrorView('Outfit not found') : OutfitBuilder(existing: v)),
    );
  }
}

class OutfitBuilder extends ConsumerStatefulWidget {
  const OutfitBuilder({super.key, this.initialItemIds = const [], this.existing});
  final List<String> initialItemIds;
  final OutfitWithItems? existing;

  @override
  ConsumerState<OutfitBuilder> createState() => _OutfitBuilderState();
}

class _OutfitBuilderState extends ConsumerState<OutfitBuilder> with AutomaticKeepAliveClientMixin {
  final Map<OutfitSlot, ClothingItem> _slots = {};
  bool _saving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      for (final i in widget.existing!.items) {
        _slots[OutfitSlot.forCategory(i.categoryEnum)] = i;
      }
    } else if (widget.initialItemIds.isNotEmpty) {
      _prefill();
    }
  }

  Future<void> _prefill() async {
    final repo = ref.read(wardrobeRepoProvider);
    for (final id in widget.initialItemIds) {
      final it = await repo.getItem(id);
      if (it != null && mounted) setState(() => _slots[OutfitSlot.forCategory(it.categoryEnum)] = it);
    }
  }

  Future<void> _pick(OutfitSlot slot) async {
    final all = await ref.read(wardrobeRepoProvider).watchItems(ItemFilter(category: slot.category)).first;
    if (!mounted) return;
    final picked = await showModalBottomSheet<ClothingItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (c, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('Choose ${slot.label.toLowerCase()}', style: Theme.of(c).textTheme.titleLarge),
            ),
            Expanded(
              child: all.isEmpty
                  ? EmptyState(icon: slot.icon, title: 'No ${slot.category.label.toLowerCase()} yet', message: 'Add some from the Wardrobe tab first.')
                  : GridView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: all.length,
                      itemBuilder: (_, i) =>
                          ItemCard(item: all[i], heroPrefix: 'pick', selected: _slots[slot]?.id == all[i].id, onTap: () => Navigator.pop(c, all[i])),
                    ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _slots[slot] = picked);
  }

  Future<void> _save() async {
    if (_slots.isEmpty) return;
    final existing = widget.existing?.outfit;
    if (existing == null) {
      final ent = ref.read(entitlementsProvider);
      if (await ref.read(outfitRepoProvider).countOutfits() >= ent.maxOutfits) {
        if (mounted) showLimitDialog(context, 'You\'ve reached the free limit of ${ent.maxOutfits} outfits.');
        return;
      }
    }
    if (!mounted) return;
    final draft = await showOutfitDetailsSheet(
      context,
      OutfitDraft(
        name: existing?.name ?? '',
        description: existing?.description,
        occasions: existing?.occasions ?? 0,
        seasons: existing?.seasons ?? 0,
        style: ClothingStyle.tryParse(existing?.style),
        isFavorite: existing?.isFavorite ?? false,
        itemIds: _ordered().map((e) => e.id).toList(),
      ),
    );
    if (draft == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final id = await ref.read(outfitRepoProvider).save(draft, id: existing?.id);
      if (!mounted) return;
      if (existing != null) {
        context.pop();
      } else {
        setState(() {
          _slots.clear();
          _saving = false;
        });
        showSnack(context, 'Outfit saved');
        context.push('/outfit/$id');
        // Natural break: after the save has completed and the user has moved on.
        ref.read(adServiceProvider).maybeShowInterstitial(AdTrigger.outfitSaved);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showSnack(context, 'Couldn\'t save: $e');
      }
    }
  }

  List<ClothingItem> _ordered() => [for (final s in OutfitSlot.values) ?_slots[s]];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = Theme.of(context);
    final hasDressAndSeparates = _slots.containsKey(OutfitSlot.dress) && (_slots.containsKey(OutfitSlot.top) || _slots.containsKey(OutfitSlot.bottom));
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Text('Tap a slot to pick a piece', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, c) {
                  // 2 columns on phones in portrait, up to 4 in landscape/tablets.
                  final cols = (c.maxWidth / 220).floor().clamp(2, 4);
                  final w = (c.maxWidth - 12 * (cols - 1)) / cols;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [for (final s in OutfitSlot.values) SizedBox(width: w, height: w * 1.1, child: _slotTile(t, s))],
                  );
                },
              ),
              if (hasDressAndSeparates)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('Tip: a dress usually replaces a top and bottom.', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.tertiary)),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                if (_slots.isNotEmpty && widget.existing == null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: OutlinedButton(
                      onPressed: () => setState(_slots.clear),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
                      child: const Text('Clear'),
                    ),
                  ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _slots.isEmpty || _saving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(widget.existing != null ? 'Save changes' : 'Save outfit (${_slots.length})'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _slotTile(ThemeData t, OutfitSlot s) {
    final it = _slots[s];
    return Card(
      child: InkWell(
        onTap: () => _pick(s),
        child: it == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s.icon, size: 32, color: t.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(s.label, style: t.textTheme.labelLarge?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Icon(Icons.add_circle_outline, size: 18, color: t.colorScheme.primary),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ItemImage(it),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 16, 4, 6),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              it.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove ${s.label}',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: () => setState(() => _slots.remove(s)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bottom sheet for naming/tagging an outfit. Returns null if cancelled.
Future<OutfitDraft?> showOutfitDetailsSheet(BuildContext context, OutfitDraft draft) {
  final name = TextEditingController(text: draft.name);
  final desc = TextEditingController(text: draft.description ?? '');
  final formKey = GlobalKey<FormState>();
  return showModalBottomSheet<OutfitDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => StatefulBuilder(
      builder: (c, setS) {
        final t = Theme.of(c);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
          child: SafeArea(
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Text('Outfit details', style: t.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: name,
                    autofocus: draft.name.isEmpty,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Monday office look'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name your outfit' : null,
                  ),
                  TextFormField(
                    controller: desc,
                    maxLines: 2,
                    maxLength: 300,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 8),
                  Text('Occasions', style: t.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  MaskChips<Occasion>(
                    values: Occasion.values,
                    label: (o) => o.label,
                    bit: (o) => o.bit,
                    mask: draft.occasions,
                    onChanged: (m) => setS(() => draft.occasions = m),
                  ),
                  const SizedBox(height: 12),
                  Text('Seasons', style: t.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  MaskChips<Season>(
                    values: Season.values,
                    label: (s) => s.label,
                    bit: (s) => s.bit,
                    mask: draft.seasons,
                    onChanged: (m) => setS(() => draft.seasons = m),
                  ),
                  const SizedBox(height: 12),
                  Text('Style', style: t.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in ClothingStyle.values)
                        ChoiceChip(label: Text(s.label), selected: draft.style == s, onSelected: (v) => setS(() => draft.style = v ? s : null)),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Favourite'),
                    value: draft.isFavorite,
                    onChanged: (v) => setS(() => draft.isFavorite = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      draft
                        ..name = name.text.trim()
                        ..description = desc.text.trim().isEmpty ? null : desc.text.trim();
                      Navigator.pop(c, draft);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
