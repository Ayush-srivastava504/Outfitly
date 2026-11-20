# Outfitly — Manual QA checklist (run on a real phone or emulator before each release)

Mark each item ✅ / ❌ with notes.

## First run
- [ ] Fresh install shows onboarding; **Skip** lands on Home
- [ ] Completing onboarding saves styles/colours (visible in Profile → Style preferences)
- [ ] Kill and reopen → onboarding not shown again

## Wardrobe
- [ ] Add via **camera** → photo processed, colour auto-detected, name suggested
- [ ] Add via **gallery** (single)
- [ ] **Add several photos** (3+) → "New item 1 of N", Save & next, Skip works
- [ ] Back out mid-add → no orphan item appears
- [ ] Add a near-identical photo → "Looks similar to…" warning, can still save
- [ ] Edit item (incl. change photo) → changes persist
- [ ] Favourite toggle on detail screen
- [ ] Delete → Undo restores; delete again without undo → gone
- [ ] Search, category chips, filter sheet (season/occasion/colour/favourites), sort, grid/list toggle
- [ ] Deny camera/photo permission → clear message, no crash

## Outfits
- [ ] Builder: fill slots, remove a slot, Clear, Save → details sheet validates empty name
- [ ] Saved outfit opens detail; Edit, Duplicate, Delete + Undo
- [ ] "Create an outfit with this" from an item pre-fills the slot
- [ ] Share as image → share sheet with PNG
- [ ] Wear today / Plan on a date

## Suggestions
- [ ] With only tops → "Almost ready" card says what to add
- [ ] With tops + bottoms (+ shoes) → suggestions with "Why this works" reasons
- [ ] Cold/Rainy adds outerwear (or explains none exists)
- [ ] Changing weather/occasion updates suggestions
- [ ] After "Wear today", the same combo is ranked lower next time

## Calendar
- [ ] Month ↔ week toggle; markers on planned days
- [ ] Plan outfit on future day; mark worn on past/today; remove with confirm
- [ ] Today's outfit appears on Home

## Insights
- [ ] Counts match reality (items, outfits, days logged)
- [ ] Most/least/never worn update after marking worn

## Settings & data
- [ ] Light / Dark / System theme switch, no unreadable text in dark mode
- [ ] Export backup → .zip saved
- [ ] Clear all data (double confirm) → empty app
- [ ] Restore backup → everything back incl. photos
- [ ] Restore a random non-backup file → friendly error, data untouched

## Platform
- [ ] Android back: inner screens pop; from non-Home tab goes Home; from Home exits
- [ ] Airplane mode: every feature works; no ad space left blank/broken
- [ ] Small screen (5", 720p) and large font (Settings → Display → Font size max): no overflow
- [ ] Rotate / background / return during photo processing
- [ ] Debug build shows **test** ads only; ads never on onboarding, add/edit item, or builder
