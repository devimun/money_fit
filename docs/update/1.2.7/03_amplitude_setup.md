# MoneyFit 1.2.7 — Amplitude 도입 계획

> 작성일·공식 문서 조회일: 2026-07-21 (KST)  
> 범위: 구현 계획만 작성. 앱 코드·의존성·스토어 설정은 이 문서에서 변경하지 않는다.

## 0. 결론

MoneyFit에는 이미 Firebase Analytics 화면 추적과 3개 수동 이벤트가 있지만, 이벤트 호출이 UI/Provider/Service에 직접 흩어져 있고 사용자 식별·속성·분석 동의·스키마 규칙이 없다. 1.2.7에서는 다음 구조로 옮긴다.

1. 공식 `amplitude_flutter` v4 SDK를 사용한다. 조사 시점 최신판은 `4.6.1`이며, 이 저장소의 Dart `^3.8.1`, Flutter 3.8+, iOS 13, Gradle 8.12, AGP 8.7.3, Kotlin 2.1.0 조건은 SDK 최소 조건을 충족한다.
2. `AnalyticsService` 한 곳으로 모든 호출을 모으고 Amplitude와 기존 Firebase Analytics를 1개 릴리스 동안 병행한다. 기능 코드가 어느 벤더 SDK도 직접 import하지 않게 한다.
3. Amplitude의 `MoneyFit Dev`와 `MoneyFit Prod` 프로젝트/API key를 분리한다. 로컬 debug/profile은 Dev, Fastlane으로 서명한 TestFlight/Internal/Production 후보는 현재 “같은 바이너리 승격” 구조 때문에 Prod를 사용한다.
4. 이벤트명과 속성값은 번역하지 않는다. 14개 언어는 `language_code`, 통화는 `currency_code`로만 나눈다.
5. 거래명·정확한 금액·이메일·문의/피드백 본문·사용자 정의 카테고리명/UUID는 절대 Amplitude에 보내지 않는다.
6. 기존 Supabase 익명 UID는 무작위 UUID이며 문의/피드백에서도 이미 쓰고 있다. 동의 후 이를 **가명(pseudonymous) `userId`** 로 사용하되 이메일/표시명은 보내지 않는다. 익명 Auth가 새로 생성되거나 로그아웃될 때는 Amplitude `reset()`도 같이 호출한다.
7. 핵심 활성화 지표는 “첫 예산 설정 후 첫 거래 기록”, 핵심 유지 행동은 “거래 기록”으로 정의한다. 광고·의견 모달 계획과도 같은 taxonomy를 공유해 1.2.7 전후 이탈/유지율을 측정한다.

Amplitude Flutter 4는 `Amplitude(Configuration(...))`, `await amplitude.isBuilt`, `track(BaseEvent(...))`, `identify`, `setUserId`, `setOptOut`, `reset`, `flush`를 제공하며, 기본 이벤트는 로컬 큐에 저장 후 묶어서 전송한다. 공식 문서상 기본 queue/flush 값은 30건/30초다. MoneyFit 규모에서는 우선 기본값을 유지한다.

## 1. 저장소 현황 감사

### 1.1 기존 Analytics

| 위치·심볼 | 현재 동작 | 문제/이관 포인트 |
|---|---|---|
| `pubspec.yaml` | `firebase_analytics: ^11.5.2`, `firebase_core`, `firebase_remote_config` 사용 | Amplitude 추가 후에도 Remote Config 때문에 `firebase_core`는 유지한다. Firebase Analytics만 1.2.8 이후 제거 후보다. |
| `lib/main.dart::main` | dotenv → Supabase → Firebase → SharedPreferences 순으로 초기화 | Amplitude key를 `.env` asset에 추가하지 않는다. 빌드별 `--dart-define`을 쓰고, SharedPreferences의 동의 상태를 읽어 SDK opt-out 상태를 정한 뒤 앱을 띄운다. |
| `lib/core/router/app_router.dart::goRouterProvider` | `FirebaseAnalyticsObserver`, `settings.name` 기반 화면 추적 | Amplitude에는 Flutter용 Navigator observer가 내장돼 있지 않다. 별도 observer를 추가한다. 수동 `NoTransitionPage`에도 `name: state.name`을 넣어 ShellRoute 하위 화면명이 null이 되지 않게 검증한다. |
| `lib/core/providers/expenses_provider.dart::CoreExpensesNotifier.addExpense` | `create_transaction` + `type`, `category` 전송 | 분석 호출을 기다리느라 비즈니스 흐름이 지연될 수 있다. `category`는 사용자 UUID일 수 있어 고카디널리티/개인정보 위험이 있다. 저장 성공 뒤 facade에 비차단 방식으로 전달하고 카테고리를 sanitize한다. |
| `lib/features/onboarding/view/budget_setup_screen.dart::_submitBudget` | `first_budget_setting` | 실제 의미는 첫 예산 설정이다. `Budget Set {is_initial:true}`로 통합하고 Amplitude에서 파생 이벤트 `Onboarding Completed`를 정의한다. 금액은 보내지 않는다. |
| `lib/core/services/data_reset_service.dart::resetAllData` | `data_reset` 후 SQLite 삭제 | facade 주입이 불가능한 static 구조다. Provider/인스턴스로 전환하거나 analytics 인자를 주입한다. 로컬 데이터 초기화는 계정 로그아웃이 아니므로 Amplitude identity까지 reset하지 않는다. |
| 그 외 | Firebase `setUserId`, `setUserProperty`, 수집 동의/opt-out 호출 없음 | 현재 GA 데이터는 기기 중심이며 로케일·통화·설정별 분석이 어렵다. Amplitude Identify와 공통 동의 저장소를 추가한다. |

현재 수동 Firebase 이벤트는 코드 기준 정확히 아래 3개다.

| Firebase 현재값 | Amplitude canonical event | 호환 규칙 |
|---|---|---|
| `create_transaction` | `Transaction Created` | `type` → `transaction_type`; `category` → allowlist 기반 `category_key`와 `is_custom_category` |
| `first_budget_setting` | `Budget Set` | `is_initial=true`, `budget_period=daily|monthly`; amount 금지 |
| `data_reset` | `Data Reset` | 사용자 확인 후 DB 삭제 시작 직전에 1회 |
| Firebase 자동 `screen_view` | `Screen Viewed` | `screen_name`은 고정 영문 enum, 화면 제목 번역문은 금지 |

