import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/features/monetization/application/ad_policy_service.dart';
import 'package:money_fit/features/monetization/application/ad_telemetry.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';

enum AdPlacement { home, calendar, expenses, stats, settings }

abstract interface class MobileAdsConsentSdk {
  Future<void> requestConsentInfoUpdate();

  Future<void> loadAndShowConsentFormIfRequired();

  Future<bool> canRequestAds();

  Future<void> initializeMobileAds();

  Future<bool> isPrivacyOptionsFormAvailable();

  Future<void> showPrivacyOptionsForm();
}

class GoogleMobileAdsConsentSdk implements MobileAdsConsentSdk {
  const GoogleMobileAdsConsentSdk();

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<void> initializeMobileAds() async {
    await MobileAds.instance.initialize();
  }

  @override
  Future<bool> isPrivacyOptionsFormAvailable() =>
      ConsentInformation.instance.isConsentFormAvailable();

  @override
  Future<void> loadAndShowConsentFormIfRequired() {
    final completion = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((_) => completion.complete());
    return completion.future;
  }

  @override
  Future<void> requestConsentInfoUpdate() {
    final completion = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      completion.complete,
      (_) => completion.complete(),
    );
    return completion.future;
  }

  @override
  Future<void> showPrivacyOptionsForm() {
    final completion = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) => completion.complete());
    return completion.future;
  }
}

/// The only Mobile Ads SDK boundary. UMP must grant [canRequestAds] before
/// this adapter initializes the SDK or a caller requests an ad.
class GoogleMobileAdsGateway {
  GoogleMobileAdsGateway({MobileAdsConsentSdk? sdk})
    : _sdk = sdk ?? const GoogleMobileAdsConsentSdk();

  final MobileAdsConsentSdk _sdk;
  Future<bool>? _initializing;
  bool _initialized = false;
  bool _canRequestAds = false;

  bool get canRequestAds => _canRequestAds;

  Future<bool> initialize() {
    if (_initialized) return Future<bool>.value(_canRequestAds);
    return _initializing ??= _initialize();
  }

  Future<bool> _initialize() async {
    try {
      await _sdk.requestConsentInfoUpdate();
      await _sdk.loadAndShowConsentFormIfRequired();
      _canRequestAds = await _sdk.canRequestAds();
      if (_canRequestAds) await _sdk.initializeMobileAds();
    } catch (_) {
      // A failed UMP flow is fail-closed for advertising but not for the app.
      _canRequestAds = false;
    } finally {
      _initialized = true;
      _initializing = null;
    }
    return _canRequestAds;
  }

  /// Settings can invoke this when UMP exposes a privacy-options entry point.
  Future<void> showPrivacyOptions() async {
    try {
      if (await _sdk.isPrivacyOptionsFormAvailable()) {
        await _sdk.showPrivacyOptionsForm();
      }
    } catch (_) {
      // The form is optional and must not disrupt settings.
    }
  }
}

/// Compatibility façade for the pre-refactor bootstrap and banner widgets.
/// New composition should inject [GoogleMobileAdsGateway] through
/// `monetization_providers.dart` rather than introducing another SDK singleton.
class AdService {
  static GoogleMobileAdsGateway _gateway = GoogleMobileAdsGateway();
  static AdPolicy Function() _policy = () => AdPolicy.defaults;
  static AdTelemetry _telemetry = const NoopAdTelemetry();

  static bool get canRequestAds => _gateway.canRequestAds;
  static GoogleMobileAdsGateway get gateway => _gateway;

  static void configure({
    required GoogleMobileAdsGateway gateway,
    required AdPolicy Function() policy,
    required AdTelemetry telemetry,
  }) {
    _gateway = gateway;
    _policy = policy;
    _telemetry = telemetry;
  }

  static Future<bool> initialize() async {
    final canRequestAds = await _gateway.initialize();
    final policy = _policy();
    await track(AdTelemetryEvent.opportunity, <String, Object>{
      'opportunity': 'sdk_initialization',
      'eligible': canRequestAds && policy.masterEnabled,
      if (!canRequestAds)
        'suppress_reason': AdSuppressionReason.consentNotReady.value,
      if (canRequestAds && !policy.masterEnabled)
        'suppress_reason': AdSuppressionReason.masterDisabled.value,
      'ad_policy_version': policy.version,
    });
    return canRequestAds;
  }

  static Future<void> showPrivacyOptions() => _gateway.showPrivacyOptions();

  static bool get bannerEnabled {
    final policy = _policy();
    return canRequestAds && policy.masterEnabled && policy.bannerEnabled;
  }

  static AdSuppressionReason? get bannerSuppressionReason {
    final policy = _policy();
    if (!canRequestAds) return AdSuppressionReason.consentNotReady;
    if (!policy.masterEnabled) return AdSuppressionReason.masterDisabled;
    if (!policy.bannerEnabled) return AdSuppressionReason.formatDisabled;
    return null;
  }

