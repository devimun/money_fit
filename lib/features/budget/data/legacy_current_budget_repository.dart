import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/budget/domain/current_budget_repository.dart';

/// v5 compatibility boundary for the `users.budget` and `users.budget_type`
/// columns. It intentionally does not change the schema or route existing
/// settings updates through a second table.
class LegacyCurrentBudgetRepository implements CurrentBudgetRepository {
  const LegacyCurrentBudgetRepository(this._users);

  final IUserRepository _users;

  @override
  Future<CurrentBudget?> read(String ownerId) async {
    final user = await _users.getUser(ownerId);
    if (user == null || user.budget <= 0) return null;
    return CurrentBudget(amount: user.budget, type: user.budgetType);
  }

  @override
  Future<void> save(String ownerId, CurrentBudget budget) async {
    final user = await _users.getUser(ownerId);
    if (user == null) {
      throw StateError('Cannot save a budget for an unknown owner: $ownerId');
    }
    await _users.updateUser(
      user.copyWith(budget: budget.amount, budgetType: budget.type),
    );
  }
}
