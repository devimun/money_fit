import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/reset/engagement_reset.dart';
import 'package:money_fit/app/reset/reset_coordinator.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('engagement reset clears all review decisions and counters', () async {
    SharedPreferences.setMockInitialValues({
      'review_first_run_at': '2026-01-01T00:00:00.000Z',
      'review_opted_out': true,
      'review_last_prompt_at': '2026-01-02T00:00:00.000Z',
      'review_prompt_count': 3,
      'review_snooze_until': '2026-01-09T00:00:00.000Z',
      'analytics_collection_enabled': false,
      'analytics_consent_version': '1',
      'ads_pending_meaningful_actions': 5,
      'ads_last_trigger_top_level_tab': '2026-01-02T00:00:00.000Z',
      'feedback_prompt_last_submitted_at': '2026-01-02T00:00:00.000Z',
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    await container.read(engagementResetterProvider).clear();

    for (final key in const [
      'review_first_run_at',
      'review_opted_out',
      'review_last_prompt_at',
      'review_prompt_count',
      'review_snooze_until',
      'analytics_collection_enabled',
      'analytics_consent_version',
      'ads_pending_meaningful_actions',
      'ads_last_trigger_top_level_tab',
      'feedback_prompt_last_submitted_at',
    ]) {
      expect(preferences.containsKey(key), isFalse);
    }
  });

  test(
    'engagement reset restores runtime collection to the cleared default',
    () async {
      SharedPreferences.setMockInitialValues({
        AnalyticsConsentRepository.collectionKey: false,
        AnalyticsConsentRepository.versionKey: '1',
      });
      final preferences = await SharedPreferences.getInstance();
      final tracker = _RecordingAnalyticsTracker();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsTrackerProvider.overrideWithValue(tracker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(engagementResetterProvider).clear();

      expect(AnalyticsConsentRepository(preferences).isEnabled, isTrue);
      expect(tracker.collectionEnabled, [true]);
      expect(tracker.resetCalls, 1);
    },
  );

  test(
    'analytics reset failures do not block persisted consent cleanup',
    () async {
      SharedPreferences.setMockInitialValues({
        AnalyticsConsentRepository.collectionKey: false,
      });
      final preferences = await SharedPreferences.getInstance();
      final tracker = _RecordingAnalyticsTracker(throwOnReset: true);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsTrackerProvider.overrideWithValue(tracker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(engagementResetterProvider).clear();

      expect(AnalyticsConsentRepository(preferences).isEnabled, isTrue);
      expect(tracker.collectionEnabled, [true]);
      expect(tracker.resetCalls, 1);
    },
  );

  test('all includes the explicit engagement reset scope', () {
    expect(ResetScope.engagement.clearsEngagementCounters, isTrue);
    expect(ResetScope.all.clearsEngagementCounters, isTrue);
    expect(ResetScope.localData.clearsEngagementCounters, isFalse);
  });
}

class _RecordingAnalyticsTracker implements AnalyticsTracker {
  _RecordingAnalyticsTracker({this.throwOnReset = false});

  final bool throwOnReset;
  final collectionEnabled = <bool>[];
  var resetCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> reset() async {
    resetCalls += 1;
    if (throwOnReset) throw StateError('offline');
  }

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled.add(enabled);
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}
}
