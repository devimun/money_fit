import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/config/ad_policy_config.dart';
import 'package:money_fit/core/services/ad_policy_service.dart';
import 'package:money_fit/core/services/prompt_coordinator.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';

/// Mobile Ads initialization is deliberately gated by UMP. Callers must not
/// load an ad until [initialize] returns true.
class AdService {
  static bool _initialized = false;
  static bool _canRequestAds = false;
  static AdPolicyConfig Function()? _policy;
  static AnalyticsService _analytics = const NoopAnalyticsService();

  static bool get canRequestAds => _canRequestAds;
  static void configurePolicy(AdPolicyConfig Function() policy) =>
      _policy = policy;
  static void configureAnalytics(AnalyticsService analytics) =>
      _analytics = analytics;
  static Future<void> track(
    AnalyticsEvent event,
    Map<String, Object?> values,
  ) => _analytics.track(event, values);
  static bool get bannerEnabled {
    final policy = _policy?.call();
    return _canRequestAds &&
        (policy?.masterEnabled ?? false) &&
        (policy?.bannerEnabled ?? false);
  }

  static Future<bool> initialize() async {
    if (_initialized) return _canRequestAds;
    try {
      final consent = ConsentInformation.instance;
      final completion = Completer<void>();
      consent.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        completion.complete,
        (_) => completion.complete(),
      );
      await completion.future;
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      _canRequestAds = await consent.canRequestAds();
      if (_canRequestAds) await MobileAds.instance.initialize();
    } catch (_) {
      _canRequestAds = false;
    } finally {
      _initialized = true;
    }
    return _canRequestAds;
  }

  /// Settings can expose this method wherever UMP reports an options entry.
  /// It is a no-op on regions where the form is not available.
  static Future<void> showPrivacyOptions() async {
    try {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await ConsentForm.showPrivacyOptionsForm((_) {});
      }
    } catch (_) {}
  }

  static const Map<ScreenType, String> _androidBannerIds = {
    ScreenType.home: 'ca-app-pub-4769455621618933/8690634882',
    ScreenType.calendar: 'ca-app-pub-4769455621618933/9888166487',
    ScreenType.settings: 'ca-app-pub-4769455621618933/1690445406',
    ScreenType.stats: 'ca-app-pub-4769455621618933/9537095506',
    ScreenType.expenses: 'ca-app-pub-4769455621618933/3003527071',
  };
  static const Map<ScreenType, String> _iosBannerIds = {
    ScreenType.home: 'ca-app-pub-4769455621618933/3825654152',
    ScreenType.calendar: 'ca-app-pub-4769455621618933/1870075669',
    ScreenType.settings: 'ca-app-pub-4769455621618933/9556993992',
    ScreenType.stats: 'ca-app-pub-4769455621618933/5901102823',
    ScreenType.expenses: 'ca-app-pub-4769455621618933/2277269778',
  };
  static const _testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitialAdId =
      'ca-app-pub-3940256099942544/4411468910';
  static const _iosReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/7377553211';
  static const _androidReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/8064282065';
  static const _androidTestAppOpenAdId =
      'ca-app-pub-3940256099942544/9257395921';
  static const _iosTestAppOpenAdId = 'ca-app-pub-3940256099942544/5575463023';
  static const _iosReleaseAppOpenAdId =
      'ca-app-pub-4769455621618933/7035055241';
  static const _androidReleaseAppOpenAdId =
      'ca-app-pub-4769455621618933/4879665193';

  static bool get isDebugMode => kDebugMode;
  static String bannerId(ScreenType screen) {
    if (isDebugMode) return _testBannerAdId;
    if (Platform.isAndroid) return _androidBannerIds[screen] ?? _testBannerAdId;
    if (Platform.isIOS) return _iosBannerIds[screen] ?? _testBannerAdId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return isDebugMode
          ? _androidTestInterstitialAdId
          : _androidReleaseInterstitialAdId;
    }
    if (Platform.isIOS) {
      return isDebugMode
          ? _iosTestInterstitialAdId
          : _iosReleaseInterstitialAdId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdId {
    if (Platform.isAndroid) {
      return isDebugMode ? _androidTestAppOpenAdId : _androidReleaseAppOpenAdId;
    }
    if (Platform.isIOS) {
      return isDebugMode ? _iosTestAppOpenAdId : _iosReleaseAppOpenAdId;
    }
    throw UnsupportedError('Unsupported platform');
  }
}

