import '../../data/db/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/services/recommendation_engine.dart';
import '../../domain/wardrobe_enums.dart';

class ComboStat {
  const ComboStat(this.items, this.count, this.outfitName);
  final List<ClothingItem> items;
  final int count;
  final String? outfitName;
}

/// All analytics are derived from real local data — nothing is estimated or invented.
class WardrobeStats {
  const WardrobeStats({
    required this.totalItems,
    required this.totalOutfits,
    required this.totalWears,
    required this.byCategory,
    required this.byColor,
    required this.mostWorn,
    required this.leastWorn,
    required this.unused,
    required this.favoriteColors,
    required this.topCombos,
    required this.recentlyAdded,
    required this.wearsLast30Days,
  });

  final int totalItems, totalOutfits, totalWears, wearsLast30Days;
  final Map<ClothingCategory, int> byCategory;
  final List<(String name, String hex, int count)> byColor;
  final List<ClothingItem> mostWorn, leastWorn, unused, recentlyAdded;
  final List<String> favoriteColors;
  final List<ComboStat> topCombos;

  static WardrobeStats compute({required List<ClothingItem> items, required List<OutfitWithItems> outfits, required List<WearLog> wearLogs, DateTime? now}) {
    final today = now ?? DateTime.now();
    final byCategory = <ClothingCategory, int>{};
    final colorCount = <String, (String, int)>{};
    for (final i in items) {
      byCategory.update(i.categoryEnum, (v) => v + 1, ifAbsent: () => 1);
      final prev = colorCount[i.colorName];
      colorCount[i.colorName] = (i.colorHex, (prev?.$2 ?? 0) + 1);
    }
    final byColor = colorCount.entries.map((e) => (e.key, e.value.$1, e.value.$2)).toList()..sort((a, b) => b.$3.compareTo(a.$3));

    final worn = items.where((i) => i.wearCount > 0).toList()..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    final least = [...worn]..sort((a, b) => a.wearCount.compareTo(b.wearCount));
    final unused = items.where((i) => i.wearCount == 0).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Favourite colours = colours of favourited items, then most-worn colours.
    final favColor = <String, int>{};
    for (final i in items) {
      favColor.update(i.colorName, (v) => v + (i.isFavorite ? 3 : 0) + i.wearCount, ifAbsent: () => (i.isFavorite ? 3 : 0) + i.wearCount);
    }
    final favoriteColors = (favColor.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).map((e) => e.key).toList();

    // Frequent combinations from wear logs grouped per calendar entry.
    final itemById = {for (final i in items) i.id: i};
    final byEntry = <String, Set<String>>{};
    for (final l in wearLogs) {
      final k = l.calendarEntryId ?? '${l.outfitId}-${l.date.millisecondsSinceEpoch}';
      byEntry.putIfAbsent(k, () => {}).add(l.itemId);
    }
    final comboCounts = <String, int>{};
    for (final ids in byEntry.values) {
      if (ids.length < 2) continue;
      comboCounts.update(comboKey(ids), (v) => v + 1, ifAbsent: () => 1);
    }
    final outfitByKey = {for (final o in outfits) comboKey(o.items.map((e) => e.id)): o.outfit.name};
    final topCombos = (comboCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => ComboStat(e.key.split('|').map((id) => itemById[id]).whereType<ClothingItem>().toList(), e.value, outfitByKey[e.key]))
        .where((c) => c.items.isNotEmpty)
        .toList();

    final cutoff = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 30));
    final entries30 = wearLogs.where((l) => !l.date.isBefore(cutoff)).map((l) => l.calendarEntryId ?? l.date.toIso8601String()).toSet();

    return WardrobeStats(
      totalItems: items.length,
      totalOutfits: outfits.length,
      totalWears: byEntry.length,
      byCategory: byCategory,
      byColor: byColor,
      mostWorn: worn.take(5).toList(),
      leastWorn: least.take(5).toList(),
      unused: unused,
      favoriteColors: favoriteColors,
      topCombos: topCombos,
      recentlyAdded: ([...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(5).toList(),
      wearsLast30Days: entries30.length,
    );
  }
}
