import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/budget_type.dart';
import 'package:money_fit/core/platform/analytics_telemetry.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

void main() {
  test('budget telemetry has only canonical safe period properties', () async {
    final tracker = _RecordingAnalyticsTracker();

    await tracker.trackBudgetSetBestEffort(
      isInitial: false,
      budgetPeriod: BudgetType.monthly,
      previousBudgetPeriod: BudgetType.daily,
    );

    expect(tracker.events, hasLength(1));
    expect(tracker.events.single.$1, 'Budget Set');
    expect(tracker.events.single.$2, {
      'is_initial': false,
      'budget_period': 'monthly',
      'previous_budget_period': 'daily',
    });
  });

  test(
    'budget telemetry omits an unchanged prior period and is fail-open',
    () async {
      final tracker = _RecordingAnalyticsTracker(throwOnTrack: true);

      await tracker.trackBudgetSetBestEffort(
        isInitial: false,
        budgetPeriod: BudgetType.daily,
        previousBudgetPeriod: BudgetType.daily,
      );

      expect(tracker.events, hasLength(1));
      expect(tracker.events.single.$1, 'Budget Set');
      expect(tracker.events.single.$2, {
        'is_initial': false,
        'budget_period': 'daily',
      });
    },
  );

  test('local database reset telemetry uses its sole safe scope', () async {
    final tracker = _RecordingAnalyticsTracker();

    await trackLocalDataResetBestEffort(tracker);

    expect(tracker.events, hasLength(1));
    expect(tracker.events.single.$1, 'Data Reset');
    expect(tracker.events.single.$2, {'scope': 'local_database'});
  });
}

class _RecordingAnalyticsTracker extends NoopAnalyticsTracker {
  _RecordingAnalyticsTracker({this.throwOnTrack = false});

  final bool throwOnTrack;
  final events = <(String, Map<String, Object>)>[];

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    events.add((name, Map<String, Object>.from(parameters)));
    if (throwOnTrack) throw StateError('analytics unavailable');
  }
}
