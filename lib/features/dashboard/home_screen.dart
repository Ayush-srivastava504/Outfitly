import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/prefs/app_prefs.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/services/recommendation_engine.dart';
import '../../shared/widgets.dart';
import '../recommendations/suggestions.dart';
import '../wardrobe/wardrobe_screen.dart';

final todayEntriesProvider = StreamProvider<List<CalendarItem>>((ref) {
  final today = dayOnly(DateTime.now());
  return ref.watch(calendarRepoProvider).watchRange(today, today.add(const Duration(days: 1)));
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final items = ref.watch(allItemsProvider);
    final outfits = ref.watch(outfitsProvider);
    final today = ref.watch(todayEntriesProvider);
    final suggestions = ref.watch(suggestionsProvider);
    final recent = ref.watch(recentlyViewedProvider);
    final prefs = ref.watch(appPrefsProvider);
    final itemList = items.value ?? const <ClothingItem>[];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(suggestionsProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
                      style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(_greeting(), style: t.textTheme.displaySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatTile(value: '${itemList.length}', label: 'Items', icon: Icons.checkroom_outlined, onTap: () => context.go('/wardrobe')),
                    const SizedBox(width: 10),
                    _StatTile(value: '${outfits.value?.length ?? 0}', label: 'Outfits', icon: Icons.style_outlined, onTap: () => context.go('/create')),
                    const SizedBox(width: 10),
                    _StatTile(
                      value: '${itemList.where((i) => i.isFavorite).length}',
                      label: 'Favourites',
                      icon: Icons.favorite_border,
                      onTap: () => context.push('/profile/analytics'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_month_outlined, color: t.colorScheme.primary),
                    title: const Text('Outfit calendar'),
                    subtitle: const Text('Plan looks and log what you wore'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/calendar'),
                  ),
                ),
              ),
              if (itemList.length >= 20 && !prefs.backupNudgeDismissed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Card(
                    color: t.colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: const Text('Back up your wardrobe'),
                      subtitle: const Text('Your data lives only on this phone. Export a backup so you never lose it.'),
                      onTap: () => context.push('/profile/backup'),
                      trailing: IconButton(
                        tooltip: 'Dismiss',
                        icon: const Icon(Icons.close),
                        onPressed: () => ref.read(appPrefsProvider.notifier).update((p) => p.copyWith(backupNudgeDismissed: true)),
                      ),
                    ),
                  ),
                ),
              // Today
              ...today.maybeWhen(
                data: (entries) => entries.isEmpty
                    ? const <Widget>[]
                    : [
                        const SectionHeader('Today\'s outfit'),
                        for (final e in entries)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: ClipRRect(borderRadius: BorderRadius.circular(10), child: OutfitCollage(e.outfit.items)),
                                ),
                                title: Text(e.outfit.outfit.name),
                                subtitle: Text(e.entry.worn ? 'Worn ✓' : 'Planned'),
                                trailing: e.entry.worn
                                    ? null
                                    : TextButton(onPressed: () => ref.read(calendarRepoProvider).setWorn(e.entry, true), child: const Text('Mark worn')),
                                onTap: () => context.push('/outfit/${e.outfit.outfit.id}'),
                              ),
                            ),
                          ),
                      ],
                orElse: () => const <Widget>[],
              ),
              SectionHeader(
                'What to wear',
                trailing: TextButton(onPressed: () => context.push('/home/suggestions'), child: const Text('More ideas')),
              ),
              const SuggestionControls(),
              const SizedBox(height: 12),
              suggestions.when(
                loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingView()),
                error: (e, _) => ErrorView(e, onRetry: () => ref.invalidate(suggestionsProvider)),
                data: (r) => switch (r) {
                  InsufficientWardrobe(:final missing) => InsufficientCard(missing),
                  Suggestions(:final list) when list.isEmpty => const InsufficientCard(['more clothes for this season and occasion']),
                  Suggestions(:final list) => SizedBox(
                    // Room for photos + text; grows with the user's font size.
                    height: 230 + 110 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
                    child: PageView.builder(
                      controller: PageController(viewportFraction: MediaQuery.sizeOf(context).width > 600 ? 0.48 : 0.88),
                      padEnds: false,
                      itemCount: list.take(3).length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 20 : 6, right: 6),
                        child: SuggestionCard(list[i], compact: true),
                      ),
                    ),
                  ),
                },
              ),
              if (itemList.isNotEmpty) ...[
                SectionHeader(
                  'Recently added',
                  trailing: TextButton(onPressed: () => context.go('/wardrobe'), child: const Text('See all')),
                ),
                _ItemStrip(itemList.take(10).toList()),
              ],
              ...recent.maybeWhen(
                data: (list) => list.isEmpty ? const <Widget>[] : [const SectionHeader('Recently viewed'), _ItemStrip(list)],
                orElse: () => const <Widget>[],
              ),
              if (itemList.isEmpty && !items.isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FilledButton.icon(
                    onPressed: () => startAddItems(context, ref),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add your first item'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.icon, this.onTap});
  final String value, label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: t.colorScheme.primary),
                const SizedBox(height: 10),
                Text(value, style: t.textTheme.headlineSmall),
                Text(label, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemStrip extends StatelessWidget {
  const _ItemStrip(this.items);
  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 170,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, i) => SizedBox(
        width: 120,
        child: ItemCard(item: items[i], heroPrefix: 'strip', onTap: () => context.push('/wardrobe/item/${items[i].id}')),
      ),
    ),
  );
}