### 1.2 식별·개인정보·동의 현황

- `UserSettingsNotifier._getSupabaseUser()`는 `signInAnonymously()`로 UUID를 얻고 로컬 `User.id`로 사용한다.
- `ContactUsDialog._submit()`은 같은 UID와 이메일·문의 본문을 Supabase `user_contact`에 저장한다.
- `ReviewPromptService.submitNegativeFeedback()`은 UID와 자유 텍스트를 Supabase `app_feedback`에 저장한다.
- `User`에는 이메일, 표시명, 예산, 언어, 통화, 알림 설정이 있다. 현재 `log('User loaded successfully: ${user.toJson()}')`도 전체 값을 로컬 로그에 출력한다. 이 객체를 통째로 analytics property로 넘기면 안 된다.
- 앱 안에는 Analytics 동의/거부 상태가 없고 개인정보 처리방침 링크만 있다. 링크는 한국어/영어/필리핀어/말레이어 4개이며 나머지 10개 로케일은 영어로 fallback한다. 외부 Notion 본문은 조사 환경에서 열리지 않아 현재 Amplitude 고지 여부를 검증하지 못했다.
- Apple App Privacy 및 Google Play Data Safety 응답도 저장소에는 없으므로 실제 콘솔에서 별도 확인해야 한다.

### 1.3 다국어 현황

`lib/core/config/locale_config.dart`는 `ko`, `en`, `es`, `pl`, `uk`, `cs`, `de`, `it`, `ro`, `sk`, `bg`, `id`, `ms`, `fil`의 14개 언어/통화를 지원한다. 이벤트명·속성 key·enum value를 l10n에서 가져오면 같은 행동이 언어별로 14개 이벤트로 쪼개진다. 문의 유형도 현재 localized label을 그대로 DB에 넣으므로 Analytics에서는 반드시 `bug_report`, `feature_suggestion`, `general_inquiry`, `other`의 내부 enum으로 먼저 변환한다.

### 1.4 배포/키 제약

- Android `fastlane beta`가 release AAB를 Internal에 올리고 `release`는 그 AAB를 Production으로 승격한다.
- iOS `fastlane beta`가 TestFlight 바이너리를 만들고 `release`는 최신 바이너리를 선택한다.
- 따라서 beta 바이너리에 Dev key를 넣었다가 그대로 운영으로 승격하면 운영 데이터가 Dev 프로젝트로 유출된다. 현 배포 구조를 유지하는 1.2.7에서는 **로컬 debug/profile만 Dev key, Fastlane beta/release candidate는 Prod key**로 고정한다.
- QA 이벤트는 Amplitude에서 내부 Supabase UID cohort로 관리하고 모든 운영 대시보드에서 `Internal / QA Users` cohort를 제외한다. Dev/Prod를 TestFlight까지 완전 분리하려면 이후 별도 bundle/application ID를 가진 flavor가 필요하다.

## 2. 목표와 비목표

### 목표

- 첫 실행 → 예산 설정 → 첫 거래 생성의 전환율과 소요 시간을 측정한다.
- 거래 생성 사용자의 D1/D7/D30 유지율을 언어·플랫폼·버전별로 본다.
- 캘린더, 통계, 필터, 알림, 테마, 문의/의견, 광고 노출이 핵심 행동과 유지율에 미치는 영향을 본다.
- 새 이벤트가 임의로 추가되거나 PII가 유입되지 않도록 tracking plan을 소스 오브 트루스로 만든다.
- Amplitude 장애/키 누락이 앱 기능을 막지 않고 Firebase로 즉시 되돌릴 수 있게 한다.

### 비목표

- 1.2.7에서 Firebase Remote Config를 제거하지 않는다.
- Session Replay, Experiment, Guides & Surveys SDK는 이번 범위에 넣지 않는다.
- 거래 금액을 매출로 해석하거나 Amplitude Revenue API로 보내지 않는다. MoneyFit 지출은 앱 매출이 아니다.
- 과거 Firebase 원시 데이터를 Amplitude에 backfill하지 않는다. 1.2.7 릴리스일을 Amplitude 추세의 시작점으로 표시한다.
- 광고 SDK의 수익값/광고주 식별자를 Amplitude에 결합하지 않는다.

## 3. SDK와 프로젝트 설정

### 3.1 패키지/플랫폼

구현 시 `pubspec.yaml`에 검증된 최신 4.x 버전을 추가한다. 조사 시점 후보는 다음과 같다.

```yaml
dependencies:
  amplitude_flutter: ^4.6.1
```

계획 단계에서는 `pubspec.lock`을 손대지 않는다. 실제 구현 PR에서만 `flutter pub get`으로 갱신하고 diff를 검토한다.

호환성 체크:

- iOS: 공식 최소 `platform :ios, '13.0'`; 저장소 `ios/Podfile`과 Xcode target 모두 이미 13.0이다.
- Android: SDK 4 최소 Gradle 8.2, AGP 8.2.2, Kotlin 1.9.22; 저장소는 각각 8.12, 8.7.3, 2.1.0이다.
- Flutter/Dart: SDK 4 최소 Flutter 3.7/Dart 3.3; 저장소는 Flutter 3.8 계열/Dart `^3.8.1`이다.

### 3.2 Amplitude 프로젝트

1. 같은 Amplitude organization 안에 `MoneyFit Dev`와 `MoneyFit Prod`를 만든다.
2. 두 프로젝트에 동일한 tracking plan을 등록한다.
3. 프로젝트 API key만 클라이언트에 넣는다. **API secret, Privacy API credential, management token은 절대 앱/저장소에 넣지 않는다.** 클라이언트 API key는 비밀값은 아니지만 환경 오염 방지를 위해 코드에 하드코딩하지 않는다.
4. 데이터 저장 지역은 정책 검토 후 US 또는 EU 한 곳으로 확정한다. EU를 선택했다면 프로젝트 자체를 Amplitude EU에 만들고 SDK도 `ServerZone.eu`로 맞춘다. key와 zone을 섞으면 안 된다.
5. 프로젝트 timezone은 운영 의사결정 기준인 `Asia/Seoul`로 맞추되, 이벤트 시간은 SDK 기본 UTC timestamp를 사용한다.

