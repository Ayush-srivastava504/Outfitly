import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ads/ad_service.dart';
import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../shared/widgets.dart';
import 'wardrobe_stats.dart';

final statsProvider = Provider<AsyncValue<WardrobeStats>>((ref) {
  final items = ref.watch(allItemsProvider);
  final outfits = ref.watch(outfitsProvider);
  final logs = ref.watch(wearLogsProvider);
  if (items.hasError) return AsyncError(items.error!, items.stackTrace!);
  if (!items.hasValue || !outfits.hasValue || !logs.hasValue) return const AsyncLoading();
  return AsyncData(WardrobeStats.compute(items: items.value!, outfits: outfits.value!, wearLogs: logs.value!));
});

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  // Captured in initState: `ref` must not be used inside dispose().
  late final AdService _ads;

  @override
  void initState() {
    super.initState();
    _ads = ref.read(adServiceProvider);
  }

  @override
  void dispose() {
    // Leaving analytics is a natural break.
    _ads.maybeShowInterstitial(AdTrigger.leftAnalytics);
    super.dispose();
  }

  static const _palette = [Color(0xFFC2643C), Color(0xFF3C7DC2), Color(0xFF5BA36B), Color(0xFFD9A441), Color(0xFF8B5FBF), Color(0xFF3CA7A2), Color(0xFFB0456A)];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final stats = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe insights')),
      bottomNavigationBar: ref.watch(adServiceProvider).banner(AdPlacement.analytics),
      body: AsyncBody(
        stats,
        data: (WardrobeStats s) {
          if (s.totalItems == 0) {
            return const EmptyState(icon: Icons.insights_outlined, title: 'No data yet', message: 'Add clothes and log what you wear to see insights here.');
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                children: [
                  _Big(value: '${s.totalItems}', label: 'Items'),
                  _Big(value: '${s.totalOutfits}', label: 'Outfits'),
                  _Big(value: '${s.wearsLast30Days}', label: 'Days logged (30d)'),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'By category',
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              for (final (i, e) in s.byCategory.entries.indexed)
                                PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: _palette[i % _palette.length],
                                  radius: 48,
                                  title: '${e.value}',
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (i, e) in s.byCategory.entries.indexed)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: _palette[i % _palette.length], shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${e.key.label} (${e.value})', style: t.textTheme.bodySmall),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _Section(
                title: 'Colours',
                child: Column(
                  children: [
                    for (final (name, hex, count) in s.byColor.take(8))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            ColorDot(hex),
                            const SizedBox(width: 8),
                            SizedBox(width: 80, child: Text(name, style: t.textTheme.bodySmall)),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: count / s.byColor.first.$3,
                                  minHeight: 10,
                                  color: hexColor(hex),
                                  backgroundColor: t.colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              child: Text('$count', textAlign: TextAlign.end, style: t.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    if (s.favoriteColors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Your go-to colours: ${s.favoriteColors.join(', ')}', style: t.textTheme.bodyMedium),
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                title: 'Most worn',
                child: s.mostWorn.isEmpty
                    ? const _Hint('Mark outfits as worn in the calendar to track this.')
                    : _ItemRows(s.mostWorn, suffix: (i) => '${i.wearCount}×'),
              ),
              if (s.leastWorn.isNotEmpty)
                _Section(
                  title: 'Least worn',
                  child: _ItemRows(s.leastWorn, suffix: (i) => '${i.wearCount}×'),
                ),
              _Section(
                title: 'Never worn (${s.unused.length})',
                child: s.unused.isEmpty
                    ? const _Hint('Great — you\'ve worn everything at least once!')
                    : _ItemRows(s.unused.take(8).toList(), suffix: (_) => ''),
              ),
              if (s.topCombos.isNotEmpty)
                _Section(
                  title: 'Favourite combinations',
                  child: Column(
                    children: [
                      for (final c in s.topCombos)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 52,
                            height: 52,
                            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: OutfitCollage(c.items)),
                          ),
                          title: Text(c.outfitName ?? c.items.map((e) => e.name).join(' + '), maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Text('${c.count}×', style: t.textTheme.titleMedium),
                        ),
                    ],
                  ),
                ),
              _Section(
                title: 'Recently added',
                child: _ItemRows(s.recentlyAdded, suffix: (_) => ''),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Big extends StatelessWidget {
  const _Big({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(value, style: t.textTheme.headlineMedium?.copyWith(color: t.colorScheme.primary)),
              Text(label, textAlign: TextAlign.center, style: t.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
}

class _ItemRows extends StatelessWidget {
  const _ItemRows(this.items, {required this.suffix});
  final List<ClothingItem> items;
  final String Function(ClothingItem) suffix;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final i in items)
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(width: 40, height: 40, child: ItemImage(i, borderRadius: BorderRadius.circular(8))),
          title: Text(i.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(suffix(i), style: Theme.of(context).textTheme.titleSmall),
          onTap: () => context.push('/wardrobe/item/${i.id}'),
        ),
    ],
  );
}
