import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/monetization/application/ad_policy_service.dart';
import 'package:money_fit/features/monetization/application/ad_telemetry.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';
import 'package:money_fit/features/monetization/data/remote_config_ad_policy_reader.dart';
import 'package:money_fit/features/monetization/data/shared_preferences_ad_frequency_state_store.dart';
import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';

/// The common Remote Config owner supplies lifecycle and local fallbacks.
/// Monetization only reads its active snapshot and never alters SDK settings.
final adPolicyReaderProvider = Provider<AdPolicyReader>(
  (ref) => RemoteConfigAdPolicyReader(ref.watch(remoteConfigReaderProvider)),
);

final adPolicyProvider = Provider<AdPolicy>(
  (ref) => AdPolicy.fromReader(ref.watch(adPolicyReaderProvider)),
);

final adFrequencyStateStoreProvider = Provider<AdFrequencyStateStore>(
  (ref) => SharedPreferencesAdFrequencyStateStore(
    ref.watch(sharedPreferencesProvider),
  ),
);

final adPolicyServiceProvider = Provider<AdPolicyService>(
  (ref) => AdPolicyService(
    ref.watch(adFrequencyStateStoreProvider),
    () => ref.read(adPolicyProvider),
    now: ref.watch(clockProvider).now,
  ),
);

final adTelemetryProvider = Provider<AdTelemetry>(
  (ref) => AnalyticsTrackerAdTelemetry(ref.watch(analyticsTrackerProvider)),
);

final googleMobileAdsGatewayProvider = Provider<GoogleMobileAdsGateway>(
  (ref) => GoogleMobileAdsGateway(),
);

/// Bootstrap must call this only after local routing is usable. It is
/// idempotent, UMP-gated, and failure is intentionally advertising-only.
final monetizationStartupProvider = Provider<Future<void> Function()>((ref) {
  final gateway = ref.watch(googleMobileAdsGatewayProvider);
  final policyService = ref.watch(adPolicyServiceProvider);
  final telemetry = ref.watch(adTelemetryProvider);
  final manager = InterstitialAdManager.instance
    ..configure(
      gateway: gateway,
      policyService: policyService,
      telemetry: telemetry,
    );
  AdService.configure(
    gateway: gateway,
    policy: () => ref.read(adPolicyProvider),
    telemetry: telemetry,
  );

  Future<void>? starting;
  return () => starting ??= () async {
    final policy = ref.read(adPolicyProvider);
    for (final key in policy.invalidKeys) {
      unawaited(
        AdService.track(AdTelemetryEvent.configInvalid, <String, Object>{
          'key': key,
          'value_source': 'remote_config',
          'ad_policy_version': policy.version,
        }),
      );
    }
    await manager.initialize();
  }();
});

/// Successful operations call this after persistence/navigation succeeds.
/// It has no display side effect, so feedback, consent, update, reset, and
/// failed-form flows remain ad-free by construction.
final monetizationActionRecorderProvider =
    Provider<Future<bool> Function(MeaningfulAdAction)>((ref) {
      final manager = InterstitialAdManager.instance;
      return manager.recordSuccessfulMeaningfulAction;
    });

/// Records a completed user action, then offers an interstitial only at a
/// natural break. The shared coordinator prevents any overlap with review,
/// feedback, update, or permission prompts.
final monetizationSafePointProvider =
    Provider<Future<void> Function(MeaningfulAdAction)>((ref) {
      final manager = InterstitialAdManager.instance;
      final recorder = ref.watch(monetizationActionRecorderProvider);
      final remoteConfig = ref.watch(remoteConfigReaderProvider);
      final gate = PromptCoordinatorInterstitialGate(
        ref.watch(promptCoordinatorProvider),
        quietPeriod: _quietPeriod(
          remoteConfig.intValue('proactive_fullscreen_quiet_seconds'),
        ),
      );

      return (action) async {
        try {
          if (!await recorder(action)) return;
          await manager.maybeShowAtSafePoint(action.trigger, gate: gate);
        } catch (_) {
          // Advertising is optional after a successful local command.
        }
      };
    });

final monetizationStateClearerProvider = Provider<Future<void> Function()>(
  (ref) => ref.read(adPolicyServiceProvider).clear,
);

Duration _quietPeriod(int seconds) =>
    Duration(seconds: seconds.clamp(0, 86400).toInt());

/// Ad adapter for the app-wide full-screen prompt arbiter.
class PromptCoordinatorInterstitialGate implements FullscreenExperienceGate {
  const PromptCoordinatorInterstitialGate(
    this._coordinator, {
    this.quietPeriod = Duration.zero,
  });

  final PromptCoordinator _coordinator;
  final Duration quietPeriod;

  @override
  Future<FullscreenExperienceLease?> tryAcquireInterstitial() async {
    final lease = _coordinator.tryAcquire(
      PromptSurface.interstitialAd,
      quietPeriod: quietPeriod,
    );
    return lease == null ? null : _PromptCoordinatorFullscreenLease(lease);
  }
}

class _PromptCoordinatorFullscreenLease implements FullscreenExperienceLease {
  const _PromptCoordinatorFullscreenLease(this._lease);

  final PromptLease _lease;

  @override
  void release() => _lease.release();
}