/// Owns one interstitial and keeps its coordinator lease through dismissal.
class InterstitialAdManager {
  static final InterstitialAdManager instance = InterstitialAdManager._();
  InterstitialAdManager._();

  InterstitialAd? _ad;
  AdPolicyService? _policy;
  AnalyticsService _analytics = const NoopAnalyticsService();
  bool _loading = false;
  bool _showing = false;
  PromptLease? _lease;
  DateTime? _shownAt;
  Completer<bool>? _showCompletion;

  void configure({
    required AdPolicyService policy,
    required AnalyticsService analytics,
  }) {
    _policy = policy;
    _analytics = analytics;
  }

  Future<void> loadAd() async {
    final policy = _policy;
    if (_loading || _ad != null || policy == null || !AdService.canRequestAds) {
      return;
    }
    final config = policy.policy;
    if (!config.masterEnabled || !config.interstitialEnabled) return;
    _loading = true;
    final started = DateTime.now();
    unawaited(
      _track(AnalyticsEvent.adRequest, {
        'ad_format': 'interstitial',
        'placement': 'natural_break',
      }),
    );
    await InterstitialAd.load(
      adUnitId: AdService.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
          _setCallbacks(ad);
          unawaited(
            _track(AnalyticsEvent.adLoadCompleted, {
              'ad_format': 'interstitial',
              'placement': 'natural_break',
              'result': 'success',
              'latency_ms': DateTime.now().difference(started).inMilliseconds,
            }),
          );
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          unawaited(
            _track(AnalyticsEvent.adLoadCompleted, {
              'ad_format': 'interstitial',
              'placement': 'natural_break',
              'result': 'failure',
              'latency_ms': DateTime.now().difference(started).inMilliseconds,
              'error_code': error.code,
              'error_domain': error.domain,
            }),
          );
        },
      ),
    );
  }

  Future<bool> recordMeaningfulAction(String trigger) async {
    final policy = _policy;
    if (policy == null) return false;
    final recorded = await policy.recordMeaningfulAction(trigger);
    if (recorded) {
      unawaited(
        _track(AnalyticsEvent.adActionRecorded, {
          'trigger': trigger,
          'action_count': policy.actionCount,
          'ad_policy_version': policy.policy.policyVersion,
        }),
      );
    }
    return recorded;
  }

  /// Deprecated compatibility shim. It only records an action; callers must
  /// explicitly choose a safe opportunity before an ad can be shown.
  Future<bool> logActionAndShowAd() => recordMeaningfulAction('legacy');

  Future<bool> maybeShowInterstitial(
    String opportunity, {
    required PromptCoordinator coordinator,
  }) async {
    final policy = _policy;
    if (policy == null) return false;
    final eligibility = policy.interstitialEligibility(
      consentReady: AdService.canRequestAds,
    );
    if (!eligibility.allowed) {
      _opportunity(opportunity, eligibility.reason);
      return false;
    }
    if (_ad == null) {
      _opportunity(opportunity, AdSuppressionReason.adNotReady);
      unawaited(loadAd());
      return false;
    }
    if (_showing) {
      _opportunity(opportunity, AdSuppressionReason.fullscreenUiBusy);
      return false;
    }
    final lease = coordinator.tryAcquire(PromptSurface.interstitialAd);
    if (lease == null) {
      _opportunity(opportunity, AdSuppressionReason.fullscreenUiBusy);
      return false;
    }
    _opportunity(opportunity, null);
    _lease = lease;
    _showing = true;
    final completion = Completer<bool>();
    _showCompletion = completion;
    try {
      await _ad!.show();
      // `show` only confirms that the SDK accepted the request. Keeping the
      // Future pending until the full-screen callback has dismissed the ad
      // lets navigation callers wait for their natural break to complete.
      return await completion.future;
    } catch (_) {
      _showing = false;
      _lease?.release();
      _lease = null;
      if (!completion.isCompleted) completion.complete(false);
      if (identical(_showCompletion, completion)) _showCompletion = null;
      unawaited(
        _track(AnalyticsEvent.adDisplayFailed, {
          'ad_format': 'interstitial',
          'placement': 'natural_break',
          'error_code': 'show_exception',
        }),
      );
      return false;
    }
  }

  void _setCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => unawaited(_onShown()),
      onAdImpression: (_) => unawaited(
        _track(AnalyticsEvent.adImpression, {
          'ad_format': 'interstitial',
          'placement': 'natural_break',
          'ad_policy_version': _policy?.policy.policyVersion ?? 'unknown',
        }),
      ),
      onAdClicked: (_) => unawaited(
        _track(AnalyticsEvent.adClicked, {
          'ad_format': 'interstitial',
          'placement': 'natural_break',
        }),
      ),
      onAdDismissedFullScreenContent: (ad) => unawaited(_finish(ad)),
      onAdFailedToShowFullScreenContent: (ad, error) =>
          unawaited(_finish(ad, errorCode: error.code)),
    );
    ad.onPaidEvent = (ad, value, precision, currencyCode) {
      unawaited(
        _track(AnalyticsEvent.adRevenueTracked, {
          'ad_format': 'interstitial',
          'placement': 'natural_break',
          'value_micros': value,
          'currency_code': currencyCode,
          'precision': precision.name,
        }),
      );
    };
  }

  Future<void> _onShown() async {
    _shownAt = DateTime.now();
    await _policy?.recordFullscreenShown();
    await _track(AnalyticsEvent.adDisplayed, {
      'ad_format': 'interstitial',
      'placement': 'natural_break',
      'ad_policy_version': _policy?.policy.policyVersion ?? 'unknown',
    });
  }

  Future<void> _finish(InterstitialAd ad, {Object? errorCode}) async {
    ad.dispose();
    _ad = null;
    _showing = false;
    _lease?.release();
    _lease = null;
    if (errorCode != null) {
      await _track(AnalyticsEvent.adDisplayFailed, {
        'ad_format': 'interstitial',
        'placement': 'natural_break',
        'error_code': '$errorCode',
      });
    } else if (_shownAt != null) {
      await _track(AnalyticsEvent.adDismissed, {
        'ad_format': 'interstitial',
        'placement': 'natural_break',
        'visible_duration_ms': DateTime.now()
            .difference(_shownAt!)
            .inMilliseconds,
      });
    }
    _shownAt = null;
    if (!(_showCompletion?.isCompleted ?? true)) {
      _showCompletion!.complete(errorCode == null);
    }
    _showCompletion = null;
    await loadAd();
  }

  void _opportunity(String opportunity, AdSuppressionReason? reason) {
    unawaited(
      _track(AnalyticsEvent.adOpportunity, {
        'opportunity': opportunity,
        'eligible': reason == null,
        if (reason != null) 'suppress_reason': reason.value,
        'ad_policy_version': _policy?.policy.policyVersion ?? 'unknown',
      }),
    );
  }

  Future<void> _track(AnalyticsEvent event, Map<String, Object?> values) =>
      _analytics.track(event, values);
  void dispose() => _ad?.dispose();
}

