# Outfitly — Release & Google Play Guide

## 1. One-time: create your upload keystore

Keep the keystore and passwords **outside** this repo and back them up (losing it means you can't ship updates unless you request an upload-key reset from Google).

```powershell
keytool -genkey -v -keystore D:\keys\outfitly-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties` (already git-ignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=D:\\keys\\outfitly-upload.jks
```

If `key.properties` is missing, the build prints a WARNING and signs with the debug key. **Play Console rejects that AAB.**

## 2. Choose the final application ID

`android/app/build.gradle.kts` → `applicationId = "com.outfitly.outfitly"`.
It must be globally unique on Google Play and **can never change** after the first upload. Change it now if you want something like `com.<yourname>.outfitly`.

## 3. AdMob setup

1. Create an AdMob account, then add an Android app (you can link it to the Play listing later).
2. Create two ad units: **Banner** and **Interstitial**.
3. In AdMob → Privacy & messaging, create a **GDPR consent message** (required for EEA/UK users). The app already runs Google's UMP consent flow and has a "Ad privacy choices" entry in Settings.
4. Build with your real IDs:

```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols `
  -PADMOB_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY `
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/1111111111 `
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/2222222222 `
  --dart-define=SUPPORT_EMAIL=you@example.com `
  --dart-define=PRIVACY_POLICY_URL=https://you.github.io/outfitly/privacy.html
```

> `-PADMOB_APP_ID` is a Gradle property; if `flutter build` doesn't forward it on your setup, set `ADMOB_APP_ID` as an environment variable or add it to `android/gradle.properties` instead.

Behaviour:
- **Debug/profile builds** always use Google's public test ad units — safe to tap.
- **Release builds without `ADMOB_*` dart-defines** show **no ads at all** (NoopAdService). The app is fully functional.
- Never tap your own live ads. Add your phone as a test device in AdMob.

Ad placements: banners on Wardrobe, Calendar and Insights. Interstitials only after saving an outfit or leaving Insights; max 1 per 3 minutes, 3 per day, never in the first 60 s after launch. No ads on onboarding, item add/edit or the outfit builder.

## 3b. Supabase (Community)

The project URL is compiled in (`lib/data/community/community_api.dart`). Pass the public **anon / publishable** key at build time — never commit it, and never put the database password anywhere in this repo:

```powershell
--dart-define=SUPABASE_ANON_KEY=sb_publishable_...
```

Without it, Community shows "Community isn't connected" and the rest of the app works offline. Schema and RLS: `supabase/schema.sql`, checks in `supabase/tests/rls_test.sql`.

## 4. Build & verify

```powershell
flutter test
flutter analyze
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=SUPABASE_ANON_KEY=...  (+ the AdMob defines above)
```

Output: `build\app\outputs\bundle\release\app-release.aab`
Keep `build\symbols` — upload it to Play Console (or keep it) to de-obfuscate crash stack traces.

Bump `version:` in `pubspec.yaml` (e.g. `1.0.1+2`) for every upload — the `+N` build number must increase.

## 5. Google Play Console checklist

- [ ] Developer account (one-time fee). **New personal accounts must run a closed test with ≥ 12 testers for 14 continuous days before production.** Start this immediately.
- [ ] Create app → name "Outfitly – Wardrobe & Outfits", default language, App, Free.
- [ ] Upload the AAB to **Internal testing** first; install via the opt-in link on a real phone.
- [ ] Play App Signing: accept (Google manages the app-signing key; you keep the upload key).
- [ ] **Privacy policy URL** — host `docs/privacy-policy.html` (e.g. GitHub Pages) and paste the link.
- [ ] **Data safety** form:
  - *Device or other IDs* (Advertising ID): collected by the Google Mobile Ads SDK, for Advertising/Analytics.
  - *Personal info → Email address*: collected **only if the user joins Community** (account management). Optional.
  - *Photos and videos → Photos* and *Personal info → Name* (username/display name): user-chosen posts and profile, shared publicly in Community. Optional.
  - *App activity → App interactions* (likes, post views, reports): collected for app functionality/analytics in Community. Optional.
  - Private wardrobe, outfits, calendar, try-on avatar: **not collected** (stay on device).
  - Encrypted in transit: Yes (HTTPS to Supabase and AdMob).
  - Deletion: in-app **Community → Profile → Delete account** removes the account, posts, likes and images. Also give a web URL for deletion requests (Play requires one) — e.g. a section of the hosted privacy policy with the support email.
- [ ] **User-generated content** (Policy → App content): the app has guidelines acceptance at sign-up, report post, block user, and an account-deletion path. Moderate reports in Supabase (`reports` table) and remove violating posts promptly.
- [ ] **Supabase before launch**: set up **custom SMTP** (Auth → SMTP settings) — the built-in email sender is heavily rate-limited and will block sign-ups. Set the Site URL / redirect URLs for email confirmation and password reset. Keep the free project active (free projects pause after ~1 week of inactivity).
- [ ] **Ads**: declare "Yes, my app contains ads".
- [ ] **Advertising ID** declaration: Yes (AdMob), purpose Advertising.
- [ ] **Target audience**: 13+ (or 18+). Do *not* target children unless you switch to Families-certified ad settings.
- [ ] **Content rating** questionnaire (expected: Everyone / PEGI 3).
- [ ] Store listing: text from `docs/STORE_LISTING.md`, icon `assets/branding/icon.png` (512×512 export), feature graphic 1024×500, at least 4 phone screenshots.
- [ ] Closed testing (12+ testers, 14 days) → apply for production.

## 6. Permissions shipped

| Permission | Source | Why |
|---|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | app + Ads SDK | Ads and the optional Community (Supabase) |
| `com.google.android.gms.permission.AD_ID` | Ads SDK (merged) | Advertising ID |
| — (no CAMERA, no storage) | — | Camera uses the system camera app via intent; gallery uses the Android Photo Picker; backups use the system file picker |
