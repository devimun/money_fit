
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

/// 특정 월의 캘린더 데이터를 제공하는 FutureProvider입니다.
/// 각 날짜별 총 지출액을 `Map<DateTime, double>` 형태로 반환합니다.
final calendarDataProvider = FutureProvider.family<Map<DateTime, double>, DateTime>((ref, selectedMonth) async {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final userSettingsAsync = ref.watch(userSettingsProvider); // AsyncValue를 직접 watch

  return userSettingsAsync.when(
    data: (user) async {
      // 사용자 데이터가 로드되면 진행
      if (user.id.isEmpty) {
        return {}; // 사용자 ID가 유효하지 않으면 빈 맵 반환
      }
      final year = selectedMonth.year;
      final month = selectedMonth.month;

      final expenses = await expenseRepository.getExpensesByMonth(user.id, year, month);

      final Map<DateTime, double> dailyTotals = {};
      for (var expense in expenses) {
        // 날짜만 비교하기 위해 시간을 0으로 설정
        final dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyTotals.update(dateOnly, (value) => value + expense.amount, ifAbsent: () => expense.amount);
      }
      return dailyTotals;
    },
    loading: () => {}, // 로딩 중일 때는 빈 맵 반환
    error: (err, st) {
      // 에러 발생 시 처리 (로그 기록 등)
      // print('Error loading user settings for calendarDataProvider: \$err'); // print 제거
      return {}; // 에러 발생 시 빈 맵 반환
    },
  );
});
