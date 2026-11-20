import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Where a banner may appear. Creation/editing screens are deliberately absent.
enum AdPlacement { wardrobe, analytics, calendar, community }

/// Natural breaks where an interstitial *may* be shown (subject to caps).
enum AdTrigger { outfitSaved, leftAnalytics }

/// Ad unit configuration. Debug builds always use Google's public test units.
/// Release builds read real IDs from `--dart-define`; if absent, ads are disabled.
class AdConfig {
  const AdConfig({required this.bannerId, required this.interstitialId});
  final String bannerId;
  final String interstitialId;

  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  static AdConfig? resolve() {
    if (kDebugMode || kProfileMode) {
      return const AdConfig(bannerId: _testBanner, interstitialId: _testInterstitial);
    }
    const banner = String.fromEnvironment('ADMOB_BANNER_ID');
    const inter = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
    if (banner.isEmpty || inter.isEmpty) return null;
    return const AdConfig(bannerId: banner, interstitialId: inter);
  }
}

abstract class AdService {
  Future<void> init();
  bool get enabled;
  Widget banner(AdPlacement placement);
  Future<void> maybeShowInterstitial(AdTrigger trigger);
  Future<bool> get privacyOptionsRequired;
  Future<void> showPrivacyOptions();
}

/// Used when ads are unconfigured, consent denies them, init fails, or the user is premium.
class NoopAdService implements AdService {
  const NoopAdService();
  @override
  Future<void> init() async {}
  @override
  bool get enabled => false;
  @override
  Widget banner(AdPlacement placement) => const SizedBox.shrink();
  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {}
  @override
  Future<bool> get privacyOptionsRequired async => false;
  @override
  Future<void> showPrivacyOptions() async {}
}

class AdMobService implements AdService {
  AdMobService(this.config, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AdConfig config;
  final DateTime Function() _now;
  bool _ready = false;
  InterstitialAd? _interstitial;

  // Frequency caps.
  static const minGap = Duration(minutes: 3);
  static const dailyCap = 3;
  static const graceAfterLaunch = Duration(seconds: 60);
  late final DateTime _launchedAt = _now();
  DateTime? _lastShown;
  int _shownToday = 0;
  DateTime _day = DateTime.now();

  @override
  bool get enabled => _ready;

  @override
  Future<void> init() async {
    try {
      final consent = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!consent.isCompleted) consent.complete();
        },
        (_) {
          if (!consent.isCompleted) consent.complete();
        },
      );
      await consent.future.timeout(const Duration(seconds: 15), onTimeout: () {});
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _ready = true;
      _loadInterstitial();
    } catch (e) {
      debugPrint('Ads disabled: $e');
      _ready = false;
    }
  }

  void _loadInterstitial() {
    if (!_ready) return;
    InterstitialAd.load(
      adUnitId: config.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) => _interstitial = ad, onAdFailedToLoad: (_) => _interstitial = null),
    );
  }

  /// Pure cap logic, exposed for tests.
  @visibleForTesting
  bool canShowNow() {
    final now = _now();
    if (now.difference(_launchedAt) < graceAfterLaunch) return false;
    if (!DateUtils.isSameDay(now, _day)) {
      _day = now;
      _shownToday = 0;
    }
    if (_shownToday >= dailyCap) return false;
    if (_lastShown != null && now.difference(_lastShown!) < minGap) return false;
    return true;
  }

  @visibleForTesting
  void recordShown() {
    _lastShown = _now();
    _shownToday++;
  }

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {
    final ad = _interstitial;
    if (!_ready || ad == null || !canShowNow()) return;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
      },
    );
    recordShown();
    await ad.show();
  }

  @override
  Widget banner(AdPlacement placement) => _ready ? _BannerSlot(adUnitId: config.bannerId) : const SizedBox.shrink();

  @override
  Future<bool> get privacyOptionsRequired async {
    try {
      return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() => ConsentForm.showPrivacyOptionsForm((_) {});
}

class _BannerSlot extends StatefulWidget {
  const _BannerSlot({required this.adUnitId});
  final String adUnitId;

  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
