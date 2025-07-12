import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

// 앱 전역에서 지출 데이터를 관리하기 위한 프로버이더.
class CoreExpensesNotifier extends AsyncNotifier<Map<DateTime, List<Expense>>> {
  // 조회된 월별 데이터는 캐시데이터에 저장합니다.
  final _cache = <String, Map<DateTime, List<Expense>>>{};

  // 초기 빌드시 현재 월의 데이터를 가져옵니다.
  @override
  Future<Map<DateTime, List<Expense>>> build() async {
    final userSettings = ref.read(userSettingsProvider).requireValue;
    final now = DateTime.now();
    return await _loadMonthlyExpenses(userSettings.id, now.year, now.month);
  }

  // 특정 월의 데이터를 가져오며, 이미 캐시된 데이터가 있다면 캐시를 사용하며 없다면 조회 후 캐시데이터에 저장합니다
  Future<Map<DateTime, List<Expense>>> _loadMonthlyExpenses(
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

  Future<void> loadMonth(int year, int month) async {
    final userSettings = ref.read(userSettingsProvider).valueOrNull;
    if (userSettings == null) return;

    state = const AsyncLoading();
    final result = await _loadMonthlyExpenses(userSettings.id, year, month);
    state = AsyncData(result);
  }

  ///  지출 추가
  Future<void> addExpense(Expense expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.createExpense(expense);

    final expenseDate = _stripTime(expense.date);
    final currentState = state.value ?? {};
    final List<Expense> updatedList = [
      ...(currentState[expenseDate] ?? []),
      expense,
    ];

    state = AsyncData({...currentState, expenseDate: updatedList});
  }

  ///  지출 수정
  Future<void> updateExpense(Expense updated) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.updateExpense(updated);

    final currentState = state.value ?? {};
    final dateKey = _stripTime(updated.date);

    // 수정 전 데이터를 제거하고 다시 추가
    final List<Expense> updatedList = (currentState[dateKey] ?? [])
        .map((e) => e.id == updated.id ? updated : e)
        .toList();

    state = AsyncData({...currentState, dateKey: updatedList});
  }

  ///  지출 삭제
  Future<void> deleteExpense(Expense deleted) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(deleted.id);

    final currentState = state.value ?? {};
    final dateKey = _stripTime(deleted.date);

    final oldList = currentState[dateKey] ?? [];
    final newList = oldList.where((e) => e.id != deleted.id).toList();

    final newState = Map<DateTime, List<Expense>>.from(currentState);

    if (newList.isEmpty) {
      newState.remove(dateKey);
    } else {
      newState[dateKey] = newList;
    }

    state = AsyncData(newState);
  }

  ///  특정 월 갱신 (예: 달 바뀜, 전체 새로고침 시)
  Future<void> refreshExpensesFor(DateTime date) async {
    final repo = ref.read(expenseRepositoryProvider);
    final userSettings = ref.read(userSettingsProvider).valueOrNull;
    if (userSettings == null) return;

    final newMap = await repo.getExpensesByMonth(
      userSettings.id,
      date.year,
      date.month,
    );

    // 기존 데이터와 병합
    final currentState = state.value ?? {};
    state = AsyncData({...currentState, ...newMap});
  }

  /// 날짜의 시간 정보 제거 (날짜별 그룹핑용)
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

final coreExpensesProvider =
    AsyncNotifierProvider<CoreExpensesNotifier, Map<DateTime, List<Expense>>>(
      CoreExpensesNotifier.new,
    );
