import 'package:flutter_test/flutter_test.dart';
import 'package:outfitly/core/ads/ad_service.dart';

void main() {
  test('interstitial caps: launch grace, min gap and daily cap', () {
    var now = DateTime(2026, 11, 19, 9);
    final s = AdMobService(
      const AdConfig(bannerId: 'b', interstitialId: 'i'),
      clock: () => now,
    );
    expect(s.canShowNow(), isFalse, reason: 'grace period after launch');

    now = now.add(const Duration(minutes: 2));
    expect(s.canShowNow(), isTrue);
    s.recordShown();
    expect(s.canShowNow(), isFalse, reason: 'minimum gap');

    for (var i = 0; i < 2; i++) {
      now = now.add(const Duration(minutes: 4));
      expect(s.canShowNow(), isTrue);
      s.recordShown();
    }
    now = now.add(const Duration(minutes: 30));
    expect(s.canShowNow(), isFalse, reason: 'daily cap of 3 reached');

    now = DateTime(2026, 11, 20, 9);
    expect(s.canShowNow(), isTrue, reason: 'cap resets next day');
  });

  test('NoopAdService is inert', () async {
    const s = NoopAdService();
    expect(s.enabled, isFalse);
    await s.maybeShowInterstitial(AdTrigger.outfitSaved);
    expect(await s.privacyOptionsRequired, isFalse);
  });
}
