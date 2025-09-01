// 뷰에 사용되는 모델을 정의한다.
import 'package:money_fit/core/models/expense_model.dart';

// 뷰모델에서  coreExpenseProvider를 통해 특정 월의 데이터를 가져오면 언제 데이터인지 카테고리별로 얼마씩 썼는지 , TOP3 지출 카테고리는 뭔지 보여준다.
class StatisticsModel {
  // 선택된 날짜(년,월)
  int year;
  int month;
  // 자율 지출 / 필수 지출 선택
  ExpenseType expenseType;
  // 카테고리별 지출 현황
  List<TotalCategory> flexExpenses;
  List<TotalCategory> essentialExpenses;
  // TOP3데이터
  List<TotalCategory> top3Expenses;
  StatisticsModel({
    required this.year,
    required this.month,
    required this.expenseType,
    required this.essentialExpenses,
    required this.flexExpenses,
    required this.top3Expenses,
  });

  StatisticsModel copyWith({
    int? year,
    int? month,
    ExpenseType? expenseType,
    List<TotalCategory>? flexExpenses,
    List<TotalCategory>? essentialExpenses,
    List<TotalCategory>? top3Expenses,
  }) {
    return StatisticsModel(
      year: year ?? this.year,
      month: month ?? this.month,
      expenseType: expenseType ?? this.expenseType,
      flexExpenses: flexExpenses ?? this.flexExpenses,
      essentialExpenses: essentialExpenses ?? this.essentialExpenses,
      top3Expenses: top3Expenses ?? this.top3Expenses,
    );
  }

  // 월별 데이터를 받아서 데이터를 만든다.
  factory StatisticsModel.fromExpenses(
    int year,
    int month,
    ExpenseType expenseType,
    Map<DateTime, List<Expense>> expenseMap,
  ) {
    // 카테고리별 필수 지출 총액을 저장하기 위한 Map을 생성합니다.
    // key: 카테고리 ID (String), value: 총액 (double)
    final essentialTotals = <String, double>{};
    // 카테고리별 자율 지출 총액을 저장하기 위한 Map을 생성합니다.
    final flexTotals = <String, double>{};

    // expenseMap에 있는 모든 지출 내역을 반복합니다.
    for (var expenses in expenseMap.values) {
      for (var expense in expenses) {
        // 지출 유형이 '필수'인 경우
        if (expense.type == ExpenseType.essential) {
          // essentialTotals Map에 해당 카테고리 ID의 지출액을 추가합니다.
          // 만약 카테고리 ID가 이미 존재하면 금액을 더하고, 없으면 새로 추가합니다.
          essentialTotals.update(
            expense.categoryId,
            (value) => value + expense.amount,
            ifAbsent: () => expense.amount,
          );
          // 지출 유형이 '자율'인 경우
        } else if (expense.type == ExpenseType.discretionary) {
          // flexTotals Map에 해당 카테고리 ID의 지출액을 추가합니다.
          flexTotals.update(
            expense.categoryId,
            (value) => value + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }
      }
    }

    // essentialTotals Map을 List<TotalCategory> 형태로 변환합니다.
    final essentialExpenses = essentialTotals.entries
        .map((e) => TotalCategory(categoryId: e.key, totalAmount: e.value))
        .toList();
    // flexTotals Map을 List<TotalCategory> 형태로 변환합니다.
    final flexExpenses = flexTotals.entries
        .map((e) => TotalCategory(categoryId: e.key, totalAmount: e.value))
        .toList();

    // 전체 지출을 기준으로 상위 3개 지출을 계산합니다.
    final combinedTotals = Map<String, double>.from(essentialTotals);
    flexTotals.forEach((categoryId, amount) {
      combinedTotals.update(categoryId, (value) => value + amount,
          ifAbsent: () => amount);
    });

    final totalExpenses = combinedTotals.entries
        .map((e) => TotalCategory(categoryId: e.key, totalAmount: e.value))
        .toList();

    // 지출액이 많은 순으로 목록을 정렬합니다.
    totalExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // 상위 3개의 지출 내역만 가져옵니다.
    final top3Expenses = totalExpenses.take(3).toList();

    // 계산된 데이터로 StatisticsModel 인스턴스를 생성하여 반환합니다.
    return StatisticsModel(
      year: year,
      month: month,
      expenseType: expenseType,
      essentialExpenses: essentialExpenses,
      flexExpenses: flexExpenses,
      top3Expenses: top3Expenses,
    );
  }
}

class TotalCategory {
  String categoryId;
  double totalAmount;
  TotalCategory({required this.categoryId, required this.totalAmount});
}
