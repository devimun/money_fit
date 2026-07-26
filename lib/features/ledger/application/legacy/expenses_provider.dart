import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/features/session/application/session_context.dart';

final ledgerVisibleDateProvider = StateProvider<DateTime>(
  (ref) => ref.watch(clockProvider).now(),
);

class ExpenseMonthKey {
  const ExpenseMonthKey({required this.userId, required this.month});

  final String userId;
  final YearMonth month;

  @override
  bool operator ==(Object other) =>
      other is ExpenseMonthKey &&
      other.userId == userId &&
      other.month == month;

  @override
  int get hashCode => Object.hash(userId, month);
}

class CoreExpensesNotifier extends AsyncNotifier<Map<DateTime, List<Expense>>> {
  final _cache = <ExpenseMonthKey, Map<DateTime, List<Expense>>>{};
  String? _activeUserId;

  @override
  Future<Map<DateTime, List<Expense>>> build() async {
    final ownerId = await ref.watch(currentOwnerIdProvider.future);
    if (_activeUserId != ownerId) {
      _cache.clear();
      _activeUserId = ownerId;
    }
    final date = ref.read(ledgerVisibleDateProvider);
    return loadMonthlyExpenses(ownerId, date.year, date.month);
  }

  Future<Map<DateTime, List<Expense>>> loadMonthlyExpenses(
    String userId,
    int year,
    int month,
  ) async {
    final key = ExpenseMonthKey(userId: userId, month: YearMonth(year, month));
    final cached = _cache[key];
    if (cached != null) return cached;

    final expenses = await ref
        .read(expenseRepositoryProvider)
        .getExpensesByMonth(userId, year, month);
    _cache[key] = expenses;
    return expenses;
  }

  List<Expense> getTodayExpense(DateTime today) =>
      (state.valueOrNull ?? {})[_stripTime(today)] ?? const [];

  Future<void> addExpense(Expense expense) async {
    await ref.read(expenseRepositoryProvider).createExpense(expense);
    await _invalidateAndReload([_keyFor(expense.userId, expense.date)]);
    unawaited(_trackCreatedExpense(expense));
  }

  Future<void> updateExpense(Expense updated) async {
    final repository = ref.read(expenseRepositoryProvider);
    final existing = await repository.findExpense(updated.id, updated.userId);
    if (existing == null) {
      throw NotFoundFailure(resource: 'Expense', identifier: updated.id);
    }
    await repository.updateExpense(updated);
    await _invalidateAndReload([
      _keyFor(existing.userId, existing.date),
      _keyFor(updated.userId, updated.date),
    ]);
  }

  Future<void> deleteExpense(Expense deleted) async {
    await ref
        .read(expenseRepositoryProvider)
        .deleteExpense(deleted.id, deleted.userId);
    await _invalidateAndReload([_keyFor(deleted.userId, deleted.date)]);
  }

  Future<bool> refreshExpensesFor(DateTime date) async {
    final ownerId = await ref.read(currentOwnerIdProvider.future);
    try {
      final expenses = await loadMonthlyExpenses(
        ownerId,
        date.year,
        date.month,
      );
      ref.read(ledgerVisibleDateProvider.notifier).state = date;
      state = AsyncData(expenses);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void clearCache() => _cache.clear();

  Future<void> _invalidateAndReload(Iterable<ExpenseMonthKey> keys) async {
    final affected = keys.toSet();
    for (final key in affected) {
      _cache.remove(key);
    }

    final ownerId = await ref.read(currentOwnerIdProvider.future);
    final visible = _keyFor(ownerId, ref.read(ledgerVisibleDateProvider));
    if (affected.contains(visible)) {
      final expenses = await loadMonthlyExpenses(
        visible.userId,
        visible.month.year,
        visible.month.month,
      );
      state = AsyncData(expenses);
    }
  }

  Future<void> _trackCreatedExpense(Expense expense) async {
    try {
      await ref
          .read(analyticsTrackerProvider)
          .track(
            'create_transaction',
            parameters: {
              'type': expense.type.name,
              'category': expense.categoryId,
            },
          );
    } catch (_) {
      // Analytics is observational and must not reverse a committed expense.
    }
  }

  ExpenseMonthKey _keyFor(String userId, DateTime date) =>
      ExpenseMonthKey(userId: userId, month: YearMonth.fromDateTime(date));

  DateTime _stripTime(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

final coreExpensesProvider =
    AsyncNotifierProvider<CoreExpensesNotifier, Map<DateTime, List<Expense>>>(
      CoreExpensesNotifier.new,
    );
