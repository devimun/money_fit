<!-- @format -->

# Riverpod 캐시 무효화

## 배경
- MoneyFit은 `FutureProvider`/`FutureProvider.family` 캐싱에 의존해 불필요한 DB 조회를 줄이고 있습니다.
- 그러나 지출 추가/수정/삭제 이후 UI가 즉시 갱신되지 않는 사례가 발생해 사용자가 앱을 재접속해야 하는 문제가 드러났습니다.

## 문제 구조
| 단계 | 현상 |
| --- | --- |
| 1 | CRUD 완료 후 Repository는 최신 데이터를 반환했습니다. |
| 2 | `FutureProvider`는 기존 캐시를 계속 제공했습니다. |
| 3 | UI는 stale 데이터를 표시해 사용자 혼란이 발생했습니다. |

## 해결 원칙
1. **데이터 조작 이후 즉시 invalidate**
   - CRUD 성공 시점에 영향을 받는 provider 인스턴스를 무효화했습니다.
2. **ViewModel(StateNotifier)에서 ref 주입**
   - Repository는 Riverpod ref에 접근할 수 없으므로, 상위 계층(Notifier)이 invalidate 책임을 지도록 수정했습니다.

## 적용 예시
```dart
class ExpenseInputNotifier extends StateNotifier<AsyncValue<void>> {
  ExpenseInputNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));
  final ExpenseRepository _repo;
  final Ref _ref;

  Future<void> addExpense(Expense expense) async {
    await _repo.createExpense(expense);
    final month = DateTime(expense.date.year, expense.date.month);
    _ref.invalidate(expenseListProvider(month));
    _ref.invalidate(calendarDataProvider(month));
  }
}
```
- `ref.invalidate(provider(arg))` 패턴으로 특정 월만 재조회했습니다.
- 홈 화면 집계용 Provider가 있다면 동일 패턴으로 호출하도록 가이드했습니다.

## 운영 체크리스트
- [ ] CRUD 담당 Notifier 모두 `Ref`를 주입받도록 검증했습니다.
- [ ] invalidate 대상 Provider를 명시적으로 리스트업(월별 지출, 캘린더, 통계 등)했습니다.
- [ ] UI 레벨에서는 `when`/`maybeWhen`으로 로딩 상태를 처리해 재조회 시 사용자 경험을 보존했습니다.

## 회고
- 캐시 전략은 반드시 무효화 전략과 함께 설계해야 한다는 교훈을 얻었습니다.
- invalidate 범위를 최소화하면 필요한 Provider만 재빌드되어 성능 손실이 미미하다는 점을 확인했습니다.
