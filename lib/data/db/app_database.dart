import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get colorHex => text()();
  TextColumn get colorName => text()();
  TextColumn get brand => text().nullable()();
  IntColumn get seasons => integer().withDefault(const Constant(0))();
  IntColumn get occasions => integer().withDefault(const Constant(0))();
  TextColumn get style => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  /// Paths are relative to the app documents directory so backups are portable.
  TextColumn get imagePath => text()();
  TextColumn get thumbPath => text()();
  TextColumn get phash => text().nullable()();

  /// Background-removed PNG used by the try-on avatar (schema v2). Relative path.
  TextColumn get cutoutPath => text().nullable()();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWorn => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Outfits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get description => text().nullable()();
  IntColumn get occasions => integer().withDefault(const Constant(0))();
  IntColumn get seasons => integer().withDefault(const Constant(0))();
  TextColumn get style => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class OutfitItems extends Table {
  TextColumn get outfitId => text().references(Outfits, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId => text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {outfitId, itemId};
}

class CalendarEntries extends Table {
  TextColumn get id => text()();

  /// Local date at midnight.
  DateTimeColumn get date => dateTime()();
  TextColumn get outfitId => text().references(Outfits, #id, onDelete: KeyAction.cascade)();
  BoolColumn get worn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {date, outfitId},
  ];
}

class WearLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemId => text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get outfitId => text().nullable()();
  TextColumn get calendarEntryId => text().nullable()();
  DateTimeColumn get date => dateTime()();
}

class RecentViews extends Table {
  TextColumn get itemId => text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get viewedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {itemId};
}

@DriftDatabase(tables: [ClothingItems, Outfits, OutfitItems, CalendarEntries, WearLogs, RecentViews])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  static QueryExecutor _open() => driftDatabase(name: 'outfitly');

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX IF NOT EXISTS idx_items_category ON clothing_items (category)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_items_created ON clothing_items (created_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_calendar_date ON calendar_entries (date)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_wear_item_date ON wear_logs (item_id, date)');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.addColumn(clothingItems, clothingItems.cutoutPath);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
