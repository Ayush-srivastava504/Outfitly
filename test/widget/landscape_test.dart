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
import 'package:outfitly/features/outfit_creator/outfit_detail_screen.dart';
import 'package:outfitly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every main screen in landscape (Galaxy A36: 2340x1080 @ 2.625 dpr) and at large text sizes.
/// Any RenderFlex overflow throws inside the test framework, so these tests fail on overflow.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final (label, size, scale) in [
    ('landscape', const Size(2340, 1080), 1.0),
    ('landscape + large text', const Size(2340, 1080), 1.3),
    ('portrait + huge text', const Size(1080, 2340), 1.6),
    ('small portrait phone', const Size(720, 1280), 1.0),
  ]) {
    group(label, () {
      late AppDatabase db;
      late Directory dir;

      setUp(() {
        db = AppDatabase(NativeDatabase.memory());
        dir = Directory.systemTemp.createTempSync('outfitly_land');
      });
      tearDown(() async {
        await db.close();
        dir.deleteSync(recursive: true);
      });

      Future<void> boot(WidgetTester tester, {required bool withData, bool onboarded = true}) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = size.width == 720 ? 2.0 : 2.625;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        if (withData) {
          final repo = WardrobeRepository(db, ImageStore(dir.path));
          final outfits = OutfitRepository(db);
          await tester.runAsync(() async {
            final ids = <String>[];
            for (final (n, c, color, hex) in [
              ('Navy oxford shirt with a long name', ClothingCategory.tops, 'Navy', '#192350'),
              ('Beige chinos', ClothingCategory.bottoms, 'Beige', '#D7C3A0'),
              ('White sneakers', ClothingCategory.shoes, 'White', '#F5F5F5'),
              ('Camel coat', ClothingCategory.outerwear, 'Camel', '#BE8C55'),
            ]) {
              ids.add(
                await repo.addItem(
                  ItemDraft(name: n, category: c, colorHex: hex, colorName: color, isFavorite: true),
                  StoredImage(imagePath: 'images/$n.jpg', thumbPath: 'thumbs/$n.jpg', colorHex: hex, colorName: color, phash: '0'),
                ),
              );
            }
            final o = await outfits.save(OutfitDraft(name: 'Monday office look', itemIds: ids));
            await CalendarRepository(db, outfits).wearOn(DateTime.now(), o);
          });
        }

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

      Future<void> tab(WidgetTester tester, String name) async {
        await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(name)));
        await settle(tester);
      }

      testWidgets('onboarding pages', timeout: const Timeout(Duration(minutes: 2)), (tester) async {
        await boot(tester, withData: false, onboarded: false);
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.text('Next'));
          await settle(tester);
        }
        expect(find.text('Make it yours'), findsOneWidget);
        await unmount(tester);
      });

      testWidgets('empty states on every tab', timeout: const Timeout(Duration(minutes: 2)), (tester) async {
        await boot(tester, withData: false);
        for (final t in ['Wardrobe', 'Create', 'Community', 'Profile', 'Home']) {
          await tab(tester, t);
        }
        await unmount(tester);
      });

      testWidgets('filled screens: tabs, item detail, outfit detail, analytics, suggestions', timeout: const Timeout(Duration(minutes: 2)), (tester) async {
        await boot(tester, withData: true);
        final r = GoRouter.of(tester.element(find.byType(NavigationBar)));
        GoRouter router() => r;

        // Home: suggestions may be below the fold in landscape; scroll the Home list to them.
        final homeList = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
        await tester.scrollUntilVisible(find.text('More ideas'), 200, scrollable: homeList);
        await tester.drag(homeList, const Offset(0, -250));
        await settle(tester);
        expect(find.text('Why this works'), findsWidgets);

        // Wardrobe grid + item detail.
        await tab(tester, 'Wardrobe');
        expect(find.text('Beige chinos'), findsOneWidget);
        await tester.tap(find.ancestor(of: find.text('Beige chinos'), matching: find.byType(Card)).first);
        await settle(tester);
        expect(find.text('Times worn'), findsOneWidget);
        router().pop();
        await settle(tester);

        // Outfit builder, saved outfits and outfit detail.
        await tab(tester, 'Create');
        await tester.tap(find.text('My outfits'));
        await settle(tester);
        expect(find.text('Monday office look'), findsOneWidget);
        final outfitId = (await tester.runAsync(() => OutfitRepository(db).watchOutfits().first))!.first.outfit.id;
        router().push('/outfit/$outfitId');
        await settle(tester);
        expect(find.byType(OutfitDetailScreen), findsOneWidget);
        router().pop();
        await settle(tester);

        // Calendar with a worn outfit (now a pushed screen, reached from Home/Profile).
        router().push('/calendar');
        await settle(tester);
        expect(find.text('Monday office look'), findsWidgets);
        router().pop();
        await settle(tester);

        // Try-on tab with the avatar.
        await tab(tester, 'Create');
        await tester.tap(find.text('Try on'));
        await settle(tester);
        expect(find.byTooltip('Avatar settings'), findsOneWidget);

        // Profile → insights.
        await tab(tester, 'Profile');
        router().push('/profile/analytics');
        await settle(tester);
        expect(find.text('By category'), findsOneWidget);
        router().pop();
        await settle(tester);

        // Full suggestions screen.
        router().push('/home/suggestions');
        await settle(tester);
        expect(find.text('Outfit ideas'), findsOneWidget);
        await unmount(tester);
      });
    });
  }
}

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
