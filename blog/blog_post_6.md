# Riverpod 캐시 무효화: 데이터 변경 시 UI 자동 업데이트하기 (`ref.invalidate()`)

Flutter 앱을 Riverpod으로 개발하다 보면 `FutureProvider`나 `StreamProvider`를 사용하여 비동기 데이터를 효율적으로 관리하게 됩니다. 이 프로바이더들은 데이터를 한 번 가져오면 그 결과를 캐시하여 불필요한 중복 조회를 막아줍니다. 이는 앱의 성능을 최적화하는 데 큰 도움이 됩니다.

하지만 여기에 한 가지 중요한 질문이 생깁니다. **"만약 데이터베이스에 새로운 지출 내역이 추가되거나 기존 지출이 수정/삭제되면, UI는 어떻게 자동으로 업데이트될까요?"** 캐시된 데이터는 변경 사항을 알지 못합니다. 이 문제를 해결하는 Riverpod의 핵심 기능이 바로 `ref.invalidate()`입니다.

## 1. 문제: 캐시된 데이터의 불일치

우리는 `expenseListProvider`와 `calendarDataProvider`와 같은 `FutureProvider.family`를 사용하여 특정 월의 지출 내역이나 캘린더 데이터를 가져옵니다. 이 프로바이더들은 데이터를 한 번 가져오면 그 결과를 메모리에 캐시합니다.

```dart
// 예시: expenseListProvider
final expenseListProvider = FutureProvider.family<List<Expense>, DateTime>((ref, selectedMonth) async {
  // ... 데이터베이스에서 지출 내역 조회 ...
});
```

만약 사용자가 새로운 지출을 추가했다고 가정해 봅시다. 데이터베이스에는 새로운 지출이 성공적으로 저장되었지만, `expenseListProvider`는 여전히 이전에 캐시해 둔 데이터를 가지고 있습니다. 따라서 UI는 새로운 지출을 반영하지 못하고 오래된 정보를 보여주게 됩니다.

## 2. 해결책: `ref.invalidate()`

Riverpod은 이러한 문제를 해결하기 위해 `ref.invalidate()` 메서드를 제공합니다. `ref.invalidate(someProvider)`를 호출하면:

1.  `someProvider`의 현재 캐시된 상태가 **무효화(invalidated)**됩니다.
2.  다음에 이 프로바이더를 `watch`하거나 `read`할 때, Riverpod은 캐시된 데이터를 버리고 `someProvider`의 `async` 블록을 **다시 실행(re-execute)**하여 최신 데이터를 가져오게 됩니다.
3.  이로 인해 해당 프로바이더를 `watch`하고 있던 모든 위젯들이 새로운 데이터로 리빌드되어 UI가 자동으로 업데이트됩니다.

## 3. `ref.invalidate()`는 언제 호출해야 할까?

`ref.invalidate()`는 **데이터를 변경하는 작업(생성, 수정, 삭제)이 성공적으로 완료된 직후**에 호출해야 합니다.

일반적으로 데이터 변경 로직은 리포지토리(Repository) 계층에서 이루어지지만, 리포지토리는 Riverpod의 `ref` 객체에 직접 접근할 수 없습니다. 따라서 `ref.invalidate()` 호출은 **리포지토리를 사용하는 상위 계층, 즉 ViewModel (또는 Riverpod의 `StateNotifier`)**에서 이루어져야 합니다.

### 예시: 지출 추가 후 캐시 무효화

가상의 `ExpenseInputNotifier`를 통해 지출을 추가하는 시나리오를 생각해 봅시다.

