import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../community/community_screens.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(wardrobeRepoProvider).markViewed(widget.id);
  }

  Future<void> _delete(ClothingItem it) async {
    final ok = await confirm(context, title: 'Delete "${it.name}"?', message: 'It will be removed from your wardrobe and from any outfits.');
    if (!ok || !mounted) return;
    final repo = ref.read(wardrobeRepoProvider);
    await repo.softDelete(it.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${it.name}"'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'Undo', onPressed: () => repo.restore(it.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(itemProvider(widget.id));
    final t = Theme.of(context);
    return item.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorView(e)),
      data: (it) {
        if (it == null || it.deletedAt != null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.search_off, title: 'Item not found', message: 'It may have been deleted.'),
          );
        }
        final seasons = seasonsOf(it.seasons);
        final occasions = occasionsOf(it.occasions);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                // Square-ish photo in portrait; capped to ~55% of the height in landscape.
                expandedHeight: (MediaQuery.sizeOf(context).width * 1.05).clamp(0.0, MediaQuery.sizeOf(context).height * 0.55),
                pinned: true,
                actions: [
                  IconButton(
                    tooltip: it.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                    icon: Icon(it.isFavorite ? Icons.favorite : Icons.favorite_border, color: it.isFavorite ? Colors.redAccent : null),
                    onPressed: () => ref.read(wardrobeRepoProvider).toggleFavorite(it),
                  ),
                  IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/wardrobe/item/${it.id}/edit')),
                  IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: () => _delete(it)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(tag: 'item-${it.id}', child: ItemImage(it, full: true)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.name, style: t.textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ColorDot(it.colorHex),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [it.colorName, it.subcategory ?? it.categoryEnum.label, ?it.brand].join(' · '),
                              style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _Stat(label: 'Times worn', value: '${it.wearCount}'),
                          _Stat(label: 'Last worn', value: it.lastWorn == null ? 'Never' : DateFormat.MMMd().format(it.lastWorn!)),
                          _Stat(label: 'Added', value: DateFormat.MMMd().format(it.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (it.styleEnum != null) _row(t, 'Style', it.styleEnum!.label),
                      _row(t, 'Seasons', seasons.isEmpty ? 'All seasons' : seasons.map((s) => s.label).join(', ')),
                      _row(t, 'Occasions', occasions.isEmpty ? 'Any occasion' : occasions.map((o) => o.label).join(', ')),
                      if (it.purchaseDate != null) _row(t, 'Purchased', DateFormat.yMMMd().format(it.purchaseDate!)),
                      if (it.notes != null) _row(t, 'Notes', it.notes!),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/create', extra: [it.id]),
                        icon: const Icon(Icons.style_outlined),
                        label: const Text('Create an outfit with this'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/try-on', extra: [it.id]),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
                        icon: const Icon(Icons.accessibility_new),
                        label: const Text('Try it on the avatar'),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => showShareToCommunity(context, ref, item: it),
                        icon: const Icon(Icons.public),
                        label: const Text('Share to community'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(ThemeData t, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
        ),
        Expanded(child: Text(value, style: t.textTheme.bodyLarge)),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: t.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(label, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
