import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/monetization/application/ad_policy_service.dart';
import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';

void main() {
  test(
    'activated Remote Config updates change ad eligibility without a restart',
    () async {
      var now = DateTime.utc(2026, 7, 28, 12);
      final client = _FakeRemoteConfigClient();
      final remoteConfig = RemoteConfigService(client);
      await remoteConfig.initialize();
      final container = ProviderContainer(
        overrides: [
          remoteConfigServiceProvider.overrideWithValue(remoteConfig),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(remoteConfig.dispose);
      addTearDown(client.dispose);

      // Start the stream-backed policy dependency before publishing updates.
      expect(container.read(adPolicyProvider).masterEnabled, isTrue);
      await Future<void>.delayed(Duration.zero);

      final store = _MemoryFrequencyStateStore(
        AdFrequencyState(
          sessionStartedAt: now.subtract(const Duration(minutes: 5)),
          sessionNumber: 1,
          fullscreenShownThisSession: 1,
          pendingMeaningfulActions: 6,
          lastFullscreenShownAt: now.subtract(const Duration(seconds: 300)),
          fullscreenHistory: [now.subtract(const Duration(hours: 1))],
        ),
      );
      final policyService = AdPolicyService(
        store,
        () => container.read(adPolicyProvider),
        now: () => now,
      );

      expect(
        (await policyService.interstitialEligibility(
          canRequestAds: true,
        )).allowed,
        isTrue,
      );

      await _activate(
        client: client,
        remoteConfig: remoteConfig,
        container: container,
        values: const {'ads_master_enabled': 'false'},
        matches: (policy) => !policy.masterEnabled,
      );
      expect(
        (await policyService.interstitialEligibility(
          canRequestAds: true,
        )).reason,
        AdSuppressionReason.masterDisabled,
      );

      await _activate(
        client: client,
        remoteConfig: remoteConfig,
        container: container,
        values: const {
          'ads_master_enabled': 'true',
          'ads_fullscreen_max_per_session': '1',
        },
        matches: (policy) => policy.maxFullscreenPerSession == 1,
      );
      expect(
        (await policyService.interstitialEligibility(
          canRequestAds: true,
        )).reason,
        AdSuppressionReason.sessionCap,
      );

      await _activate(
        client: client,
        remoteConfig: remoteConfig,
        container: container,
        values: const {
          'ads_fullscreen_max_per_session': '3',
          'ads_interstitial_cooldown_seconds': '600',
        },
        matches: (policy) =>
            policy.maxFullscreenPerSession == 3 &&
            policy.interstitialCooldown == const Duration(seconds: 600),
      );
      expect(
        (await policyService.interstitialEligibility(
          canRequestAds: true,
        )).reason,
        AdSuppressionReason.cooldown,
      );

      final invalid = await _activate(
        client: client,
        remoteConfig: remoteConfig,
        container: container,
        values: const {'ads_interstitial_cooldown_seconds': 'not-a-number'},
        matches: (policy) =>
            policy.invalidKeys.contains('ads_interstitial_cooldown_seconds'),
      );
      expect(invalid.interstitialCooldown, const Duration(seconds: 300));
      expect(
        (await policyService.interstitialEligibility(
          canRequestAds: true,
        )).allowed,
        isTrue,
      );
      expect(store.state.fullscreenShownThisSession, 1);
      expect(store.state.fullscreenHistory, [
        now.subtract(const Duration(hours: 1)),
      ]);
    },
  );
}

Future<AdPolicy> _activate({
  required _FakeRemoteConfigClient client,
  required RemoteConfigService remoteConfig,
  required ProviderContainer container,
  required Map<String, Object> values,
  required bool Function(AdPolicy policy) matches,
}) async {
  final update = remoteConfig.updates.first;
  client.values.addAll(values);
  client.updatesController.add(null);
  await update;

  for (var attempt = 0; attempt < 20; attempt++) {
    await Future<void>.delayed(Duration.zero);
    final policy = container.read(adPolicyProvider);
    if (matches(policy)) return policy;
  }
  throw StateError('Activated ad policy did not reach the expected snapshot.');
}

class _MemoryFrequencyStateStore implements AdFrequencyStateStore {
  _MemoryFrequencyStateStore(this.state);

  AdFrequencyState state;

  @override
  Future<void> clear() async => state = const AdFrequencyState();

  @override
  Future<AdFrequencyState> read() async => state;

  @override
  Future<void> write(AdFrequencyState value) async => state = value;
}

class _FakeRemoteConfigClient implements RemoteConfigClient {
  final values = <String, Object>{};
  final updatesController = StreamController<void>.broadcast();

  @override
  Future<bool> activate() async => true;

  @override
  bool boolValue(String key) => values[key] == true;

  @override
  Future<void> configure({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  }) async {}

  @override
  Future<bool> fetchAndActivate() async => true;

  @override
  int intValue(String key) {
    final value = values[key];
    return switch (value) {
      int() => value,
      String() => int.tryParse(value) ?? 0,
      _ => 0,
    };
  }

  @override
  bool isRemoteValue(String key) => values.containsKey(key);

  @override
  Future<void> setDefaults(Map<String, Object> defaults) async {
    for (final entry in defaults.entries) {
      values.putIfAbsent(entry.key, () => entry.value);
    }
  }

  @override
  String stringValue(String key) => '${values[key] ?? ''}';

  @override
  Stream<void> get updates => updatesController.stream;

  Future<void> dispose() => updatesController.close();
}
