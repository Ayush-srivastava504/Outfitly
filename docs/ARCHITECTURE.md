# Outfitly — Architecture & Build Plan

**Smart Digital Wardrobe & Outfit Planner** · Flutter · Android-first · Offline-first · v1.0 plan
Prepared 19 Nov 2026 · Target toolchain: Flutter 3.47 stable, Android SDK 36 (both verified on the build machine)

---

## 1. Goals and hard constraints

| Constraint | How the design meets it |
|---|---|
| Zero recurring cost | No backend, no Firebase, no paid APIs. Everything runs on the device. |
| Offline-first | SQLite (Drift) + local image files. Only ads need the network, and they are optional. |
| No login | One local profile, stored in preferences. |
| Privacy | Clothing photos never leave the device, except through a user-initiated share or backup export. |
| No fake features | Premium is gated behind an `Entitlements` interface that returns *free* until real Play Billing is added. There are no mock purchase buttons. |
| Release-ready | Signed AAB, permissions audit, privacy policy and store listing are part of the plan. |

**Guiding rule:** a working 8-feature app beats a broken 25-feature one. Section 3 separates what must ship in v1.0 from what can wait.

---

## 2. Feature checklist

### 2.1 Must ship in v1.0 (core workflows)
- [ ] Onboarding (3 screens + preferences: style, units, categories; skippable)
- [ ] Add clothing from camera, gallery or multi-select; compressed images and thumbnails
- [ ] Item metadata: name, category, subcategory, color (auto-detected, editable), brand, seasons, occasions, style, favorite, purchase date, notes
- [ ] Wardrobe grid/list, search, filters (color/category/occasion/season), sort (recent/category/favorites)
- [ ] Edit and delete with undo; duplicate warning (perceptual hash)
- [ ] Outfit creator: pick items → slot-based canvas → save, edit, duplicate, favorite
- [ ] Share outfit as a PNG image
- [ ] Daily suggestions: local recommendation engine with explanations; weather entered manually
- [ ] Calendar: month/week views, assign outfit to a date, mark as worn
- [ ] Analytics: totals, category pie chart, most/least worn, colors, unused items
- [ ] Settings: theme (light/dark/system), backup/restore (ZIP), clear data, privacy, version, feedback
- [ ] AdMob banners + capped interstitials with consent (UMP); the app works fully without ads
- [ ] Premium-ready gating (limits enforced through the `Entitlements` interface)

### 2.2 Deferred to v1.1+
- Free-form drag/rotate canvas (v1.0 uses a clean slot layout: Top / Bottom / Shoes / Outerwear / Accessory)
- Background removal (on-device segmentation)
- Play Billing subscriptions
- Optional live weather (free Open-Meteo API, opt-in, cached)
- Packing lists for travel

---

## 3. High-level architecture

```
┌──────────────────────────── Presentation (features/*) ───────────────────────────┐
│  Screens & widgets  ──watch──▶  Riverpod Notifiers/Providers  (UI state only)      │
└───────────────────────────────────────┬───────────────────────────────────────────┘
                                         │ calls use-cases / repositories
┌──────────────────────────────── Domain (domain/*) ───────────────────────────────┐
│  Entities (ClothingItem, Outfit, WearLog …)   Repository interfaces               │
│  Services: RecommendationEngine, ColorAnalyzer, DuplicateDetector (pure Dart)     │
└───────────────────────────────────────┬───────────────────────────────────────────┘
                                         │ implemented by
┌───────────────────────────────── Data (data/*) ──────────────────────────────────┐
│  Drift DB (SQLite) + DAOs   ImageStore (app documents dir)   PrefsStore           │
│  BackupService (ZIP: JSON + images)                                               │
└───────────────────────────────────────────────────────────────────────────────────┘
 Cross-cutting (core/*): router, theme, AdService, Entitlements, logging, errors
```

**Rules**
- `domain/` has no Flutter imports, which keeps the engines unit-testable and fast.
- Widgets never touch Drift directly; they go through a repository via a provider.
- Streams from Drift (`watch()`) drive the UI, so lists and analytics update automatically.
- Every repository method returns a `Result<T>` (success or typed failure). No exception reaches the UI uncaught.

---

## 4. Folder structure

