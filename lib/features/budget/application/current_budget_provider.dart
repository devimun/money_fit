import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/platform/analytics_telemetry.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/budget/domain/current_budget_repository.dart';

/// Temporary identity seam. App composition adapts the legacy settings owner
/// here until PR 5.1 introduces SessionContext.
abstract interface class CurrentOwner {
  Future<String> get id;
}

final currentOwnerProvider = Provider<CurrentOwner>((ref) {
  throw UnimplementedError('App composition must provide CurrentOwner.');
});

final currentBudgetRepositoryProvider = Provider<CurrentBudgetRepository>((
  ref,
) {
  throw UnimplementedError(
    'App composition must provide CurrentBudgetRepository.',
  );
});

final currentBudgetProvider = FutureProvider<CurrentBudget?>((ref) async {
  final ownerId = await ref.watch(currentOwnerProvider).id;
  return ref.watch(currentBudgetRepositoryProvider).read(ownerId);
});

final budgetSetupCompleteProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(currentBudgetProvider).whenData((budget) => budget != null);
});

class CurrentBudgetCommands {
  const CurrentBudgetCommands(this._ref);

  final Ref _ref;

  Future<void> save(CurrentBudget budget) async {
    final ownerId = await _ref.read(currentOwnerProvider).id;
    await _ref.read(currentBudgetRepositoryProvider).save(ownerId, budget);
    _ref.invalidate(currentBudgetProvider);
  }

  /// Persists the first budget before emitting its corresponding telemetry.
  /// A failed write therefore cannot produce a setup-complete event.
  Future<void> saveInitialBudget(
    CurrentBudget budget, {
    required AnalyticsTracker analytics,
  }) async {
    await save(budget);
    await analytics.trackBudgetSetBestEffort(
      isInitial: true,
      budgetPeriod: budget.type,
    );
  }
}

final currentBudgetCommandsProvider = Provider<CurrentBudgetCommands>(
  CurrentBudgetCommands.new,
);
