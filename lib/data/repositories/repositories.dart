import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/services/duplicate_detector.dart';
import '../../domain/services/recommendation_engine.dart';
import '../../domain/wardrobe_enums.dart';
import '../db/app_database.dart';
import '../storage/image_store.dart';

const _uuid = Uuid();

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

enum ItemSort { recent, category, favorites, name }

class ItemFilter {
  const ItemFilter({this.query = '', this.category, this.colorName, this.occasion, this.season, this.favoritesOnly = false, this.sort = ItemSort.recent});

  final String query;
  final ClothingCategory? category;
  final String? colorName;
  final Occasion? occasion;
  final Season? season;
  final bool favoritesOnly;
  final ItemSort sort;

  bool get isActive => query.isNotEmpty || category != null || colorName != null || occasion != null || season != null || favoritesOnly;

  ItemFilter copyWith({
    String? query,
    ClothingCategory? Function()? category,
    String? Function()? colorName,
    Occasion? Function()? occasion,
    Season? Function()? season,
    bool? favoritesOnly,
    ItemSort? sort,
  }) => ItemFilter(
    query: query ?? this.query,
    category: category != null ? category() : this.category,
    colorName: colorName != null ? colorName() : this.colorName,
    occasion: occasion != null ? occasion() : this.occasion,
    season: season != null ? season() : this.season,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is ItemFilter &&
      other.query == query &&
      other.category == category &&
      other.colorName == colorName &&
      other.occasion == occasion &&
      other.season == season &&
      other.favoritesOnly == favoritesOnly &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(query, category, colorName, occasion, season, favoritesOnly, sort);
}

extension ClothingItemX on ClothingItem {
  ClothingCategory get categoryEnum => ClothingCategory.parse(category);
  ClothingStyle? get styleEnum => ClothingStyle.tryParse(style);

  RecoItem toReco() => RecoItem(
    id: id,
    name: name,
    category: categoryEnum,
    colorHex: colorHex,
    colorName: colorName,
    seasons: seasons,
    occasions: occasions,
    style: styleEnum,
    isFavorite: isFavorite,
    wearCount: wearCount,
    lastWorn: lastWorn,
  );
}

/// Input for creating or editing an item.
class ItemDraft {
  ItemDraft({
    required this.name,
    required this.category,
    this.subcategory,
    required this.colorHex,
    required this.colorName,
    this.brand,
    this.seasons = 0,
    this.occasions = 0,
    this.style,
    this.isFavorite = false,
    this.purchaseDate,
    this.notes,
  });

  String name;
  ClothingCategory category;
  String? subcategory;
  String colorHex;
  String colorName;
  String? brand;
  int seasons;
  int occasions;
  ClothingStyle? style;
  bool isFavorite;
  DateTime? purchaseDate;
  String? notes;
}

class WardrobeRepository {
  WardrobeRepository(this.db, this.images);
  final AppDatabase db;
  final ImageStore images;

