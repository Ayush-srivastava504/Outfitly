import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/prefs/app_prefs.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/services/recommendation_engine.dart';
import '../../domain/wardrobe_enums.dart';
import '../../shared/widgets.dart';
import '../wardrobe/wardrobe_screen.dart';

class OccasionNotifier extends Notifier<Occasion?> {
  @override
  Occasion? build() => null;
  void set(Occasion? o) => state = o;
}

final suggestionOccasionProvider = NotifierProvider<OccasionNotifier, Occasion?>(OccasionNotifier.new);

/// Recomputes whenever the wardrobe, wear history, weather or occasion change.
final suggestionsProvider = FutureProvider<RecoResult>((ref) async {
  final items = await ref.watch(allItemsProvider.future);
  await ref.watch(wearLogsProvider.future);
  final prefs = ref.watch(appPrefsProvider);
  final occasion = ref.watch(suggestionOccasionProvider);
  final combos = await ref.read(calendarRepoProvider).recentCombos();
  final ctx = RecoContext(
    today: DateTime.now(),
    weather: prefs.lastWeather,
    occasion: occasion,
    preferredColors: prefs.preferredColors,
    preferredStyles: prefs.preferredStyles,
    recentCombos: combos,
  );
  return ref.read(recoEngineProvider).suggest(items.map((e) => e.toReco()).toList(), ctx);
});

/// Weather + occasion selectors. Weather is entered manually — the app never claims live data.
class SuggestionControls extends ConsumerWidget {
  const SuggestionControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider);
    final occasion = ref.watch(suggestionOccasionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final w in Weather.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${w.emoji} ${w.label}'),
                    selected: prefs.lastWeather == w,
                    onSelected: (_) => ref.read(appPrefsProvider.notifier).update((p) => p.copyWith(lastWeather: w)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Any occasion'),
                  selected: occasion == null,
                  onSelected: (_) => ref.read(suggestionOccasionProvider.notifier).set(null),
                ),
              ),
              for (final o in Occasion.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o.label),
                    selected: occasion == o,
                    onSelected: (s) => ref.read(suggestionOccasionProvider.notifier).set(s ? o : null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SuggestionCard extends ConsumerWidget {
  const SuggestionCard(this.s, {super.key, this.compact = false});
  final Suggestion s;
  final bool compact;

  Future<String> _ensureOutfit(WidgetRef ref, List<ClothingItem> items) {
    final name = '${items.first.colorName} ${items.first.categoryEnum.label.toLowerCase().replaceAll(RegExp(r's$'), '')} look';
    return ref.read(outfitRepoProvider).findOrCreateForItems(items.map((e) => e.id).toList(), name);
  }

  /// In the compact carousel the card has a fixed height, so the photos flex to fill what's left.
  Widget _photoStrip(bool compact, Widget row) => compact ? Expanded(child: row) : SizedBox(height: 190, child: row);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final all = ref.watch(allItemsProvider).value ?? const <ClothingItem>[];
    final items = [for (final r in s.items) ...all.where((i) => i.id == r.id)];
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _photoStrip(
            compact,
            Row(
              children: [
                for (final i in items)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: GestureDetector(
                        onTap: () => context.push('/wardrobe/item/${i.id}'),
                        child: ItemImage(i, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why this works', style: t.textTheme.labelLarge?.copyWith(color: t.colorScheme.primary)),
                const SizedBox(height: 4),
                for (final r in s.reasons.take(compact ? 2 : 4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text('• $r', maxLines: 2, overflow: TextOverflow.ellipsis, style: t.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final id = await _ensureOutfit(ref, items);
                    if (context.mounted) showSnack(context, 'Saved to My outfits', actionLabel: 'View', onAction: () => context.push('/outfit/$id'));
                  },
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save', maxLines: 1),
                ),
                const Spacer(),
                // Flexible + scale-down keeps both buttons on one line even with very large system fonts.
                Flexible(
                  flex: 4,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      final id = await _ensureOutfit(ref, items);
                      await ref.read(calendarRepoProvider).wearOn(DateTime.now(), id);
                      if (context.mounted) showSnack(context, 'Enjoy! Logged as worn today.');
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Wear today', maxLines: 1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen list of suggestions.
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(suggestionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit ideas')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SuggestionControls(),
          const SizedBox(height: 12),
          result.when(
            loading: () => const Padding(padding: EdgeInsets.all(48), child: LoadingView()),
            error: (e, _) => ErrorView(e),
            data: (r) => switch (r) {
              InsufficientWardrobe(:final missing) => InsufficientCard(missing),
              Suggestions(:final list) => Column(
                children: [
                  for (final s in list) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: SuggestionCard(s)),
                  if (list.isEmpty) const InsufficientCard(['more clothes for this season and occasion']),
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}

class InsufficientCard extends ConsumerWidget {
  const InsufficientCard(this.missing, {super.key});
  final List<String> missing;

  @override
  Widget build(BuildContext context, WidgetRef ref) => EmptyState(
    icon: Icons.auto_awesome_outlined,
    title: 'Almost ready for suggestions',
    message: 'Add ${missing.join(', ')} that suit the selected weather and occasion.',
    action: FilledButton.icon(onPressed: () => startAddItems(context, ref), icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Add clothes')),
  );
}
