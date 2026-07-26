import 'package:money_fit/features/budget/domain/spending_policy.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';

class CalendarCellData {
  final DateTime date;
  final List<Expense> expenses;
  final bool isSuccess;

  CalendarCellData({
    required this.date,
    required this.expenses,
    required this.isSuccess,
  });

  factory CalendarCellData.from(
    DateTime date,
    List<Expense> expenses,
    double dailyBudget, {
    SpendingPolicy policy = const SpendingPolicy(),
  }) {
    double discTotal = expenses
        .where((e) => e.type == ExpenseType.discretionary)
        .fold(0.0, (sum, e) => sum + e.amount);

    final isSuccess = policy.isSuccessfulDay(
      discretionarySpending: discTotal,
      dailyBudget: dailyBudget,
    );

    return CalendarCellData(
      date: date,
      expenses: expenses,
      isSuccess: isSuccess,
    );
  }

  double get discretionaryTotal => expenses
      .where((e) => e.type == ExpenseType.discretionary)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get essentialTotal => expenses
      .where((e) => e.type == ExpenseType.essential)
      .fold(0.0, (sum, e) => sum + e.amount);
}

class CalendarState {
  final DateTime selectedDay;
  final CalendarStat calendarStat;
  final Map<DateTime, CalendarCellData> calendarCells;

  CalendarState({
    required this.selectedDay,
    required this.calendarStat,
    required this.calendarCells,
  });
}

// 상단 스테이터스바 전용 클래스
class CalendarStat {
  double monthlyDiscretionaryExpense; // 월간 자율 지출 총액
  double monthlyEssentialExpense; // 월간 필수 지출 총액
  int successfulDays; // 성공일 수
  int failedDays; // 실패일 수
  int consecutiveSuccessfulDays; // 연속 성공일 수

  CalendarStat({
    required this.monthlyDiscretionaryExpense,
    required this.monthlyEssentialExpense,
    required this.successfulDays,
    required this.failedDays,
    required this.consecutiveSuccessfulDays,
  });

  factory CalendarStat.fromExpenses(
    Map<DateTime, List<Expense>> expensesMap,
    double dailyBudget, {
    SpendingPolicy policy = const SpendingPolicy(),
  }) {
    double discTotal = 0;
    double essTotal = 0;
    final discretionaryByDay = <DateTime, double>{};
    final recordedDays = <DateTime>{};

    for (final entry in expensesMap.entries) {
      final day = DateTime(entry.key.year, entry.key.month, entry.key.day);
      final expenses = entry.value;
      double dayDisc = 0;
      double dayEss = 0;

      for (final e in expenses) {
        if (e.type == ExpenseType.discretionary) {
          dayDisc += e.amount;
        } else {
          dayEss += e.amount;
        }
      }

      discTotal += dayDisc;
      essTotal += dayEss;
      discretionaryByDay[day] = dayDisc;
      recordedDays.add(day);
    }

    final success = recordedDays
        .where(
          (day) => policy.isSuccessfulDay(
            discretionarySpending: discretionaryByDay[day] ?? 0,
            dailyBudget: dailyBudget,
          ),
        )
        .length;
    final fail = recordedDays.length - success;
    final maxStreak = policy.longestStreak(
      discretionaryByDay: discretionaryByDay,
      recordedDays: recordedDays,
      dailyBudgetFor: (_) => dailyBudget,
    );

    return CalendarStat(
      monthlyDiscretionaryExpense: discTotal,
      monthlyEssentialExpense: essTotal,
      successfulDays: success,
      failedDays: fail,
      consecutiveSuccessfulDays: maxStreak,
    );
  }
}
