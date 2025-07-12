### **리팩터링 보고서: `HomeViewModel` 구조 개선**

#### **1. 문제 상황 진단: 왜 리팩터링이 필요했나?**

최초에 지적해주신 문제는 `HomeViewModel` 내 여러 메서드에서 `await ref.read(coreExpensesProvider.future)`와 같은 코드가 반복적으로 사용되고 있다는 점이었습니다.

이 방식의 근본적인 문제점은 다음과 같습니다.

*   **명령형 프로그래밍**: `ref.read`를 호출하는 것은 "지금 당장 데이터를 가져와"라고 명령하는 것과 같습니다. 이는 상태가 변경되면 UI가 자동으로 업데이트되는 Riverpod의 **선언적, 반응형** 패러다임과 맞지 않습니다.
*   **상태 불일치 위험**: `coreExpensesProvider`의 데이터가 다른 곳에서 변경되었을 때, `HomeViewModel`은 그 사실을 자동으로 알지 못합니다. `refreshTodayExpenses()` 같은 메서드를 수동으로 호출해야만 상태가 갱신되므로, 데이터가 일치하지 않을 위험이 존재합니다.
*   **불필요한 복잡성**: `initialize(user)` 메서드를 통해 외부(`SplashScreen`)에서 `User` 객체를 주입받고, 상태 초기화를 수동으로 진행해야 했습니다. 이는 `HomeViewModel`을 독립��으로 테스트하기 어렵게 만들고, 의존성 관리를 복잡하게 합니다.

**결론**: `HomeViewModel`이 필요한 데이터(사용자 정보, 지출 내역)를 **직접 구독(watch)**하여, 해당 데이터가 변경될 때마다 자신의 상태를 **자동으로 재계산(rebuild)**하도록 구조를 변경해야 합니다.

---

#### **2. 핵심 리팩터링: `StateNotifier`에서 `AsyncNotifier`로 전환**

이 문제를 해결하기 위해 `HomeViewModel`을 Riverpod의 구버전 API인 `StateNotifier`에서 최신 API인 `AsyncNotifier`로 전환했습니다. `AsyncNotifier`는 비동기 데이터를 다루는 데 최적화되어 있으며, `build` 메서드 내에서 다른 프로바이더를 `watch`하여 반응형으로 상태를 구축할 수 있습니다.

##### **2.1. `lib/features/home/viewmodel/home_data_provider.dart` 수정**

**변경 전 (`StateNotifier` 기반)**

```dart
// ... (HomeState, SpendingStatus 모델은 동일)

class HomeViewModel extends StateNotifier<HomeState> {
  final Ref ref;

  HomeViewModel(this.ref)
    : super(
        const HomeState(
          dailyBudget: 0,
          todayExpenseList: [],
          monthlyVariableExpenseAvg: 0,
          consecutiveAchievementDays: 0,
        ),
      );

  // 👎 수동으로 호출해야 하는 초기화 메서드
  Future<bool> initialize(User user) async {
    try {
      // 👎 데이터를 직접 읽어오는 명령형 코드
      final expensesByDate = await ref.read(coreExpensesProvider.future);
      // ... (데이터 계산 로직) ...
      state = state.copyWith(
        dailyBudget: user.dailyBudget,
        // ...
      );
      return true;
    } catch (_) {
      state = state.copyWith(hasError: true);
      return false;
    }
  }

  // 👎 상태를 수동으로 갱신하기 위한 메서드
  Future<void> refreshTodayExpenses() async {
    final expensesByDate = await ref.read(coreExpensesProvider.future);
    // ...
  }

  // ... (기타 메서드들)
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(ref),
);
```

**변경 후 (`AsyncNotifier` 기반)**

`AsyncNotifier`는 비동기 작업의 `loading`, `data`, `error` 상태를 자동으로 관리해줍니다. `build` 메서드가 그 핵심입니다.

