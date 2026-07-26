import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/data/category_row.dart';
import 'package:money_fit/features/ledger/data/expense_row.dart';
import 'package:money_fit/features/ledger/data/ledger_mapper.dart';
import 'package:money_fit/features/ledger/domain/category.dart';

void main() {
  const mapper = LedgerMapper(LedgerCurrency(code: 'KRW', decimalDigits: 0));

  test('maps v5 expense rows with an explicit legacy currency snapshot', () {
    final entry = mapper.expenseFromRow(
      const ExpenseRow(
        id: 'expense',
        userId: 'owner',
        name: 'Lunch',
        amount: 1200,
        date: '2026-07-15',
        categoryId: 'food',
        type: 'essential',
        createdAt: '2026-07-15T10:00:00.000',
        updatedAt: '2026-07-15T11:00:00.000',
      ),
    );

    expect(entry.amount.minorUnits, 1200);
    expect(entry.amount.currency.code, 'KRW');
    expect(entry.occurredOn.toString(), '2026-07-15');
  });

  test('scopes built-in categories to the requesting owner', () {
    final category = mapper.categoryFromRow(
      const CategoryRow(
        id: 'food',
        userId: null,
        name: 'Food',
        type: 'essential',
        isDeletable: false,
      ),
      'owner',
    );

    expect(category.ownerId, 'owner');
    expect(category.kind, SpendingKind.essential);
    expect(category.isBuiltIn, isTrue);
  });

  test('rejects unknown category kinds instead of silently falling back', () {
    expect(
      () => mapper.categoryFromRow(
        const CategoryRow(
          id: 'unknown',
          userId: 'owner',
          name: 'Unknown',
          type: 'unexpected',
          isDeletable: true,
        ),
        'owner',
      ),
      throwsFormatException,
    );
  });
}