  static Future<void> track(
    String event,
    Map<String, Object> attributes,
  ) async {
    try {
      await _telemetry.track(event, attributes);
    } catch (_) {
      // Telemetry must never prevent an ad decision or a local app action.
    }
  }

  static const Map<AdPlacement, String> _androidBannerIds = {
    AdPlacement.home: 'ca-app-pub-4769455621618933/8690634882',
    AdPlacement.calendar: 'ca-app-pub-4769455621618933/9888166487',
    AdPlacement.settings: 'ca-app-pub-4769455621618933/1690445406',
    AdPlacement.stats: 'ca-app-pub-4769455621618933/9537095506',
    AdPlacement.expenses: 'ca-app-pub-4769455621618933/3003527071',
  };
  static const Map<AdPlacement, String> _iosBannerIds = {
    AdPlacement.home: 'ca-app-pub-4769455621618933/3825654152',
    AdPlacement.calendar: 'ca-app-pub-4769455621618933/1870075669',
    AdPlacement.settings: 'ca-app-pub-4769455621618933/9556993992',
    AdPlacement.stats: 'ca-app-pub-4769455621618933/5901102823',
    AdPlacement.expenses: 'ca-app-pub-4769455621618933/2277269778',
  };
  static const _androidTestBannerAdId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _iosTestBannerAdId = 'ca-app-pub-3940256099942544/2934735716';
  static const _androidTestInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitialAdId =
      'ca-app-pub-3940256099942544/4411468910';
  static const _iosReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/7377553211';
  static const _androidReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/8064282065';

  static bool get isDebugMode => kDebugMode;

  static String bannerId(AdPlacement placement) {
    if (isDebugMode) {
      return Platform.isIOS ? _iosTestBannerAdId : _androidTestBannerAdId;
    }
    if (Platform.isAndroid) {
      return _androidBannerIds[placement] ?? _androidTestBannerAdId;
    }
    if (Platform.isIOS) return _iosBannerIds[placement] ?? _iosTestBannerAdId;
    return _androidTestBannerAdId;
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
    return _androidTestInterstitialAdId;
  }
}

/// Owns a single interstitial. The only public display method requires a
/// safe opportunity and a full-screen lease; action recording is separate.
class InterstitialAdManager {
  InterstitialAdManager({GoogleMobileAdsGateway? gateway})
    : _gateway = gateway ?? GoogleMobileAdsGateway();

  static final instance = InterstitialAdManager();

  GoogleMobileAdsGateway _gateway;
  AdPolicyService? _policyService;
  AdTelemetry _telemetry = const NoopAdTelemetry();
  InterstitialAd? _ad;
  bool _loading = false;
  bool _showing = false;
  FullscreenExperienceLease? _lease;
  DateTime? _shownAt;
  Completer<bool>? _showCompletion;

  void configure({
    required GoogleMobileAdsGateway gateway,
    required AdPolicyService policyService,
    required AdTelemetry telemetry,
  }) {
    _gateway = gateway;
    _policyService = policyService;
    _telemetry = telemetry;
  }

  Future<void> initialize() async {
    final policy = _policyService;
    if (policy == null) return;
    await policy.initializeSession();
    await _gateway.initialize();
    await loadAd();
  }

