import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitly/core/prefs/app_prefs.dart';
import 'package:outfitly/core/providers.dart';
import 'package:outfitly/data/community/community_api.dart';
import 'package:outfitly/data/db/app_database.dart';
import 'package:outfitly/features/community/community_providers.dart';
import 'package:outfitly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_community_api.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory dir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('outfitly_community');
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<void> pump(WidgetTester tester, CommunityApi api) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          appDirProvider.overrideWithValue(dir.path),
          communityApiProvider.overrideWithValue(api),
        ],
        child: const OutfitlyApp(),
      ),
    );
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Community')));
    await settle(tester);
  }

  testWidgets('without a Supabase key the tab explains it is not connected', (tester) async {
    await pump(tester, const DisabledCommunityApi());
    expect(find.text('Community isn\'t connected'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('sign-up requires guidelines, then profile setup, then feed', (tester) async {
    final api = FakeCommunityApi();
    api.seedPost(uid: 'u-other', username: 'maya', title: 'Linen shirt');
    await pump(tester, api);
    expect(find.text('Join the Outfitly community'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'me@test.dev');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'supersecret');
    await tapVisible(tester, find.text('Create account'));
    await settle(tester);
    expect(find.text('Please accept the community guidelines.'), findsOneWidget);

    await tapVisible(tester, find.byType(Checkbox));
    await tapVisible(tester, find.text('Create account'));
    await settle(tester);
    expect(find.text('Create your profile'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'Bad Name!');
    await tester.enterText(find.widgetWithText(TextFormField, 'Display name'), 'Me');
    await tapVisible(tester, find.text('Continue'));
    await settle(tester);
    expect(find.text('Use 3–24 letters, numbers or _'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'me_style');
    await tapVisible(tester, find.text('Continue'));
    await settle(tester);
    expect(find.text('Linen shirt'), findsOneWidget, reason: 'feed shows other users\' posts');
    expect(api.profiles[api.currentUserId]!.username, 'me_style');
    await unmount(tester);
  });

  testWidgets('email-confirmation flow tells the user to check their inbox', (tester) async {
    final api = FakeCommunityApi(requireEmailConfirm: true);
    await pump(tester, api);
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'me@test.dev');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'supersecret');
    await tapVisible(tester, find.byType(Checkbox));
    await tapVisible(tester, find.text('Create account'));
    await settle(tester);
    expect(find.textContaining('Check your inbox'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    await unmount(tester);
  });

  Future<FakeCommunityApi> signedIn() async {
    final api = FakeCommunityApi();
    await api.signUp('me@test.dev', 'supersecret');
    await api.saveProfile(username: 'me', displayName: 'Me', isPublic: true);
    return api;
  }

  testWidgets('like / unlike updates the count optimistically and on the server', (tester) async {
    final api = await signedIn();
    final post = api.seedPost(uid: 'u-other', username: 'maya');
    await pump(tester, api);
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byTooltip('Like'));
    await settle(tester);
    expect(find.text('1'), findsOneWidget);
    expect(api.likes, contains((post.id, api.currentUserId!)));
    await tester.tap(find.byTooltip('Unlike'));
    await settle(tester);
    expect(find.text('0'), findsOneWidget);
    expect(api.likes, isEmpty);
    await unmount(tester);
  });

  testWidgets('report hides the post; block hides all of that user\'s posts', (tester) async {
    final api = await signedIn();
    api.seedPost(uid: 'u-a', username: 'spammer', title: 'Spam post');
    api.seedPost(uid: 'u-b', username: 'rude', title: 'Rude post 1');
    api.seedPost(uid: 'u-b', username: 'rude', title: 'Rude post 2');
    await pump(tester, api);

    await tester.tap(find.byTooltip('Post options').first);
    await settle(tester);
    await tester.tap(find.text('Report post'));
    await settle(tester);
    await tester.tap(find.text('Spam'));
    await settle(tester);
    expect(api.reports, hasLength(1));
    expect(find.text('Spam post'), findsNothing);

    await tester.tap(find.byTooltip('Post options').first);
    await settle(tester);
    await tester.tap(find.text('Block user'));
    await settle(tester);
    await tester.tap(find.text('Block'));
    await settle(tester);
    expect(find.text('Rude post 1'), findsNothing);
    expect(find.text('Rude post 2'), findsNothing);
    await unmount(tester);
  });

  testWidgets('my stats show likes and views; account deletion signs out', (tester) async {
    final api = await signedIn();
    final mine = await api.share(kind: 'item', localRef: 'x', title: 'My jacket', images: const []);
    api.likes.add((mine.id, 'u-fan'));
    api.views.add((mine.id, 'u-fan'));
    await pump(tester, api);

    GoRouter.of(tester.element(find.byType(NavigationBar))).push('/community/me');
    await settle(tester);
    expect(find.text('My jacket'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.textContaining('♥ 1'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    GoRouter.of(tester.element(find.byType(NavigationBar))).push('/community/account');
    await settle(tester);
    await tester.tap(find.text('Delete community account'));
    await settle(tester);
    await tester.tap(find.text('Delete account'));
    await settle(tester);
    await tester.tap(find.text('Yes, delete'));
    await settle(tester);
    expect(api.currentUserId, isNull);
    expect(api.posts.where((p) => p.title == 'My jacket'), isEmpty);
    expect(find.text('Join the Outfitly community'), findsOneWidget);
    await unmount(tester);
  });

  test('feed pagination uses keyset cursor without duplicates', () async {
    final api = await signedIn();
    final base = DateTime(2026, 11, 1);
    for (var i = 0; i < 45; i++) {
      api.seedPost(
        uid: 'u-x',
        username: 'xx',
        title: 'p$i',
        at: base.add(Duration(minutes: i)),
      );
    }
    final first = await api.feed(limit: 20);
    final second = await api.feed(before: first.last.createdAt, limit: 20);
    final third = await api.feed(before: second.last.createdAt, limit: 20);
    final all = [...first, ...second, ...third].map((p) => p.id).toList();
    expect(all.toSet().length, 45);
    expect(third.length, 5);
  });
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

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}
