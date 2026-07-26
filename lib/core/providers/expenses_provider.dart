import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/foundation_providers.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

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
    final user = await ref.watch(userSettingsProvider.future);
    if (_activeUserId != user.id) {
      _cache.clear();
      _activeUserId = user.id;
    }
    final date = ref.read(dateManager);
    return loadMonthlyExpenses(user.id, date.year, date.month);
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
    final user = await ref.read(userSettingsProvider.future);
    try {
      final expenses = await loadMonthlyExpenses(
        user.id,
        date.year,
        date.month,
      );
      ref.read(dateManager.notifier).changeDate(date);
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

    final user = await ref.read(userSettingsProvider.future);
    final visible = _keyFor(user.id, ref.read(dateManager));
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