```dart
// lib/features/expense/viewmodel/expense_input_notifier.dart (가상의 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';
import 'package:money_fit/features/calendar/viewmodel/calendar_data_provider.dart';

class ExpenseInputNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseRepository _expenseRepository;
  final Ref _ref; // Ref를 주입받습니다.

  ExpenseInputNotifier(this._expenseRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addExpense(Expense expense) async {
    state = const AsyncValue.loading();
    try {
      await _expenseRepository.createExpense(expense); // 데이터베이스에 저장
      state = const AsyncValue.data(null);

      // 중요: 데이터 변경 후 관련 프로바이더 캐시 무효화
      // FutureProvider.family는 인자를 정확히 지정해야 합니다.
      final affectedMonth = DateTime(expense.date.year, expense.date.month, 1); // 지출이 발생한 월
      _ref.invalidate(expenseListProvider(affectedMonth)); // 해당 월의 지출 목록 무효화
      _ref.invalidate(calendarDataProvider(affectedMonth)); // 해당 월의 캘린더 데이터 무효화

      // 만약 메인 화면에 오늘 지출 총액 같은 프로바이더가 있다면 그것도 무효화해야 합니다.
      // _ref.invalidate(todayExpensesTotalProvider);

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  // updateExpense, deleteExpense 메서드도 유사하게 invalidate를 호출합니다.
}

// 이 StateNotifier를 제공하는 Provider
final expenseInputProvider = StateNotifierProvider<ExpenseInputNotifier, AsyncValue<void>>((ref) {
  return ExpenseInputNotifier(ref.watch(expenseRepositoryProvider), ref); // Ref를 전달
});
```

## 4. 현재 코드에 반영하기

현재 MoneyFit 프로젝트에서는 `UserSettingsNotifier`가 `UserRepository`를 사용하여 사용자 설정을 업데이트하고 있습니다. 사용자 설정이 변경될 때 `userSettingsProvider`의 캐시를 무효화하여 UI에 최신 설정이 반영되도록 수정하겠습니다.

`lib/features/settings/viewmodel/user_settings_provider.dart` 파일의 `UserSettingsNotifier`에 `Ref`를 주입받고, `updateDailyBudget`, `toggleDarkMode`, `toggleNotifications` 메서드에서 `_ref.invalidate(userSettingsProvider)`를 호출하도록 변경합니다.

```dart
// lib/features/settings/viewmodel/user_settings_provider.dart (수정 후)

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... (기존 임포트)

class UserSettingsNotifier extends StateNotifier<AsyncValue<User>> {
  final UserRepository _userRepository;
  final Ref _ref; // Ref 추가

  UserSettingsNotifier(this._userRepository, this._ref) // 생성자 수정
    : super(const AsyncValue.loading()) {
    _loadUser();
  }

  // ... (기존 _loadUser 메서드)

  Future<void> updateDailyBudget(double newBudget) async {
    // ... (기존 로직)
    try {
      await _userRepository.updateUser(updatedUser);
      _ref.invalidate(userSettingsProvider); // 변경 후 프로바이더 무효화
    } catch (e, st) {
      // ...
    }
  }

  Future<void> toggleDarkMode() async {
    // ... (기존 로직)
    try {
      await _userRepository.updateUser(updatedUser);
      _ref.invalidate(userSettingsProvider); // 변경 후 프로바이더 무효화
    } catch (e, st) {
      // ...
    }
  }

  Future<void> toggleNotifications() async {
    // ... (기존 로직)
    try {
      await _userRepository.updateUser(updatedUser);
      _ref.invalidate(userSettingsProvider); // 변경 후 프로바이더 무효화
    } catch (e, st) {
      // ...
    }
  }
}

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, AsyncValue<User>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserSettingsNotifier(userRepository, ref); // Ref를 전달
});
```

## 결론

`ref.invalidate()`는 Riverpod 앱에서 데이터의 최신성을 유지하고 UI를 효율적으로 업데이트하는 데 필수적인 도구입니다. 데이터 변경이 발생하는 모든 지점에서 관련 프로바이더를 적절히 무효화함으로써, 사용자에게 항상 최신 정보를 제공하고 앱의 반응성을 높일 수 있습니다.
