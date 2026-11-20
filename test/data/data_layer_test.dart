import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:outfitly/data/backup/backup_service.dart';
import 'package:outfitly/data/db/app_database.dart';
import 'package:outfitly/data/repositories/repositories.dart';
import 'package:outfitly/data/storage/image_store.dart';
import 'package:outfitly/domain/services/recommendation_engine.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';
import 'package:outfitly/features/analytics/wardrobe_stats.dart';
import 'package:path/path.dart' as p;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory dir;
  late ImageStore images;
  late WardrobeRepository wardrobe;
  late OutfitRepository outfits;
  late CalendarRepository calendar;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory(setup: (raw) => raw.execute('PRAGMA foreign_keys = ON')));
    dir = await Directory.systemTemp.createTemp('outfitly_test');
    images = ImageStore(dir.path);
    wardrobe = WardrobeRepository(db, images);
    outfits = OutfitRepository(db);
    calendar = CalendarRepository(db, outfits);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  /// Writes a fake stored image so file-handling paths are exercised.
  Future<StoredImage> fakeImage(String id, {List<int> rgb = const [25, 35, 80]}) async {
    final im = img.Image(width: 20, height: 20)..clear(img.ColorRgb8(rgb[0], rgb[1], rgb[2]));
    final bytes = img.encodeJpg(im);
    for (final d in ['images', 'thumbs']) {
      await Directory(p.join(dir.path, d)).create(recursive: true);
      await File(p.join(dir.path, d, '$id.jpg')).writeAsBytes(bytes);
    }
    return StoredImage(
      imagePath: p.join('images', '$id.jpg'),
      thumbPath: p.join('thumbs', '$id.jpg'),
      colorHex: '#192350',
      colorName: 'Navy',
      phash: '0f0f0f0f0f0f0f0f',
    );
  }

  Future<String> addItem(String name, ClothingCategory c, {String color = 'Navy', bool fav = false, int seasons = 0}) async {
    final image = await fakeImage(name);
    return wardrobe.addItem(ItemDraft(name: name, category: c, colorHex: '#192350', colorName: color, isFavorite: fav, seasons: seasons), image);
  }

  group('WardrobeRepository', () {
    test('add, read, update, favourite', () async {
      final id = await addItem('Shirt', ClothingCategory.tops);
      var it = await wardrobe.getItem(id);
      expect(it!.name, 'Shirt');
      await wardrobe.updateItem(id, ItemDraft(name: '  Oxford shirt ', category: ClothingCategory.tops, colorHex: '#FFFFFF', colorName: 'White', brand: ''));
      it = await wardrobe.getItem(id);
      expect(it!.name, 'Oxford shirt');
      expect(it.brand, isNull, reason: 'blank strings stored as null');
      await wardrobe.toggleFavorite(it);
      expect((await wardrobe.getItem(id))!.isFavorite, isTrue);
    });

    test('filters: query, category, colour, favourites, season', () async {
      await addItem('Navy shirt', ClothingCategory.tops, fav: true);
      await addItem('Black jeans', ClothingCategory.bottoms, color: 'Black', seasons: Season.winter.bit);
      await addItem('Summer shorts', ClothingCategory.bottoms, color: 'Beige', seasons: Season.summer.bit);

      Future<List<String>> names(ItemFilter f) async => (await wardrobe.watchItems(f).first).map((e) => e.name).toList();
      expect(await names(const ItemFilter(query: 'jeans')), ['Black jeans']);
      expect((await names(const ItemFilter(category: ClothingCategory.bottoms))).length, 2);
      expect(await names(const ItemFilter(colorName: 'Beige')), ['Summer shorts']);
      expect(await names(const ItemFilter(favoritesOnly: true)), ['Navy shirt']);
      expect(await names(const ItemFilter(season: Season.winter)), containsAll(['Navy shirt', 'Black jeans']));
      expect(await names(const ItemFilter(season: Season.winter)), isNot(contains('Summer shorts')));
      expect(await names(const ItemFilter(sort: ItemSort.name)), ['Black jeans', 'Navy shirt', 'Summer shorts']);
    });

    test('soft delete hides, restore brings back, purge removes row and files', () async {
      final id = await addItem('Tee', ClothingCategory.tops);
      await wardrobe.softDelete(id);
      expect(await wardrobe.watchItems().first, isEmpty);
      expect(await wardrobe.countItems(), 0);
      await wardrobe.restore(id);
      expect(await wardrobe.countItems(), 1);

      await wardrobe.softDelete(id);
      expect(await wardrobe.purgeDeleted(olderThan: Duration.zero), 1);
      expect(await wardrobe.getItem(id), isNull);
      expect(File(p.join(dir.path, 'images', 'Tee.jpg')).existsSync(), isFalse);
    });

    test('duplicate detection by perceptual hash', () async {
      final id = await addItem('A', ClothingCategory.tops);
      expect((await wardrobe.findSimilar('0f0f0f0f0f0f0f0e')).map((e) => e.id), [id]);
      expect(await wardrobe.findSimilar('f0f0f0f0f0f0f0f0'), isEmpty);
      expect(await wardrobe.findSimilar('0f0f0f0f0f0f0f0f', excludeId: id), isEmpty);
    });
  });

  group('Outfits & calendar', () {
    test('save, edit, duplicate, delete outfits', () async {
      final top = await addItem('Top', ClothingCategory.tops);
      final bottom = await addItem('Bottom', ClothingCategory.bottoms);
      final id = await outfits.save(OutfitDraft(name: 'Look', itemIds: [top, bottom]));
      var o = await outfits.getOutfit(id);
      expect(o!.items.map((e) => e.name), ['Top', 'Bottom']);

      await outfits.save(
        OutfitDraft(name: 'Look 2', itemIds: [bottom]),
        id: id,
      );
      o = await outfits.getOutfit(id);
      expect(o!.outfit.name, 'Look 2');
      expect(o.items.single.name, 'Bottom');

      final copy = await outfits.duplicate(id);
      expect((await outfits.getOutfit(copy))!.outfit.name, 'Look 2 (copy)');
      expect(await outfits.countOutfits(), 2);

      await outfits.softDelete(copy);
      expect(await outfits.countOutfits(), 1);
      expect(() => outfits.save(OutfitDraft(name: 'Empty', itemIds: [])), throwsArgumentError);
    });

    test('deleted items disappear from outfits', () async {
      final top = await addItem('Top', ClothingCategory.tops);
      final bottom = await addItem('Bottom', ClothingCategory.bottoms);
      final id = await outfits.save(OutfitDraft(name: 'Look', itemIds: [top, bottom]));
      await wardrobe.softDelete(top);
      expect((await outfits.getOutfit(id))!.items.map((e) => e.name), ['Bottom']);
    });

    test('findOrCreateForItems reuses an existing identical outfit', () async {
      final a = await addItem('A', ClothingCategory.tops);
      final b = await addItem('B', ClothingCategory.bottoms);
      final first = await outfits.findOrCreateForItems([a, b], 'x');
      final second = await outfits.findOrCreateForItems([b, a], 'y');
      expect(second, first);
      expect(await outfits.countOutfits(), 1);
    });

    test('marking worn updates wear counts, history and anti-repetition', () async {
      final a = await addItem('A', ClothingCategory.tops);
      final b = await addItem('B', ClothingCategory.bottoms);
      final o = await outfits.save(OutfitDraft(name: 'L', itemIds: [a, b]));
      final day = DateTime.now();
      await calendar.wearOn(day, o);

      final item = await wardrobe.getItem(a);
      expect(item!.wearCount, 1);
      expect(item.lastWorn, dayOnly(day));
      expect((await calendar.recentCombos()).keys.single, comboKey([a, b]));

      // Assigning the same outfit twice on the same day is idempotent.
      await calendar.assign(day, o);
      final entries = await calendar.watchRange(day, day.add(const Duration(days: 1))).first;
      expect(entries, hasLength(1));

      await calendar.setWorn(entries.single.entry, false);
      expect((await wardrobe.getItem(a))!.wearCount, 0);
      expect((await wardrobe.getItem(a))!.lastWorn, isNull);

      final again = await calendar.watchRange(day, day.add(const Duration(days: 1))).first;
      await calendar.remove(again.single.entry);
      expect(await calendar.watchRange(day, day.add(const Duration(days: 1))).first, isEmpty);
    });
  });

  group('Backup', () {
    test('export → wipe → restore round-trips rows and photos', () async {
      final a = await addItem('A', ClothingCategory.tops, fav: true);
      final b = await addItem('B', ClothingCategory.bottoms);
      final o = await outfits.save(OutfitDraft(name: 'Look', itemIds: [a, b]));
      await calendar.wearOn(DateTime(2026, 11, 1), o);

      final svc = BackupService(db, dir.path);
      final zip = await svc.export();
      await svc.wipe();
      expect(await wardrobe.countItems(), 0);
      expect(Directory(p.join(dir.path, 'images')).existsSync(), isFalse);

      final summary = await svc.restore(zip);
      expect(summary.items, 2);
      expect(summary.outfits, 1);
      expect(summary.calendarEntries, 1);
      final restored = await wardrobe.getItem(a);
      expect(restored!.isFavorite, isTrue);
      expect(restored.wearCount, 1);
      expect(File(images.resolve(restored.imagePath)).existsSync(), isTrue);
      expect((await outfits.getOutfit(o))!.items, hasLength(2));
    });

    test('restore removes orphaned photos from the previous wardrobe', () async {
      final svc = BackupService(db, dir.path);
      await addItem('Keep', ClothingCategory.tops);
      final zip = await svc.export();
      await addItem('Later', ClothingCategory.tops);
      await svc.restore(zip);
      expect(File(p.join(dir.path, 'images', 'Later.jpg')).existsSync(), isFalse);
      expect(File(p.join(dir.path, 'images', 'Keep.jpg')).existsSync(), isTrue);
    });

    test('rejects garbage and foreign files without touching data', () async {
      await addItem('Safe', ClothingCategory.tops);
      final svc = BackupService(db, dir.path);
      await expectLater(svc.restore(Uint8List.fromList([1, 2, 3, 4])), throwsA(isA<BackupException>()));
      expect(await wardrobe.countItems(), 1);
    });
  });

  group('WardrobeStats', () {
    test('computes real counts from stored data', () async {
      final a = await addItem('A', ClothingCategory.tops, fav: true);
      final b = await addItem('B', ClothingCategory.bottoms, color: 'Black');
      await addItem('C', ClothingCategory.bottoms, color: 'Black');
      final o = await outfits.save(OutfitDraft(name: 'Look', itemIds: [a, b]));
      await calendar.wearOn(DateTime.now(), o);
      await calendar.wearOn(DateTime.now().subtract(const Duration(days: 2)), o);

      final s = WardrobeStats.compute(
        items: await wardrobe.watchItems().first,
        outfits: await outfits.watchOutfits().first,
        wearLogs: await calendar.watchWearLogs().first,
      );
      expect(s.totalItems, 3);
      expect(s.totalOutfits, 1);
      expect(s.totalWears, 2);
      expect(s.wearsLast30Days, 2);
      expect(s.byCategory[ClothingCategory.bottoms], 2);
      expect(s.byColor.first.$1, 'Black');
      expect(s.mostWorn.first.wearCount, 2);
      expect(s.unused.single.name, 'C');
      expect(s.topCombos.single.count, 2);
      expect(s.topCombos.single.outfitName, 'Look');
      expect(s.favoriteColors.first, 'Navy');
    });
  });
}
