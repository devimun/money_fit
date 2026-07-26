import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/spending_kind.dart';
import 'package:money_fit/features/ledger/data/legacy/category_model.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_legacy_category_repository.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_legacy_expense_repository.dart';
import 'package:money_fit/features/session/data/sqlite_v6_local_owner_repository.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';

import '../../../support/v6_database_fixture.dart';

void main() {
  test(
    'legacy presentation contracts operate on owner-scoped v6 rows',
    () async {
      final database = await V6DatabaseFixture.open();
      addTearDown(database.database.close);
      final owner = LocalOwner(
        id: 'owner',
        createdAt: DateTime.utc(2026, 7, 26),
      );
      await SqliteV6LocalOwnerRepository(database).create(owner);
      final categories = SqliteV6LegacyCategoryRepository(database);
      final expenses = SqliteV6LegacyExpenseRepository(database);
      final custom = Category(
        id: 'custom',
        userId: owner.id,
        name: 'Coffee',
        type: SpendingKind.discretionary,
        isDeletable: true,
      );

      await categories.createCategory(custom);
      await expenses.createExpense(
        Expense(
          id: 'expense',
          userId: owner.id,
          name: 'Latte',
          amount: 4.25,
          date: DateTime.utc(2026, 7, 26),
          categoryId: custom.id,
          type: SpendingKind.discretionary,
          createdAt: DateTime.utc(2026, 7, 26),
          updatedAt: DateTime.utc(2026, 7, 26),
        ),
      );

      final month = await expenses.getExpensesByMonth(owner.id, 2026, 7);
      expect((await categories.getAllCategories(owner.id)).length, 16);
      expect(month.values.single.single.amount, 4.25);
      expect(
        (await database.database.query('expenses')).single['amount_minor'],
        425,
      );
    },
  );
}
