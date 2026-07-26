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

typedef ResetOperation = Future<void> Function();

/// The concrete work owned by each reset boundary.
///
/// Keeping the scope policy independent from Riverpod makes the destructive
/// sequence directly testable and prevents new callers from accidentally
/// omitting the required state invalidation step.
class ResetOperations {
  const ResetOperations({
    required this.resetLocalData,
    required this.clearPreferences,
    required this.clearSession,
    required this.cancelNotifications,
    required this.clearEngagement,
    required this.invalidateDependentState,
  });

  final ResetOperation resetLocalData;
  final ResetOperation clearPreferences;
  final ResetOperation clearSession;
  final ResetOperation cancelNotifications;
  final ResetOperation clearEngagement;
  final ResetOperation invalidateDependentState;
}

/// Runs exactly the work declared by [scope], then discards derived state.
///
/// A failed destructive operation is intentionally surfaced to the caller and
/// does not claim that the reset completed.  Invalidation happens only after
/// the selected persistent operations have all succeeded.
Future<void> runResetScope({
  required ResetScope scope,
  required ResetOperations operations,
}) async {
  switch (scope) {
    case ResetScope.localData:
      await operations.resetLocalData();
      await operations.clearSession();
    case ResetScope.preferences:
      await operations.clearPreferences();
    case ResetScope.session:
      await operations.clearSession();
    case ResetScope.notifications:
      await operations.cancelNotifications();
    case ResetScope.engagement:
      await operations.clearEngagement();
    case ResetScope.all:
      await operations.resetLocalData();
      await operations.clearPreferences();
      await operations.cancelNotifications();
      await operations.clearEngagement();
      await operations.clearSession();
  }
  await operations.invalidateDependentState();
}

/// Applies a declared reset scope and invalidates every state holder whose
/// value could otherwise describe data that no longer exists.
class ResetCoordinator {
  const ResetCoordinator(this._ref);

  final Ref _ref;

  Future<void> reset(ResetScope scope) => runResetScope(
    scope: scope,
    operations: ResetOperations(
      resetLocalData: () => _ref.read(appDatabaseProvider).reset(),
      clearPreferences: () =>
          _ref.read(appPreferencesProvider.notifier).clear(),
      clearSession: () => _ref.read(sessionProvider.notifier).clearLocalOwner(),
      cancelNotifications: () =>
          _ref.read(notificationSchedulerProvider).cancelAll(),
      clearEngagement: () => _ref.read(engagementResetterProvider).clear(),
      invalidateDependentState: () async => _invalidateDependentState(),
    ),
  );

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
