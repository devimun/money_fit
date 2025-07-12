// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:money_fit/core/models/expense_model.dart';
// import 'package:money_fit/core/providers/repository_providers.dart';
// import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

// /// 특정 월의 지출 목록을 제공하는 FutureProvider입니다.
// /// 선택된 월(year, month)과 현재 사용자 ID에 따라 지출 내역을 가져옵니다.
// final expenseListProvider = FutureProvider.family<List<Expense>, DateTime>((ref, selectedMonth) async {
//   final expenseRepository = ref.watch(expenseRepositoryProvider);
//   final userSettingsAsync = ref.watch(userSettingsProvider); // AsyncValue를 직접 watch

//   return userSettingsAsync.when(
//     data: (user) async {
//       // 사용자 데이터가 로드되면 진행
//       if (user.id.isEmpty) {
//         return []; // 사용자 ID가 유효하지 않으면 빈 목록 반환
//       }
//       final year = selectedMonth.year;
//       final month = selectedMonth.month;
//       return expenseRepository.getExpensesByMonth(user.id, year, month);
//     },
//     loading: () => [], // 로딩 중일 때는 빈 목록 반환
//     error: (err, st) {
//       // 에러 발생 시 처리 (로그 기록 등)
//       // print('Error loading user settings for expenseListProvider: \$err'); // print 제거
//       return []; // 에러 발생 시 빈 목록 반환
//     },
//   );
// });