```dart
// home_view_model.dart
import 'dart:async'; // Completer 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/theme/design_palette.dart';
// 👍 User 정보를 제공하는 프로바이더를 직접 참조
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

// ... (HomeState, SpendingStatus 모델은 동일)

// 👍 AsyncNotifier를 상속
class HomeViewModel extends AsyncNotifier<HomeState> {
  // 👍 `build` 메서드가 상태를 구축하고 반환
  @override
  Future<HomeState> build() async {
    // 👍 userSettingsProvider를 구독(watch). 이 프로바이더가 변경되면 build 메서드가 자동 재실행됨
    final userAsyncValue = ref.watch(userSettingsProvider);

    // userAsyncValue의 상태(data, loading, error)에 따라 분기 처리
    return await userAsyncValue.when(
      data: (user) async {
        // 👍 coreExpensesProvider를 구독(watch). 지출 내역이 변경되면 자동 재실행됨
        final expensesByDate = await ref.watch(coreExpensesProvider.future);

        // --- 여기서부터는 이전 initialize 메서드의 로직과 유사 ---
        final today = DateTime.now();
        // ... (데이터 계산 로직) ...

        return HomeState(
          dailyBudget: user.dailyBudget,
          todayExpenseList: todayExpenses,
          monthlyVariableExpenseAvg: average,
          consecutiveAchievementDays: consecutiveDays,
        );
      },
      // 사용자 정보가 로딩 중일 때는 HomeState의 Future를 반환하여 대기
      loading: () => Completer<HomeState>().future,
      // 에러 발생 시 에러를 전파
      error: (e, s) => throw e,
    );
  }

  // --- CRUD 메서드들은 거의 동일 ---
  Future<void> addExpense(Expense expense) async {
    await ref.read(coreExpensesProvider.notifier).addExpense(expense);
  }
  // ... (updateExpense, deleteExpense) ...

  // 👍 예산 업데이트는 userSettingsProvider를 통해 처리
  Future<void> updateDailyBudget(double newBudget) async {
    await ref.read(userSettingsProvider.notifier).updateDailyBudget(newBudget);
  }
  // ...
}

// 👍 프로바이더 선언 방식 변경
final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
```

---

#### **3. 의존성 수정: `HomeViewModel`을 사용하는 UI 업데이트**

`HomeViewModel`의 구조가 바뀌었으므로, 이를 사용하던 화면들도 수정해야 했습니다.

##### **3.1. `lib/features/auth/view/splash_screen.dart` 수정**

`SplashScreen`은 더 이상 `initialize`를 수동으로 호출할 필요가 없어��습니다. 대신 `homeViewModelProvider`의 상태 변화를 감지하여 화면을 전환합니다.

**변경 전**

```dart
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👎 userSettingsProvider를 수신하여 복잡한 로직 처리
    ref.listen<AsyncValue<User?>>(userSettingsProvider, (previous, next) async {
      if (next.isLoading || next.isRefreshing) return;

      if (next.hasError || next.value == null || next.value!.dailyBudget == 0.0) {
        context.go('/onboarding');
        return;
      }
      // ...
      // 👎 homeViewModelProvider를 수동으로 초기화
      final success = await ref
          .read(homeViewModelProvider.notifier)
          .initialize(user);
      if (context.mounted) {
        context.go(success ? '/home' : '/onboarding');
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
```

**변경 후**

코드가 훨씬 간결하고 선언적으로 바뀌었습니다.

```dart
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👍 homeViewModelProvider의 상태 변화를 직접 수신
    ref.listen<AsyncValue<HomeState>>(homeViewModelProvider, (previous, next) {
      next.when(
        // 데이터 로딩 성공 시 홈으로 이동
        data: (_) {
          if (context.mounted) {
            context.go('/home');
          }
        },
        // 에러 발생 시 (사용자 정보 누락 등) 온보딩으로 이동
        error: (err, stack) {
          if (context.mounted) {
            context.go('/onboarding');
          }
        },
        // 로딩 중에는 아무것도 하지 않음
        loading: () {},
      );
    });

    // homeViewModelProvider를 구독하여 build 메서드가 실행되도록 함
    ref.watch(homeViewModelProvider);

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
```