  Future<void> loadAd() async {
    final policy = _policyService;
    if (_loading || _ad != null || policy == null || !_gateway.canRequestAds) {
      return;
    }
    final config = policy.policy;
    if (!config.masterEnabled || !config.interstitialEnabled) return;
    _loading = true;
    final startedAt = DateTime.now();
    unawaited(
      _track(AdTelemetryEvent.request, <String, Object>{
        'ad_format': 'interstitial',
        'placement': 'natural_break',
        'ad_policy_version': config.version,
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
            _track(AdTelemetryEvent.loadCompleted, <String, Object>{
              'ad_format': 'interstitial',
              'placement': 'natural_break',
              'result': 'success',
              'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
            }),
          );
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          unawaited(
            _track(AdTelemetryEvent.loadCompleted, <String, Object>{
              'ad_format': 'interstitial',
              'placement': 'natural_break',
              'result': 'failure',
              'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
              'error_code': error.code,
              'error_domain': error.domain,
            }),
          );
        },
      ),
    );
  }

  Future<bool> recordSuccessfulMeaningfulAction(
    MeaningfulAdAction action,
  ) async {
    final policy = _policyService;
    if (policy == null) return false;
    final recorded = await policy.recordSuccessfulMeaningfulAction(action);
    if (recorded) {
      await _track(AdTelemetryEvent.actionRecorded, <String, Object>{
        'trigger': action.trigger,
        'action_count': await _actionCount(policy),
        'ad_policy_version': policy.policy.version,
      });
    }
    return recorded;
  }

  /// Legacy call sites may invoke this during a transition. It deliberately
  /// records only an action and can never create an interstitial by itself.
  @Deprecated('Use recordSuccessfulMeaningfulAction after success.')
  Future<bool> logActionAndShowAd() =>
      recordSuccessfulMeaningfulAction(MeaningfulAdAction.legacy);

  Future<bool> maybeShowAtSafePoint(
    String opportunity, {
    required FullscreenExperienceGate gate,
  }) async {
    final policy = _policyService;
    if (policy == null) {
      await _opportunity(opportunity, AdSuppressionReason.notConfigured);
      return false;
    }
    final eligibility = await policy.interstitialEligibility(
      canRequestAds: _gateway.canRequestAds,
    );
    if (!eligibility.allowed) {
      await _opportunity(opportunity, eligibility.reason!);
      return false;
    }
    if (_ad == null) {
      await _opportunity(opportunity, AdSuppressionReason.adNotReady);
      unawaited(loadAd());
      return false;
    }
    if (_showing) {
      await _opportunity(opportunity, AdSuppressionReason.fullscreenUiBusy);
      return false;
    }
    final lease = await gate.tryAcquireInterstitial();
    if (lease == null) {
      await _opportunity(opportunity, AdSuppressionReason.fullscreenUiBusy);
      return false;
    }

    await _opportunity(opportunity, null);
    _lease = lease;
    _showing = true;
    final completion = Completer<bool>();
    _showCompletion = completion;
    try {
      await _ad!.show();
      return await completion.future;
    } catch (_) {
      _showing = false;
      _releaseLease();
      if (!completion.isCompleted) completion.complete(false);
      if (identical(_showCompletion, completion)) _showCompletion = null;
      await _track(AdTelemetryEvent.displayFailed, <String, Object>{
        'ad_format': 'interstitial',
        'placement': 'natural_break',
        'error_code': 'show_exception',
      });
      return false;
    }
  }

  void _setCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => unawaited(_onShown()),
      onAdImpression: (_) => unawaited(
        _track(AdTelemetryEvent.impression, <String, Object>{
          'ad_format': 'interstitial',
          'placement': 'natural_break',
          'ad_policy_version': _policyService?.policy.version ?? 'unknown',
        }),
      ),
      onAdClicked: (_) => unawaited(
        _track(AdTelemetryEvent.clicked, <String, Object>{
          'ad_format': 'interstitial',
          'placement': 'natural_break',
        }),
      ),
      onAdDismissedFullScreenContent: (shownAd) => unawaited(_finish(shownAd)),
      onAdFailedToShowFullScreenContent: (shownAd, error) =>
          unawaited(_finish(shownAd, errorCode: error.code)),
    );
    ad.onPaidEvent = (_, value, precision, currencyCode) {
      unawaited(
        _track(AdTelemetryEvent.revenueTracked, <String, Object>{
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
    await _policyService?.recordFullscreenShown();
    await _track(AdTelemetryEvent.displayed, <String, Object>{
      'ad_format': 'interstitial',
      'placement': 'natural_break',
      'ad_policy_version': _policyService?.policy.version ?? 'unknown',
    });
  }

  Future<void> _finish(InterstitialAd ad, {Object? errorCode}) async {
    ad.dispose();
    _ad = null;
    _showing = false;
    _releaseLease();
    if (errorCode != null) {
      await _track(AdTelemetryEvent.displayFailed, <String, Object>{
        'ad_format': 'interstitial',
        'placement': 'natural_break',
        'error_code': '$errorCode',
      });
    } else if (_shownAt != null) {
      await _track(AdTelemetryEvent.dismissed, <String, Object>{
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

  Future<void> _opportunity(String opportunity, AdSuppressionReason? reason) {
    return _track(AdTelemetryEvent.opportunity, <String, Object>{
      'opportunity': opportunity,
      'eligible': reason == null,
      if (reason != null) 'suppress_reason': reason.value,
      'ad_policy_version': _policyService?.policy.version ?? 'unknown',
    });
  }

  Future<int> _actionCount(AdPolicyService policy) async {
    return policy.pendingMeaningfulActionCount();
  }

  Future<void> _track(String event, Map<String, Object> attributes) async {
    try {
      await _telemetry.track(event, attributes);
    } catch (_) {
      // Optional telemetry must not alter ad behaviour.
    }
  }

  void _releaseLease() {
    _lease?.release();
    _lease = null;
  }

  /// Compatibility entry point used by the current engagement resetter.
  void resetCounters() {
    unawaited(_policyService?.clear() ?? Future<void>.value());
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
    _releaseLease();
  }
}