### 3.3 build-time 설정

새 `lib/core/config/analytics_config.dart`가 아래 compile-time 값만 읽게 한다.

```text
AMPLITUDE_API_KEY
AMPLITUDE_SERVER_ZONE=us|eu
ANALYTICS_ENV=dev|prod
AMPLITUDE_ENABLED=true|false
```

- `String.fromEnvironment`을 사용하고 `.env` asset에는 추가하지 않는다.
- debug/profile 실행은 `AMPLITUDE_DEV_API_KEY`, Fastlane beta는 `AMPLITUDE_PROD_API_KEY`를 shell/CI 환경에서 `--dart-define`으로 넘긴다.
- key가 없으면 앱을 crash시키지 않고 `NoopAnalytics`로 동작하되 debug 로그/테스트는 실패 신호를 낸다. production build 검증 단계에서는 key 누락을 사전 실패시킨다.
- Fastlane 로그에 실제 key를 출력하지 않는다.
- Android `Fastfile::beta`의 `flutter build appbundle --release`와 iOS `build_app`의 Flutter dart-define 전달 방식을 각각 smoke test한다. iOS는 `DART_DEFINES` base64/Flutter build wrapper 전달이 빌드 환경마다 달라질 수 있으므로 archive 안에서 설정값을 확인하는 테스트를 포함한다.

### 3.4 권장 SDK Configuration

초기값은 명시적으로 고정한다. `AutocaptureEnabled()`는 향후 SDK가 추가하는 자동 이벤트까지 켤 수 있으므로 사용하지 않는다.

```text
autocapture:
  sessions=true
  appLifecycles=true
  deepLinks=false        # Android만 지원되어 플랫폼 비교를 왜곡하므로 이번에는 끔
locationListening=false
useAdvertisingIdForDeviceId=false
useAppSetIdForDeviceId=false
flushQueueSize=30
flushIntervalMillis=30000
logLevel=debug(debug build) / warn(release)
```

`TrackingOptions`는 분석에 필요한 platform/language/app version/OS만 남기고 다음 값은 끈다: `ipAddress`, `region`, `dma`, `country`, `city`, `carrier`, `latLag`, `adid`, `appSetId`, `idfv`. 정확한 위치·광고 식별자는 MoneyFit의 제품 분석에 필요하지 않다. 기기 모델도 꼭 필요한 버그 분석 목적이 없다면 끄는 쪽을 우선한다.

## 4. 코드 구조와 파일·심볼 단위 작업

### 4.1 새 파일

| 파일 | 책임 |
|---|---|
| `lib/core/config/analytics_config.dart` | dart-define 파싱, dev/prod/zone/enabled 검증. key 값 자체는 로그/`toString()`에서 숨김. |
| `lib/core/analytics/analytics_event.dart` | event name, property key, 허용 enum, `schema_version=1`의 단일 정의. 문자열 literal을 기능 코드에서 금지. |
| `lib/core/analytics/analytics_service.dart` | Amplitude 초기화, Firebase legacy mapping, `track`, `identify`, `setUserId`, `setCollectionEnabled`, `reset`, `flush`. 각 sink 실패를 독립적으로 삼켜 사용자 흐름을 보존. |
| `lib/core/analytics/analytics_sanitizer.dart` | PII key denylist와 속성 타입/길이/카디널리티 검증. 기본 카테고리 allowlist 외 값은 `custom`으로 치환. |
| `lib/core/analytics/analytics_navigator_observer.dart` | `didPush`, `didReplace`, 필요 시 `didPop`에서 중복 없이 `Screen Viewed` 전송. route name allowlist만 허용. |
| `lib/core/providers/analytics_provider.dart` | 초기화된 service를 Riverpod으로 제공해 widget/provider 테스트에서 fake로 override. |
| `lib/core/repositories/analytics_consent_repository.dart` | SharedPreferences의 `analytics_collection_enabled`, `analytics_consent_version` 저장·조회. |
| `lib/features/settings/widgets/analytics_setting.dart` | 사용자가 수집을 켜거나 끄는 스위치와 정책 링크. 법적 근거가 opt-in이면 첫 선택 전 disabled. |

### 4.2 기존 파일 수정