  Stream<List<ClothingItem>> watchItems([ItemFilter f = const ItemFilter()]) {
    final q = db.select(db.clothingItems)..where((t) => t.deletedAt.isNull());
    if (f.query.trim().isNotEmpty) {
      final like = '%${f.query.trim()}%';
      q.where((t) => t.name.like(like) | t.brand.like(like) | t.subcategory.like(like) | t.colorName.like(like));
    }
    if (f.category != null) q.where((t) => t.category.equals(f.category!.name));
    if (f.colorName != null) q.where((t) => t.colorName.equals(f.colorName!));
    if (f.favoritesOnly) q.where((t) => t.isFavorite.equals(true));
    if (f.occasion != null) {
      q.where((t) => t.occasions.equals(0) | t.occasions.bitwiseAnd(Variable(f.occasion!.bit)).isNotValue(0));
    }
    if (f.season != null) {
      q.where((t) => t.seasons.equals(0) | t.seasons.bitwiseAnd(Variable(f.season!.bit)).isNotValue(0));
    }
    q.orderBy([
      switch (f.sort) {
        ItemSort.recent => (t) => OrderingTerm.desc(t.createdAt),
        ItemSort.category => (t) => OrderingTerm.asc(t.category),
        ItemSort.favorites => (t) => OrderingTerm.desc(t.isFavorite),
        ItemSort.name => (t) => OrderingTerm.asc(t.name),
      },
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return q.watch();
  }

  Stream<ClothingItem?> watchItem(String id) => (db.select(db.clothingItems)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<ClothingItem?> getItem(String id) => (db.select(db.clothingItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> countItems() async {
    final c = db.clothingItems.id.count();
    final row =
        await (db.selectOnly(db.clothingItems)
              ..addColumns([c])
              ..where(db.clothingItems.deletedAt.isNull()))
            .getSingle();
    return row.read(c) ?? 0;
  }

  /// Items whose perceptual hash is close to [phash].
  Future<List<ClothingItem>> findSimilar(String phash, {String? excludeId}) async {
    const detector = DuplicateDetector();
    final all = await (db.select(db.clothingItems)..where((t) => t.deletedAt.isNull() & t.phash.isNotNull())).get();
    return all.where((i) => i.id != excludeId && detector.isSimilar(i.phash!, phash)).toList();
  }

  Future<String> addItem(ItemDraft d, StoredImage image) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await db
        .into(db.clothingItems)
        .insert(
          ClothingItemsCompanion.insert(
            id: id,
            name: d.name.trim(),
            category: d.category.name,
            subcategory: Value(_blankToNull(d.subcategory)),
            colorHex: d.colorHex,
            colorName: d.colorName,
            brand: Value(_blankToNull(d.brand)),
            seasons: Value(d.seasons),
            occasions: Value(d.occasions),
            style: Value(d.style?.name),
            isFavorite: Value(d.isFavorite),
            purchaseDate: Value(d.purchaseDate),
            notes: Value(_blankToNull(d.notes)),
            imagePath: image.imagePath,
            thumbPath: image.thumbPath,
            phash: Value(image.phash),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateItem(String id, ItemDraft d, {StoredImage? newImage}) async {
    final old = await getItem(id);
    await (db.update(db.clothingItems)..where((t) => t.id.equals(id))).write(
      ClothingItemsCompanion(
        name: Value(d.name.trim()),
        category: Value(d.category.name),
        subcategory: Value(_blankToNull(d.subcategory)),
        colorHex: Value(d.colorHex),
        colorName: Value(d.colorName),
        brand: Value(_blankToNull(d.brand)),
        seasons: Value(d.seasons),
        occasions: Value(d.occasions),
        style: Value(d.style?.name),
        isFavorite: Value(d.isFavorite),
        purchaseDate: Value(d.purchaseDate),
        notes: Value(_blankToNull(d.notes)),
        updatedAt: Value(DateTime.now()),
        imagePath: newImage == null ? const Value.absent() : Value(newImage.imagePath),
        thumbPath: newImage == null ? const Value.absent() : Value(newImage.thumbPath),
        phash: newImage == null ? const Value.absent() : Value(newImage.phash),
        // A new photo invalidates the try-on cut-out.
        cutoutPath: newImage == null ? const Value.absent() : const Value(null),
      ),
    );
    if (newImage != null && old != null) await images.deleteFiles([old.imagePath, old.thumbPath, ?old.cutoutPath]);
  }

  Future<void> toggleFavorite(ClothingItem i) =>
      (db.update(db.clothingItems)..where((t) => t.id.equals(i.id))).write(ClothingItemsCompanion(isFavorite: Value(!i.isFavorite)));

  Future<void> softDelete(String id) =>
      (db.update(db.clothingItems)..where((t) => t.id.equals(id))).write(ClothingItemsCompanion(deletedAt: Value(DateTime.now())));

  Future<void> restore(String id) => (db.update(db.clothingItems)..where((t) => t.id.equals(id))).write(const ClothingItemsCompanion(deletedAt: Value(null)));

  /// Permanently removes items deleted more than [olderThan] ago, including image files.
  Future<int> purgeDeleted({Duration olderThan = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final doomed = await (db.select(db.clothingItems)..where((t) => t.deletedAt.isSmallerOrEqualValue(cutoff))).get();
    for (final i in doomed) {
      await (db.delete(db.clothingItems)..where((t) => t.id.equals(i.id))).go();
      await images.deleteFiles([i.imagePath, i.thumbPath, ?i.cutoutPath]);
    }
    return doomed.length;
  }

  Future<void> markViewed(String id) => db.into(db.recentViews).insertOnConflictUpdate(RecentViewsCompanion.insert(itemId: id, viewedAt: DateTime.now()));

  Stream<List<ClothingItem>> watchRecentlyViewed({int limit = 10}) {
    final q = db.select(db.recentViews).join([innerJoin(db.clothingItems, db.clothingItems.id.equalsExp(db.recentViews.itemId))])
      ..where(db.clothingItems.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(db.recentViews.viewedAt)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map((r) => r.readTable(db.clothingItems)).toList());
  }

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

class OutfitWithItems {
  const OutfitWithItems(this.outfit, this.items);
  final Outfit outfit;
  final List<ClothingItem> items;
}

class OutfitDraft {
  OutfitDraft({required this.name, this.description, this.occasions = 0, this.seasons = 0, this.style, this.isFavorite = false, required this.itemIds});
  String name;
  String? description;
  int occasions;
  int seasons;
  ClothingStyle? style;
  bool isFavorite;
  List<String> itemIds;
}

class OutfitRepository {
  OutfitRepository(this.db);
  final AppDatabase db;

  Stream<List<OutfitWithItems>> watchOutfits({bool favoritesOnly = false}) {
    final q = db.select(db.outfits)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (favoritesOnly) q.where((t) => t.isFavorite.equals(true));
    final joined = q.join([
      leftOuterJoin(db.outfitItems, db.outfitItems.outfitId.equalsExp(db.outfits.id)),
      leftOuterJoin(db.clothingItems, db.clothingItems.id.equalsExp(db.outfitItems.itemId) & db.clothingItems.deletedAt.isNull()),
    ])..orderBy([OrderingTerm.desc(db.outfits.updatedAt), OrderingTerm.asc(db.outfitItems.position)]);
    return joined.watch().map(_group);
  }

  Stream<OutfitWithItems?> watchOutfit(String id) {
    final joined = (db.select(db.outfits)..where((t) => t.id.equals(id))).join([
      leftOuterJoin(db.outfitItems, db.outfitItems.outfitId.equalsExp(db.outfits.id)),
      leftOuterJoin(db.clothingItems, db.clothingItems.id.equalsExp(db.outfitItems.itemId) & db.clothingItems.deletedAt.isNull()),
    ])..orderBy([OrderingTerm.asc(db.outfitItems.position)]);
    return joined.watch().map((rows) {
      final g = _group(rows);
      return g.isEmpty ? null : g.first;
    });
  }

  Future<OutfitWithItems?> getOutfit(String id) => watchOutfit(id).first;

  List<OutfitWithItems> _group(List<TypedResult> rows) {
    final map = <String, OutfitWithItems>{};
    for (final r in rows) {
      final o = r.readTable(db.outfits);
      final entry = map.putIfAbsent(o.id, () => OutfitWithItems(o, []));
      final item = r.readTableOrNull(db.clothingItems);
      if (item != null) entry.items.add(item);
    }
    return map.values.toList();
  }

  Future<int> countOutfits() async {
    final c = db.outfits.id.count();
    final row =
        await (db.selectOnly(db.outfits)
              ..addColumns([c])
              ..where(db.outfits.deletedAt.isNull()))
            .getSingle();
    return row.read(c) ?? 0;
  }

  Future<String> save(OutfitDraft d, {String? id}) async {
    if (d.itemIds.isEmpty) throw ArgumentError('An outfit needs at least one item');
    final now = DateTime.now();
    final outfitId = id ?? _uuid.v4();
    await db.transaction(() async {
      if (id == null) {
        await db
            .into(db.outfits)
            .insert(
              OutfitsCompanion.insert(
                id: outfitId,
                name: d.name.trim(),
                description: Value(d.description),
                occasions: Value(d.occasions),
                seasons: Value(d.seasons),
                style: Value(d.style?.name),
                isFavorite: Value(d.isFavorite),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (db.update(db.outfits)..where((t) => t.id.equals(id))).write(
          OutfitsCompanion(
            name: Value(d.name.trim()),
            description: Value(d.description),
            occasions: Value(d.occasions),
            seasons: Value(d.seasons),
            style: Value(d.style?.name),
            isFavorite: Value(d.isFavorite),
            updatedAt: Value(now),
          ),
        );
        await (db.delete(db.outfitItems)..where((t) => t.outfitId.equals(id))).go();
      }
      for (var i = 0; i < d.itemIds.length; i++) {
        await db.into(db.outfitItems).insert(OutfitItemsCompanion.insert(outfitId: outfitId, itemId: d.itemIds[i], position: Value(i)));
      }
    });
    return outfitId;
  }

  Future<String> duplicate(String id) async {
    final src = await getOutfit(id);
    if (src == null) throw StateError('Outfit not found');
    return save(
      OutfitDraft(
        name: '${src.outfit.name} (copy)',
        description: src.outfit.description,
        occasions: src.outfit.occasions,
        seasons: src.outfit.seasons,
        style: ClothingStyle.tryParse(src.outfit.style),
        itemIds: src.items.map((e) => e.id).toList(),
      ),
    );
  }

  /// Returns an existing outfit with exactly these items, or creates one.
  Future<String> findOrCreateForItems(List<String> itemIds, String name) async {
    final key = comboKey(itemIds);
    final all = await watchOutfits().first;
    for (final o in all) {
      if (comboKey(o.items.map((e) => e.id)) == key) return o.outfit.id;
    }
    return save(OutfitDraft(name: name, itemIds: itemIds));
  }

  Future<void> toggleFavorite(Outfit o) => (db.update(db.outfits)..where((t) => t.id.equals(o.id))).write(OutfitsCompanion(isFavorite: Value(!o.isFavorite)));

  Future<void> softDelete(String id) => (db.update(db.outfits)..where((t) => t.id.equals(id))).write(OutfitsCompanion(deletedAt: Value(DateTime.now())));

  Future<void> restore(String id) => (db.update(db.outfits)..where((t) => t.id.equals(id))).write(const OutfitsCompanion(deletedAt: Value(null)));

  Future<int> purgeDeleted({Duration olderThan = const Duration(days: 7)}) =>
      (db.delete(db.outfits)..where((t) => t.deletedAt.isSmallerOrEqualValue(DateTime.now().subtract(olderThan)))).go();
}

class CalendarItem {
  const CalendarItem(this.entry, this.outfit);
  final CalendarEntry entry;
  final OutfitWithItems outfit;
}

class CalendarRepository {
  CalendarRepository(this.db, this.outfits);
  final AppDatabase db;
  final OutfitRepository outfits;

  /// Entries in [start, end) grouped with their outfits.
  Stream<List<CalendarItem>> watchRange(DateTime start, DateTime end) {
    final q =
        (db.select(db.calendarEntries)
              ..where((t) => t.date.isBiggerOrEqualValue(dayOnly(start)) & t.date.isSmallerThanValue(dayOnly(end)))
              ..orderBy([(t) => OrderingTerm.asc(t.date)]))
            .watch();
    return q.asyncMap((entries) async {
      final result = <CalendarItem>[];
      for (final e in entries) {
        final o = await outfits.getOutfit(e.outfitId);
        if (o != null && o.outfit.deletedAt == null) result.add(CalendarItem(e, o));
      }
      return result;
    });
  }

  Future<void> assign(DateTime date, String outfitId) => db
      .into(db.calendarEntries)
      .insert(
        CalendarEntriesCompanion.insert(id: _uuid.v4(), date: dayOnly(date), outfitId: outfitId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> remove(CalendarEntry e) async {
    if (e.worn) await setWorn(e, false);
    await (db.delete(db.calendarEntries)..where((t) => t.id.equals(e.id))).go();
  }

  /// Marks an entry worn/unworn, keeping wear logs and per-item counters in sync.
  Future<void> setWorn(CalendarEntry e, bool worn) async {
    if (e.worn == worn) return;
    await db.transaction(() async {
      await (db.update(db.calendarEntries)..where((t) => t.id.equals(e.id))).write(CalendarEntriesCompanion(worn: Value(worn)));
      final o = await outfits.getOutfit(e.outfitId);
      final itemIds = o?.items.map((i) => i.id).toList() ?? const <String>[];
      if (worn) {
        for (final id in itemIds) {
          await db.into(db.wearLogs).insert(WearLogsCompanion.insert(itemId: id, outfitId: Value(e.outfitId), calendarEntryId: Value(e.id), date: e.date));
        }
      } else {
        await (db.delete(db.wearLogs)..where((t) => t.calendarEntryId.equals(e.id))).go();
      }
      for (final id in itemIds) {
        await _recomputeItemWear(id);
      }
    });
  }

  Future<void> _recomputeItemWear(String itemId) async {
    final logs = await (db.select(db.wearLogs)..where((t) => t.itemId.equals(itemId))).get();
    DateTime? last;
    for (final l in logs) {
      if (last == null || l.date.isAfter(last)) last = l.date;
    }
    await (db.update(db.clothingItems)..where((t) => t.id.equals(itemId))).write(ClothingItemsCompanion(wearCount: Value(logs.length), lastWorn: Value(last)));
  }

  /// "Wear today": assigns (if needed) and marks worn.
  Future<void> wearOn(DateTime date, String outfitId) async {
    await assign(date, outfitId);
    final e = await (db.select(db.calendarEntries)..where((t) => t.date.equals(dayOnly(date)) & t.outfitId.equals(outfitId))).getSingle();
    await setWorn(e, true);
  }

  /// comboKey → most recent worn date, for anti-repetition.
  Future<Map<String, DateTime>> recentCombos({int days = 30}) async {
    final since = dayOnly(DateTime.now()).subtract(Duration(days: days));
    final entries = await (db.select(db.calendarEntries)..where((t) => t.worn.equals(true) & t.date.isBiggerOrEqualValue(since))).get();
    final map = <String, DateTime>{};
    for (final e in entries) {
      final o = await outfits.getOutfit(e.outfitId);
      if (o == null) continue;
      final k = comboKey(o.items.map((i) => i.id));
      final prev = map[k];
      if (prev == null || e.date.isAfter(prev)) map[k] = e.date;
    }
    return map;
  }

  Stream<List<WearLog>> watchWearLogs() => db.select(db.wearLogs).watch();
}
