/// What the current user is allowed to do.
///
/// v1.0 ships [FreeEntitlements] only. A billing-backed implementation
/// (Google Play Billing via `in_app_purchase`) will replace it in a later release;
/// nothing in the app pretends a purchase is possible today.
abstract class Entitlements {
  bool get isPremium;
  int get maxItems;
  int get maxOutfits;
  bool get advancedStats;
  bool get showAds;
}

class FreeEntitlements implements Entitlements {
  const FreeEntitlements();
  @override
  bool get isPremium => false;
  @override
  int get maxItems => 150;
  @override
  int get maxOutfits => 50;
  @override
  bool get advancedStats => false;
  @override
  bool get showAds => true;
}

class LimitReached implements Exception {
  LimitReached(this.message);
  final String message;
  @override
  String toString() => message;
}
