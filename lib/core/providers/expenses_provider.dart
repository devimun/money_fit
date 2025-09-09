import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

// 앱 전역에서 지출 데이터를 관리하기 위한 프로버이더.
class CoreExpensesNotifier extends AsyncNotifier<Map<DateTime, List<Expense>>> {
  // 조회된 월별 데이터는 캐시데이터에 저장합니다.
  final _cache = <String, Map<DateTime, List<Expense>>>{};

  // 초기 빌드시 현재 월의 데이터를 가져옵니다.
  @override
  Future<Map<DateTime, List<Expense>>> build() async {
    final userSettings = await ref.read(userSettingsProvider.future);
    final now = ref.watch(dateManager);
    return await loadMonthlyExpenses(userSettings.id, now.year, now.month);
  }

  // 특정 월의 데이터를 가져오며, 이미 캐시된 데이터가 있다면 캐시를 사용하며 없다면 조회 후 캐시데이터에 저장합니다
  Future<Map<DateTime, List<Expense>>> loadMonthlyExpenses(
    String userId,
    int year,
    int month,
  ) async {
    final key = '$year-$month';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final repo = ref.read(expenseRepositoryProvider);
    final expenses = await repo.getExpensesByMonth(userId, year, month);
    _cache[key] = expenses;
    return expenses;
  }

  List<Expense> getTodayExpense(DateTime today) {
    final dateKey = _stripTime(today);
    final currentState = state.value ?? {};
    return currentState[dateKey] ?? [];
  }

  ///  지출 추가
  Future<void> addExpense(Expense expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.createExpense(expense);

    // Log create_transaction event
    await FirebaseAnalytics.instance.logEvent(
      name: 'create_transaction',
      parameters: {
        'type': expense.type.name, // 'income' or 'expense'
        'category': expense.categoryId,
      },
    );

    final dateKey = _stripTime(expense.date);
    final currentState = state.value ?? {};
    final List<Expense> updatedList = [
      expense,
      ...(currentState[dateKey] ?? []),
    ];

    final Map<DateTime, List<Expense>> newState = {
      ...currentState,
      dateKey: updatedList,
    };

    final cacheKey = '${expense.date.year}-${expense.date.month}';
    _cache[cacheKey] = newState;
    log(newState.toString());

    state = AsyncData(newState);
  }

  ///  지출 수정
  Future<void> updateExpense(Expense updated) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.updateExpense(updated);

    final dateKey = _stripTime(updated.date);
    final currentState = state.value ?? {};

    final List<Expense> updatedList = (currentState[dateKey] ?? [])
        .map((e) => e.id == updated.id ? updated : e)
        .toList();

    final Map<DateTime, List<Expense>> newState = {
      ...currentState,
      dateKey: updatedList,
    };
    final cacheKey = '${updated.date.year}-${updated.date.month}';
    _cache[cacheKey] = newState;
    state = AsyncData(newState);
  }

  ///  지출 삭제
  Future<void> deleteExpense(Expense deleted) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(deleted.id);

    final dateKey = _stripTime(deleted.date);
    final currentState = state.value ?? {};

    final oldList = currentState[dateKey] ?? [];
    final newList = oldList.where((e) => e.id != deleted.id).toList();

    final Map<DateTime, List<Expense>> newState =
        Map<DateTime, List<Expense>>.from(currentState);

    if (newList.isEmpty) {
      newState.remove(dateKey);
    } else {
      newState[dateKey] = newList;
    }
    final cacheKey = '${deleted.date.year}-${deleted.date.month}';
    _cache[cacheKey] = newState;

    state = AsyncData(newState);
  }

  ///  특정 월 갱신 (예: 달 바뀜, 전체 새로고침 시)
  Future<bool> refreshExpensesFor(DateTime date) async {
    final userSettings = await ref.read(userSettingsProvider.future);

    log(date.toString());
    final newMap = await loadMonthlyExpenses(
      userSettings.id,
      date.year,
      date.month,
    );
    log(newMap.toString());
    if (newMap.isEmpty) {
      return false;
    } else {
      ref.read(dateManager.notifier).changeDate(date);
      state = AsyncData(newMap);
      return true;
    }
  }

  /// 날짜의 시간 정보 제거 (날짜별 그룹핑용)
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

final coreExpensesProvider =
    AsyncNotifierProvider<CoreExpensesNotifier, Map<DateTime, List<Expense>>>(
      CoreExpensesNotifier.new,
    );
