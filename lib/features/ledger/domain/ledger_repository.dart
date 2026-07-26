import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/features/ledger/domain/category.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';

class ExpenseMonthKey {
  const ExpenseMonthKey({required this.ownerId, required this.month});

  final String ownerId;
  final YearMonth month;

  @override
  bool operator ==(Object other) =>
      other is ExpenseMonthKey &&
      ownerId == other.ownerId &&
      month == other.month;

  @override
  int get hashCode => Object.hash(ownerId, month);
}

class MonthlyLedger {
  const MonthlyLedger({required this.key, required this.entries});

  final ExpenseMonthKey key;
  final List<ExpenseEntry> entries;
}

abstract interface class LedgerRepository {
  Future<MonthlyLedger> readMonth(ExpenseMonthKey key);
  Future<ExpenseEntry?> findExpense(String id, String ownerId);
  Future<void> insertExpense(ExpenseEntry expense);
  Future<void> replaceExpense(ExpenseEntry expense);
  Future<void> deleteExpense(String id, String ownerId);
  Future<List<LedgerCategory>> readCategories(String ownerId);
}
