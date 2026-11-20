import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:outfitly/data/db/app_database.dart';
import 'package:outfitly/data/repositories/repositories.dart';
import 'package:outfitly/data/storage/cutout_service.dart';
import 'package:outfitly/data/storage/image_store.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('CutoutService', () {
    late AppDatabase db;
    late Directory dir;
    late ImageStore store;
    late WardrobeRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dir = Directory.systemTemp.createTempSync('outfitly_cutout');
      store = ImageStore(dir.path);
      repo = WardrobeRepository(db, store);
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    Future<ClothingItem> addPhoto(String name, img.Image photo) async {
      final rel = p.join('images', '$name.jpg');
      File(store.resolve(rel))
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(img.encodeJpg(photo, quality: 95));
      final id = await repo.addItem(
        ItemDraft(name: name, category: ClothingCategory.tops, colorHex: '#192350', colorName: 'Navy'),
        StoredImage(imagePath: rel, thumbPath: rel, colorHex: '#192350', colorName: 'Navy', phash: '0'),
      );
      return (await repo.getItem(id))!;
    }

    test('flood-fill engine produces a transparent, trimmed PNG and stores it', () async {
      final photo = img.Image(width: 200, height: 200)..clear(img.ColorRgb8(250, 250, 250));
      img.fillRect(photo, x1: 50, y1: 30, x2: 150, y2: 170, color: img.ColorRgb8(25, 35, 80));
      final item = await addPhoto('shirt', photo);

      final svc = CutoutService(db, store, engines: [const FloodFillBackgroundRemoval()]);
      final updated = await svc.ensureCutout(item);
      expect(updated!.cutoutPath, isNotNull);

      final png = img.decodePng(File(store.resolve(updated.cutoutPath!)).readAsBytesSync())!;
      expect(png.width, inInclusiveRange(95, 106), reason: 'transparent margins trimmed to the garment');
      expect(png.height, inInclusiveRange(135, 146));
      expect(png.getPixel(png.width ~/ 2, png.height ~/ 2).a, 255);

      // Cached on the second call; regenerated (new file, old removed) when forced.
      expect((await svc.ensureCutout(updated))!.cutoutPath, updated.cutoutPath);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final again = await svc.ensureCutout(updated, force: true);
      expect(again!.cutoutPath, isNot(updated.cutoutPath));
      expect(File(store.resolve(updated.cutoutPath!)).existsSync(), isFalse);
    });

    test('busy photo: no cut-out, item unchanged, no crash', () async {
      final photo = img.Image(width: 120, height: 120);
      for (final px in photo) {
        px
          ..r = (px.x * 37) % 256
          ..g = (px.y * 53) % 256
          ..b = ((px.x + px.y) * 29) % 256;
      }
      final item = await addPhoto('busy', photo);
      final svc = CutoutService(db, store, engines: [const FloodFillBackgroundRemoval()]);
      final r = await svc.ensureCutout(item);
      expect(r!.cutoutPath, isNull);
    });

    test('changing an item photo clears its cut-out', () async {
      final photo = img.Image(width: 100, height: 100)..clear(img.ColorRgb8(250, 250, 250));
      img.fillRect(photo, x1: 20, y1: 20, x2: 80, y2: 80, color: img.ColorRgb8(200, 30, 40));
      final item = await addPhoto('tee', photo);
      final withCutout = await CutoutService(db, store, engines: [const FloodFillBackgroundRemoval()]).ensureCutout(item);
      final cutoutFile = File(store.resolve(withCutout!.cutoutPath!));
      expect(cutoutFile.existsSync(), isTrue);

      await repo.updateItem(
        item.id,
        ItemDraft(name: 'tee', category: ClothingCategory.tops, colorHex: '#C82328', colorName: 'Red'),
        newImage: const StoredImage(imagePath: 'images/new.jpg', thumbPath: 'thumbs/new.jpg', colorHex: '#C82328', colorName: 'Red', phash: '1'),
      );
      expect((await repo.getItem(item.id))!.cutoutPath, isNull);
      expect(cutoutFile.existsSync(), isFalse);
    });
  });

  test('schema v1 → v2 migration adds cutout_path and keeps existing rows', () async {
    final dir = Directory.systemTemp.createTempSync('outfitly_migrate');
    final file = File(p.join(dir.path, 'db.sqlite'));
    try {
      // Build a v1 database: current schema minus the v2 column, user_version = 1, one existing row.
      var db = AppDatabase(NativeDatabase(file));
      await db.customSelect('select 1').get(); // create schema
      await db.close();
      final raw = sqlite.sqlite3.open(file.path)
        ..execute('ALTER TABLE clothing_items DROP COLUMN cutout_path')
        ..execute(
          "INSERT INTO clothing_items (id, name, category, color_hex, color_name, image_path, thumb_path, created_at, updated_at) "
          "VALUES ('old', 'Old shirt', 'tops', '#000000', 'Black', 'i.jpg', 't.jpg', 0, 0)",
        )
        ..execute('PRAGMA user_version = 1');
      raw.dispose();

      db = AppDatabase(NativeDatabase(file));
      final row = await (db.select(db.clothingItems)..where((t) => t.id.equals('old'))).getSingle();
      expect(row.name, 'Old shirt');
      expect(row.cutoutPath, isNull);
      final cols = await db.customSelect("SELECT name FROM pragma_table_info('clothing_items')").get();
      expect(cols.map((c) => c.read<String>('name')), contains('cutout_path'));
      await db.close();
    } finally {
      dir.deleteSync(recursive: true);
    }
  });
}
