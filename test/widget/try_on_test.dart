import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:outfitly/core/prefs/app_prefs.dart';
import 'package:outfitly/core/providers.dart';
import 'package:outfitly/data/db/app_database.dart';
import 'package:outfitly/data/repositories/repositories.dart';
import 'package:outfitly/data/storage/cutout_service.dart';
import 'package:outfitly/data/storage/image_store.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';
import 'package:outfitly/features/try_on/try_on_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always "succeeds" with a small transparent PNG, so the UI path can be tested without ML Kit.
class _FakeEngine implements BackgroundRemovalEngine {
  int calls = 0;
  @override
  Future<Uint8List?> removeBackground(String imagePath) async {
    calls++;
    final im = img.Image(width: 10, height: 10, numChannels: 4)..clear(img.ColorRgba8(25, 35, 80, 255));
    return img.encodePng(im);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('dressing the avatar: pick top, dress replaces top+bottom, remove, avatar settings', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final dir = Directory.systemTemp.createTempSync('outfitly_tryon');
    final store = ImageStore(dir.path);
    final engine = _FakeEngine();
    final repo = WardrobeRepository(db, store);
    await tester.runAsync(() async {
      Directory('${dir.path}/images').createSync();
      for (final (n, c) in [('Navy shirt', ClothingCategory.tops), ('Chinos', ClothingCategory.bottoms), ('Green dress', ClothingCategory.dresses)]) {
        File('${dir.path}/images/$n.jpg').writeAsBytesSync([1, 2, 3]);
        await repo.addItem(
          ItemDraft(name: n, category: c, colorHex: '#192350', colorName: 'Navy'),
          StoredImage(imagePath: 'images/$n.jpg', thumbPath: 'images/$n.jpg', colorHex: '#192350', colorName: 'Navy', phash: '0'),
        );
      }
    });
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          appDirProvider.overrideWithValue(dir.path),
          cutoutServiceProvider.overrideWithValue(CutoutService(db, store, engines: [engine])),
        ],
        child: const MaterialApp(home: Scaffold(body: TryOnView())),
      ),
    );
    await settle(tester);
    expect(find.textContaining('Pick clothes below'), findsOneWidget);

    // Wear the top → background removal runs once and the layer gets a cut-out.
    await tester.tap(find.text('Navy shirt'));
    await settle(tester);
    expect(engine.calls, 1);
    // The cut-out is written with real file + DB I/O. Poll the file system (no drift lock involved)
    // and pump between polls so the app's fake-async continuations, including the DB update, can run.
    final cutouts = Directory('${dir.path}/cutouts');
    for (var i = 0; i < 50 && !(cutouts.existsSync() && cutouts.listSync().isNotEmpty); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester);
    final shirt = await tester.runAsync(() => (db.select(db.clothingItems)..where((t) => t.name.equals('Navy shirt'))).getSingle());
    expect(shirt!.cutoutPath, isNotNull);
    expect(find.byTooltip('Take off'), findsOneWidget);

    // Add bottoms, then a dress: the dress replaces both.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Bottoms'));
    await settle(tester);
    await tester.tap(find.text('Chinos'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dresses'));
    await settle(tester);
    await tester.tap(find.text('Green dress'));
    await settle(tester);
    // Only one layer (the dress) remains selected/removable.
    expect(find.byTooltip('Take off'), findsOneWidget);

    // Take off the dress → empty again.
    await tester.tap(find.byTooltip('Take off'));
    await settle(tester);
    expect(find.textContaining('Pick clothes below'), findsOneWidget);

    // Avatar settings persist.
    await tester.tap(find.byTooltip('Avatar settings'));
    await settle(tester);
    await tester.tap(find.text('Curvy'));
    await tester.tap(find.bySemanticsLabel('Skin tone 4'));
    await settle(tester);
    expect(prefs.getString('tryOnShape'), 'curvy');
    expect(prefs.getInt('tryOnSkin'), 3);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(milliseconds: 500));
}
