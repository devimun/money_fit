import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/repositories/sqlite_v6_user_repository.dart';
import 'package:money_fit/features/budget/data/sqlite_v6_current_budget_repository.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/session/data/sqlite_v6_local_owner_repository.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/v6_database_fixture.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'new v6 local owner has ledger settings and built-in categories',
    () async {
      final fixture = await V6DatabaseFixture.open();
      addTearDown(fixture.database.close);
      final repository = SqliteV6LocalOwnerRepository(fixture);

      await repository.create(
        LocalOwner(
          id: 'owner',
          remoteUserId: ' remote-user ',
          createdAt: DateTime.utc(2026, 7, 26),
        ),
      );

      expect((await repository.get('owner'))!.remoteUserId, 'remote-user');
      expect(
        (await fixture.database.query(
          'ledger_settings',
        )).single['currency_code'],
        'USD',
      );
      expect(
        (await fixture.database.query(
          'categories',
          where: 'owner_id = ?',
          whereArgs: ['owner'],
        )).length,
        15,
      );
      await repository.setRemoteUserId('owner', null);
      expect((await repository.get('owner'))!.remoteUserId, isNull);
    },
  );

  test('v6 current budget uses owner ledger minor units', () async {
    final fixture = await V6DatabaseFixture.open();
    addTearDown(fixture.database.close);
    final owners = SqliteV6LocalOwnerRepository(fixture);
    await owners.create(LocalOwner(id: 'owner', createdAt: DateTime.utc(2026)));
    await fixture.database.update(
      'ledger_settings',
      {'currency_code': 'KRW'},
      where: 'owner_id = ?',
      whereArgs: ['owner'],
    );
    final budgets = SqliteV6CurrentBudgetRepository(
      fixture,
      now: () => DateTime.utc(2026, 7, 26),
    );

    await budgets.save(
      'owner',
      const CurrentBudget(amount: 50000, type: BudgetType.monthly),
    );

    final current = await budgets.read('owner');
    expect(current!.amount, 50000);
    expect(current.type, BudgetType.monthly);
    expect(
      (await fixture.database.query('budgets')).single['amount_minor'],
      50000,
    );
  });

  test('v6 user compatibility projection writes normalized tables', () async {
    final fixture = await V6DatabaseFixture.open();
    addTearDown(fixture.database.close);
    final users = SqliteV6UserRepository(database: fixture);
    final createdAt = DateTime.utc(2026, 7, 26, 10);
    await users.createUser(
      User(
        id: 'owner',
        budget: 12.34,
        budgetType: BudgetType.daily,
        isDarkMode: false,
        notificationsEnabled: false,
        createdAt: createdAt,
        updatedAt: createdAt,
        currencyCode: 'usd',
      ),
    );

    final user = await users.getUser('owner');
    expect(user!.budget, 12.34);
    expect(user.currencyCode, 'USD');
    expect((await fixture.database.query('local_users')).single['id'], 'owner');
    expect(
      (await fixture.database.query('budgets')).single['amount_minor'],
      1234,
    );

    await users.updateUser(
      user.copyWith(
        budget: 50000,
        budgetType: BudgetType.monthly,
        currencyCode: 'KRW',
      ),
    );
    final updated = await users.getUser('owner');
    expect(updated!.budget, 50000);
    expect(updated.budgetType, BudgetType.monthly);
    expect(updated.currencyCode, 'KRW');
    expect(
      (await fixture.database.query('budgets')).single['amount_minor'],
      50000,
    );
  });
}
