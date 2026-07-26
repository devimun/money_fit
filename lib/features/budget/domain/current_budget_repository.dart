import 'package:money_fit/features/budget/domain/current_budget.dart';

abstract interface class CurrentBudgetRepository {
  Future<CurrentBudget?> read(String ownerId);
  Future<void> save(String ownerId, CurrentBudget budget);
}
