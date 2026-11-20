import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitly/core/prefs/app_prefs.dart';
import 'package:outfitly/core/providers.dart';
import 'package:outfitly/data/db/app_database.dart';
import 'package:outfitly/data/repositories/repositories.dart';
import 'package:outfitly/data/storage/image_store.dart';
import 'package:outfitly/domain/wardrobe_enums.dart';
import 'package:outfitly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory dir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('outfitly_widget');
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = false}) async {
    SharedPreferences.setMockInitialValues({'onboardingDone': onboarded});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs), databaseProvider.overrideWithValue(db), appDirProvider.overrideWithValue(dir.path)],
        child: const OutfitlyApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('first launch shows onboarding; Skip goes to Home and persists', (tester) async {
    await pumpApp(tester);
    expect(find.text('Your wardrobe, in your pocket'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(find.text('What to wear'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingDone'), isTrue);
    await unmount(tester);
  });

  testWidgets('onboarding can be completed with preferences', (tester) async {
    await pumpApp(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester);
    }
    expect(find.text('Make it yours'), findsOneWidget);
    await tester.tap(find.text('Minimal'));
    await tester.pump();
    await tester.tap(find.text('Get started'));
    await settle(tester);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('preferredStyles'), ['minimal']);
    await unmount(tester);
  });

  testWidgets('bottom navigation reaches every tab with proper empty states', (tester) async {
    await pumpApp(tester, onboarded: true);
    expect(find.text('Almost ready for suggestions'), findsOneWidget);

    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.text('Your wardrobe is empty'), findsOneWidget);

    await tester.tap(find.text('Create').last);
    await settle(tester);
    expect(find.text('Tap a slot to pick a piece'), findsOneWidget);
    await tester.tap(find.text('My outfits'));
    await settle(tester);
    expect(find.text('No outfits yet'), findsOneWidget);

    await tester.tap(find.text('Community'));
    await settle(tester);
    expect(find.text("Community isn't connected"), findsOneWidget);

    GoRouter.of(tester.element(find.byType(NavigationBar))).push('/calendar');
    await settle(tester);
    expect(find.text('Nothing planned'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('My wardrobe'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('wardrobe lists items and search filters them', (tester) async {
    final images = ImageStore(dir.path);
    final repo = WardrobeRepository(db, images);
    await tester.runAsync(() async {
      for (final (n, c) in [('Navy shirt', ClothingCategory.tops), ('Black jeans', ClothingCategory.bottoms)]) {
        await repo.addItem(
          ItemDraft(name: n, category: c, colorHex: '#192350', colorName: 'Navy'),
          StoredImage(imagePath: 'images/$n.jpg', thumbPath: 'thumbs/$n.jpg', colorHex: '#192350', colorName: 'Navy', phash: '0'),
        );
      }
    });
    await pumpApp(tester, onboarded: true);
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.text('Navy shirt'), findsOneWidget);
    expect(find.text('Black jeans'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jeans');
    await settle(tester);
    expect(find.text('Navy shirt'), findsNothing);
    expect(find.text('Black jeans'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);
    expect(find.text('No matches'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('home shows real suggestions once the wardrobe can form an outfit', (tester) async {
    final repo = WardrobeRepository(db, ImageStore(dir.path));
    await tester.runAsync(() async {
      for (final (n, c, color, hex) in [
        ('Navy shirt', ClothingCategory.tops, 'Navy', '#192350'),
        ('Beige chinos', ClothingCategory.bottoms, 'Beige', '#D7C3A0'),
      ]) {
        await repo.addItem(
          ItemDraft(name: n, category: c, colorHex: hex, colorName: color),
          StoredImage(imagePath: 'images/$n.jpg', thumbPath: 'thumbs/$n.jpg', colorHex: hex, colorName: color, phash: '0'),
        );
      }
    });
    await pumpApp(tester, onboarded: true);
    expect(find.text('Why this works'), findsWidgets);
    expect(find.text('Wear today'), findsWidgets);
    await unmount(tester);
  });

  testWidgets('Android back from a non-home tab returns to Home', (tester) async {
    await pumpApp(tester, onboarded: true);
    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('My wardrobe'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('What to wear'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('dark theme renders', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingDone': true, 'themeMode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs), databaseProvider.overrideWithValue(db), appDirProvider.overrideWithValue(dir.path)],
        child: const OutfitlyApp(),
      ),
    );
    await settle(tester);
    final ctx = tester.element(find.text('What to wear'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
    await unmount(tester);
  });
}

/// Lets Drift's real async work complete between frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(seconds: 1));
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pump(const Duration(seconds: 1));
}