| 파일·심볼 | 구체 작업 |
|---|---|
| `lib/main.dart::main` | SharedPreferences 동의 상태와 `AnalyticsConfig`를 읽어 service 초기화. `await amplitude.isBuilt` 실패 시 Noop으로 계속. `ProviderScope`에 service/consent override. SDK 초기화는 오직 여기에서 시작하도록 보장. |
| `lib/main.dart::_MyAppState` | `userSettingsProvider`가 성공하면 `analytics.setUserId(user.id)` 후 안전한 user properties를 Identify. locale/theme 설정 변화 listener는 중복 Identify를 피하도록 마지막 값과 비교. |
| `lib/core/router/app_router.dart::goRouterProvider` | Amplitude observer 추가, 기존 Firebase observer는 dual-write 기간 유지. 모든 `NoTransitionPage`에 stable `name` 부여. `/update-check`, `/`, `/budget_setup`, `/home`, `/calendar`, `/stats`, `/expense_list`, `/settings`를 각각 canonical screen enum으로 매핑. |
| `lib/core/providers/expenses_provider.dart` | Firebase import 제거. `addExpense` 저장 성공 후 `Transaction Created`; `updateExpense` 성공 후 `Transaction Updated`; `deleteExpense` 성공 후 `Transaction Deleted`. 이벤트 실패로 CRUD를 rollback하지 않음. |
| `lib/core/widgets/expense_management/expense_add_form.dart` | 폼 entry point(`home`, `calendar`, `expense_list`)을 명시적으로 받아 event property로 넘김. 이름/금액/text controller 값은 analytics로 전달 금지. |
| `lib/features/onboarding/view/budget_setup_screen.dart::_submitBudget` | `Budget Set`의 `is_initial=true`, `budget_period` 전송. DB update가 성공한 뒤 전송. |
| `lib/features/settings/widgets/budget_setting.dart::_showBudgetDialog` | 같은 `Budget Set`에 `is_initial=false`, 변경 전/후 period만 전송. 금액 및 변화량 금지. |
| `lib/features/settings/viewmodel/user_settings_provider.dart::_loadUser` | UID 확정 뒤 identity를 한 번 설정. `reset()`이 실제 Supabase sign-out/new anonymous user를 만들므로 시작 직전에 analytics `flush` 후 `reset`, 새 UID 생성 뒤 다시 `setUserId`. |
| `lib/core/services/data_reset_service.dart` | static Firebase 호출 제거. analytics를 주입받는 service/provider로 변경. `Data Reset` 전송 후 로컬 DB만 삭제하며 identity는 유지. |
| `lib/features/settings/widgets/language_setting.dart::_changeLocale` | 저장 성공 후 `Language Changed {from_language,to_language,currency_code}`. 표시명/국기/번역문 금지. Identify의 `language_code`, `currency_code` 갱신. |
| `lib/features/settings/widgets/notification_setting.dart::_handleNotificationToggle` | 실제 permission/result가 확정된 뒤 `Notification Preference Changed {enabled, permission_result}`. 요청 전 토글 값만 보내지 않음. |
| `lib/core/providers/theme_provider.dart` 및 설정 widgets | P1로 `Theme Preference Changed`/`Font Size Changed`; 색상 hex는 고카디널리티이므로 `preset|custom`만 전송. |
| `lib/features/expense/viewmodel/expense_list_provider.dart::applyFilters` | `Expense Filter Applied`에 filter 사용 여부/type/sort/month_offset만 전송. 카테고리는 기본 allowlist 또는 `custom`. |
| `lib/features/statistics/viewmodel/view_model.dart` | 기간/지출 유형 변경 이벤트. 같은 값을 다시 누른 경우 이벤트 금지. |
| `lib/core/providers/category_providers.dart` | 생성/삭제 성공 뒤 `Category Created/Deleted`에 expense type만 전송. 이름/UUID 금지. |
| `lib/features/settings/widgets/contact_us_dialog.dart` | 문의 성공/실패만 `Inquiry Submitted`. email/details 금지. localized `_selectedInquiryType` 대신 stable enum을 도입하고 UI에서만 번역. Slack 알림 계획과 enum을 공유. |
| `lib/core/services/review_prompt_service.dart` | prompt shown/answer/submit result를 측정하되 자유 입력 `detail`은 Supabase에만 저장. 1.2.7 의견 모달 계획과 중복 노출되지 않게 공동 eligibility coordinator 사용. |
| `lib/core/services/ad_service.dart` | 광고 계획에서 load/display/impression/dismiss/fail callback을 추가할 때 공통 taxonomy 사용. 광고 unit ID, 광고주 정보는 보내지 않음. |
| `lib/features/settings/widgets/app_information_section.dart` | Analytics 설정 UI 추가. 개인정보 처리방침으로 바로 이동 가능하게 유지. |
| `lib/l10n/app_*.arb` | 동의/Analytics 설정 문자열을 14개 ARB에 추가. 생성된 `app_localizations_*.dart`는 직접 수정하지 않고 gen-l10n으로 재생성. |
| `lib/core/services/update_service.dart` | 선택 사항이지만 권장: Remote Config `amplitude_collection_enabled` kill switch 기본값 추가. 사용자 동의와 remote gate가 모두 true일 때만 수집. fetch 실패 시 마지막 활성값/보수적 기본값 사용. |
| `ios/fastlane/Fastfile`, `android/fastlane/Fastfile` | beta archive/AAB에 Prod API key와 zone 전달, 값 존재 여부만 확인. release lane이 기존 beta 바이너리를 승격한다는 사실을 주석/README에 명시. |

### 4.3 호출 규칙

- 화면/widget은 SDK 인스턴스에 접근하지 않고 `ref.read(analyticsProvider)`만 사용한다.
- 비즈니스 작업은 **DB/권한/서버 성공 후** 기록한다. 버튼 tap과 성공을 혼동하지 않는다.
- analytics 실패는 사용자에게 snackbar를 띄우거나 본 작업을 실패시키지 않는다.
- 같은 이벤트는 한 계층에서만 보낸다. 예: 거래 생성은 form button이 아니라 repository 성공을 알고 있는 `CoreExpensesNotifier.addExpense`에서 보낸다.
- event property는 `Map<String, Object>`의 허용 타입만 사용하고 null property는 제거한다.
- 앱 lifecycle/세션은 Amplitude autocapture를 사용하며 별도 `App Opened`, `Session Started` custom 이벤트를 만들지 않는다.

## 5. 이벤트 taxonomy v1

명명 규칙은 Amplitude 권장 방식에 맞춰 사용자 관점의 영문 Title Case, `[Object] [Past-tense Verb]`를 사용한다. 속성 key/value는 `lower_snake_case`다. 이벤트나 enum을 rename하지 않고 의미가 바뀌면 schema version을 올리거나 새 이벤트를 만든다.

### 5.1 공통 속성

모든 custom event에 facade가 자동 부착한다.

| 속성 | 타입/예시 | 규칙 |
|---|---|---|
| `schema_version` | int `1` | tracking plan breaking change 때만 증가 |
| `analytics_env` | `dev|prod` | 프로젝트 분리 오류 확인용 |
| `language_code` | `ko`, `en` 등 | ISO-like 지원 코드, 번역명 금지 |
| `currency_code` | `KRW`, `USD` 등 | 정확한 금액 없이 통화권 분석 |
| `source_screen` | stable screen enum | 해당되는 이벤트만. route path/user input 금지 |

SDK가 자동 제공하는 platform, OS, app version, device 정보는 같은 이름으로 다시 보내지 않는다.

### 5.2 P0 — 1.2.7 필수

