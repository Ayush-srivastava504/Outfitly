# Outfitly — Smart Digital Wardrobe & Outfit Planner

Flutter · Android · offline-first · no backend · no paid APIs.

## Status: v1.0 built
See `docs/ARCHITECTURE.md` (plan) and `docs/RELEASE.md` (signing, AdMob, Play Console).

## Run
```powershell
cd D:\Outfitly
flutter pub get
flutter run                 # debug, Google test ads
flutter test                # unit + database + widget tests
```

## Build for Play
```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
# → build\app\outputs\bundle\release\app-release.aab
```
Needs `android/key.properties` for a Play-uploadable signature, and `--dart-define` AdMob IDs for live ads (see docs/RELEASE.md).

## Layout
```
lib/core      router, theme, prefs, ads (AdMob + Noop), premium entitlements, providers
lib/domain    pure Dart: enums, ColorAnalyzer, DuplicateDetector, RecommendationEngine
lib/data      Drift DB, repositories, ImageStore, BackupService (ZIP)
lib/features  onboarding, dashboard, wardrobe, outfit_creator, recommendations,
              calendar, analytics, settings, premium
lib/shared    reusable widgets
test/         domain, core, data (in-memory SQLite), widget/navigation
```

After changing tables in `lib/data/db/app_database.dart`, regenerate code and add a migration:
```powershell
D:\flutter\bin\dart run build_runner build --delete-conflicting-outputs
```
