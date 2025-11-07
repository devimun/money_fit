<!-- @format -->

# FutureProvider.family 운용

## 배경
- 월별 지출, 캘린더, 통계 등 날짜별로 다른 데이터를 호출해야 하는 화면이 늘어나면서 동일 Provider를 재사용하되 인자에 따라 결과를 구분할 방법이 필요했습니다.
- 불필요한 DB 조회를 줄이고자 Riverpod이 제공하는 캐싱 전략을 적극 활용하기로 결정했습니다.

## 개념 정리
| 요소 | 설명 |
| --- | --- |
| `FutureProvider` | 하나의 asynchronous 상태만 관리합니다. |
| `FutureProvider.family<T, Arg>` | `Arg` 값을 키로 삼아 다수의 Provider 인스턴스를 생성·캐시합니다. |

## 구현 스케치
```dart
final expenseListProvider =
    FutureProvider.family<List<Expense>, DateTime>((ref, selectedMonth) async {
  return ref
      .watch(expenseRepositoryProvider)
      .getExpensesByMonth(selectedMonth.year, selectedMonth.month);
});
```
- `ref.watch(expenseListProvider(DateTime(2025, 7)))`은 2025년 7월용 인스턴스를 생성합니다.
- 동일 인자로 다시 watch 하면 캐시된 데이터가 반환되어 DB 호출이 생략됩니다.

## 운영 시나리오
1. **메인 홈**: `DateTime.now()` 기준으로 호출해 오늘 카드 전용 데이터를 구성했습니다.
2. **캘린더 탭**: 사용자가 월을 이동할 때마다 `expenseListProvider(선택월)`을 watch하여 달라진 월 데이터를 반영했습니다.
3. **통계 탭**: `statisticsViewModel`이 내부적으로 동일 월 데이터를 재사용하여 top3/파이차트를 계산했습니다.

## 이점
- 동일 월 데이터를 여러 화면에서 조회해도 DB hit는 최초 1회로 줄었습니다.
- 인자 기반 캐싱 덕분에 테스트 코드에서도 특정 월 데이터를 쉽게 주입했습니다.
- `ref.invalidate(provider(arg))` 패턴과 결합해 CRUD 이후 특정 월만 재조회할 수 있어 효율적이었습니다.

## 회고
- family 패턴 덕분에 Provider 개수를 기능별로 폭증시키지 않고, 인자 조합만으로 케이스를 관리할 수 있었습니다.
- 추후 사용자/카테고리 등 복합 키가 필요하면 `({DateTime month, String userId})` 형태의 record를 인자로 넘기는 방식을 검토할 예정입니다.
