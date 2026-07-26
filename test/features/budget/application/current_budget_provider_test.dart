import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/budget_type.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/budget/domain/current_budget_repository.dart';

void main() {
  test(
    'setup status follows CurrentBudget presence rather than its amount',
    () async {
      final repository = _FakeBudgetRepository();
      final container = ProviderContainer(
        overrides: [
          currentOwnerProvider.overrideWithValue(const _Owner('owner')),
          currentBudgetRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentBudgetProvider.future);
      expect(container.read(budgetSetupCompleteProvider).valueOrNull, isFalse);

      await container
          .read(currentBudgetCommandsProvider)
          .save(const CurrentBudget(amount: 1, type: BudgetType.daily));

      await container.read(currentBudgetProvider.future);
      expect(container.read(budgetSetupCompleteProvider).valueOrNull, isTrue);
    },
  );
}

class _Owner implements CurrentOwner {
  const _Owner(this.value);

  final String value;

  @override
  Future<String> get id async => value;
}

class _FakeBudgetRepository implements CurrentBudgetRepository {
  CurrentBudget? value;

  @override
  Future<CurrentBudget?> read(String ownerId) async => value;

  @override
  Future<void> save(String ownerId, CurrentBudget budget) async =>
      value = budget;
}
