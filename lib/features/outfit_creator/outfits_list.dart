import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets.dart';

class OutfitsList extends ConsumerStatefulWidget {
  const OutfitsList({super.key});
  @override
  ConsumerState<OutfitsList> createState() => _OutfitsListState();
}

class _OutfitsListState extends ConsumerState<OutfitsList> with AutomaticKeepAliveClientMixin {
  bool _favOnly = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final outfits = ref.watch(outfitsProvider);
    return AsyncBody(
      outfits,
      data: (List<OutfitWithItems> all) {
        final list = _favOnly ? all.where((o) => o.outfit.isFavorite).toList() : all;
        if (all.isEmpty) {
          return const EmptyState(
            icon: Icons.style_outlined,
            title: 'No outfits yet',
            message: 'Combine pieces in the Create tab, or save one of your daily suggestions on Home.',
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${list.length} outfit${list.length == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  FilterChip(label: const Text('Favourites'), selected: _favOnly, onSelected: (v) => setState(() => _favOnly = v)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(icon: Icons.favorite_border, title: 'No favourite outfits', message: 'Tap the heart on an outfit to favourite it.')
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) => OutfitCard(list[i], onTap: () => context.push('/outfit/${list[i].outfit.id}')),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class OutfitCard extends StatelessWidget {
  const OutfitCard(this.o, {super.key, this.onTap});
  final OutfitWithItems o;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: OutfitCollage(o.items)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.outfit.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.textTheme.labelLarge),
                        Text(
                          '${o.items.length} piece${o.items.length == 1 ? '' : 's'}',
                          style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (o.outfit.isFavorite) const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet listing outfits to pick one (e.g. for the calendar).
Future<String?> pickOutfit(BuildContext context, WidgetRef ref) async {
  final all = await ref.read(outfitRepoProvider).watchOutfits().first;
  if (!context.mounted) return null;
  return showModalBottomSheet<String>(
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
            child: Text('Choose an outfit', style: Theme.of(c).textTheme.titleLarge),
          ),
          Expanded(
            child: all.isEmpty
                ? EmptyState(
                    icon: Icons.style_outlined,
                    title: 'No outfits yet',
                    message: 'Create an outfit first, then plan it here.',
                    action: FilledButton(
                      onPressed: () {
                        Navigator.pop(c);
                        context.go('/create');
                      },
                      child: const Text('Create outfit'),
                    ),
                  )
                : GridView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: all.length,
                    itemBuilder: (_, i) => OutfitCard(all[i], onTap: () => Navigator.pop(c, all[i].outfit.id)),
                  ),
          ),
        ],
      ),
    ),
  );
}