| 이벤트 | 발생 시점 | 속성 | 코드 지점/분석 목적 |
|---|---|---|---|
| `Screen Viewed` | canonical 화면이 foreground route가 됐을 때 1회 | `screen_name`, `previous_screen_name`, `navigation_type` | `AnalyticsNavigatorObserver`; 화면 도달/경로 |
| `Budget Set` | 첫 예산/설정 예산 저장 성공 | `is_initial:bool`, `budget_period:daily|monthly`, `previous_budget_period?` | onboarding/settings; activation. `amount` 금지 |
| `Transaction Created` | SQLite insert 성공 | `transaction_type:essential|discretionary`, `category_key`, `is_custom_category`, `entry_point` | 핵심 가치 행동 |
| `Transaction Updated` | SQLite update 성공 | 위와 동일, `changed_fields`는 `type|category|date|amount|name`의 배열만 | 편집 수요. 실제 값 금지 |
| `Transaction Deleted` | SQLite delete 성공 | `transaction_type`, `category_key`, `is_custom_category`, `source_screen` | 입력 마찰/정리 행동 |
| `Expense Filter Applied` | 필터 적용 | `has_type_filter`, `has_category_filter`, `category_key?`, `sort_order`, `month_offset_bucket` | 검색/필터 가치 |
| `Statistics View Changed` | 월 또는 지출 유형이 실제 변경 | `control:period|transaction_type`, `transaction_type?`, `month_offset_bucket?` | 통계 사용성 |
| `Calendar Period Changed` | 월 이동/선택 성공 | `method:previous|next|picker`, `month_offset_bucket` | 캘린더 탐색 |
| `Notification Preference Changed` | OS 권한과 앱 설정 결과 확정 | `enabled`, `permission_result:granted|denied|permanently_denied|not_required` | 알림 adoption |
| `Language Changed` | locale/DB 저장 성공 | `from_language`, `to_language`, `currency_code` | 다국어 유지율 비교 |
| `Inquiry Submitted` | Supabase insert 결과 | `inquiry_type:bug_report|feature_suggestion|general_inquiry|other`, `result:success|failure` | 문의/Slack 파이프라인 건강도. email/body 금지 |
| `Feedback Submitted` | 리뷰/새 의견의 Supabase commit 성공 | `source:review_negative|proactive_prompt`, `length_bucket`, `attempt_count_bucket` | 본문 없이 제출 전환 측정. 실패는 `Feedback Submission Failed`로 분리 |
| `Data Reset` | 사용자가 확인하고 초기화 시작 | `scope:local_database` | churn/재온보딩 신호 |

기본 카테고리 `food`, `traffic`, `communication`, `housing`, `medical`, `insurance`, `necessities`, `finance`, `eating-out`, `cafe`, `shopping`, `hobby`, `travel`, `subscribe`, `beauty`만 `category_key`로 허용한다. 나머지 UUID/문자열은 무조건 `custom`으로 치환한다. 사용자 정의 카테고리 이름은 보내지 않는다.

`month_offset_bucket`은 정확한 YYYY-MM가 아니라 `current`, `past_1_3`, `past_4_12`, `past_13_plus`로 보낸다. 사용자의 재무 활동 시점을 과도하게 상세화하지 않으면서 과거 탐색 깊이는 분석할 수 있다.

### 5.3 P0 — 광고/의견 모달과 공동 사용

| 이벤트 | 속성 | 비고 |
|---|---|---|
| `Ad Action Recorded` | `trigger`, `screen`, `action_count`, `ad_policy_version` | 유효 행동만 기록 |
| `Ad Opportunity` | `opportunity`, `eligible`, `suppress_reason`, `ad_policy_version` | 자연스러운 중단점에서 eligibility 판정 |
| `Ad Request` | `ad_format:banner|interstitial|app_open`, `placement`, `platform` | SDK load 요청 |
| `Ad Load Completed` | `ad_format`, `placement`, `result:success|failure`, `latency_ms`, `error_code?`, `error_domain?` | raw error message나 unit ID 금지 |
| `Ad Displayed` | `ad_format`, `placement`, `trigger`, `ad_policy_version` | Google show callback에서 기록 |
| `Ad Impression` | `ad_format`, `placement`, `ad_policy_version` | SDK impression callback에서 기록 |
| `Ad Clicked` | `ad_format`, `placement` | SDK click callback에서 기록 |
| `Ad Dismissed` | `ad_format`, `placement`, `visible_duration_ms` | 전면 광고 이후 핵심 행동 이탈 분석 |
| `Ad Display Failed` | `ad_format`, `placement`, `error_code` | 표시 실패 원인 분리 |
| `Ad Revenue Tracked` | `ad_format`, `placement`, `value_micros`, `currency_code`, `precision` | `onPaidEvent`; 지출 금액과 혼동 금지 |
| `Ad Config Invalid` | `key`, `value_source`, `ad_policy_version` | 비정상 Remote Config 값 fallback |
| `Feedback Prompt Opportunity` | `variant`, `eligible`, `suppress_reason`, `policy_version`, `trigger` | 리뷰/광고와 상호배제된 safe point 평가 |
| `Feedback Prompt Shown` | `variant`, `policy_version`, `install_age_bucket`, `action_count_bucket`, `session_count_bucket` | 실제 dialog가 열린 뒤 기록 |
| `Feedback Prompt Responded` | `action:submit|later|dismiss|never`, `policy_version`, `visible_duration_bucket` | 본문 금지 |
| `Feedback Submitted` | `source:review_negative|proactive_prompt`, `length_bucket`, `attempt_count_bucket` | Supabase commit 성공 뒤 기록 |
| `Feedback Submission Failed` | `source`, `error_category`, `attempt_count_bucket` | 실패 원문·오류 전문 금지 |

광고 횟수 증가 실험은 `ad_policy_version`을 반드시 넣는다. 그래야 1.2.6 기준 정책과 새 threshold/cooldown 정책의 거래 생성률, 세션 길이, D1/D7 유지율을 비교할 수 있다.

### 5.4 P1 — 데이터가 안정된 뒤

