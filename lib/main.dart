import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/ads/ad_service.dart';
import 'core/prefs/app_prefs.dart';
import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/community/community_api.dart';
import 'data/community/supabase_community_api.dart';
import 'data/db/app_database.dart';
import 'features/community/community_providers.dart';
import 'data/repositories/repositories.dart';
import 'data/storage/image_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final docs = await getApplicationDocumentsDirectory();
  final db = AppDatabase();

  // Ads are optional: missing config, denied consent or init failure → NoopAdService.
  final adConfig = AdConfig.resolve();
  final AdService ads = adConfig == null ? const NoopAdService() : AdMobService(adConfig);

  // Online community is optional: without SUPABASE_ANON_KEY (or if init fails) the app stays fully offline.
  CommunityApi community = const DisabledCommunityApi();
  if (CommunityConfig.enabled) {
    try {
      community = await SupabaseCommunityApi.initialize();
    } catch (e) {
      debugPrint('Community disabled: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        appDirProvider.overrideWithValue(docs.path),
        adServiceProvider.overrideWithValue(ads),
        communityApiProvider.overrideWithValue(community),
      ],
      child: const OutfitlyApp(),
    ),
  );

  // Non-blocking startup chores.
  ads.init();
  final images = ImageStore(docs.path);
  WardrobeRepository(db, images).purgeDeleted();
  OutfitRepository(db).purgeDeleted();
}

class OutfitlyApp extends ConsumerWidget {
  const OutfitlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appPrefsProvider.select((p) => p.themeMode));
    return MaterialApp.router(
      title: 'Outfitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