/// App-open remains disabled by the control policy. It never defers a show:
/// an ad that loads after content is visible is simply saved for a later valid
/// foreground opportunity.
class AppOpenAdManager {
  static final AppOpenAdManager instance = AppOpenAdManager._();
  AppOpenAdManager._();

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  bool _loading = false;
  bool _showing = false;
  AdPolicyService? _policy;
  AnalyticsService _analytics = const NoopAnalyticsService();
  PromptLease? _lease;
  DateTime? _shownAt;
  final Duration _maxCacheAge = const Duration(hours: 4);

  bool get isAvailable =>
      _ad != null &&
      _loadedAt != null &&
      DateTime.now().difference(_loadedAt!) < _maxCacheAge;

  void configure({
    required AdPolicyService policy,
    required AnalyticsService analytics,
  }) {
    _policy = policy;
    _analytics = analytics;
  }

  Future<void> loadAd() async {
    if (_loading ||
        isAvailable ||
        !AdService.canRequestAds ||
        !(_policy?.policy.masterEnabled ?? false) ||
        !(_policy?.policy.appOpenEnabled ?? false)) {
      return;
    }
    _loading = true;
    final started = DateTime.now();
    unawaited(
      _analytics.track(AnalyticsEvent.adRequest, {
        'ad_format': 'app_open',
        'placement': 'foreground',
      }),
    );
    await AppOpenAd.load(
      adUnitId: AdService.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
          _loading = false;
          unawaited(
            _analytics.track(AnalyticsEvent.adLoadCompleted, {
              'ad_format': 'app_open',
              'placement': 'foreground',
              'result': 'success',
              'latency_ms': DateTime.now().difference(started).inMilliseconds,
            }),
          );
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _loadedAt = null;
          _loading = false;
          unawaited(
            _analytics.track(AnalyticsEvent.adLoadCompleted, {
              'ad_format': 'app_open',
              'placement': 'foreground',
              'result': 'failure',
              'latency_ms': DateTime.now().difference(started).inMilliseconds,
              'error_code': error.code,
              'error_domain': error.domain,
            }),
          );
        },
      ),
    );
  }

  /// Called only from an app lifecycle observer after a confirmed foreground
  /// transition. A late-loaded ad is never shown by this method.
  Future<bool> maybeShowAppOpen({
    required Duration backgroundDuration,
    required PromptCoordinator coordinator,
  }) async {
    final policy = _policy;
    if (policy == null ||
        backgroundDuration < policy.policy.appOpenMinBackground) {
      return false;
    }
    final eligibility = policy.appOpenEligibility(
      consentReady: AdService.canRequestAds,
    );
    if (!eligibility.allowed || !isAvailable || _showing) return false;
    final lease = coordinator.tryAcquire(PromptSurface.appOpenAd);
    if (lease == null) return false;
    _lease = lease;
    _showing = true;
    final ad = _ad!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => unawaited(_onShown()),
      onAdImpression: (_) => unawaited(
        _analytics.track(AnalyticsEvent.adImpression, {
          'ad_format': 'app_open',
          'placement': 'foreground',
          'ad_policy_version': _policy?.policy.policyVersion ?? 'unknown',
        }),
      ),
      onAdClicked: (_) => unawaited(
        _analytics.track(AnalyticsEvent.adClicked, {
          'ad_format': 'app_open',
          'placement': 'foreground',
        }),
      ),
      onAdDismissedFullScreenContent: (shownAd) => unawaited(_finish(shownAd)),
      onAdFailedToShowFullScreenContent: (shownAd, error) =>
          unawaited(_finish(shownAd, errorCode: error.code)),
    );
    ad.onPaidEvent = (ad, value, precision, currencyCode) {
      unawaited(
        _analytics.track(AnalyticsEvent.adRevenueTracked, {
          'ad_format': 'app_open',
          'placement': 'foreground',
          'value_micros': value,
          'currency_code': currencyCode,
          'precision': precision.name,
        }),
      );
    };
    try {
      await ad.show();
      return true;
    } catch (_) {
      _showing = false;
      _lease?.release();
      _lease = null;
      return false;
    }
  }

  Future<void> _onShown() async {
    _shownAt = DateTime.now();
    await _policy?.recordFullscreenShown();
    await _analytics.track(AnalyticsEvent.adDisplayed, {
      'ad_format': 'app_open',
      'placement': 'foreground',
      'ad_policy_version': _policy?.policy.policyVersion ?? 'unknown',
    });
  }

  Future<void> _finish(AppOpenAd ad, {Object? errorCode}) async {
    ad.dispose();
    _ad = null;
    _loadedAt = null;
    _showing = false;
    _lease?.release();
    _lease = null;
    if (errorCode != null) {
      await _analytics.track(AnalyticsEvent.adDisplayFailed, {
        'ad_format': 'app_open',
        'placement': 'foreground',
        'error_code': '$errorCode',
      });
    } else if (_shownAt != null) {
      await _analytics.track(AnalyticsEvent.adDismissed, {
        'ad_format': 'app_open',
        'placement': 'foreground',
        'visible_duration_ms': DateTime.now()
            .difference(_shownAt!)
            .inMilliseconds,
      });
    }
    _shownAt = null;
    await loadAd();
  }

  Future<void> dispose() async {
    _ad?.dispose();
    _ad = null;
  }
}