- `Category Created`, `Category Deleted`: `transaction_type`만.
- `Theme Preference Changed`: `mode:light|dark`; 색은 `source:preset|custom`만.
- `Font Size Changed`: `size:small|medium|large`.
- `Review Prompt Responded`: `experience:positive|negative`, `action`; 자유 텍스트 금지.
- `Update Prompt Viewed/Responded`: required/recommended와 action.
- transaction form open/abandon은 UI 이벤트 양이 커지므로 P0 activation 데이터가 안정된 뒤 추가한다.

### 5.5 User properties

Identify는 값이 바뀔 때와 identity 최초 확정 시에만 보낸다. Identify 이후 property가 chart event에 반영되는 것은 다음 이벤트부터라는 SDK 특성을 고려해, identity/속성 갱신 후 관련 성공 이벤트를 보낸다.

| 허용 user property | 타입 | 설정 지점 |
|---|---|---|
| `language_code` | string | user load / locale 변경 |
| `currency_code` | string | user load / locale 변경 |
| `budget_period` | `daily|monthly` | user load / Budget Set |
| `notifications_enabled` | bool | user load / permission 결과 |
| `theme_mode` | `light|dark` | theme load/change |
| `font_size` | `small|medium|large` | theme load/change |
| `has_completed_onboarding` | bool | budget > 0을 직접 보내지 않고 boolean으로 변환 |
| `auth_mode` | `anonymous|account` | 현재는 anonymous; 추후 계정 연결 상태 확인용 |

금지 user property: `email`, `display_name`, `budget`, `created_at`의 정확 timestamp, transaction count/amount의 원시값, inquiry/feedback 내용. Supabase `User.toJson()` 전체 전달도 금지한다.

## 6. 사용자 식별, 동의, 삭제

### 6.1 식별 순서

1. SDK는 동의 상태에 맞춰 초기화한다. 사용자 식별 전에는 SDK-generated device ID를 사용한다.
2. Supabase user가 준비되면 `setUserId(user.id)`를 호출한다. UUID는 5자 이상이며 Amplitude 제약을 충족한다.
3. 허용 user properties를 `Identify().set(...)`으로 설정한다.
4. 첫 도메인 이벤트를 보낸다. 같은 device에서 먼저 발생한 익명 event는 Amplitude identity resolution으로 병합될 수 있다.
5. `UserSettingsNotifier.reset()`처럼 auth UID가 바뀌는 경우 `flush()` → `reset()` → 새 UID `setUserId()` 순서로 전환한다. 단순 SQLite `Data Reset`은 같은 사용자이므로 reset하지 않는다.

Supabase anonymous UUID를 사용하므로 이 데이터는 “완전 익명”이 아니라 가명 처리된 행동 데이터다. 개인정보 처리방침도 그렇게 표현해야 한다.

### 6.2 동의/opt-out

법적 근거는 출시 전에 운영자가 확정해야 한다. 기술 구현은 어느 정책도 지원하되 개인정보 우선 기본은 아래로 한다.

- 새 설치: `analytics_collection_enabled`가 없으면 SDK를 `optOut=true`로 시작하고 간결한 Analytics 동의 선택을 1회 제공한다.
- 기존 설치: 현재 Firebase Analytics 수집 이력이 있더라도 Amplitude라는 새 수탁자/도구가 추가되므로 정책 업데이트 안내와 선택을 제공한다.
- 동의 시: preference 저장 → Firebase collection enabled → Amplitude `setOptOut(false)` → identity/Identify → 이후 이벤트.
- 거부/철회 시: 철회 이벤트를 내용 없이 가능한 범위에서 먼저 전송/flush → Amplitude `setOptOut(true)` → Firebase `setAnalyticsCollectionEnabled(false)`. 그 뒤에는 analytics 이벤트를 보내지 않는다.
- consent UI와 새 의견 요청 모달/리뷰 모달/업데이트 모달은 같은 세션에서 연달아 띄우지 않는다.
- `analytics_consent_version`을 저장해 개인정보 고지의 중대한 변경 때만 재확인한다.

만약 운영자가 별도 동의 없이 정당한 이익/계약상 필요를 근거로 수집하기로 법률 검토를 마쳤다면 첫 모달 대신 기본 enabled + 설정의 명시적 opt-out을 쓸 수 있다. 근거 결정과 정책 문서 업데이트가 끝나기 전에는 production default를 enabled로 바꾸지 않는다.

### 6.3 데이터 최소화와 삭제

- Amplitude project TTL을 제품 의사결정에 필요한 최소 기간으로 설정한다. 초기 제안은 13개월이며 법률/운영 검토 후 확정한다.
- 사용자 삭제 요청은 Supabase/SQLite만 지우면 끝나지 않는다. backend 운영 도구가 Amplitude User Privacy API v2에 동일 UID 삭제 job을 제출하고 완료 상태를 감사 로그로 남겨야 한다.
- User Privacy API credential은 서버/운영 도구에만 둔다.
- 삭제 job은 향후 수집을 막지 않으므로 앱 opt-out도 함께 적용한다.
- 개인정보 처리방침에는 수집 목적, event/기기/가명 ID 종류, Amplitude 처리자, 저장 지역, 보유 기간, 철회·삭제 방법을 추가한다.
- Apple App Privacy 및 Google Play Data Safety에서 Analytics/Identifiers/Usage Data 선언을 실제 SDK 구성과 대조한다.

## 7. Firebase 병행과 이관

### Phase A — Tracking plan/Dev (출시 전)

1. Amplitude Data에 taxonomy v1과 property type/required rule을 먼저 등록한다.
2. `MoneyFit Dev`만 연결해 Event Explorer/User Profile raw event로 검증한다.
3. 기능 코드의 Firebase direct import 4곳을 facade로 교체한다.
4. Firebase adapter는 기존 3개 event 이름/속성을 그대로 보존한다. 새 P0 이벤트를 Firebase에 무리하게 복제해 GA schema를 늘리지 않는다.

### Phase B — 1.2.7 dual-write

