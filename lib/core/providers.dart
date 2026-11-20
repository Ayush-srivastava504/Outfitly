import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup/backup_service.dart';
import '../data/db/app_database.dart';
import '../data/repositories/repositories.dart';
import '../data/storage/cutout_service.dart';
import '../data/storage/image_store.dart';
import '../domain/services/recommendation_engine.dart';
import 'ads/ad_service.dart';
import 'premium/entitlements.dart';

/// Overridden in main() / tests.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError());
final appDirProvider = Provider<String>((ref) => throw UnimplementedError());
final adServiceProvider = Provider<AdService>((ref) => const NoopAdService());

final entitlementsProvider = Provider<Entitlements>((ref) => const FreeEntitlements());

final imageStoreProvider = Provider((ref) => ImageStore(ref.watch(appDirProvider)));
final wardrobeRepoProvider = Provider((ref) => WardrobeRepository(ref.watch(databaseProvider), ref.watch(imageStoreProvider)));
final outfitRepoProvider = Provider((ref) => OutfitRepository(ref.watch(databaseProvider)));
final calendarRepoProvider = Provider((ref) => CalendarRepository(ref.watch(databaseProvider), ref.watch(outfitRepoProvider)));
final backupServiceProvider = Provider((ref) => BackupService(ref.watch(databaseProvider), ref.watch(appDirProvider)));
final cutoutServiceProvider = Provider((ref) => CutoutService(ref.watch(databaseProvider), ref.watch(imageStoreProvider)));
final recoEngineProvider = Provider((ref) => const RecommendationEngine());

final itemsProvider = StreamProvider.family<List<ClothingItem>, ItemFilter>((ref, filter) => ref.watch(wardrobeRepoProvider).watchItems(filter));
final allItemsProvider = StreamProvider<List<ClothingItem>>((ref) => ref.watch(wardrobeRepoProvider).watchItems());
final itemProvider = StreamProvider.family<ClothingItem?, String>((ref, id) => ref.watch(wardrobeRepoProvider).watchItem(id));
final recentlyViewedProvider = StreamProvider((ref) => ref.watch(wardrobeRepoProvider).watchRecentlyViewed());

final outfitsProvider = StreamProvider<List<OutfitWithItems>>((ref) => ref.watch(outfitRepoProvider).watchOutfits());
final outfitProvider = StreamProvider.family<OutfitWithItems?, String>((ref, id) => ref.watch(outfitRepoProvider).watchOutfit(id));
final wearLogsProvider = StreamProvider((ref) => ref.watch(calendarRepoProvider).watchWearLogs());
