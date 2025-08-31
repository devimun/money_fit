// coreExpenseProvider를 구독해서 한달치 데이터를 가져온다.
// 한달치 데이터를 모델 생성자에 전달한다.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/statistics/model/models.dart';

class StatisticsViewModel extends AsyncNotifier<StatisticsModel> {
  @override
  FutureOr<StatisticsModel> build() async {
    final expensesMap = await ref.watch(coreExpensesProvider.future);
    final date = ref.watch(dateManager);
    return StatisticsModel.fromExpenses(
      date.year,
      date.month,
      ExpenseType.discretionary,
      expensesMap,
    );
  }

  void changeDate(int year, int month) {
    final newDate = DateTime(year, month);
    ref.read(dateManager.notifier).changeDate(newDate);
  }

  void changeExpenseType(ExpenseType expenseType) {
    if (state.value!.expenseType == expenseType) {
      null;
    } else {
      state = AsyncData(state.value!.copyWith(expenseType: expenseType));
    }
  }
}