```
lib/
  main.dart                    # bootstrap: DB, prefs, ads init (guarded), ProviderScope
  app.dart                     # MaterialApp.router + theme
  core/
    router/app_router.dart     # GoRouter + StatefulShellRoute (5 tabs)
    theme/                     # tokens, light/dark ColorScheme, typography
    ads/ad_service.dart        # interface + AdMobService + NoopAdService
    premium/entitlements.dart  # interface + FreeEntitlements + limits
    utils/ result.dart, logger.dart, date_utils.dart
  domain/
    entities/                  # ClothingItem, Outfit, OutfitItem, WearLog, Preferences
    repositories/              # abstract WardrobeRepo, OutfitRepo, CalendarRepo
    services/
      recommendation_engine.dart
      color_analyzer.dart      # dominant color + named color + harmony rules
      duplicate_detector.dart  # dHash + Hamming distance
  data/
    db/app_database.dart       # Drift tables, migrations
    db/daos/                   # wardrobe_dao, outfit_dao, calendar_dao, stats_dao
    repositories/              # Drift implementations
    storage/image_store.dart   # save/compress/thumbnail/delete
    backup/backup_service.dart # export/import ZIP, schema versioned
  features/
    onboarding/  dashboard/  wardrobe/  outfit_creator/  recommendations/
    calendar/    analytics/  settings/  premium/          ads/ (banner widget)
  shared/widgets/              # EmptyState, ErrorView, ItemCard, ConfirmDialog, ChipFilter
test/  integration_test/
```

---

## 5. Navigation

`StatefulShellRoute.indexedStack` keeps each tab's state and back stack:

| Tab | Root route | Child routes |
|---|---|---|
| Home | `/home` | `/home/suggestions` |
| Wardrobe | `/wardrobe` | `/wardrobe/add`, `/wardrobe/item/:id`, `/wardrobe/item/:id/edit` |
| Create | `/create` | `/create/:outfitId` (edit) |
| Calendar | `/calendar` | `/calendar/day/:date` |
| Profile | `/profile` | `/profile/analytics`, `/profile/settings`, `/profile/backup`, `/profile/premium` |

`/onboarding` sits outside the shell. A redirect sends a first-time user there. Android back pops within the current tab first, then returns to Home, then exits.

---

## 6. Data model (Drift / SQLite)

```
clothing_items
  id TEXT PK (uuid)        name TEXT            category TEXT (enum)
  subcategory TEXT?        color_hex TEXT       color_name TEXT
  brand TEXT?              seasons TEXT (csv bitmask)   occasions TEXT (bitmask)
  style TEXT?              is_favorite BOOL     purchase_date DATE?
  notes TEXT?              image_path TEXT      thumb_path TEXT
  phash TEXT               wear_count INT       last_worn DATE?
  created_at, updated_at, deleted_at (soft delete for undo)

outfits
  id PK, name, description?, occasion?, season?, style?, is_favorite,
  cover_path?, created_at, updated_at, deleted_at

outfit_items            (outfit_id FK, item_id FK, slot TEXT, z_index INT)  PK(outfit_id,item_id)

calendar_entries        (id PK, date DATE, outfit_id FK, worn BOOL, note?)  UNIQUE(date, outfit_id)

wear_logs               (id PK, item_id FK, outfit_id FK?, date DATE)  -- feeds analytics
recent_views            (item_id PK, viewed_at)
```

- Seasons and occasions are stored as integer **bitmasks**, so filters are single indexed comparisons.
- Indexes: `clothing_items(category)`, `(is_favorite)`, `(created_at)`, `calendar_entries(date)`, `wear_logs(item_id,date)`.
- Soft delete enables a 5-second **Undo** snackbar. A purge job removes rows and image files older than 7 days.
- `schemaVersion` starts at 1. Every change ships a Drift migration and a migration test.

---

## 7. Core engines (on-device, no AI APIs)

### 7.1 Image pipeline
1. `image_picker` (Android Photo Picker, so no storage permission is needed on Android 13+).
2. `flutter_image_compress`: longest edge 1600 px, JPEG quality 82 for the full image and 300 px for the thumbnail. This runs in an isolate.
3. Files are saved under `appDocs/images/{uuid}.jpg` and `thumbs/{uuid}.jpg`. The DB stores relative paths, so backup and restore are portable.

### 7.2 Color analyzer
- Down-sample the thumbnail to 64×64, drop near-white and near-transparent background pixels, then run k-means (k = 3) in Lab space. The largest cluster is the dominant color.
- Map it to the nearest of ~24 named colors (Black, Navy, Beige, Olive, …) by ΔE distance. The user can always override the result.

### 7.3 Duplicate detector
- A 64-bit **dHash** of the grayscale 9×8 thumbnail. If the Hamming distance to an existing item is ≤ 6, show a "Looks similar to …" warning. It never blocks the save.

### 7.4 Recommendation engine
**Inputs:** wardrobe items, manual weather (Cold / Mild / Warm / Hot / Rainy), occasion, season, preferred colors and styles, wear history, favorites.

