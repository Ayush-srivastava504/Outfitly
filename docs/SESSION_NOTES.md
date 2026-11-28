# Outfitly — session handoff (updated 28 Nov 2026, ~22:05 IST)

## Session 28 Nov
- Local release builds stall on this 7.7 GB PC (swap thrash). **Build in the cloud instead:** GitHub Actions `.github/workflows/build-android.yml` (Actions → Build Android → Run workflow; tick "aab" for the Play bundle). Secrets set: KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS, SUPABASE_ANON_KEY.
- Fixed release-only startup crash (R8 stripped `androidx.work.impl.WorkDatabase_Impl`): added `android/app/proguard-rules.pro` + `proguardFiles(...)` in app/build.gradle.kts.
- Local `android/gradle.properties` heap lowered 8G → 2560m (CI bumps it to 6g).
- Run 46163920987: signed APK + AAB in `build/cloud/` (symbols in `build/cloud/symbols`). APK installed on phone RZGYC13J23J, launches with no crash; UI not yet checked by hand.
- Repo github.com/Ayush-srivastava504/Outfitly is **public** (artifacts downloadable 7 days). Owner was told to rotate the Supabase secret key + DB password (shared in chat).

## Next
1. Owner tests the app on the phone (community sign-in, try-on, backup).
2. Upload `build/cloud/app-release.aab` to Play Console internal testing.
3. StudyOS.

---
# Outfitly — session handoff (updated 20 Nov 2026, ~21:00 IST)

## Session 20 Nov evening — what changed
- Fixed app bugs: My-community screen crashed on posts with no images (`imageUrls.first`); avatar initials crashed on empty names (`initial()` helper in community_screens.dart).
- Fixed tests: community sign-up taps now scroll into view (`tapVisible`); fake API seeds posts without network images; try-on test polls the cutouts folder (an earlier version deadlocked on drift's lock inside `runAsync`).
- Test status: core/data/domain suites + community_test + landscape_test **pass**. `try_on_test.dart` fix was being re-run when the session paused — re-run it first.
- `docs/RELEASE.md` updated: Supabase key define, Data safety for Community, UGC policy, custom SMTP before launch.
- Supabase publishable key received from owner — **not stored in any file**; ask the owner for it again (Dashboard → Project Settings → API Keys) when building.
- AAB **not built**: PC had 0.06–0.2 GB RAM free (mysqld, JobPilot python, Chrome, ProtonVPN, 2nd Claude window). Owner will free memory first.

## Resume order
1. `flutter test test/widget/try_on_test.dart` (run tests one at a time; never start a second run while one is going — it locks sqlite3.dll).
2. `flutter analyze`
3. Close other apps, then: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=SUPABASE_ANON_KEY=<key>`
4. StudyOS: engines + tests already written in `D:\StudyOS\lib\domain\engines\` and `test\domain\engines_test.dart` (not yet run). Next: `flutter create --org <org> --project-name studyos .` in D:\StudyOS, add deps (intl, flutter_riverpod, drift…), run the engine tests, then follow ARCHITECTURE.md §15.

---
(Earlier notes below)

# Outfitly — session handoff (20 Nov 2026, ~02:00 IST)

Resume this exact chat: `cd D:\Outfitly` then `claude --resume` (pick this session) — or start fresh and say
"read docs/SESSION_NOTES.md and continue".

## Where we are
| Area | Status |
|---|---|
| Outfitly v1 core (wardrobe, outfits, suggestions, calendar, insights, backup, ads, premium gate) | Built, 56 tests passed earlier, ran on phone (Galaxy A36, `RZGYC13J23J`) |
| Rotation / large-text overflow fixes (all screens) | Done, verified by `test/widget/landscape_test.dart` (19 widget tests green) |
| Bug: `ref` used in `dispose()` (Insights, item form) | Fixed |
| 2D avatar try-on (`lib/features/try_on/`, `lib/data/storage/cutout_service.dart`, DB schema v2 `cutout_path`) | Written, analyzer clean, **tests not yet run** |
| Community (`lib/data/community/`, `lib/features/community/`), Calendar moved off the tab bar | Written, **tests not yet run** |
| Supabase backend (`supabase/schema.sql`) | **Applied to the live project**, 15/15 RLS checks passed (`supabase/tests/rls_test.sql`, rolled back) |
| Privacy screen + `docs/privacy-policy.html` | Updated for community data |
| Upload keystore | Created: `D:\keys\outfitly-upload.jks`; passwords in `D:\keys\outfitly-upload-PASSWORDS.txt` and `android/key.properties` (git-ignored). **Back these up.** |
| Release AAB | Not built yet |
| StudyOS (`D:\StudyOS`) | Plan only (`docs/ARCHITECTURE.md`) |

Last full test run was **killed by Windows for low memory** (0.7 GB of 7.7 GB free) — not a test failure.
Close Edge / VS Code before running tests or Gradle builds.

## Next steps (in order)
1. `flutter test` → fix failures (new: `test/widget/community_test.dart`, `test/widget/try_on_test.dart`,
   `test/data/cutout_and_migration_test.dart`, `test/domain/background_remover_test.dart`; updated app_flow/landscape tests).
2. `flutter analyze` clean.
3. Install on phone with the Supabase key:
   `flutter run -d RZGYC13J23J --dart-define=SUPABASE_ANON_KEY=<key>`
4. Update `docs/RELEASE.md`: Supabase key define, Data safety (email, user content photos, app interactions),
   UGC policy (report/block/guidelines present), account-deletion URL, Supabase custom SMTP before launch
   (built-in email is rate-limited).
5. Build AAB (signed with the new upload key):
   `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=SUPABASE_ANON_KEY=<key>`
   → `build\app\outputs\bundle\release\app-release.aab`
6. Then StudyOS.

## Needed from the owner
- **Supabase anon / publishable key** (Dashboard → Project Settings → API Keys). Project URL is already in code:
  `https://hvebjndsvsoabnnhufnt.supabase.co` (region ap-southeast-1, pooler `aws-0-ap-southeast-1.pooler.supabase.com`).
- **Reset the Supabase database password** (it was shared in chat). Do not store it in this repo.
- Optional: decide final `applicationId` (currently `com.outfitly.outfitly`) before the first Play upload.

## Environment gotchas (Windows)
- Use `D:\flutter\bin\dart` (the `dart` on PATH is a different SDK) for `build_runner`.
- `android/gradle.properties` has `kotlin.incremental=false` (project on D:, pub cache on C:).
- psql: `D:\New folder (4)\bin\psql.exe`. Direct DB host is IPv6-only; use the pooler above with user `postgres.hvebjndsvsoabnnhufnt`.
- If tests fail to start with "failed to delete sqlite3.dll": `taskkill /F /IM flutter_tester.exe`.
- Release build once stalled ~20 min in R8 with no log output; first debug build took ~19 min.
