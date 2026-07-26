import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/features/ledger/application/ledger_providers.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';

class ExpenseCommands {
  const ExpenseCommands(this._ref);

  final Ref _ref;

  Future<void> create(ExpenseEntry expense) async {
    await _ref.read(ledgerRepositoryProvider).insertExpense(expense);
    _invalidate(expense);
  }

  Future<void> replace(ExpenseEntry expense) async {
    final existing = await _ref
        .read(ledgerRepositoryProvider)
        .findExpense(expense.id, expense.ownerId);
    await _ref.read(ledgerRepositoryProvider).replaceExpense(expense);
    if (existing != null) _invalidate(existing);
    _invalidate(expense);
  }

  Future<void> delete(ExpenseEntry expense) async {
    await _ref
        .read(ledgerRepositoryProvider)
        .deleteExpense(expense.id, expense.ownerId);
    _invalidate(expense);
  }

  void _invalidate(ExpenseEntry expense) {
    _ref.invalidate(
      monthlyLedgerProvider(
        ExpenseMonthKey(
          ownerId: expense.ownerId,
          month: YearMonth.fromLocalDate(expense.occurredOn),
        ),
      ),
    );
  }
}

final expenseCommandsProvider = Provider((ref) => ExpenseCommands(ref));
