// coreExpenseProvider를 구독해서 한달치 데이터를 가져온다.
// 한달치 데이터를 모델 생성자에 전달한다.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';

class StatisticsViewModel extends AsyncNotifier<StatisticsModel> {
  @override
  FutureOr<StatisticsModel> build() async {
    final expensesMap = await ref.watch(coreExpensesProvider.future);
    final date = ref.watch(statisticsVisibleMonthProvider);
    final expenseType = ref.watch(statisticsExpenseTypeProvider);
    return StatisticsModel.fromExpenses(
      date.year,
      date.month,
      expenseType,
      expensesMap,
    );
  }

  void changeDate(int year, int month) {
    final newDate = DateTime(year, month);
    ref.read(statisticsVisibleMonthProvider.notifier).state = newDate;
  }

  void changeExpenseType(ExpenseType expenseType) {
    ref.read(statisticsExpenseTypeProvider.notifier).state = expenseType;
  }
}

final statisticsVisibleMonthProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime(now.year, now.month);
});

final statisticsExpenseTypeProvider = StateProvider<ExpenseType>(
  (ref) => ExpenseType.discretionary,
);

final statisticsViewModelProvider =
    AsyncNotifierProvider<StatisticsViewModel, StatisticsModel>(
      StatisticsViewModel.new,
    );