- 화면은 Firebase observer + Amplitude observer를 모두 둔다.
- 기존 3개 canonical action은 facade가 Amplitude와 Firebase 양쪽으로 보낸다.
- Amplitude 장애/비활성화는 Firebase 흐름에 영향을 주지 않는다.
- 7~14일 동안 아래를 비교한다.
  - 플랫폼/버전/내부 사용자 제외 후 `create_transaction` 대 `Transaction Created` 일별 건수 차이.
  - 첫 예산 설정 건수와 화면 도달 순서.
  - 동일 사용자 중복, null `screen_name`, invalid property type, custom category UUID 유출 여부.
- identity와 session 정의가 달라 사용자 수가 정확히 같을 필요는 없다. 동일 의미 action event 건수는 지연 반영을 고려해 일별 ±10% 안을 목표로 하고 차이는 샘플 raw event로 설명 가능해야 한다.

### Phase C — 1.2.8 이후 Firebase Analytics 제거 판단

아래 조건을 모두 만족할 때만 `firebase_analytics`와 `FirebaseAnalyticsObserver`를 제거한다.

- 14일 연속 P0 event schema invalid 0건.
- `Transaction Created`/`Budget Set`의 누락·중복 원인이 해소됨.
- 핵심 funnel/retention/dashboard가 Amplitude에서 저장·공유됨.
- opt-out, UID reset, 삭제 요청 runbook 검증 완료.
- 운영자가 Firebase GA 화면을 더 이상 의존하지 않음을 확인.

`firebase_core`, `firebase_remote_config`, `firebase_options.dart`, Google service plist/json은 Remote Config 때문에 유지한다.

## 8. Dashboard, funnel, cohort

### 8.1 `MoneyFit Product Health` dashboard

1. DAU/WAU/MAU 및 stickiness: QA cohort 제외, platform/version breakdown.
2. 핵심 행동: `Transaction Created` 사용자 수, 사용자당 주간 생성 횟수, essential/discretionary 비율.
3. 활성화 funnel(7일 window): `[Amplitude] Application Installed` → `Screen Viewed(screen_name=budget_setup)` → `Budget Set(is_initial=true)` → `Transaction Created`.
4. activation time: 설치→첫 예산, 첫 예산→첫 거래 median/p75.
5. feature adoption: Calendar/Statistics/Expense List 도달률과 filter/statistics 변경 사용자 비율.
6. locale health: `language_code`, `currency_code`, platform, app version별 activation/retention. 번역별 event를 만들지 않는다.
7. data quality tile: unknown screen, unexpected event, invalid property, `analytics_env=dev`가 Prod에 들어온 건수.

### 8.2 `Retention` dashboard

- 시작 이벤트: 첫 `Transaction Created`.
- return 이벤트: `Transaction Created` (보조선 `Screen Viewed(home)`).
- D1/D7/D30과 주간 retention을 language/platform/version별 비교한다.
- “앱을 열기만 한 사용자”보다 “재무 기록을 다시 한 사용자”를 진짜 retention으로 본다.

### 8.3 `Monetization vs Experience` dashboard

- `Ad Displayed` per DAU/session, format/placement/policy version.
- `Ad Load Completed(result=failure)` 비율.
- 광고 노출 후 같은 세션 내 `Transaction Created` 전환과 session end까지 시간.
- `ad_policy_version`별 D1/D7 retention, feedback prompt negative/submit 비율.
- 광고 빈도 증가는 광고 노출 수만 보지 않고 핵심 행동/유지율 guardrail과 함께 승인한다. 기준값은 1.2.7 이전 2주 baseline을 얻은 뒤 확정한다.

### 8.4 `Voice of Customer` funnel

`Feedback Prompt Shown` → `Feedback Prompt Responded(action=submit)` → `Feedback Submitted`를 언어/trigger별로 본다. 문의 본문이나 피드백 문장은 Amplitude dashboard가 아니라 Supabase/Slack의 접근 제한된 운영 채널에서만 본다.

### 8.5 저장 cohort

- `New Installs — 1.2.7+`
- `Activated — Budget + First Transaction`
- `Recorders — 2+ active weeks`
- `Not Activated within 3 days`
- `Feedback Submitters`
- `Ad Heavy — policy threshold 이상`
- `Internal / QA Users` (모든 운영 chart에서 제외)

## 9. 테스트 계획

### 9.1 단위 테스트

| 테스트 파일 | 검증 |
|---|---|
| `test/core/config/analytics_config_test.dart` | key/env/zone 파싱, 누락 시 Noop, key가 로그에 노출되지 않음 |
| `test/core/analytics/analytics_sanitizer_test.dart` | PII denylist, 최대 길이/허용 타입, custom category UUID→`custom`, 15개 기본 카테고리 허용 |
| `test/core/analytics/analytics_service_test.dart` | Amplitude 한 sink 실패 시 Firebase/앱 흐름 유지, opt-out일 때 0건, legacy event mapping |
| `test/core/analytics/analytics_navigator_observer_test.dart` | push/replace/pop에서 canonical 화면 1회, null/unknown route drop, 중복 route event 방지 |
| `test/core/repositories/analytics_consent_repository_test.dart` | first-run/동의/철회/version migration |
| 각 provider test | CRUD 성공 때 정확히 1회, 실패/동일값/no-op 때 0회, 금지값이 fake event에 없음 |

테스트 fake는 event명과 sanitized properties만 메모리에 모으며 실제 SDK/channel/network를 부르지 않는다.

### 9.2 Widget/통합 테스트

- 14개 locale에서 Analytics setting/동의 문구 overflow·missing key가 없는지 확인한다.
- `/update-check`부터 `/settings`까지 route name이 모두 non-null canonical value인지 확인한다.
- 첫 예산 설정에서 `Budget Set` 후 홈 이동, 첫 거래 성공에서 `Transaction Created` 1회인지 확인한다.
- 거래 form validation 실패, DB insert 실패, 문의 Supabase 실패는 success event를 만들지 않는다.
- consent 거부 상태에서 앱 시작·화면 이동·거래 생성 후 fake sink가 비어 있는지 확인한다.
- Supabase sign-out/new anonymous UID에서 이전 user ID와 다음 이벤트가 섞이지 않는지 확인한다.

