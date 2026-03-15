<!-- @format -->

# MoneyFit Case Study

## Role & Objective

- 구현자/리드 개발자로 참여, 온보딩부터 데이터 시각화까지 한 사람의 일상을 관리할 수 있는 개인 재무 코치 앱 구축
- 목표는 **로컬에 안전하게 보관되는 지출 데이터**와 **원활한 다국어 UX**를 제공하면서, 업데이트·광고·리뷰 유도 같은 성장 파이프라인까지 한번에 정비하는 것

---

## Product Overview

- **콘셉트:** 매일·매월의 자율 지출 한도를 즉시 확인하고, 소비 패턴을 연속성 있게 추적할 수 있는 모바일 가계부
- **핵심 기능**
  - **온보딩:** 초기 화폐 단위/예산을 설정하고 월간 자율 지출 목표까지 입력
  - **홈:** 일간·월간 원형 게이지, 오늘 지출 요약, 목표 달성 streak, 빠른 지출 등록
  - **캘린더:** 날짜별 성공/실패 배지, 필수/자율 지출 합계, 월간 통계 패널
  - **통계:** 카테고리 파이차트, Top3 지출, 월 변경 시 즉시 재계산
  - **지출 내역:** 유형/카테고리/정렬 필터, 바텀시트 입력 폼
  - **설정:** 예산·다크 모드·알림 토글, 데이터 초기화, 문의, 업데이트·리뷰 유도
- **타깃:** 20~30대 대학생·사회초년층. 다국어 지원(KR/EN/ID/MY)으로 동남아 시장까지 확장 가능한 구조

---

## Architecture At A Glance

```text
lib/
 ├── core/                  # 공통 인프라 (DB, 서비스, 라우터, 테마, Provider)
 ├── features/
 │   ├── home/
 │   ├── calendar/
 │   ├── expense/
 │   ├── statistics/
 │   └── settings/
 ├── widgets/               # 전역 공용 위젯
 └── l10n/                  # 다국어 리소스
```

- **State management:** `flutter_riverpod` 기반 MVVM. 각 기능은 `features/{feature}` 아래에서 `view`, `viewmodel`, `model`, `widgets`를 필요에 따라 조합해 구성하며, 모든 feature가 동일한 폴더 세트를 갖는 것은 아닙니다.
- **Navigation:** `go_router` (`core/router/app_router.dart`)의 ShellRoute를 활용해 하단 탭 네비게이션과 라우팅을 모듈화. Firebase Analytics observer를 붙여 화면 전환 로그를 자동 수집.
- **Dependency graph:** Provider tree에서 Repository·Service를 주입 (`core/providers/repository_providers.dart`). DB 싱글톤, NotificationService, Supabase Client 등은 Provider를 통해 lazy load.

---

## Data Pipeline & Persistence

1. **앱 부팅**

   - `main.dart`에서 `.env` 로드 → Supabase/Firebase 초기화 → `ProviderScope` 진입.
   - `app_initializerProvider` (`core/services/app_initializer.dart`)가 Remote Config, AdMob, Notification, (디버그) 더미 데이터까지 순차 초기화.

2. **사용자 식별**

   - `UserSettingsNotifier` (`features/settings/viewmodel/user_settings_provider.dart`)가 Supabase 익명 로그인으로 UID 확보. 로컬 SQLite(`DatabaseHelper`)에 사용자 레코드가 없으면 즉시 생성.

3. **로컬 데이터 저장소**

   - SQLite + `sqflite` 사용. `DatabaseHelper`는 **Singleton + lazy init**으로 커넥션을 공유하며, `_seedDatabase`로 기본 카테고리/예산을 주입.
   - Repositories (`core/repositories/*.dart`)는 CRUD를 담당하며, Interface 기반으로 레이어 분리. 필요 시 Supabase 전환을 고려해 추상화 유지.

4. **고수준 상태**

   - `coreExpensesProvider` (`AsyncNotifier`)가 월별 지출 Map을 캐싱해 중복 쿼리를 제거. `loadMonthlyExpenses`는 `(year, month)` 키로 메모리 캐시를 유지해 화면 전환 시 즉시 응답.
   - ViewModel 단계에서 지표 계산: 예: `HomeViewModel`은 남은 예산/연속 달성일/일일·월간 예산을 계산해 도메인 모델 `HomeState`로 전달.

5. **UI 반영**
   - 각 화면은 `AsyncValue`를 구독해 `loading/error/data` UI를 스스로 처리. 필터/달력 선택 등은 `NotifierProvider`(`select_date_provider.dart`)로 글로벌 날짜 컨텍스트 공유.

---

## Feature Modules

### Onboarding (`features/onboarding`)

- 3단계 설명 → `BudgetSetupScreen`에서 일/월 예산 선택 및 입력.
- 제출 시 `UserSettingsNotifier.updateBudget` 호출, Firebase Analytics `onboarding_complete` 이벤트와 함께 홈으로 라우팅하며 알림 권한 다이얼로그 트리거.

### Home (`features/home`)

- 핵심 KPI 카드 + 오늘 지출 바텀 시트.  
  `HomeViewModel`이 일간/월간 잔여 예산, 월평균 지출, 연속 달성일 등을 계산해 `HomeMainCard`·`HomeActionButtons`에 공급.
- `ScreenType.home` 배너 광고와 Interstitial 전환 기록 (`InterstitialAdManager.logActionAndShowAd`)으로 수익화 포인트 확보.

### Calendar (`features/calendar`)

- `CalendarState`는 날짜별 `CalendarCellData`를 캐싱, 자율/필수 지출 합계와 성공 배지를 계산.
- 상단 `CalendarStat`는 월간 총 지출, 성공/실패/연속 성공일을 한꺼번에 제공 → 소비 리듬 파악에 집중.