**Candidate generation (templates)**
- `Top + Bottom + Shoes [+ Outerwear if Cold/Rainy] [+ Accessory]`
- `Dress + Shoes [+ Outerwear] [+ Accessory]`
- First filter items by season/weather and occasion bitmasks. The search is bounded by sampling up to 15 items per slot, with favorites and least-recently-worn items first, which keeps it to a few thousand combos at most.

**Scoring** (weights in `RecoWeights`, unit-tested):
| Component | Score |
|---|---|
| Color harmony | neutrals pair with anything; analogous (Δhue < 40°) +; complementary (150–210°) +; ≥3 saturated hues − |
| Style coherence | all items share the style → +; formal mixed with sporty → − |
| Preference match | preferred colors and styles → + |
| Favorites | + per favorite item |
| Freshness | − if any item was worn in the last 3 days; − if this exact combo was worn in the last 14 days |
| Rotation | + for items with low `wear_count` (encourages using the whole wardrobe) |

**Diversity:** pick the top 5 using Maximal Marginal Relevance, so suggestions don't all share the same jeans.

**Explanations:** each suggestion lists its top-scoring components as plain text, e.g. *"Navy and beige are a classic neutral pair · suits Office · you haven't worn this shirt in 12 days."*

If the wardrobe lacks a required slot, the engine returns a typed `InsufficientWardrobe(missing: [Shoes])` and the UI shows a helpful empty state. It never fabricates a suggestion.

---

## 8. State management (Riverpod)

- `riverpod` with code generation (`@riverpod`) for providers. `AsyncNotifier` handles mutations.
- Provider families such as `itemsProvider(filter)`, `outfitProvider(id)` and `suggestionsProvider(context)`.
- The DB, repositories and services are provided once at the root and overridden in tests with an in-memory DB.

---

## 9. Monetization architecture

### 9.1 Ads (`google_mobile_ads`)
```dart
abstract class AdService { Future<void> init(); Widget banner(AdPlacement p); Future<void> maybeShowInterstitial(AdTrigger t); }
```
- `AdMobService` is used when ad unit IDs exist and consent allows. `NoopAdService` is used otherwise (ads disabled, init failure, or premium user).
- **Consent:** the UMP SDK (`ConsentInformation` / `ConsentForm`) runs before ad requests, and a *Privacy options* entry in Settings lets users change it.
- **Placements:** banners on Wardrobe list, Analytics and Calendar. Banners never appear on the outfit creator, the add/edit item screen or onboarding.
- **Interstitials** fire only after saving an outfit or leaving Analytics. They are capped at 1 per 3 minutes and 3 per day, never in the first session, and never within 60 s of app start.
- Debug builds always use Google's **test ad unit IDs**. Real IDs come from `--dart-define` at release time and are never hard-coded in the repo.

### 9.2 Premium (ready, not faked)
```dart
abstract class Entitlements { bool get isPremium; int get maxItems; int get maxOutfits; bool get advancedStats; }
class FreeEntitlements implements Entitlements { isPremium=false; maxItems=150; maxOutfits=50; ... }
```
The Premium screen describes what is coming, with no buy button until Play Billing (`in_app_purchase`) is integrated and tested in v1.1.

---

## 10. Packages (all free / OSS-compatible)

