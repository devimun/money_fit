import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/reset/engagement_reset.dart';
import 'package:money_fit/app/reset/reset_coordinator.dart';
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
    ]) {
      expect(preferences.containsKey(key), isFalse);
    }
  });

  test('all includes the explicit engagement reset scope', () {
    expect(ResetScope.engagement.clearsEngagementCounters, isTrue);
    expect(ResetScope.all.clearsEngagementCounters, isTrue);
    expect(ResetScope.localData.clearsEngagementCounters, isFalse);
  });
}