### Statistics (`features/statistics`)

- 월별 카테고리 지출을 `StatisticsModel`로 작성 후 `fl_chart` 파이차트로 시각화.
- `changeDate` 호출 시 전역 날짜 컨텍스트 갱신 → 홈·지출 내역과 자연스럽게 동기화.

### Expense List (`features/expense`)

- 월별 데이터를 필터링(`ExpensesListViewModel.filteringData`)해 날짜→지출 리스트 Map 구성.
- 유형/카테고리/정렬 필터를 바텀시트(`ExpenseFilterBottomSheet`)에서 조정, 결과는 즉시 Provider 상태로 반영.
- 지출 추가/수정 UI는 `BaseBottomSheet` + `ExpenseAddForm` 조합. 제출 시 리뷰 유도(`ReviewPromptService`)와 광고 정책을 동시에 처리.

### Settings (`features/settings`)

- 섹션 단위로 상태를 분리: 예산 수정, 알림, 다크 모드, 데이터 초기화, 문의, 버전/정책.
- `DataResetService.resetAllData`가 SQLite 초기화 후 `FlutterPhoenix`로 앱을 재시작.
- 문의(`ContactUsDialog`)는 Supabase `user_contact` 테이블에 저장해 고객 응대를 손쉽게 할 수 있도록 설계.

---

## Cross-cutting Services & Growth Loops

- **Update Gate** (`core/widgets/update_gate.dart`, `UpdateCheckScreen`): Firebase Remote Config로 강제/권장 업데이트를 판별하고, 모달·배너로 노출. Changelog JSON을 로케일별로 파싱.
- **NotificationService:** `flutter_local_notifications`와 `timezone` 패키지를 이용해 10/14/20시 알림 예약. 권한 거부 시 앱 설정 이동 안내까지 포함.
- **AdService:** 테스트/실서비스 앱 ID를 분리하고, 배너/Banner · 전면/Interstitial · 앱 오픈 광고까지 클래스로 관리. 액션 횟수 기반 쿨다운으로 UX 저하 방지.
- **ReviewPromptService:** SharedPreferences에 리뷰 프롬프트 메타데이터를 저장해 노출 빈도/스누즈/opt-out을 제어. Supabase에 부정 피드백을 수집하고, 긍정 시 스토어로 유도.
- **Analytics:** Firebase Analytics로 지출 생성(`create_transaction`), 온보딩 완료, 데이터 초기화 등 핵심 이벤트 추적.
- **Localization:** `l10n.yaml` + `lib/l10n/*.arb`로 한국어·영어·필리핀어·말레이시아어 지원. 카테고리 라벨까지 로케일별로 반환 (`categoryProvider.getCategoryName`).
- **Design System:** `AppTheme`와 `DesignPalette`가 다크/라이트 테마, 텍스트 스타일, 재사용 카드 데코레이션을 제공. 프라이머리 브라운 톤을 중심으로 재무 앱의 신뢰감을 확보.

---

## Developer Experience Highlights

- **Repository Abstraction:** Interface 위에 구현체를 올려, 향후 Supabase 등 원격 동기화 레이어를 추가하기 용이.
- **DatabaseSeeder:** 디버그 모드에서 지역별 현실적인 예산 데이터를 생성, UI 테스트와 시연을 빠르게 진행 가능.
- **Bottom Sheet Framework:** `BaseBottomSheet`로 공통 타이틀/닫기/버튼 레이아웃을 확보해 모듈 간 일관된 UX 구현.
- **Routing Analytics:** `FirebaseAnalyticsObserver`를 단일 지점에 추가해, 라우팅 코드 수정을 최소화하면서도 이벤트 수집.
- **Project Governance:** `REFACTORING_ROADMAP.md`, `todo.md` 등 문서로 리팩토링 진행 상황을 추적.

---

## Impact & Metrics

- **사용자 유지 장치:** 알림 스케줄링 + 연속 성공일/예산 KPI 시각화로 데일리 액션을 유도.
- **수익화:** 앱 오픈/배너/전면 광고를 화면 컨텍스트 기준으로 제어해 eCPM 최적화.
- **국제 확장:** 다국어·다통화 포맷(`formatCurrencyAdaptive`)을 갖춘 덕분에 KR/EN/ID/MY 스토어 런칭을 신속히 반복.
- **지원 채널:** Supabase 기반 문의/피드백 수집 파이프라인으로 고객 대응 속도 향상.

---

## Lessons & Next Steps

- 현재 위젯 테스트는 기본 샘플(`test/widget_test.dart`) 수준 → **ViewModel 단위 테스트**와 **통계 계산 회귀 테스트**를 추가해 신뢰도 확보 필요.
- Riverpod 캐시 갱신 로직은 월 기준으로 최적화되어 있으나, 특정 날짜 수정 시 다른 월 영향 여부를 감지하는 인덱싱 개선 여지 존재.
- Supabase와 SQLite를 이중으로 사용하는 만큼, 오프라인→온라인 동기화 전략(충돌 해소, 백그라운드 싱크)을 구체화하면 SaaS로 확장 가능.
- Google 애널리틱스를 통한 이벤트가 늘어남에 따라, **Amplitude/Mixpanel** 등 퍼널 분석 도구 연동을 검토해 마케팅 효율화.

---

## Tech Stack

`Flutter 3.8`, `Riverpod`, `sqflite`, `Supabase`, `Firebase (Core/Analytics/Remote Config)`, `Google Mobile Ads`, `GoRouter`, `Intl`, `Flutter Local Notifications`, `Flutter Phoenix`, `fl_chart`
