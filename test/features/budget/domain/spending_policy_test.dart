import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/budget/domain/spending_policy.dart';
import 'package:money_fit/core/foundation/budget_type.dart';

void main() {
  const policy = SpendingPolicy();

  test('uses approved rounding for 28–31 day months', () {
    final cases = [
      (BudgetType.daily, 100.0, DateTime(2026, 2), 0, 100.0),
      (BudgetType.monthly, 10000.0, DateTime(2025, 2), 0, 357.0),
      (BudgetType.monthly, 10000.0, DateTime(2024, 2), 0, 344.0),
      (BudgetType.monthly, 10000.0, DateTime(2026, 4), 0, 333.0),
      (BudgetType.monthly, 10000.0, DateTime(2026, 7), 2, 322.58),
    ];

    for (final value in cases) {
      expect(
        policy.dailyBudget(
          budgetType: value.$1,
          budget: value.$2,
          month: value.$3,
          decimalDigits: value.$4,
        ),
        value.$5,
      );
    }
  });

  test('defines zero spending, missing days, and budget boundaries', () {
    expect(
      policy.isRecordedSuccessfulDay(
        hasRecord: true,
        discretionarySpending: 0,
        dailyBudget: 100,
      ),
      isTrue,
    );
    expect(
      policy.isRecordedSuccessfulDay(
        hasRecord: false,
        discretionarySpending: 0,
        dailyBudget: 100,
      ),
      isFalse,
    );
    expect(
      policy.isSuccessfulDay(discretionarySpending: 100, dailyBudget: 100),
      isTrue,
    );
    expect(
      policy.isSuccessfulDay(discretionarySpending: 100.01, dailyBudget: 100),
      isFalse,
    );
  });

  test(
    'uses current budget for past and current months and excludes future averages',
    () {
      final totals = {
        DateTime(2026, 6, 30): 300.0,
        DateTime(2026, 7, 1): 60.0,
        DateTime(2026, 8, 1): 999.0,
      };

      expect(
        policy.monthlyAverage(
          discretionaryByDay: totals,
          month: DateTime(2026, 6),
          asOf: DateTime(2026, 7, 3),
        ),
        10,
      );
      expect(
        policy.monthlyAverage(
          discretionaryByDay: totals,
          month: DateTime(2026, 7),
          asOf: DateTime(2026, 7, 3),
        ),
        20,
      );
      expect(
        policy.monthlyAverage(
          discretionaryByDay: totals,
          month: DateTime(2026, 8),
          asOf: DateTime(2026, 7, 3),
        ),
        0,
      );
    },
  );

  test('streak crosses months but stops at a missing or failed day', () {
    final records = {
      DateTime(2026, 6, 30),
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 3),
    };
    final amounts = {
      DateTime(2026, 6, 30): 0.0,
      DateTime(2026, 7, 1): 80.0,
      DateTime(2026, 7, 3): 120.0,
    };

    expect(
      policy.currentStreak(
        discretionaryByDay: amounts,
        recordedDays: records,
        asOf: DateTime(2026, 7, 1),
        dailyBudgetFor: (_) => 100,
      ),
      2,
    );
    expect(
      policy.longestStreak(
        discretionaryByDay: amounts,
        recordedDays: records,
        dailyBudgetFor: (_) => 100,
      ),
      2,
    );
  });
}