##### **3.2. `lib/features/home/view/home_screen.dart` 수정**

`homeViewModelProvider`가 이제 `HomeState`가 아닌 `AsyncValue<HomeState>`를 반환하므로, UI에서 `when`을 사용하여 `loading`, `data`, `error` 상태를 모두 처리해야 합니다.

**변경 전**

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👎 state가 HomeState라고 가정하고 바로 사용
    final state = ref.watch(homeViewModelProvider);
    final status = state.spendingStatus; // 에러 발생! state는 이제 AsyncValue임
    // ...
    return Scaffold(
      // ... UI 코드
    );
  }
}
```

**변경 후**

```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👍 homeViewModelProvider가 반환하는 AsyncValue를 받음
    final homeStateAsync = ref.watch(homeViewModelProvider);
    // ...

    // 👍 when을 사용하여 상태에 따라 다른 UI를 렌더링
    return homeStateAsync.when(
      data: (state) {
        // 데이터가 있을 때의 UI (기존 Scaffold)
        final status = state.spendingStatus;
        // ...
        return Scaffold(
          // ... UI 코드
        );
      },
      loading: () => const Scaffold(
        // 로딩 중일 때의 UI
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        // 에러 발생 시의 UI
        body: Center(child: Text('오류가 발생했습니다: $error')),
      ),
    );
  }
}
```

##### **3.3. `lib/features/onboarding/view/daily_budget_setup_screen.dart` 수정**

이전에는 예산 설정 후 `homeViewModelProvider`의 상태를 수동으로 업데이트하는 코드가 있었습니다.

**변경 전**

```dart
Future<void> _submitBudget() async {
  // ...
  await ref.read(userSettingsProvider.notifier).updateDailyBudget(newBudget);
  // 👎 불필요한 수동 업데이트
  ref.read(homeViewModelProvider.notifier).dailyBudgetUpdate(newBudget);
  // ...
}
```

**변경 후**

`homeViewModelProvider`가 `userSettingsProvider`를 `watch`하고 있으므로, `userSettingsProvider`만 업데이트하면 `HomeViewModel`은 자동으로 상태를 갱신합니다. 따라서 수동 업데이트 코드를 삭제했습니다.

```dart
Future<void> _submitBudget() async {
  // ...
  await ref.read(userSettingsProvider.notifier).updateDailyBudget(newBudget);
  // 👍 수동 업데이트 코드 삭제
  if (mounted) {
    await _showNotificationDialog();
  }
}
```

---

#### **4. 최종 검증**

모든 코드 수정 후 `flutter analyze`를 실행하여 발생했던 오류와 경고(미사용 import, 잘못된 메서드 호출 등)를 모두 해결했으며, 최종적으로 "No issues found!" 결과를 확인했습니다.

#### **요약**

이번 리팩터링을 통해 `HomeViewModel`을 **명령형** 구조에서 **선언적이고 반응형**인 구조로 개선했습니다.

1.  **문제**: `ref.read`의 반복적 사용과 수동 상태 관리.
2.  **해결**: `StateNotifier`를 `AsyncNotifier`로 전환.
3.  **과정**:
    *   `HomeViewModel`�� `build` 메서드에서 `userSettingsProvider`와 `coreExpensesProvider`를 `watch`하도록 변경.
    *   불필요해진 `initialize` 메서드와 수동 갱신 로직 제거.
    *   `SplashScreen`과 `HomeScreen` 등 관련 UI를 `AsyncValue`의 `when`을 사용하도록 수정.
4.  **결과**: 코드의 안정성과 유지보수성이 향상되었고, Riverpod의 철학에 더 잘 맞는 코드가 되었습니다. 상태 관리가 자동화되어 예측 가능성이 높아졌습니다.
