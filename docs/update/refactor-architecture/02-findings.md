# 문제 진단과 우선순위

> 이 문서는 코드 미관이 아니라 사용자 데이터 정확성, 장애 복구 가능성, 변경 파급 범위를 기준으로 우선순위를 매긴다.  
> “확인된 결함”과 “제품 정책 결정이 필요한 위험”을 구분했다.

## 1. 우선순위 정의

| 등급 | 의미 | 처리 원칙 |
| --- | --- | --- |
| P0 | clean build/test를 막거나 데이터가 저장·표시됐다고 오인할 수 있음 | 구조 이동보다 먼저 수정 |
| P1 | 기능 경계를 무너뜨리고 결함을 반복 생성함 | P0 보호 테스트 후 점진 이전 |
| P2 | 불필요한 코드·자산·설정으로 유지보수와 배포를 느리게 함 | 기능 이전과 별개인 작은 PR로 제거 |
| Decision | 코드만으로 정답을 정할 수 없는 제품·데이터 정책 | ADR 승인 후 schema/domain 변경 |

## 2. 위험 요약

| ID | 등급 | 발견 사항 | 예상 영향 |
| --- | --- | --- | --- |
| R-01 | P0 | .env 필수 asset 부재 | clean checkout의 analyze/test/build 재현 실패 |
| R-02 | P0 | 등록 폰트가 실제 TTF가 아닌 HTML | 폰트 load 실패, 번들 오염, 플랫폼별 fallback 차이 |
| R-03 | P0 | 월 조회 오류를 빈 결과로 변환 | 데이터 손상/DB 장애를 “지출 없음”으로 표시 |
| R-04 | P0 | update 0건·예외를 성공처럼 처리 | DB와 화면 state 불일치 |
| R-05 | P0 | form이 async 저장을 기다리지 않음 | 실패 전 화면 pop/review 실행, 중복 제출 가능 |
| R-06 | P0 | 수정 시 date·createdAt을 현재 시각으로 덮음 | 원본 거래 시점과 생성 이력 유실 |
| R-07 | P0 | 수동 월 cache key/invalidation 오류 | 사용자·월 간 데이터 오염 또는 stale 화면 |
| R-08 | P0 | 빈 달을 이동 실패로 처리 | 정상적인 빈 월 탐색 불가 |
| R-09 | P0 | FK/check/index 부재 | orphan row, 잘못된 type/금액, 성능 저하 |
| R-10 | P0/Decision | REAL 금액·통화 snapshot 부재 및 잘못된 decimal 적용 | 반올림 오차, KRW/IDR threshold 오류, 과거 의미 변형 |
| R-11 | P0 | “전체 reset”이 SQLite만 지움 | 설정·세션·알림·memory state 잔존, analytics 실패 시 삭제 중단 |
| R-12 | P0 | protected route redirect가 없음 | deep link가 강제 업데이트와 setup/startup gate를 우회 |
| R-13 | P1 | optional SDK가 startup gate에 결합 | 일부 실패는 onboarding 오인, update gate 정지, 일부는 무시 |
| R-14 | P1 | core → feature 역참조와 cycle | 독립 테스트·교체·기능 단위 수정 불가 |
| R-15 | P1 | dateManager의 다중 의미 | 탭/캘린더/통계가 서로 선택 상태를 덮어씀 |
| R-16 | P1 | 성공·평균·streak 규칙 중복 | 화면마다 같은 사용자 데이터의 해석이 다름 |
| R-17 | P1 | preference source of truth 중복 | locale/theme/notification 저장소 간 불일치 |
| R-18 | P1 | 테스트가 theme/settings에 편중 | ledger, migration, startup 회귀를 차단하지 못함 |
| R-19 | P2 | 미도달·중복 코드와 superfile | 탐색 비용과 잘못된 수정 지점 증가 |
| R-20 | P2 | 빌드 산출물·잘못된 gitignore | 저장소 비대화, 인증 파일 노출 위험 |

## 3. P0 — 재현성과 데이터 정확성

### 3.1 clean checkout이 실행 기준선을 만들지 못한다

#### 확인된 사실

