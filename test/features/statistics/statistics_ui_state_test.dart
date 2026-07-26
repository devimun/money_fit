import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';

void main() {
  test('builds immutable category totals from a month projection', () {
    final day = DateTime(2026, 7, 1);
    final state = StatisticsModel.fromExpenses(
      2026,
      7,
      ExpenseType.discretionary,
      {
        day: [
          _expense(day, 'cafe', 10, ExpenseType.discretionary),
          _expense(day, 'cafe', 20, ExpenseType.discretionary),
          _expense(day, 'rent', 30, ExpenseType.essential),
        ],
      },
    );

    expect(state.flexExpenses.single.totalAmount, 30);
    expect(state.essentialExpenses.single.categoryId, 'rent');
    expect(state.top3Expenses.map((item) => item.totalAmount), [30.0, 30.0]);
  });
}

Expense _expense(
  DateTime date,
  String category,
  double amount,
  ExpenseType type,
) => Expense(
  id: '$category-$amount',
  userId: 'owner',
  name: category,
  amount: amount,
  date: date,
  categoryId: category,
  type: type,
  createdAt: date,
  updatedAt: date,
);
