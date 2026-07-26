import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/budget/data/legacy_current_budget_repository.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';

void main() {
  test('reads an unconfigured v5 budget as absent', () async {
    final repository = LegacyCurrentBudgetRepository(_FakeUsers(_user(0)));

    expect(await repository.read('owner'), isNull);
  });

  test('writes CurrentBudget through the existing v5 user row', () async {
    final users = _FakeUsers(_user(100));
    final repository = LegacyCurrentBudgetRepository(users);

    await repository.save(
      'owner',
      const CurrentBudget(amount: 3000, type: BudgetType.monthly),
    );

    expect(users.user.budget, 3000);
    expect(users.user.budgetType, BudgetType.monthly);
  });
}

class _FakeUsers implements IUserRepository {
  _FakeUsers(this.user);

  User user;

  @override
  Future<void> createUser(User user) async => this.user = user;

  @override
  Future<void> deleteUser(String id) async {}

  @override
  Future<User?> getUser(String id) async => id == user.id ? user : null;

  @override
  Future<List<User>> getAllUsers() async => [user];

  @override
  Future<void> updateUser(User user) async => this.user = user;
}

User _user(double budget) => User(
  id: 'owner',
  budget: budget,
  budgetType: BudgetType.daily,
  isDarkMode: false,
  notificationsEnabled: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
