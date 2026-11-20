import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/ads/ad_service.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/services/color_analyzer.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../premium/premium_screen.dart';

class WardrobeFilterNotifier extends Notifier<ItemFilter> {
  @override
  ItemFilter build() => const ItemFilter();
  void set(ItemFilter f) => state = f;
}

final wardrobeFilterProvider = NotifierProvider<WardrobeFilterNotifier, ItemFilter>(WardrobeFilterNotifier.new);

class GridModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final wardrobeGridProvider = NotifierProvider<GridModeNotifier, bool>(GridModeNotifier.new);

/// Opens camera/gallery and routes to the item form. Shared by Home quick actions.
Future<void> startAddItems(BuildContext context, WidgetRef ref) async {
  final ent = ref.read(entitlementsProvider);
  final count = await ref.read(wardrobeRepoProvider).countItems();
  if (!context.mounted) return;
  if (count >= ent.maxItems) {
    showLimitDialog(context, 'You\'ve reached the free limit of ${ent.maxItems} items.');
    return;
  }
  final source = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Take a photo'), onTap: () => Navigator.pop(c, 'camera')),
          ListTile(leading: const Icon(Icons.photo_outlined), title: const Text('Choose from gallery'), onTap: () => Navigator.pop(c, 'gallery')),
          ListTile(
            leading: const Icon(Icons.collections_outlined),
            title: const Text('Add several photos'),
            subtitle: const Text('Up to 10 at once'),
            onTap: () => Navigator.pop(c, 'multi'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return;
  final picker = ImagePicker();
  try {
    final remaining = ent.maxItems - count;
    List<XFile> files;
    if (source == 'camera') {
      final f = await picker.pickImage(source: ImageSource.camera, maxWidth: 2400, maxHeight: 2400);
      files = f == null ? [] : [f];
    } else if (source == 'gallery') {
      final f = await picker.pickImage(source: ImageSource.gallery);
      files = f == null ? [] : [f];
    } else {
      files = await picker.pickMultiImage(limit: remaining.clamp(2, 10));
    }
    if (files.isEmpty || !context.mounted) return;
    if (files.length > remaining) files = files.take(remaining).toList();
    context.push('/wardrobe/add', extra: files.map((f) => f.path).toList());
  } on PlatformException catch (e) {
    if (!context.mounted) return;
    final denied = e.code.contains('denied') || e.code.contains('access');
    showSnack(
      context,
      denied ? 'Permission denied. Allow camera/photos access in system settings to add items.' : 'Couldn\'t open the picker: ${e.message ?? e.code}',
    );
  }
}

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});
  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(wardrobeFilterProvider);
    final items = ref.watch(itemsProvider(filter));
    final grid = ref.watch(wardrobeGridProvider);
    final prefs = ref.watch(appPrefsProvider);
    final cats = [
      ...ClothingCategory.values.where(prefs.preferredCategories.contains),
      ...ClothingCategory.values.where((c) => !prefs.preferredCategories.contains(c)),
    ];
    void setFilter(ItemFilter f) => ref.read(wardrobeFilterProvider.notifier).set(f);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wardrobe'),
        actions: [
          IconButton(
            tooltip: grid ? 'List view' : 'Grid view',
            icon: Icon(grid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => ref.read(wardrobeGridProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Filters and sort',
            icon: Badge(
              isLabelVisible: filter.colorName != null || filter.occasion != null || filter.season != null || filter.favoritesOnly,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => _openFilters(context, filter, setFilter),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-item',
        onPressed: () => startAddItems(context, ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add'),
      ),
      // One scroll view: search + chips scroll away, so landscape keeps room for clothes.
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search name, brand, colour…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: filter.query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  setFilter(filter.copyWith(query: ''));
                                },
                              ),
                      ),
                      onChanged: (q) => setFilter(filter.copyWith(query: q)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: filter.category == null,
                            onSelected: (_) => setFilter(filter.copyWith(category: () => null)),
                          ),
                        ),
                        for (final c in cats)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.label),
                              selected: filter.category == c,
                              onSelected: (s) => setFilter(filter.copyWith(category: () => s ? c : null)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                ...items.when(
                  loading: () => [const SliverFillRemaining(child: LoadingView())],
                  error: (e, _) => [SliverFillRemaining(child: ErrorView(e))],
                  data: (list) {
                    if (list.isEmpty) {
                      return [
                        SliverFillRemaining(
                          child: filter.isActive
                              ? EmptyState(
                                  icon: Icons.search_off,
                                  title: 'No matches',
                                  message: 'Try a different search or clear your filters.',
                                  action: OutlinedButton(
                                    onPressed: () {
                                      _search.clear();
                                      setFilter(const ItemFilter());
                                    },
                                    child: const Text('Clear filters'),
                                  ),
                                )
                              : EmptyState(
                                  icon: Icons.checkroom_outlined,
                                  title: 'Your wardrobe is empty',
                                  message: 'Add your first piece of clothing with the camera or from your gallery.',
                                  action: FilledButton.icon(
                                    onPressed: () => startAddItems(context, ref),
                                    icon: const Icon(Icons.add_a_photo_outlined),
                                    label: const Text('Add clothes'),
                                  ),
                                ),
                        ),
                      ];
                    }
                    return [grid ? _grid(list) : _list(list)];
                  },
                ),
              ],
            ),
          ),
          ref.watch(adServiceProvider).banner(AdPlacement.wardrobe),
        ],
      ),
    );
  }

  Widget _grid(List<ClothingItem> list) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
    sliver: SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 190, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: list.length,
      itemBuilder: (context, i) => ItemCard(item: list[i], onTap: () => context.push('/wardrobe/item/${list[i].id}')),
    ),
  );

  Widget _list(List<ClothingItem> list) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
    sliver: SliverList.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final it = list[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: SizedBox(
              width: 56,
              height: 56,
              child: Hero(
                tag: 'item-${it.id}',
                child: ItemImage(it, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            title: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                ColorDot(it.colorHex, size: 10),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${it.colorName} · ${it.categoryEnum.label}${it.brand != null ? ' · ${it.brand}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: it.isFavorite ? const Icon(Icons.favorite, color: Colors.redAccent, size: 18) : null,
            onTap: () => context.push('/wardrobe/item/${it.id}'),
          ),
        );
      },
    ),
  );

  void _openFilters(BuildContext context, ItemFilter current, void Function(ItemFilter) apply) {
    var f = current;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) {
          final t = Theme.of(c);
          void upd(ItemFilter n) => setS(() => f = n);
          return SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              builder: (c, scroll) => ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Text('Filter & sort', style: t.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Sort by', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final (s, l) in [
                        (ItemSort.recent, 'Recently added'),
                        (ItemSort.category, 'Category'),
                        (ItemSort.favorites, 'Favourites first'),
                        (ItemSort.name, 'Name'),
                      ])
                        ChoiceChip(
                          label: Text(l),
                          selected: f.sort == s,
                          onSelected: (_) => upd(f.copyWith(sort: s)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Favourites only'),
                    value: f.favoritesOnly,
                    onChanged: (v) => upd(f.copyWith(favoritesOnly: v)),
                  ),
                  Text('Season', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in Season.values)
                        ChoiceChip(
                          label: Text(s.label),
                          selected: f.season == s,
                          onSelected: (sel) => upd(f.copyWith(season: () => sel ? s : null)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Occasion', style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final o in Occasion.values)
                        ChoiceChip(
                          label: Text(o.label),
                          selected: f.occasion == o,
                          onSelected: (sel) => upd(f.copyWith(occasion: () => sel ? o : null)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Colour', style: t.textTheme.titleSmall),
                      const Spacer(),
                      if (f.colorName != null)
                        TextButton(
                          onPressed: () => upd(f.copyWith(colorName: () => null)),
                          child: const Text('Any colour'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ColorPickerChips(
                    selected: f.colorName,
                    onSelected: (NamedColor nc) => upd(f.copyWith(colorName: () => f.colorName == nc.name ? null : nc.name)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            apply(ItemFilter(query: current.query));
                            Navigator.pop(c);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            apply(f);
                            Navigator.pop(c);
                          },
                          child: const Text('Apply'),
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
}
