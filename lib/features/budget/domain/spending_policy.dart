import 'package:money_fit/core/foundation/budget_type.dart';

class SpendingPolicy {
  const SpendingPolicy();

  double dailyBudget({
    required BudgetType budgetType,
    required double budget,
    required DateTime month,
    required int decimalDigits,
  }) {
    if (budgetType == BudgetType.daily) return budget;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final raw = budget / days;
    if (decimalDigits == 0) return raw.floorToDouble();
    final multiplier = _pow10(decimalDigits);
    return (raw * multiplier).roundToDouble() / multiplier;
  }

  bool isSuccessfulDay({
    required double discretionarySpending,
    required double dailyBudget,
  }) => discretionarySpending <= dailyBudget;

  /// A day without any ledger record is not participation. A recorded day
  /// with only essential expenses is therefore a successful zero-spend day.
  bool isRecordedSuccessfulDay({
    required bool hasRecord,
    required double discretionarySpending,
    required double dailyBudget,
  }) =>
      hasRecord &&
      isSuccessfulDay(
        discretionarySpending: discretionarySpending,
        dailyBudget: dailyBudget,
      );

  /// Uses elapsed calendar days for the current month and all calendar days
  /// for completed months. Future months have no average yet.
  double monthlyAverage({
    required Map<DateTime, double> discretionaryByDay,
    required DateTime month,
    required DateTime asOf,
  }) {
    final normalizedMonth = DateTime(month.year, month.month);
    final normalizedAsOf = DateTime(asOf.year, asOf.month, asOf.day);
    if (normalizedMonth.isAfter(
      DateTime(normalizedAsOf.year, normalizedAsOf.month),
    )) {
      return 0;
    }
    final days =
        normalizedMonth.year == normalizedAsOf.year &&
            normalizedMonth.month == normalizedAsOf.month
        ? normalizedAsOf.day
        : DateTime(normalizedMonth.year, normalizedMonth.month + 1, 0).day;
    final total = discretionaryByDay.entries
        .where(
          (entry) =>
              entry.key.year == normalizedMonth.year &&
              entry.key.month == normalizedMonth.month,
        )
        .fold<double>(0, (sum, entry) => sum + entry.value);
    return total / days;
  }

  /// Counts backward from [asOf]. Missing dates break the streak while a
  /// recorded essential-only day remains successful. Streaks may cross month
  /// boundaries because the rule is defined over consecutive calendar days.
  int currentStreak({
    required Map<DateTime, double> discretionaryByDay,
    required Set<DateTime> recordedDays,
    required DateTime asOf,
    required double Function(DateTime day) dailyBudgetFor,
  }) {
    var streak = 0;
    var day = DateTime(asOf.year, asOf.month, asOf.day);
    while (recordedDays.contains(day) &&
        isSuccessfulDay(
          discretionarySpending: discretionaryByDay[day] ?? 0,
          dailyBudget: dailyBudgetFor(day),
        )) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int longestStreak({
    required Map<DateTime, double> discretionaryByDay,
    required Set<DateTime> recordedDays,
    required double Function(DateTime day) dailyBudgetFor,
  }) {
    final days = recordedDays.toList()..sort();
    var longest = 0;
    var streak = 0;
    DateTime? previous;
    for (final day in days) {
      final successful = isSuccessfulDay(
        discretionarySpending: discretionaryByDay[day] ?? 0,
        dailyBudget: dailyBudgetFor(day),
      );
      final consecutive =
          previous != null && day.difference(previous).inDays == 1;
      streak = successful ? (consecutive ? streak + 1 : 1) : 0;
      if (streak > longest) longest = streak;
      previous = day;
    }
    return longest;
  }
}

double _pow10(int digits) {
  var result = 1.0;
  for (var index = 0; index < digits; index++) {
    result *= 10;
  }
  return result;
}
