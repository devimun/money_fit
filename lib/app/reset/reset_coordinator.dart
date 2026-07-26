import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/app/reset/engagement_reset.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/ledger/application/legacy/category_providers.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/session/application/session_context.dart';

enum ResetScope {
  localData,
  preferences,
  session,
  notifications,
  engagement,
  all,
}

extension ResetScopeCoverage on ResetScope {
  bool get clearsEngagementCounters =>
      this == ResetScope.engagement || this == ResetScope.all;
}

/// Applies a declared reset scope and invalidates every state holder whose
/// value could otherwise describe data that no longer exists.
class ResetCoordinator {
  const ResetCoordinator(this._ref);

  final Ref _ref;

  Future<void> reset(ResetScope scope) async {
    if (scope == ResetScope.localData || scope == ResetScope.all) {
      await _ref.read(appDatabaseProvider).reset();
    }
    if (scope == ResetScope.preferences || scope == ResetScope.all) {
      await _ref.read(appPreferencesProvider.notifier).clear();
    }
    if (scope == ResetScope.notifications || scope == ResetScope.all) {
      await _ref.read(notificationServiceProvider).cancelAllNotifications();
    }
    if (scope.clearsEngagementCounters) {
      await _ref.read(engagementResetterProvider).clear();
    }
    if (scope == ResetScope.session ||
        scope == ResetScope.localData ||
        scope == ResetScope.all) {
      await _ref.read(sessionProvider.notifier).clearLocalOwner();
    }
    _invalidateDependentState();
  }

  void _invalidateDependentState() {
    _ref.invalidate(coreExpensesProvider);
    _ref.invalidate(categoryProvider);
    _ref.invalidate(currentBudgetProvider);
    _ref.invalidate(notificationControllerProvider);
    _ref.invalidate(sessionContextProvider);
  }
}

final resetCoordinatorProvider = Provider<ResetCoordinator>(
  ResetCoordinator.new,
);
