import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

enum SortType { asc, desc }

// ExpensesList 뷰에 나타낼 데이터 형식을 정의하는 모델
class ExpensesListState {
  // 해당 달의 전체 데이터
  final DateTime searchDate;
  final ExpenseType? expenseType;
  final String? categoryId;
  final SortType sortType;
  final Map<DateTime, List<Expense>> expenses;
  ExpensesListState({
    required this.searchDate,
    required this.expenseType,
    required this.categoryId,
    required this.expenses,
    required this.sortType,
  });
}

// expenses 스크린을 담당하는 뷰모델
// 최초 빌드 시 coreExpenseProvider의 데이터를 받아온다.
class ExpensesListViewModel extends AsyncNotifier<ExpensesListState> {
  @override
  Future<ExpensesListState> build() async {
    state = AsyncLoading();
    // 조회 기준 당월 데이터
    final searchDate = ref.watch(dateManager);
    final buildData = await ref.read(coreExpensesProvider.future);
    final filtered = filteringData(buildData, null, null, SortType.desc);

    return ExpensesListState(
      searchDate: DateTime(searchDate.year, searchDate.month),
      expenseType: null,
      categoryId: null,
      sortType: SortType.desc,
      expenses: filtered,
    );
  }

  // 전체 데이터를 필터에 맞게 수정하는 필터
  Map<DateTime, List<Expense>> filteringData(
    Map<DateTime, List<Expense>> data,
    ExpenseType? expenseType,
    String? categoryId,
    SortType sortType,
  ) {
    final Map<DateTime, List<Expense>> filteredMap = {};
    for (final entry in data.entries) {
      final filteredList = entry.value.where((expense) {
        final matchesType = expenseType == null || expenseType == expense.type;
        final matchesCategory =
            categoryId == null || expense.categoryId == categoryId;
        return matchesType && matchesCategory;
      }).toList();

      if (filteredList.isNotEmpty) {
        filteredList.sort(
          (a, b) => sortType == SortType.asc
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date),
        );
        filteredMap[entry.key] = filteredList;
      }
    }
    return filteredMap;
  }

  /// 유저가 필터 옵션을 바꿨을 때 호출하는 메서드
  Future<void> applyFilters({
    required DateTime searchDate,
    ExpenseType? expenseType,
    String? categoryId,
    required SortType sortType,
  }) async {
    state = AsyncLoading();
    final user = await ref.read(userSettingsProvider.future);
    // coreExpensesProvider 에서 원본 데이터 조회
    final rawData = await ref
        .read(coreExpensesProvider.notifier)
        .loadMonthlyExpenses(user.id, searchDate.year, searchDate.month);
    // 필터링 수행
    final filtered = filteringData(rawData, expenseType, categoryId, sortType);

    // 상태 갱신
    state = AsyncData(
      ExpensesListState(
        searchDate: DateTime(searchDate.year, searchDate.month),
        expenseType: expenseType,
        categoryId: categoryId,
        sortType: sortType,
        expenses: filtered,
      ),
    );
  }
}

final expenseListProvider =
    AsyncNotifierProvider<ExpensesListViewModel, ExpensesListState>(
      () => ExpensesListViewModel(),
    );