### 9.3 실제 기기 QA

Android/iOS 각각 다음 matrix를 `MoneyFit Dev`에서 먼저 검증한다.

1. fresh install + consent accept/reject.
2. 기존 1.2.6 upgrade + 동의 선택.
3. offline에서 거래 2건 → online 복귀 → 순서/중복/flush 확인.
4. background/foreground 5분 경계의 session event.
5. 한국어→영어, KRW→USD property 전환이 다음 event부터 반영되는지.
6. 데이터 초기화(identity 유지)와 auth reset(identity 교체)의 차이.
7. 광고 load/display/dismiss와 거래 성공 순서.
8. release build에서 debug log/key 값이 보이지 않는지.

Amplitude User Profiles의 Raw view에서 금지 필드(`name`, `amount`, `email`, `details`, `detail`, raw category UUID)가 한 건도 없는지 직접 검색한다.

## 10. 릴리스·모니터링·롤백

### 출시 순서

1. 개인정보/데이터 보유/서버 지역 결정과 정책 문구 업데이트.
2. Dev/Prod 프로젝트·tracking plan·API key·QA cohort 생성.
3. facade + sanitizer + consent + P0 event 구현.
4. Dev 실제 기기 QA 및 schema validation.
5. Fastlane archive에 Prod key가 들어가고 Dev key가 없는지 사전 검사.
6. TestFlight/Internal 소수 사용자 → 24~48시간 raw event 확인.
7. 1.2.7 단계 출시 후 7~14일 dual-write 비교.
8. dashboard owner와 주간 점검 일정을 지정.

### 운영 경보/점검

- `Transaction Created`가 7일 동일 요일 baseline 대비 급감하거나 갑자기 2배 이상 증가하면 중복/누락 조사.
- `unknown` screen/property, invalid schema, Prod의 `analytics_env=dev`는 0이어야 한다.
- 광고 실패율과 `Ad Displayed` per DAU가 정책값을 벗어나면 광고 변경을 되돌린다.
- 동의율 자체는 locale별로 보되 거부 사용자의 행동을 추정/재식별하지 않는다.

### 롤백

- 1차: Firebase Remote Config `amplitude_collection_enabled=false`로 Amplitude sink만 중지하고 Firebase legacy 측정을 유지한다. 이 gate는 사용자 opt-out보다 우선한다.
- 2차: Amplitude Data에서 잘못된 event/property ingestion을 block하고 관련 dashboard를 숨긴다.
- 3차: patch build에서 `AMPLITUDE_ENABLED=false`; facade는 Noop Amplitude + Firebase만 사용한다.
- SDK 초기화가 crash/ANR 원인이면 Amplitude 초기화를 try/catch/timeout 경계 밖으로 격리하고 앱 시작은 계속돼야 한다.
- 이미 잘못 수집한 PII는 단순 hide/rename으로 끝내지 않고 Amplitude self-service deletion/User Privacy API 절차를 실행한다.

## 11. 완료 조건

- [ ] 기능 코드에 `firebase_analytics`/`amplitude_flutter` direct import가 없고 core analytics 계층에만 존재한다.
- [ ] 현재 Firebase 3개 이벤트와 화면 추적의 1.2.7 dual-write가 동작한다.
- [ ] P0 taxonomy와 type/required rules가 Amplitude Data에 등록돼 있다.
- [ ] Dev/Prod key가 분리되고 Fastlane 승격 바이너리의 key 정책이 문서화돼 있다.
- [ ] 14개 언어의 consent/settings UI와 privacy link가 검증됐다.
- [ ] 거래명·금액·email·문의/피드백 본문·custom category 식별자가 raw event에 없다.
- [ ] opt-in/opt-out, auth reset, local data reset, offline flush가 iOS/Android 실제 기기에서 통과했다.
- [ ] activation, retention, ads, voice-of-customer dashboard와 QA 제외 cohort가 공유됐다.
- [ ] Remote Config kill switch와 Firebase-only rollback이 검증됐다.
- [ ] Apple App Privacy/Google Data Safety/개인정보 처리방침 업데이트가 완료됐다.

## 12. 공식 자료

모든 링크는 2026-07-21에 조회했다.

- [Amplitude Flutter SDK 4](https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4) — 설치, 호환성, Configuration, autocapture, Identify, user ID, opt-out/reset, queue/flush, EU zone.
- [amplitude_flutter on pub.dev](https://pub.dev/packages/amplitude_flutter) — 공식 패키지 최신 버전 `4.6.1`과 플랫폼/빌드 호환성.
- [Amplitude Flutter TrackingOptions source](https://github.com/amplitude/Amplitude-Flutter/blob/main/lib/tracking_options.dart) — IP/지역/기기/광고 ID 등 수집 항목별 disable 옵션.
- [Create a tracking plan](https://amplitude.com/docs/data/create-tracking-plan) — 구현 전에 event/property/type/required rule을 정의하는 workflow.
- [Plan your taxonomy](https://amplitude.com/docs/data/data-planning-playbook) — 일관된 event naming과 event/user property 구분.
- [Getting started with Amplitude](https://amplitude.com/docs/data/data-get-started) — Dev/Prod 테스트 프로젝트 분리 권장.
- [Track unique users](https://amplitude.com/docs/data/sources/instrument-track-unique-users) — device ID/user ID/Amplitude ID 병합과 logout/reset 주의사항.
- [Privacy and consent implementation guide](https://amplitude.com/docs/data/privacy-and-consent-implementation) — 동의 모델, 최소 수집, 보유기간, opt-out/삭제 검증.
- [User Privacy API](https://amplitude.com/docs/apis/analytics/user-privacy) — user ID 기반 삭제와 삭제 후 향후 수집 차단이 별도라는 점.
- [Funnel analysis](https://amplitude.com/docs/analytics/charts/funnel-analysis/funnel-analysis-interpret) — 전환율, drop-off, time-to-convert 분석.
- [Retention analysis](https://amplitude.com/docs/analytics/charts/retention-analysis/retention-analysis-build) — start/return event 기반 유지율 정의.