| Purpose | Package | License |
|---|---|---|
| State | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | MIT |
| Routing | `go_router` | BSD-3 |
| Database | `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `drift_dev` | MIT |
| Preferences | `shared_preferences` | BSD-3 |
| Images | `image_picker`, `flutter_image_compress`, `image` | BSD / MIT |
| Files | `path_provider`, `path`, `file_picker`, `archive` | BSD / MIT |
| Charts | `fl_chart` | MIT |
| Calendar | `table_calendar` | Apache-2.0 |
| Share | `share_plus` | BSD-3 |
| Ads | `google_mobile_ads` (includes UMP) | Apache-2.0 (SDK under Google terms) |
| Utils | `uuid`, `intl`, `collection`, `equatable`/`freezed` | MIT / BSD |
| Branding | `flutter_launcher_icons`, `flutter_native_splash` (dev) | MIT |
| Testing | `flutter_test`, `integration_test`, `mocktail` | BSD / MIT |

Versions are resolved to the latest stable at build time and locked in `pubspec.lock`. **Avoid** packages under commercial licenses (e.g. Syncfusion).

---

## 11. UI/UX system

- **Look:** minimal fashion-tech. Warm-neutral surfaces (#FAF8F5 light / #121212 dark), one accent (deep terracotta #C2643C) and a charcoal text color.
- **Type:** *Playfair Display* for headings and *Inter* for body, bundled as assets so they work offline.
- **Components:** 16 px radius cards, 4:5 image ratio tiles, filter chips, bottom sheets for forms and Hero transitions from grid to detail.
- **States:** every list has loading (shimmer), empty (illustration + CTA) and error (retry) states.
- **Accessibility:** contrast ≥ 4.5:1, 48 dp tap targets, semantics labels on image tiles, text scaling up to 200% without overflow.

---

## 12. Permissions audit

| Permission | Why | Notes |
|---|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | Ads only | The app works offline |
| `com.google.android.gms.permission.AD_ID` | Added by the Ads SDK | Declare it in the Play Console data-safety form |
| Camera | Taking photos | `image_picker` uses the system camera intent, so no `CAMERA` permission is declared |
| Storage | Not needed | The Photo Picker and app-private storage cover it |

---

## 13. Testing plan

| Layer | What | Tooling |
|---|---|---|
| Unit | RecommendationEngine (templates, weights, recency, insufficient wardrobe), ColorAnalyzer, dHash, bitmask helpers, Entitlements limits | `flutter_test` |
| Database | CRUD, soft delete/undo/purge, cascade on outfit delete, migrations v1→vN | Drift `NativeDatabase.memory()` |
| Backup | Export → wipe → import produces identical rows and image files; corrupt ZIP and wrong schema version are rejected cleanly | temp dirs |
| Widget | Wardrobe empty/loaded/error, filters, item form validation, outfit save, settings theme toggle | `flutter_test` + provider overrides |
| Navigation | Onboarding redirect, tab state retention, deep-link to item, back behavior | GoRouter in widget tests |
| Integration | Add item → create outfit → assign to calendar → analytics shows it → restart → still there | `integration_test` on emulator |
| Manual | Dark mode, 5" screen, permission denied, low storage, airplane mode, process death during save | Checklist in `docs/QA_CHECKLIST` |

Exit criteria: all tests green, `flutter analyze` clean, zero critical or high bugs open.

---

## 14. Release pipeline

1. `applicationId`: `com.<yourname>.outfitly` (choose it once; it cannot change after publishing).
2. `minSdk 23`, `targetSdk` = the current Play requirement (35/36), `compileSdk 36`.
3. Signing: `upload-keystore.jks` kept **outside the repo**, referenced through `android/key.properties`, which is git-ignored. Back the keystore up separately.
4. Enable R8 shrink and obfuscate with `--split-debug-info=build/symbols`.
5. Build: `flutter build appbundle --release --dart-define=ADMOB_APP_ID=... --dart-define=ADMOB_BANNER_ID=...`
6. Output: `build/app/outputs/bundle/release/app-release.aab`
7. Verify: `bundletool` size check, manifest permission review, and an install of the universal APK on a device.
8. Store: privacy policy (free GitHub Pages), data-safety form (Ads: device ID; no personal data collected), content rating, 8 screenshots, feature graphic.

> **Play Console reality check:** new *personal* developer accounts must run a **closed test with at least 12 testers for 14 continuous days** before they can publish to production. Plan for that. The build can be done in one day; the public release cannot. AdMob also only fully serves ads once the app is linked to its live Play listing.

---

## 15. One-day build schedule (10 h)

| Hour | Work | Done when |
|---|---|---|
| 1 | `flutter create`, packages, theme, router shell, Drift schema | App boots into 5 empty tabs |
| 2–3 | Wardrobe: picker, compression, add/edit/delete, grid, filters | Items persist across restarts |
| 4–5 | Outfit creator + RecommendationEngine (+ unit tests) | Suggestions with explanations |
| 6 | Calendar + analytics charts | Wear logs drive the charts |
| 7 | Settings, backup/restore, ads + consent, entitlements | Backup round-trip passes |
| 8–9 | Test suite, emulator run-through, fix bugs, polish states | All tests green |
| 10 | Icons, splash, signing, AAB, store assets | AAB built and verified |

**Cut order if time runs short:** recently viewed → duplicate detection → week calendar view → share image. Never cut backup or data persistence.

---

## 16. Risks

| Risk | Mitigation |
|---|---|
| Image memory pressure on large wardrobes | Thumbnails in grids, `cacheWidth` on `Image.file`, compression in isolates |
| Users lose data on uninstall | Prominent backup reminder after 20 items; ZIP export to Downloads/Drive via the share sheet |
| Ads policy violations | Test IDs in debug, frequency caps, no ads near tap-heavy creation flows |
| Scope creep | Section 2.2 is the parking lot |