- [pubspec.yaml](../../../pubspec.yaml#L78-L86)이 .env를 runtime asset으로 필수 등록한다.
- .gitignore는 .env를 제외하지만 .env.example이나 build-time fallback이 없다.
- [main.dart](../../../lib/main.dart#L18-L24)는 dotenv.load 후 Supabase 값 두 개를 강제 언래핑한다.
- 현재 checkout에는 .env가 없다.
- flutter analyze는 asset_does_not_exist warning을 내고, flutter test는 test 수집 전에 “No file or variants found for asset: .env”로 중단된다.

#### 영향

새 개발자, CI, 새 worktree가 동일한 명령으로 프로젝트를 검증할 수 없다. 테스트 코드 자체가 맞는지 판단하기 전에 asset bundle 단계에서 실패한다.

#### 개선

두 선택지 중 하나를 명시적으로 채택한다.

1. 권장: public client configuration은 --dart-define 또는 generated environment config로 전달하고, validation된 AppEnvironment를 composition root에서 주입한다.
2. 단기: 비밀이 없는 placeholder .env.example을 제공하고 test asset용 fixture를 명시한다.

Supabase anon key가 앱 asset에 들어가는 것 자체가 보안 경계는 아니다. 배포 앱에서는 추출 가능하므로 RLS와 backend policy가 실질적 보호 수단이어야 한다. 문서와 CI에는 실제 값을 기록하지 않는다.

### 3.2 Pretendard asset이 폰트가 아니다

#### 확인된 사실

[PretendardVariable.ttf](../../../assets/fonts/PretendardVariable.ttf)에 대해 file 명령을 실행하면 HTML document로 식별되며 첫 내용도 HTML doctype이다. 그러나 [pubspec.yaml](../../../pubspec.yaml#L83-L86)과 ThemeData는 이를 Pretendard Variable로 등록·사용한다.

#### 영향

- Flutter font loader가 파일을 읽지 못하고 시스템 fallback을 사용할 수 있다.
- 플랫폼과 locale에 따라 typography가 달라져 screenshot/widget 결과가 흔들린다.
- 280KB의 잘못된 페이지가 앱 bundle에 들어간다.

#### 개선

공식 배포처의 실제 font binary와 license를 함께 넣고 checksum/file type을 CI에서 검증한다. 또는 앱 요구를 만족하면 시스템 font를 사용해 font asset 자체를 제거한다.

### 3.3 저장소가 실패를 정상적인 빈 값으로 위장한다

#### 확인된 사실

[ExpenseRepository.getExpensesByMonth](../../../lib/core/repositories/expense_repository.dart#L68-L104)는 SQLite query와 Expense.fromJson 전체를 try/catch하고 Exception이면 빈 Map을 반환한다.

#### 영향

다음 세 상태를 구별할 수 없다.

- 해당 월 지출이 정말 0건
- DB open/query 실패
- 한 row의 type/date/amount decoding 실패

사용자는 데이터가 사라졌다고 느낄 수 있고, UI는 빈 데이터라는 잘못된 결정을 cache한다.

#### 개선

repository는 빈 결과만 빈 collection으로 반환하고 실패는 typed failure 또는 원래 stack trace를 보존해 throw한다. application layer가 StorageFailure, CorruptDataFailure 등을 UI state로 변환한다. parse 실패 row를 조용히 버릴지 전체 query를 실패시킬지는 migration 정책으로 결정하되 telemetry와 recovery action을 남긴다.

### 3.4 update가 실제로 반영되지 않아도 성공한다

#### 확인된 사실

[ExpenseRepository.updateExpense](../../../lib/core/repositories/expense_repository.dart#L107-L130)는:

- affected row가 0이어도 조회/log만 하고 반환한다.
- 모든 예외를 catch/log하고 반환한다.

그 뒤 CoreExpensesNotifier는 repository가 성공했다고 보고 in-memory state와 cache를 수정한다.

delete도 affected row를 확인하지 않고 userId predicate 없이 id만 사용한다.

#### 영향

화면에서는 수정/삭제된 것으로 보이지만 앱을 재시작하면 이전 값이 다시 나타난다. 이것은 구조 부채가 아니라 데이터 신뢰성 결함이다.

#### 개선

- update/delete 결과가 정확히 1행인지 검증한다.
- 0행은 NotFoundFailure, 2행 이상은 invariant violation으로 처리한다.
- delete predicate에 owner userId를 포함한다.
- catch-and-log를 제거하고 command state가 실패를 표시하게 한다.
- SQLite 쓰기 성공 후 read model invalidation을 수행한다.

### 3.5 Expense form의 비동기 계약과 수정 의미가 잘못돼 있다

#### 확인된 사실

[ExpenseAddForm](../../../lib/core/widgets/expense_management/expense_add_form.dart#L15-L24)의 callback type은 void Function(Expense)지만 실제 caller는 async command를 넘긴다. [submit](../../../lib/core/widgets/expense_management/expense_add_form.dart#L154-L190)은 callback을 await하지 않은 채 review prompt를 띄우고 화면을 닫는다.

수정 모드에서도 다음 값이 모두 now로 만들어진다.

- date
- createdAt
- updatedAt

id만 기존 값을 보존한다. 화면은 날짜 입력도 제공하지 않고 DateTime.now를 표시한다. TextEditingController 두 개에 dispose도 없다. type toggle은 눌린 index를 사용하지 않고 현재 값을 뒤집는다.

#### 영향

- 저장 실패가 사용자에게 보이기 전에 form이 닫힌다.
- 빠른 재탭으로 중복 command 가능성이 있다.
- 과거 거래 수정 시 거래일이 오늘로 이동한다.
- createdAt 감사 이력이 사라진다.
- 수정 전·후가 다른 달이면 old/new 월 cache가 함께 갱신되지 않는다.

#### 개선

View callback을 Future<void> Function(ExpenseDraft) 또는 ViewModel intent로 바꾸고 await한다. View는 saving/error/effect만 표시한다. ID와 timestamp는 application command가 Clock/IdGenerator로 만든다.

- create: 새 id, occurredOn, createdAt=now, updatedAt=now
- update: 기존 id/createdAt 보존, 선택된 occurredOn 보존 또는 명시 수정, updatedAt만 now
- submit 중 button disable
- 성공 effect에서만 pop/review
- controller dispose

### 3.6 월 cache가 identity와 source state를 혼합한다

#### 확인된 사실

[CoreExpensesNotifier](../../../lib/core/providers/expenses_provider.dart#L11-L36)의 cache key는 year-month 문자열뿐이다. userId가 key에 없다. provider의 public state는 현재 월 한 개지만 private cache는 여러 월을 보관한다.

mutation은 현재 public state 전체를 mutation 대상 월의 cache entry로 저장한다. update로 거래 날짜가 이동할 때 원래 날짜 entry를 제거하지 않으며 old/new 월을 모두 갱신하지 않는다. userSettings는 build에서 read하고 dateManager만 watch한다.

#### 영향

- anonymous session이 바뀌거나 reset 후 같은 provider instance가 남으면 사용자 간 cache 오염 가능성이 있다.
- 현재 월이 아닌 거래 mutation은 다른 월 Map을 잘못 저장할 수 있다.
- 월 이동·수정 후 오래된 데이터가 계속 보인다.
- cache 생명주기와 화면 state 생명주기를 독립적으로 테스트하기 어렵다.

#### 개선

단기에는 key를 ExpenseMonthKey(userId, YearMonth)로 바꾸고 모든 command에서 old/new key를 명시적으로 invalidate한다. 목표 구조에서는 Riverpod family query를 source of truth로 쓰고 수동 cache를 제거한다. 성능 측정 후 필요할 때만 bounded TTL/LRU를 repository 아래에 추가한다.

### 3.7 빈 달을 오류처럼 취급한다

[refreshExpensesFor](../../../lib/core/providers/expenses_provider.dart#L124-L141)는 query 결과가 빈 Map이면 dateManager와 state를 변경하지 않고 false를 반환한다. [CalendarHeader](../../../lib/features/calendar/view/widgets/calendar_header.dart#L42-L88)는 이를 “데이터가 없음” snackbar로 처리하고 해당 달로 이동하지 않는다.

빈 collection은 성공적인 query 결과다. visible month는 데이터 존재 여부와 독립적으로 바뀌어야 한다. query state를 loading/data(empty 포함)/error로 유지하고, empty UI는 이동한 달 안에서 그린다.

### 3.8 DB schema가 domain invariant를 보호하지 않는다

#### 현재 v5 schema

[DatabaseHelper](../../../lib/core/database/database_helper.dart#L97-L137)에는 다음이 없다.

- expenses.user_id → users.id FOREIGN KEY
- expenses.category_id → categories.id FOREIGN KEY
- custom category의 user_id FK
- amount > 0 CHECK
- expense/category type CHECK
- budget_type CHECK
- user/date 및 category/date query index
- PRAGMA foreign_keys = ON

[CategoryRepository.deleteCategory](../../../lib/core/repositories/category_repository.dart)는 참조 중인 Expense 존재 여부나 archive/reassign 정책 없이 row를 삭제할 수 있다.

#### 영향

orphan Expense, 알 수 없는 enum, 음수/0원, 잘못된 budget type이 저장될 수 있다. 데이터가 늘수록 월 query와 통계가 느려진다.

#### 개선

DB v6 후보는 [03-target-architecture.md](./03-target-architecture.md#9-sqlite-v6-후보)에 정의한다. 중요한 원칙은 schema migration을 파일 이동과 같은 PR에 넣지 않고, v1~v5 fixture를 실제로 upgrade하는 테스트를 먼저 만드는 것이다.

### 3.9 돈과 통화의 의미가 보존되지 않는다

#### 확인된 사실

- Expense.amount와 User.budget은 double, SQLite REAL이다.
- Expense에는 currencyCode가 없다.
- locale/currency 변경은 과거 Expense 값을 변환하거나 원 통화를 보존하지 않고 표시 symbol만 바꾼다.
- 모든 과거 월의 예산 성취 계산에 현재 User.budget을 사용한다.
- [calculateDailyBudget](../../../lib/core/functions/functions.dart#L164-L185)은 decimalDigits 기본값이 2다. Home과 Calendar의 production caller는 이 인자를 전달하지 않으므로, 설정상 소수점 0자리인 KRW/IDR 월 예산도 2자리 방식으로 일 예산을 반올림한다.

#### 제품 정책 결정

MoneyFit이 “단일 장부 통화” 앱인지, 거래마다 통화를 보존하는 앱인지 결정해야 한다.

현재 제품 범위에는 **사용자 장부당 통화 하나**를 권장한다.

- LedgerCurrency를 owner별 한 곳에 저장하고 Expense/Budget 금액은 그 통화를 상속하는 minor unit 정수로 저장한다.
- mixed currency를 허용하지 않아 월 합계·평균·streak·예산 비교가 항상 같은 단위가 되게 한다.
- 장부에 값이 존재할 때 통화 변경은 차단하거나, 사용자가 확인한 환율로 모든 금액을 원자적으로 변환하는 별도 migration으로 처리한다. symbol만 바꾸는 relabel은 금지한다.
- 거래별 통화가 실제 제품 요구가 되면 original amount/currency, normalized ledger amount, 환율과 기준 시각 snapshot까지 별도 설계한다. currencyCode 필드 하나만 거래에 추가해서는 합산할 수 없다.

budget history는 별도의 제품 결정이다. 현재 요구만으로는 CurrentBudget을 분리하는 것이 기본이며, 과거 월을 당시 예산으로 평가해야 한다는 요구가 확정될 때만 effectiveFrom history를 추가한다. history 없이 과거 월을 현재 예산으로 해석한다면 그 의미를 UI/정책에 명시한다.

지원 통화의 decimal digit이 모두 같지 않으므로 “금액 × 100”만 하드코딩하면 안 된다.

단기 hotfix에서도 Home/Calendar caller가 현재 LocaleConfig.decimalDigits를 명시적으로 전달하고, KRW·IDR·USD의 월 예산 경계값을 characterization test로 고정해야 한다. 장기적으로 Money가 rounding policy를 소유하면 이 선택 인자를 화면 projection이 전달하지 않게 한다.

### 3.10 reset이 “전체 데이터 삭제”가 아니다

[DataResetService](../../../lib/core/services/data_reset_service.dart)는 analytics event를 먼저 await한 뒤 SQLite 파일만 삭제한다.

남을 수 있는 상태:

- SharedPreferences의 locale/theme/font/review/migration 값
- Supabase session
- 예약 notification
- Riverpod in-memory cache/state
- 광고/리뷰 counter

Analytics 실패는 DB 삭제 자체를 막을 수 있다. UI 문구가 “전체 데이터 삭제”라면 계약과 구현이 다르다.

reset scope를 LocalLedger, Preferences, Session, Notifications, All로 명시하고 coordinator가 순서를 관리해야 한다. analytics는 결과에 영향을 주지 않는 best-effort다.

### 3.11 protected route가 startup gate를 우회한다

[GoRouter](../../../lib/core/router/app_router.dart#L19-L119)에는 redirect가 없다. /home, /calendar, /stats, /expense_list, /settings를 initial location 또는 deep link로 직접 열면 /update-check와 Splash를 거치지 않는다.

영향:

- Remote Config가 강제 업데이트를 지시해도 보호 화면에 직접 진입할 수 있다.
- budget setup이 끝나지 않은 상태로 feature route가 열릴 수 있다.
- appInitializer의 광고/알림/category preload가 실행됐다는 가정이 깨진다.

full router 재작성 전에도 최소 BootstrapGate 상태와 redirect를 먼저 도입해 protected route를 막아야 한다. force update, setup, ready, recoverable failure를 router source로 만들고 widget의 initState navigation을 최종적으로 제거한다.

## 4. P1 — 경계와 책임

### 4.1 Feature-first의 핵심 조건인 소유권이 없다

Feature-first는 단순히 features 폴더를 만드는 패턴이 아니다. 한 변경 이유에 필요한 domain/application/data/presentation이 한 기능 경계에 모이고, 다른 기능은 공개 계약만 사용해야 한다.

현재 Expense/Category의 entity, DTO, repository, CRUD state, form, category UI가 core에 분산돼 있다. features/expense는 list/filter projection만 가진다. 결과적으로 어떤 기능도 ledger 전체를 책임지지 않는다.

**판정:** 현재는 “Feature-first directory + layer-first ownership”이다.

### 4.2 의존성 방향이 뒤집혀 있다

core가 feature를 직접 import하는 진짜 역참조는 다음과 같다.

| 발신 | 수신 | 이유 |
| --- | --- | --- |
| core/providers/expenses_provider | settings ViewModel | 사용자 ID 획득 |
| core/providers/category_providers | settings ViewModel | 사용자 ID 획득 |
| core/services/notification_service | settings ViewModel | permission 결과로 user state 변경 |
| core/services/app_initializer | home ViewModel | startup preload |
| core/widgets/today_expense_list | home ViewModel | CRUD/화면 state 접근 |

app_router의 feature import도 composition 책임이 core에 있다는 신호다. router 자체 참조는 필연적이지만 위치가 app이어야 한다.

file-level cycle:

```text
notification_service.dart
  → user_settings_provider.dart
  → notification_service.dart

ad_service.dart
  → ad_banner_widget.dart (ScreenType 사용)
  → ad_service.dart
```

cycle은 테스트 대역과 초기화 순서를 어렵게 하고 책임을 한 방향으로 설명할 수 없게 만든다.

### 4.3 dateManager는 하나의 state가 아니라 다섯 state다

하나의 DateTime이 다음 의미로 쓰인다.

1. 홈이 보여줄 day
2. 캘린더 visible month
3. 캘린더 selected day
4. 통계 selected month
5. 지출 목록 filter month

하단 탭 이동도 dateManager를 오늘로 재설정한다. 따라서 한 화면의 interaction이 다른 화면 query를 재실행하거나 선택을 잃게 한다.

분리 대상:

- homeDayProvider
- calendarVisibleMonthProvider
- calendarSelectedDayProvider
- statisticsMonthProvider
- expenseFilterState.selectedMonth

실제 “오늘”은 mutable UI state가 아니라 주입된 Clock의 today다.

### 4.4 MVVM 경계에 UI와 SDK가 침투한다

현재 ViewModel/Notifier에 존재하는 presentation/platform 의존:

- Home state가 Flutter Color와 AppThemeColors를 앎
- Category notifier가 BuildContext와 l10n을 받음
- NotificationService가 BuildContext, WidgetRef, dialog, settings ViewModel을 앎
- ReviewPromptService가 BuildContext와 dialog factory를 앎
- widget이 UUID/Clock/entity 생성, 광고, review policy를 실행
- ContactUsDialog가 Supabase table insert를 직접 수행

MVVM에서 ViewModel이 Flutter를 절대 import하면 안 된다는 기계적 규칙보다 중요한 것은 **business command를 headless test로 실행할 수 있어야 한다**는 점이다. 현재는 context/plugin/global singleton 없이 핵심 흐름을 실행하기 어렵다.

### 4.5 계산 규칙이 화면마다 다르다

Home과 Calendar가 각각 예산 성공·streak를 계산한다.

| 사례 | Home | Calendar |
| --- | --- | --- |
| 자율 지출 0원인 날 | streak 실패 | Expense key가 있으면 성공 |
| 지출 record가 전혀 없는 날 | streak 즉시 중단 | iteration에서 빠져 연속성 검증 안 함 |
| 기준 날짜 | DateTime.now | 월 Map의 정렬된 key |
| 평균 분모 | 지출이 있는 날짜 key 수 | 별도 집계 |
| 현재/과거 예산 | 현재 user budget | 현재 user budget |

같은 데이터가 화면마다 다른 메시지와 수치를 만들 수 있다. SpendingPolicy를 순수 domain service로 만들고 모든 projection이 동일 결과를 사용해야 한다.

### 4.6 UserSettingsNotifier는 과도한 aggregate다

[user_settings_provider.dart](../../../lib/features/settings/viewmodel/user_settings_provider.dart)는 다음을 한 notifier가 소유한다.

- Supabase session lookup 및 anonymous sign-in
- local User 조회/생성
- budget 수정
- notification scheduling/cancel
- locale/currency persistence
- sign out/reset

이로 인해 Home, Calendar, Category, Expense, Onboarding이 settings feature에 의존한다. settings는 UI entry point일 뿐 세션·예산·preferences의 domain owner가 아니다.

목표 소유자:

- session: identity와 local/remote mapping
- budget: budget plan/history
- preferences: theme/locale/font/notification preference
- notifications: permission/schedule adapter
- settings: 위 기능들의 화면 조합

### 4.7 preference source of truth가 중복된다

| 값 | 저장 위치 | 앱이 실제 읽는 경로 |
| --- | --- | --- |
| dark mode | User SQLite의 deprecated field + SharedPreferences ThemeSettings | ThemeSettings, 시작 시 User에서 migration |
| language | User SQLite + SharedPreferences LocaleConfig | MaterialApp은 LocaleConfig |
| currency | User SQLite + SharedPreferences LocaleConfig | formatter는 LocaleConfig |
| notification enabled | User SQLite + OS permission/scheduled notification | User/permission/plugin이 분산 |

UI가 prefs를 바꾼 뒤 DB를 바꾸는 식의 다중 write는 중간 실패 시 분기한다. theme seed/mode/font 세 notifier도 같은 JSON을 각자 read-modify-write하므로 동시 변경에서 last-write-wins가 가능하다.

PreferencesState 하나와 repository 하나를 source of truth로 정하고 원자적으로 저장한다. OS permission은 preference와 다른 external state로 모델링한다.

### 4.8 외부 SDK가 application outcome을 결정한다

Firebase Analytics, AdMob, Supabase, notification, URL launcher가 View 또는 command 안에서 직접 호출된다.

대표 사례:

- Expense insert 성공 후 analytics를 await하고 나서야 state 갱신
- data reset 전에 analytics await
- form submit 전에 interstitial action await
- startup에서 광고/알림 init await

관측·수익화는 핵심 command의 성공 조건이 아니다. AnalyticsTracker, AdsGateway 같은 작은 port를 app composition에서 연결하고 실패는 best-effort로 격리한다.

### 4.9 라우팅 state가 두 개다

GoRouter location과 navigationIndexProvider가 동일한 선택 탭을 나타낸다. route path/extra key도 문자열 Map으로 하드코딩된다. ShellRoute는 각 탭 stack을 보존하지 않는다.

StatefulShellRoute.indexedStack의 navigationShell.currentIndex를 source of truth로 사용하고 typed argument를 정의한다. 광고 action은 bottom nav widget이 아닌 navigation policy/observer에서 발생시킨다.

### 4.10 startup failure 상태가 네 갈래로 분산된다

- runApp 전 .env/Supabase/Firebase/intl/SharedPreferences 오류: 앱 route가 생성되지 않음.
- update gate의 PackageInfo/Remote Config 설정 오류: outer catch가 없어 checking 화면에 머물 수 있음.
- Splash가 기다린 initializer의 uncaught 오류: 원인과 무관하게 budget setup으로 이동.
- initializer Remote Config 설정과 UpdateService.fetchAndActivate 일부 오류: 조용히 무시.

목표는 모든 오류를 한 화면에 합치는 것이 아니라, critical local failure와 optional remote failure를 구분해 typed BootstrapState로 표현하는 것이다.

## 5. P1 — 테스트와 검증 공백

### 5.1 현재 테스트 분포

| 지표 | 현재 |
| --- | --- |
| test 파일 | 15 |
| 선언된 test case | 128 |
| 집중 영역 | locale, ThemeSettings, ThemeRepository, theme/provider, settings theme widgets |
| 실행 결과 | .env asset 문제로 0개 실행 |

다음 핵심 경로의 테스트는 0개다.

- SQLite 최초 생성과 v1/v2/v3/v4/v5 migration
- Expense create/update/delete/month query
- cache key와 old/new month invalidation
- Category delete/orphan 정책
- Home/Calendar/Statistics 계산 일관성
- first launch/offline/existing user startup
- update/ads/notification 실패 격리
- router/deep link/back/tab state
- reset scope

test/widget_test.dart는 기본 Counter template 기대값을 유지한다. font_size_setting_test는 현재 Radio 기반 UI와 provider dependency를 반영하지 않은 흔적이 있다. 테스트 개수보다 production behavior와의 연결이 우선이다.

### 5.2 CI와 architecture guard가 없다

.github/workflows가 없고 analysis_options는 기본 flutter_lints 수준이다. 금지해야 할 import가 재도입돼도 자동으로 알 수 없다.

최소 CI:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
architecture import-boundary test
font/config/assets validation
```

DB migration test는 host sqflite 환경 또는 integration test 전략을 명시해야 한다.

## 6. P2 — superfile과 불필요한 복잡성

큰 파일이라는 사실만으로 잘못은 아니다. 아래 파일들은 **서로 다른 변경 이유**를 함께 가져서 분리 또는 축소가 필요하다.

| 파일 | LOC | 섞인 책임 | 조치 방향 |
| --- | ---: | --- | --- |
| statistics.dart | 435 | provider, page composition, picker, chart, rank UI, error | projection state와 섹션 widget 분리 |
| theme_provider.dart | 382 | persistence state 3개 + light/dark ThemeData | PreferencesController 1개 + ThemeFactory |
| database_seeder.dart | 321 | production tree의 다국어 dummy data | test fixture로 이동 또는 삭제 |
| home_data_provider.dart | 305 | UI model, Color, policy, projection, command | SpendingPolicy + HomeViewModel |
| ad_service.dart | 277 | SDK init, banner sizing type, interstitial, unused app-open | AdsGateway와 실제 사용 정책만 유지 |
| database_helper.dart | 255 | connection, schema, migration, seed, reset | AppDatabase + versioned migration |
| expense_list_screen.dart | 243 | page, list rows, delete/edit interactions, form launch | 작은 screen composition과 item/action 분리 |
| contact_us_dialog.dart | 220 | dialog form, validation, Supabase DTO/write | FeedbackViewModel + repository |
| functions.dart | 196 | Widget, l10n, formatting, budget math, URL | 각각 domain/formatting/platform으로 이동 |
| expense_add_form.dart | 192 | form state, entity creation, ads, review, navigation | pure form + command/effect |

분리 기준은 “200줄 초과”가 아니라 변경 이유다. 반대로 class 하나를 파일 4개로 나누는 형식적 Clean Architecture도 피한다.

## 7. P2 — 하드코딩 분류

### 즉시 고쳐야 하는 하드코딩

| 위치 | 값 | 문제 |
| --- | --- | --- |
| MonthYearPickerDialog | 2023~2027 | 전달받은 firstDate/lastDate 무시, 범위 밖 initialItem=-1 가능 |
| Calendar bounds | 2025-07~2030-12 | 데이터 보유 범위나 제품 정책과 무관 |
| DatabaseSeeder | 특정 user ID, 2025년 7월, locale별 dummy data | production source에 개인 개발 fixture |
| Android fastlane Appfile | /Users/jun/Desktop/money_fit 절대 경로 | 현재 checkout 경로와도 불일치, 다른 환경 실행 불가 |
| route | path와 extra Map key 문자열 | rename 시 compile-time 보호 없음 |
| notification | channel ID/name, schedule 정책이 service 내부 | migration/제품 정책 추적 어려움 |

### 코드에 있어도 되지만 이름과 중앙화가 필요한 값

- spending threshold 70%/50%
- ad exposure interval
- review prompt threshold
- update fetch timeout/minimum interval
- default daily budget 50,000
- 기본 category ID와 ordering

이 값들은 magic number가 아니라 product policy다. feature config/value object에 이름을 주고 unit test 및 변경 이력을 둔다.

## 8. P2 — 미도달·중복 코드

main import graph 기준으로 아래 7개 파일, 총 1,151 LOC는 도달하지 않거나 전부 주석/중복이다.

| 파일 | LOC | 상태 | 결정 |
| --- | ---: | --- | --- |
| core/database/database_seeder.dart | 321 | initializer가 주석 처리 | test fixture로 이동 또는 삭제 |
| core/repositories/category.dart | 22 | 파일 전체 주석 | 삭제 |
| core/repositories/theme_repository_provider.dart | 18 | provider 중복, main graph 미사용 | 삭제 |
| core/theme/app_theme.dart | 263 | deprecated theme island | 현재 theme과 비교 후 삭제 |
| core/theme/design_palette.dart | 185 | app_theme에서만 사용 | 함께 삭제 |
| core/widgets/update_gate.dart | 201 | 파일 전체 주석 | 삭제 |
| features/onboarding/view/onboarding_screen.dart | 141 | route 주석 처리 | 제품 결정 후 복구 또는 삭제 |

추가 후보:

- AppOpenAdManager의 미사용 구현과 주석 preload
- AdService.instance
- currencySymbolProvider, currencyDecimalDigitsProvider
- LocaleNotifier.setLocale
- repository의 호출되지 않는 query/update/delete 메서드
- near-duplicate responsive text wrapper 7개

미도달 분석은 reflection/dynamic route를 쓰지 않는 현재 코드 전제다. onboarding은 제품 기능 결정 전 기계적으로 삭제하지 않는다.

## 9. P2 — 저장소와 배포 위생

### 9.1 추적 중인 생성 산출물

- ios/Runner.ipa 약 31MB
- ios/Runner.app.dSYM.zip 약 44MB
- Android/iOS fastlane report.xml
- Fastlane 자동 생성 README

현재 checkout 기준 약 75MB의 build artifact가 source repository에 있다. 앞으로 ignore해도 Git history 용량은 줄지 않으므로 history rewrite는 팀/remote 조율이 필요한 별도 작업이다.

### 9.2 .gitignore inline comment가 pattern을 무효화한다

[.gitignore](../../../.gitignore#L58-L78)의 다음과 같은 줄은 Git에서 inline comment로 해석되지 않는다.

```text
*.p12                        # 인증서 파일
```

전체 문자열이 pattern이 되어 실제 .p12를 ignore하지 못한다. mobileprovision, keystore, local.properties, fastlane report 등 여러 보안/산출물 규칙이 같은 문제를 가진다. comment를 별도 줄로 옮기고 git check-ignore test로 검증해야 한다.

### 9.3 Fastlane portability

[android/fastlane/Appfile](../../../android/fastlane/Appfile)은 개발자 홈의 절대 JSON key 경로를 하드코딩하며 현재 프로젝트 실제 경로와도 다르다. environment variable 또는 CI secret path를 사용해야 한다.

[ios/fastlane/Appfile](../../../ios/fastlane/Appfile)은 개인 email과 team ID를 추적한다. password/secret은 아니지만 portability와 개인정보 측면에서 environment/CI config로 옮기는 편이 낫다.

### 9.4 사용하지 않는 dependency와 asset

정적 사용 기준 직접 dependency 중 cupertino_icons와 auto_size_text가 사용되지 않는다. 제거하면 의존성과 update surface를 줄일 수 있다.

assets/images 전체 wildcard 때문에 다음이 runtime bundle 후보가 된다.

- Group 2~6 약 2.2MB: 코드 참조 없음
- onboarding 1~3 약 188KB: 현재 미도달 화면만 사용
- moneyfit.gif 약 6.1MB: README용으로 보이며 runtime 참조 없음

icon.png은 launcher/splash build-time asset이므로 runtime assets 목록에 별도 등록할 필요가 있는지 확인한다. 최대 약 9MB의 불필요 bundle input을 줄일 수 있다.

루트 package-lock.json은 package.json 없이 비어 있는 Node 생태계 흔적이다. 필요 없다면 삭제한다.

### 9.5 플랫폼 범위

Windows scaffold가 있으나 Firebase option이 명시적으로 지원하지 않는다. 선택지는 둘 중 하나다.

- Android/iOS 전용임을 README와 CI에 선언하고 Windows scaffold를 제거
- Windows를 지원 범위에 넣고 Firebase, DB, ads, notification의 대체/guard를 구현

지원하지 않는 플랫폼 디렉터리를 유지하는 것은 “가능한 플랫폼”이라는 잘못된 신호를 준다.

## 10. 과도한 추상화와 부족한 추상화

현재 IUserRepository, IExpenseRepository, ICategoryRepository는 구현체가 각각 하나이고 provider가 concrete implementation을 노출한다. interface가 실제 대체 가능 경계로 사용되지 않고 이름만 추가한다.

선택은 명확해야 한다.

- domain repository contract로 승격: feature/domain에 두고 application은 contract만 보며 data adapter를 app에서 주입
- 현재처럼 concrete만 쓸 것이라면 I-prefix interface 제거

반면 Clock, IdGenerator, AnalyticsTracker, NotificationGateway, AuthRepository처럼 실제로 nondeterministic하거나 SDK를 격리해야 할 seam은 없다. 추상화가 필요한 곳과 필요 없는 곳이 반대다.

## 11. Ponytail 단순화 감사

아래는 “가장 적은 코드로 같은 동작을 유지”하는 관점의 후보이며, 실제 삭제 전 reachability test와 제품 확인이 필요하다.

- delete: 전부 주석인 category.dart와 update_gate.dart를 제거 — 약 223 LOC.
- delete: 중복 theme_repository_provider.dart를 제거 — 약 18 LOC.
- delete: production에서 미사용인 database_seeder.dart를 test fixture로 옮기거나 제거 — production 약 321 LOC.
- delete: 미사용 cupertino_icons와 auto_size_text dependency를 제거 — 직접 dependency 2개.
- delete: 미참조 image와 runtime wildcard를 정리 — bundle input 최대 약 9MB.
- native: responsive text wrapper 7개를 Text/AutoSize가 정말 필요한 한 adapter로 축소 — 약 200 LOC 후보.
- shrink: light/dark ThemeData 중복을 ThemeFactory 공통 builder로 합치고 theme notifier 3개를 하나로 통합 — 약 300~500 LOC 후보.
- shrink: review dialog 5개와 service의 상태/타입을 현재 실제 branch에 맞춰 축소 — 약 300 LOC 후보.
- shrink: ad_service에서 사용되지 않는 AppOpenAdManager와 widget type 의존을 제거 — 약 100 LOC 후보.
- yagni: 실제 port로 쓰지 않는 I-prefixed repository interface는 제거하거나 domain contract로 이동 — 중간 형태를 유지하지 않음.
- yagni: 모든 feature에 domain/data/usecases 폴더를 선제 생성하지 않고 실제 책임이 있는 층만 생성.
- stdlib: MonthYearPicker의 고정 연도 배열/looping wheel 대신 전달된 DateTime 범위와 표준 picker primitive를 사용.

예상 net:

- 안전한 즉시 정리: handwritten production 약 -1,300~-1,500 LOC, 직접 dependency -2.
- 구조 단순화까지 완료: handwritten production 약 -2,000~-3,000 LOC, 직접 dependency 최대 -4.
- 생성 l10n을 repository에서 생성하도록 전환할 경우 tracked line은 추가로 약 -11,206이지만 runtime 코드 절감은 아니다.

LOC 감소는 목표가 아니라 경계 회복의 부산물이다. 숫자를 맞추기 위해 유효한 onboarding이나 접근성 UI를 삭제해서는 안 된다.

## 12. 수정 순서의 핵심

1. .env/font/test 실행 기준선을 복구한다.
2. 저장소 실패, async submit, timestamp, cache/empty month를 보호 테스트와 함께 고친다.
3. domain 정책과 identity/value object를 만든다.
4. ledger vertical slice를 core에서 feature로 옮긴다.
5. projection, preferences/session/startup, router를 차례로 정리한다.
6. DB v6는 fixture와 backup/rollback 전략이 준비된 별도 단계에서 수행한다.

목표 구조: [03-target-architecture.md](./03-target-architecture.md)  
실행 순서: [04-migration-roadmap.md](./04-migration-roadmap.md)
