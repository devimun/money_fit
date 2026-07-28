import 'package:money_fit/core/foundation/budget_type.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

/// Canonical, non-identifying analytics emitted after a budget write commits.
///
/// Analytics is observational: a transient SDK failure must never reverse an
/// already-persisted budget change or keep setup/reset flows from completing.
extension BudgetAnalyticsTelemetry on AnalyticsTracker {
  Future<void> trackBudgetSetBestEffort({
    required bool isInitial,
    required BudgetType budgetPeriod,
    BudgetType? previousBudgetPeriod,
  }) async {
    try {
      await track(
        AnalyticsEvent.budgetSet.canonicalName,
        parameters: {
          'is_initial': isInitial,
          'budget_period': budgetPeriod.name,
          if (!isInitial &&
              previousBudgetPeriod != null &&
              previousBudgetPeriod != budgetPeriod)
            'previous_budget_period': previousBudgetPeriod.name,
        },
      );
    } catch (_) {
      // Analytics must not change the outcome of a completed budget write.
    }
  }
}

/// Records a successful local-database reset without coupling reset completion
/// to analytics availability.
Future<void> trackLocalDataResetBestEffort(AnalyticsTracker tracker) async {
  try {
    await tracker.track(
      AnalyticsEvent.dataReset.canonicalName,
      parameters: const {'scope': 'local_database'},
    );
  } catch (_) {
    // Reset completion is authoritative; analytics remains observational.
  }
}
