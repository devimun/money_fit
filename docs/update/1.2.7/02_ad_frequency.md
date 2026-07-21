# MoneyFit 1.2.7 광고 노출 빈도 개선 계획

- 작성일: 2026-07-21
- 범위: 광고 빈도·지면·정책 설정, 계측, 실험, 테스트, 롤백 계획
- 비범위: 이 문서에서는 앱 코드나 AdMob/Firebase 콘솔 설정을 실제로 변경하지 않는다.

## 1. 결론

MoneyFit의 광고 수익을 안전하게 높이는 1차안은 다음과 같다.

1. 현재 전면 광고의 하드코딩된 `12회 액션 + 10분 쿨다운`을 Remote Config 정책으로 옮긴다.
2. 행동을 세는 시점과 광고를 띄우는 시점을 분리한다. 캘린더 셀 선택이나 필터 적용 중에는 행동만 기록하고, 저장 완료나 상위 화면 전환 같은 자연스러운 중단점에서만 광고를 검토한다.
3. 첫 실험은 기존 정책을 대조군으로 유지하고 `8회 액션 + 8분 쿨다운` 후보군과 비교한다. 신규 사용자 보호, 세션/24시간 상한, 개인정보 동의, 전면 UI 충돌 방지는 두 군 모두 동일하게 적용한다.
4. 배너는 이미 5개 주요 화면에 있으므로 개수를 더 늘리지 않는다. 고정 320×50을 적응형 배너로 개선하고 AdMob의 Google 최적화 자동 새로고침을 켜는 것이 우선이다.
5. 앱 오프닝 광고 코드는 존재하지만 현재 꺼져 있다. 전면 광고 빈도 실험과 동시에 켜지 말고, 1차 실험의 승자 확정 뒤 별도 실험으로 진행한다.

권장 1.2.7 기본값은 **현재 수준을 보존하는 안전한 오프라인 폴백**이다. 서버에서 실험군에만 빈도를 올리고, 문제가 생기면 앱 업데이트 없이 즉시 기존 값 또는 전체 비활성화로 돌아갈 수 있어야 한다.

## 2. 저장소 현황 조사

### 2.1 광고·설정 스택

| 항목 | 확인된 상태 | 근거 |
|---|---|---|
| 광고 SDK | `google_mobile_ads: ^6.0.0` 사용 | `pubspec.yaml:50` |
| Firebase Analytics | 이미 설치·초기화되어 있고 일부 핵심 이벤트를 전송 | `pubspec.yaml:49`, `lib/core/router/app_router.dart:112-117`, `lib/core/providers/expenses_provider.dart:50-57` |
| Remote Config | 패키지 설치 및 앱 시작 시 fetch/activate 경로 존재 | `pubspec.yaml:63`, `lib/core/services/update_service.dart:40-64`, `lib/core/widgets/update_check_screen.dart:23-25` |
| Firebase 초기화 | 라우터 실행 전 초기화 | `lib/main.dart:18-26` |
| AdMob 초기화 | 스플래시의 `appInitializerProvider`에서 SDK 초기화 후 전면 광고 선로딩 | `lib/features/auth/view/splash_screen.dart:21-24`, `lib/core/services/app_initializer.dart:27-33` |
| Android App ID | Manifest에 등록됨 | `android/app/src/main/AndroidManifest.xml:54-56` |
| iOS App ID | Info.plist에 등록됨 | `ios/Runner/Info.plist:9-10` |
| 배너 광고 단위 | Android/iOS 각각 5개 화면용 운영 ID가 코드에 하드코딩됨 | `lib/core/services/ad_service.dart:18-32` |
| 전면 광고 단위 | Android/iOS 운영 ID가 코드에 하드코딩됨 | `lib/core/services/ad_service.dart:35-40`, `79-87` |
| 앱 오프닝 광고 단위 | Android/iOS 운영 ID와 매니저 구현은 있으나 초기화가 주석 처리됨 | `lib/core/services/ad_service.dart:42-56`, `180-277`, `lib/core/services/app_initializer.dart:30-31` |

저장소만으로는 AdMob 콘솔의 다음 값은 확인할 수 없다. 구현 전 소유자 계정에서 별도로 캡처해 변경 전 기준값을 남겨야 한다.

- 10개 배너 광고 단위의 자동 새로고침 활성화 여부와 주기
- 앱 수준 및 전면/앱 오프닝 광고 단위 수준 frequency cap
- high-engagement ads 활성화 여부
- eCPM floor, mediation, 국가별 fill rate
- 최근 28일 광고 형식/광고 단위/국가별 요청, match, show, impression, CTR, eCPM, 수익
- AdMob Policy center 경고 및 invalid traffic/confirmed click 상태

### 2.2 현재 배너 지면

`AdBannerWidget`은 고정 `AdSize.banner`(320×50)를 한 번 로드하고, 실패해도 58px 공간을 유지한다(`lib/core/widgets/ads/ad_banner_widget.dart:16-76`). 화면별 위치는 다음과 같다.

| 화면 | 위치 | 특이사항 |
|---|---|---|
| 홈 | `lib/features/home/view/home_screen.dart:84-99` | 스크롤 콘텐츠 최상단 |
| 캘린더 | `lib/features/calendar/view/calendar_screen.dart:19-26` | 캘린더 위에 고정 |
| 지출 목록 | `lib/features/expense/view/expense_list_screen.dart:40-53` | 헤더와 목록 사이 |
| 통계 | `lib/features/statistics/view/statistics.dart:34-46` | 데이터가 있을 때 차트와 TOP 3 사이의 스크롤 콘텐츠 |
| 설정 | `lib/features/settings/view/settings_screen.dart:13-24` | 스크롤 목록 최상단 |

즉, 핵심 탭에는 배너가 이미 모두 있다. 추가 배너 삽입보다 다음 개선의 기대효과가 크다.

- 화면 너비를 활용하는 anchored/inline adaptive banner
- AdMob의 Google 최적화 자동 새로고침
- 짧은 탭 왕복 때 60초 안에 새 요청을 반복하지 않는 캐시/수명 정책
- 광고와 버튼·내비게이션 사이의 명확한 비클릭 여백

### 2.3 현재 전면 광고 정책과 호출 위치

`InterstitialAdManager`의 현재 정책은 다음과 같다(`lib/core/services/ad_service.dart:90-178`).

- 프로세스 메모리의 `_actionCount`가 12에 도달해야 한다.
- 마지막 노출 후 최소 10분이 지나야 한다.
- 광고가 실제 표시되면 시각과 액션 카운터를 초기화한다.
- 닫힘 또는 표시 실패 후 다음 광고를 선로딩한다.
- 앱 재시작 시 액션 수와 마지막 노출 시각이 모두 초기화된다.
- 로드/표시/노출/클릭/수익/억제 사유 이벤트가 없다.

현재 `logActionAndShowAd()` 호출 표현식은 8개이며 실제 사용자 맥락은 다음과 같다.

| 호출 위치 | 현재 트리거 | 판정 |
|---|---|---|
| `lib/widgets/bottom_nav_bar.dart:125-153` | 캘린더·통계·지출 목록 탭으로 이동 | 자연스러운 화면 전환 후보지만, 현재는 광고 호출을 기다리지 않고 곧바로 라우팅함 |
| `lib/features/calendar/view/widgets/calendar_cell.dart:23-37` | 날짜 셀을 눌러 상세 바텀시트 열기 | 사용자가 기대한 콘텐츠를 막으므로 노출 지점으로 부적합; 행동 누적만 가능 |
| `lib/features/calendar/view/widgets/calendar_header.dart:43-59` | 이전 달 데이터 조회 성공 | 탐색 중단 위험; 행동 누적만 가능 |
| `lib/features/calendar/view/widgets/calendar_header.dart:71-87` | 다음 달 데이터 조회 성공 | 탐색 중단 위험; 행동 누적만 가능 |
| `lib/features/expense/view/widgets/filter_components/filter_action_buttons.dart:46-61` | 필터 적용 | 즉시 결과를 기대하므로 노출 지점으로 부적합; 행동 누적만 가능 |
| `lib/features/statistics/view/statistics.dart:72-88` | 통계 조회 월 변경 | 탐색 중단 위험; 행동 누적만 가능 |
| `lib/features/statistics/view/statistics.dart:315-330` | 지출 유형 탭 변경 | 반복 탭이 쉬워 액션 부풀림 가능; 노출 지점으로 부적합 |
| `lib/core/widgets/expense_management/expense_add_form.dart:154-190` | 지출 등록/수정 제출 | **검증 및 저장보다 광고가 먼저 실행됨. 잘못된 폼도 카운트되고 광고가 뜰 수 있어 우선 수정 필요** |

하단 탭 호출 하나가 세 개 목적지를, 캘린더 헤더의 두 호출이 이전/다음 이동을 각각 처리하므로 코드상 호출은 8곳, 사용자 트리거 종류는 10개이다.

### 2.4 앱 오프닝 광고 상태

`AppOpenAdManager`는 선로딩, 4시간 캐시 만료, 닫힘 후 재로딩을 구현해 두었다(`lib/core/services/ad_service.dart:180-277`). 그러나 다음 이유로 현재 활성화하면 안 된다.

- `app_initializer.dart:30-31`에서 선로딩이 주석 처리되어 있고 앱 lifecycle listener도 없다.
- 광고가 준비되지 않았을 때 `_deferShowUntilLoaded = true`로 두었다가 늦게 표시한다(`ad_service.dart:240-248`). 사용자가 이미 홈에서 작업을 시작한 뒤 광고가 튀어나올 수 있다.
- 신규 사용자 유예, 짧은 백그라운드 왕복 제외, 전면 광고와의 통합 쿨다운, 일일 상한이 없다.
- 이벤트 계측이 디버그 로그뿐이다.
- 테스트 앱 오프닝 ID가 Android용 한 개로 공용 처리된다. 공식 문서는 Android와 iOS 테스트 ID를 구분한다.

### 2.5 Remote Config 적용 가능성

적용 가능하며 새 의존성도 필요 없다. 단, 현재 구조를 그대로 재사용하면 초기화 순서에 취약하다.

- 최초 라우트 `/update-check`에서 `UpdateService.fetchUpdateStatus()`가 `fetchAndActivate()`를 실행하므로 정상 시작 경로에서는 광고 초기화 전 서버 값이 활성화될 수 있다.
- 반면 `appInitializerProvider`는 Remote Config settings만 설정하고 defaults/fetch/activate는 하지 않는다(`lib/core/services/app_initializer.dart:17-26`). 딥링크, 테스트, 향후 라우터 변경에서는 광고 값이 준비되었다고 보장할 수 없다.
- `UpdateService`가 Remote Config 전역 설정과 업데이트 도메인을 함께 소유한다. 광고 도메인을 직접 추가하기보다 공용 `RemoteConfigService`가 settings/defaults/fetch/activate를 한 번 수행하고, 업데이트와 광고 설정이 그 값을 읽게 하는 편이 안전하다.
- Firebase Analytics가 이미 있으므로 Firebase Remote Config A/B Testing을 사용할 수 있다. 향후 Amplitude를 추가해도 Firebase A/B Testing을 쓰는 동안 Firebase Analytics는 제거하지 않는다.

### 2.6 출시 전 차단해야 할 위험

1. **동의 선행 누락:** `AdService.initialize()`가 바로 Mobile Ads SDK를 초기화하고 광고를 요청하지만 UMP의 `requestConsentInfoUpdate`, 동의 폼, `canRequestAds()` 검사가 없다. 유럽 언어권을 포함한 14개 로케일 앱이므로 빈도 확대보다 먼저 처리한다.
2. **iOS 테스트 ID 오류:** 배너·전면·앱 오프닝 테스트 ID가 Android 값 하나씩으로 공용 처리된다(`ad_service.dart:33-43`). 공식 iOS 테스트 ID로 플랫폼 분기해야 iOS 검증이 신뢰 가능하다.
3. **비동기 저장 완료 보장 없음:** `ExpenseAddForm.onSubmit` 타입은 `void Function`인데 실제 콜백은 `async`이다(`expense_add_form.dart:15-24`, `home_action_buttons.dart:59-66`). 폼은 이를 await하지 않고 리뷰 프롬프트와 pop을 진행한다. 광고 eligibility는 저장 성공 이후에만 평가되도록 콜백 타입을 `Future<void> Function`으로 바꾸고 await해야 한다.
4. **전면 UI 충돌:** 저장 흐름에는 이미 리뷰 프롬프트가 있고, 1.2.7에는 의견 모달도 추가될 예정이다. 동의 폼, 리뷰, 의견, 업데이트, 광고가 동시에 경쟁하지 않도록 한 번에 하나만 허용하는 전면 UI 게이트가 필요하다.
5. **프로세스 재시작 우회:** 10분 쿨다운과 상한이 메모리에만 있어 앱을 재시작하면 리셋된다. 마지막 노출과 rolling 24시간 노출 이력은 영속화한다.

## 3. 목표와 비목표

### 목표

- 광고 수익/DAU와 광고 수익/1,000 세션을 유의미하게 높인다.
- 사용자가 작업 도중 갑자기 막혔다고 느끼는 노출을 줄인다.
- 빈도와 형식을 앱 업데이트 없이 실험·중단·롤백한다.
- Android/iOS, 14개 로케일, 신규/기존 사용자에서 일관된 정책을 보장한다.
- 광고 요청부터 실제 수익까지 원인을 추적할 수 있게 한다.

### 비목표

- 한 릴리스에서 전면 광고, 앱 오프닝, collapsible/native/rewarded 형식을 모두 동시에 도입하지 않는다.
- 사용자의 저장·삭제·문의 같은 핵심 작업 완료를 광고 시청에 종속하지 않는다.
- Remote Config로 플랫폼 정책 또는 개인정보 동의를 우회하지 않는다.
- 데이터 없이 eCPM floor나 high-engagement ads를 즉시 공격적으로 바꾸지 않는다.

## 4. 목표 광고 정책

### 4.1 정책 모델

현재 `logActionAndShowAd()` 한 메서드를 다음 두 단계로 분리한다.

```text
recordMeaningfulAction(trigger)
  -> 유효한 사용자 행동만 누적
  -> 광고를 즉시 표시하지 않음

maybeShowInterstitial(opportunity)
  -> 자연스러운 중단점에서 호출
  -> 동의, 신규 유예, 세션 시간, 액션 수, 쿨다운,
     세션/24시간 상한, 다른 전면 UI, 광고 준비 상태를 모두 통과할 때만 표시
```

이 구조를 쓰면 노출 빈도를 높이면서도 달력 셀을 누르는 순간이나 잘못된 폼 제출처럼 나쁜 타이밍을 제거할 수 있다.

### 4.2 의미 있는 행동과 노출 기회

| 사용자 행동 | 액션 누적 | 그 자리에서 노출 | 구현 원칙 |
|---|---:|---:|---|
| 지출 추가/수정 저장 성공 | 예 | 예, 단 저장 성공 UI 이후 | 저장 콜백을 await하고 리뷰/의견 모달이 예정되어 있으면 광고를 양보 |
| 지출 삭제 성공 | 예 | 선택 | 확인 다이얼로그가 닫힌 뒤에만 기회로 사용 |
| 서로 다른 상위 탭 이동 | 예 | 예 | eligible이면 라우팅 전 광고를 표시하고 dismiss 후 목적지로 이동; 중복 탭/연타는 제외 |
| 캘린더 날짜 상세 열기 | 예 | 아니오 | 상세를 즉시 보여줌 |
| 캘린더 월 이동 | 예 | 아니오 | 실제 월이 바뀐 경우만 카운트; 빈 데이터/실패 제외 |
| 지출 필터 적용 | 예 | 아니오 | 필터 값이 실제로 변경된 경우만 카운트 |
| 통계 월 변경 | 예 | 아니오 | 실제 값 변경만 카운트 |
| 통계 지출 유형 변경 | 선택 | 아니오 | 반복 탭 부풀림 방지를 위해 세션당 동일 값 중복 제외 |
| 폼 검증 실패, 네트워크/DB 실패 | 아니오 | 아니오 | 실패한 핵심 작업으로 수익화하지 않음 |
| 문의, 의견 작성, 개인정보 설정 | 아니오 | 아니오 | 신뢰·지원 흐름에는 광고 금지 |

연타 방지를 위해 동일 trigger는 최소 2초 debounce하고, 같은 상태값을 다시 선택한 행동은 카운트하지 않는다. 액션 가중치는 1로 시작한다. 지면별 가중치를 처음부터 다르게 두면 실험 해석이 어려워진다.

### 4.3 제안 기본값과 실험값

앱 내 defaults는 네트워크 실패 시에도 안전한 대조군이어야 한다.

| 정책 | 앱 내 기본값/대조군 A | 1차 후보군 B | 하드 안전 범위 |
|---|---:|---:|---:|
| 전면 광고 활성화 | `true` | `true` | kill switch 지원 |
| 필요한 의미 행동 수 | 12 | 8 | 6~30 |
| 전면 광고 최소 간격 | 600초 | 480초 | 최소 300초 |
| 세션 시작 후 최초 광고 유예 | 120초 | 120초 | 최소 60초 |
| 신규 사용자 유예 | 완료된 3세션 | 완료된 3세션 | 최소 2세션 |
| 세션당 전면 광고 상한 | 3회 | 3회 | 최대 4회 |
| rolling 24시간 전면 광고 상한 | 8회 | 8회 | 최대 12회 |
| 앱 오프닝 광고 | `false` | `false` | 별도 실험 전까지 off |

`8회 + 8분`은 시작 후보이지 영구 확정값이 아니다. 현재 사용자별 세션 길이·행동 수 분포가 없으므로, 먼저 7일 이상 baseline을 수집해 후보군에서 실제 광고/DAU가 얼마나 늘어나는지 시뮬레이션한다. p50 세션이 8회 행동보다 짧으면 10→8→6처럼 단계적으로 내리고, 반대로 사용자 이탈이 보이면 간격 또는 신규 유예를 늘린다.

세션은 앱 foreground 진입부터 30분 이상 background 또는 프로세스 종료까지로 정의한다. 쿨다운과 rolling 24시간 상한은 앱 재시작에도 유지되도록 `SharedPreferences`에 실제 **노출 성공 시각**만 저장한다. 로드 실패나 eligibility만으로 상한을 소비하지 않는다.

### 4.4 이중 frequency cap

클라이언트 정책만 믿지 않고 AdMob 콘솔에도 방어선을 둔다.

- 앱 수준 cap: 초기에는 모든 interstitial/app open을 합쳐 사용자당 `3 impressions / 30 minutes`를 제안한다.
- 광고 단위 수준 cap: 앱 오프닝 실험을 시작할 때 app-open에 더 엄격한 별도 cap을 둔다.
- 클라이언트: 5분 이상 최소 간격, 세션/rolling 24시간 상한을 별도로 적용한다.
- 실제 cap 변경은 적용에 최대 24시간 걸릴 수 있으므로 rollout 전날 설정한다.

AdMob은 앱 수준과 광고 단위 수준 cap 중 먼저 도달한 제한을 적용한다. 서버 지연으로 소폭 초과될 수 있으므로 클라이언트 cap도 필요하다.

### 4.5 배너 전략

1. 다섯 지면의 AdMob 콘솔 자동 새로고침 상태를 먼저 확인한다.
2. 꺼져 있으면 코드에서 수동 타이머를 만들지 않고 **Google optimized auto refresh**를 사용한다. 비교 실험이 꼭 필요하면 60초 이상 custom을 후보로 두되 Google 최적화를 우선한다.
3. 캘린더처럼 화면 상단에 계속 보이는 지면은 anchored adaptive banner를 사용한다.
4. 홈·통계·설정처럼 스크롤 콘텐츠 안에 있는 지면은 inline adaptive 또는 명확히 상단 고정된 anchored adaptive 중 레이아웃 테스트 결과로 결정한다.
5. 같은 광고 단위를 화면 왕복 때 60초 이내 재요청하지 않도록 화면 수명/캐시를 검토한다. 숨겨진 탭의 배너가 계속 refresh되지 않게 실제 visible 상태에서만 요청한다.
6. 광고와 내비게이션·필터·버튼 사이에 비클릭 여백/구분선을 둔다. 로드 전후 레이아웃 shift가 없어야 한다.
7. collapsible banner는 1.2.7 범위에서 제외한다. 시야 점유가 커 별도 실험과 정책 검증이 필요하다.

### 4.6 앱 오프닝 광고 2차 실험

1차 전면 광고 실험 승자 확정 후에만 시작한다.

- `app_open_enabled=false`를 기본값으로 둔다.
- 최소 3개 완료 세션을 지난 사용자만 대상이다.
- background가 2분 이상이었다가 foreground로 돌아오는 경우만 기회로 본다.
- 마지막 interstitial/app-open 노출 후 최소 4시간을 둔 보수적 후보로 시작한다.
- cold start에서는 `/update-check` 또는 splash 로딩 화면 동안 준비된 광고만 표시한다. 앱 콘텐츠로 진입한 뒤 로드가 끝났다면 그 세션에서는 건너뛴다.
- 현재 `_deferShowUntilLoaded`처럼 늦게 도착한 광고를 콘텐츠 위에 표시하지 않는다.
- 폼, 문의, 의견, 리뷰, 동의, 업데이트 다이얼로그가 열려 있으면 표시하지 않는다.
- 전면 광고와 동일한 rolling 24시간 상한을 공유한다.
- lifecycle `resumed` 중복 이벤트와 광고 클릭 후 앱 복귀가 다시 app-open을 유발하지 않도록 `_isShowing` 및 foreground transition을 검증한다.
- 기존 4시간 캐시 만료 검사는 유지하되 Android/iOS 테스트 ID를 분리한다.

## 5. Remote Config 설계

### 5.1 키 제안

| 키 | 타입 | 앱 내 기본값 | 용도 |
|---|---|---:|---|
| `ads_master_enabled` | bool | `true` | 모든 광고 요청 kill switch |
| `ads_banner_enabled` | bool | `true` | 배너 별도 kill switch |
| `ads_interstitial_enabled` | bool | `true` | 전면 광고 별도 kill switch |
| `ads_interstitial_actions_required` | int | `12` | 의미 행동 임계값 |
| `ads_interstitial_cooldown_seconds` | int | `600` | 전면 광고 최소 간격 |
| `ads_min_session_age_seconds` | int | `120` | 세션 초반 유예 |
| `ads_new_user_grace_sessions` | int | `3` | 신규 사용자 유예 |
| `ads_fullscreen_max_per_session` | int | `3` | interstitial+app-open 세션 상한 |
| `ads_fullscreen_max_per_24h` | int | `8` | interstitial+app-open rolling 상한 |
| `ads_app_open_enabled` | bool | `false` | 앱 오프닝 별도 kill switch |
| `ads_app_open_min_background_seconds` | int | `120` | 짧은 앱 전환 제외 |
| `ads_app_open_cooldown_seconds` | int | `14400` | app-open 보수적 최소 간격 |
| `ads_policy_version` | string | `control_12_600_v1` | 모든 이벤트에 붙일 정책 식별자 |

Remote Config 값은 신뢰 입력으로 보지 않는다. 앱에서 최소/최대 범위를 clamp하고, 파싱 실패·0·음수·비정상 조합은 앱 기본값으로 되돌린 뒤 `Ad Config Invalid`를 기록한다. 광고 단위 ID와 비밀값은 Remote Config에 넣지 않는다.

### 5.2 초기화 순서

```text
Firebase.initializeApp
  -> RemoteConfigService.setDefaults + fetchAndActivate
  -> UMP consent update/form
  -> ConsentInformation.canRequestAds 확인
  -> MobileAds.initialize
  -> active AdPolicyConfig 생성
  -> 전면 광고 선로딩
  -> 앱 데이터 초기화
```

- fetch 실패 시 캐시된 활성값, 그마저 없으면 앱 내 기본값을 쓴다.
- 광고 초기화가 Remote Config 네트워크 완료 때문에 무한 대기하지 않도록 기존 10초 timeout을 유지하고 폴백한다.
- 운영 kill switch 반영을 빠르게 하기 위해 `onConfigUpdated`를 구독하되, A/B experiment parameter는 실시간 Remote Config 대상이 아니라는 점을 고려한다.
- 세션 중 임계값이 변경돼도 이미 표시 중인 광고에는 영향을 주지 않고 다음 opportunity부터 적용한다.
- `UpdateService`와 광고 서비스가 각자 `setConfigSettings()`를 덮어쓰지 않게 공용 초기화 지점을 하나로 만든다.

## 6. 개인정보·광고 정책 선행 작업

### 6.1 UMP와 광고 요청 게이트

- 앱 시작마다 `ConsentInformation.instance.requestConsentInfoUpdate()`를 호출한다.
- 필요한 경우 `ConsentForm.loadAndShowConsentFormIfRequired()`를 표시한다.
- `canRequestAds()`가 true인 경우에만 SDK 초기화/광고 요청 경로를 한 번 실행한다. 두 콜백에서 중복 초기화하지 않도록 idempotent guard를 둔다.
- privacy options entry point가 필요한 지역에서는 설정 화면에 진입점을 추가한다.
- 동의 실패/네트워크 실패 시 무조건 personalized ads로 간주하지 않는다. UMP 상태에 따라 요청 가능 여부를 준수한다.
- iOS ATT를 사용할지, 비개인화 광고만으로 운영할지 개인정보 처리방침·App Store privacy label·Google Play Data safety와 함께 결정한다. ATT 없이 cross-app tracking을 수행하지 않는다.
- 연령 대상/COPPA 설정을 제품 정책과 스토어 등급에 맞춰 명시적으로 정한다.

### 6.2 배치 정책

Google은 interstitial을 자연스러운 전환점에 배치하고 매 행동마다 표시하지 말 것을 권고한다. 다음을 금지 기준으로 테스트한다.

- 앱 시작 직후 콘텐츠가 보인 다음 늦게 튀어나오는 광고
- 사용자가 날짜, 필터, 통계 탭, 저장 버튼을 반복 탭하는 중 갑자기 뜨는 광고
- 광고 닫기 직후 리뷰/의견/권한 모달이 연달아 뜨는 흐름
- 배너가 버튼 또는 하단 내비게이션과 맞닿아 accidental click을 유발하는 레이아웃
- 광고 로드로 콘텐츠가 움직여 원래 누르려던 위치에 광고가 들어오는 layout shift
- 문의, 의견, 개인정보/동의, 데이터 삭제, 강제 업데이트 화면의 광고

high-engagement ads는 닫기까지 더 긴 시간이 걸릴 수 있으므로 초기 빈도 상향과 동시에 새로 켜지 않는다. 현재 콘솔 상태를 기록하고, 별도 실험 없이 변경하지 않는다.

## 7. 이벤트 계측

광고 실험은 “요청 수”가 아니라 실제 노출·수익과 사용자 행동을 함께 봐야 한다. Firebase Analytics와 1.2.7에서 추가될 Amplitude가 같은 이벤트 이름/속성 계약을 사용하도록 공용 tracker 인터페이스를 둔다. Firebase A/B Testing을 사용하는 동안 실험군 판정의 원본은 Firebase로 유지한다.

### 7.1 필수 이벤트

| 이벤트 | 발생 시점 | 핵심 속성 |
|---|---|---|
| `Ad Action Recorded` | 유효 행동 누적 | `trigger`, `screen`, `action_count`, `ad_policy_version` |
| `Ad Opportunity` | 자연스러운 중단점 진입 | `opportunity`, `eligible`, `suppress_reason`, `ad_policy_version` |
| `Ad Request` | SDK load 요청 | `ad_format`, `placement`, `platform` |
| `Ad Load Completed` | load 성공 또는 실패 | `ad_format`, `placement`, `result:success\|failure`, `latency_ms`, `error_code?`, `error_domain?` |
| `Ad Displayed` | full screen show callback | `ad_format`, `trigger`, `action_count`, `seconds_since_last_fullscreen`, `ad_policy_version` |
| `Ad Impression` | SDK impression callback | `ad_format`, `placement`, `ad_policy_version`, `experiment_variant` |
| `Ad Clicked` | SDK click callback | `ad_format`, `placement` |
| `Ad Dismissed` | 닫힘 | `ad_format`, `visible_duration_ms` |
| `Ad Display Failed` | 표시 실패 | `ad_format`, `placement`, `error_code` |
| `Ad Revenue Tracked` | `onPaidEvent` | `value_micros`, `currency_code`, `precision`, `ad_format`, `placement` |
| `Ad Config Invalid` | RC 값 검증 실패 | `key`, `value_source`, `ad_policy_version` |

`suppress_reason`은 최소 다음 enum을 사용한다.

```text
master_disabled, format_disabled, consent_not_ready,
new_user_grace, session_too_young, action_threshold,
cooldown, session_cap, rolling_24h_cap, fullscreen_ui_busy,
ad_not_ready, app_background, stale_app_open, duplicate_trigger
```

공통 속성은 `platform`, `app_version`, `build_number`, `locale`, `session_id`, `ad_policy_version`, `experiment_variant`이다. 문의 내용, 지출명/금액, 이메일, 광고 ID 등 개인정보·민감 금융 데이터는 광고 이벤트에 넣지 않는다. `error.message` 전문도 전송 전 민감정보 포함 가능성을 검토하고 code/domain 위주로 보낸다.

### 7.2 핵심 지표와 가드레일

**수익 지표**

- 광고 수익/DAU
- 광고 수익/1,000 세션
- format·placement·국가별 impressions/DAU, show rate, fill rate, eCPM
- 요청 대비 load 성공률, opportunity 대비 impression 전환율

**사용자 경험 가드레일**

- D1/D7 retention
- 세션당 성공한 지출 저장 수와 저장 완료율
- 광고 dismiss 후 30초 내 앱 background/종료율
- 세션 길이, 핵심 탭 전환 완료율
- 문의/부정 의견 비율, 리뷰 프롬프트 부정 응답률
- crash-free sessions 및 ANR
- AdMob Policy center 경고, confirmed click, invalid traffic 변화

승자 기준 초안은 다음과 같다. 실험 시작 전 baseline 분산과 표본 크기로 다시 고정한다.

- 광고 수익/DAU 또는 광고 수익/1,000 세션이 10% 이상 개선
- D1 retention 하락이 2%p 이내
- 성공한 지출 저장/세션 하락이 상대 5% 이내
- dismiss 후 30초 종료율 증가가 3%p 이내
- crash-free sessions 하락이 0.2%p 이내
- 정책 경고 0건

## 8. A/B 및 점진 배포 계획

### 단계 0: 계측-only 기준선

- 코드 정책은 12회/10분 그대로 둔다.
- UMP, 영속 cap, Remote Config defaults, 이벤트, 테스트 ID 분리, 전면 UI 게이트만 먼저 배포한다.
- 최소 7일과 한 번의 완전한 주말을 포함해 행동 수/세션, opportunity, 억제 사유, 광고 수익 기준선을 수집한다.
- 기존 메모리 정책과 새 eligibility engine의 결정을 shadow mode로 함께 계산해 불일치를 확인한다.

### 단계 1: 전면 광고 빈도 실험

| 군 | 정책 | 비율 |
|---|---|---:|
| A 대조군 | 12회 + 10분 | 50% |
| B 후보군 | 8회 + 8분 | 50% |

- 신규 사용자 유예와 모든 hard cap은 동일하다.
- 먼저 내부/테스트 기기에서 검증한 뒤 운영 노출을 5%로 24시간 시작한다.
- 치명 가드레일이 없으면 25%로 72시간, 이후 목표 100% 실험 모집단으로 늘린다.
- 최소 7일, 요일 효과 포함, 사전 계산한 표본 수를 만족하기 전 승자를 선언하지 않는다.
- 트래픽이 너무 적어 유의성 도달이 현실적으로 어렵다면 14~28일 방향성 자료와 사용자별 session replay가 아닌 집계 지표로 판단하되, 더 공격적인 값으로 자동 승격하지 않는다.

### 단계 2: 배너 최적화

- 전면 광고 실험과 지표가 섞이지 않게 별도 기간에 진행한다.
- 기존 fixed banner + 현재 refresh를 대조군으로, adaptive banner + Google optimized refresh를 후보로 비교한다.
- 화면별 광고 수익, layout shift, screen render 오류, accidental click/CTR 급증을 확인한다.
- CTR 급증은 성공으로 간주하지 않고 배치 오류부터 조사한다.

### 단계 3: 앱 오프닝 광고

- 1차 전면 광고 승자 정책을 모든 군에 고정한 뒤 eligible 기존 사용자 일부만 대상으로 한다.
- A: app-open off, B: 3세션 이후 + 2분 background + 4시간 cooldown.
- cold start와 resume을 분리 분석한다.
- B군의 interstitial+app-open 통합 상한은 A군 interstitial 상한과 동일하게 유지한다.

한 실험에서 threshold, cooldown, app-open, banner refresh를 동시에 바꾸지 않는다. 그래야 수익/이탈 변화의 원인을 알 수 있다.

## 9. 구현 파일 계획

### 광고 코어

- `lib/core/services/ad_service.dart`
  - Android/iOS별 테스트 ID 분리
  - SDK 호출부와 policy/eligibility를 분리
  - interstitial의 `isShowing`, load retry/backoff, impression/click/paid callback 추가
  - app-open의 늦은 deferred show 제거 및 전면 광고 공용 cap 연결
- 신규 `lib/core/config/ad_policy_config.dart`
  - Remote Config key, defaults, clamp, 불변 policy snapshot
- 신규 `lib/core/services/ad_policy_service.dart`
  - 의미 행동, session age, 신규 유예, cooldown, rolling cap, suppress reason 판정
  - clock과 storage를 주입해 단위 테스트 가능하게 구성
- 신규 `lib/core/services/ad_event_tracker.dart`
  - Firebase/Amplitude 양쪽에 동일 계약 전송
- 신규 `lib/core/services/ad_consent_service.dart`
  - UMP 상태와 중복 없는 광고 초기화 게이트
- 신규 또는 공용 `lib/core/services/fullscreen_experience_coordinator.dart`
  - consent/update/review/feedback/ad 중 한 번에 하나만 허용

### 초기화·lifecycle

- `lib/core/services/app_initializer.dart`
  - 공용 Remote Config 초기화 → 동의 → Mobile Ads → 선로딩 순서 적용
- `lib/core/services/update_service.dart`
  - Remote Config 초기화 책임을 공용 서비스로 이동하고 update key 읽기만 담당
- `lib/main.dart` 또는 dedicated lifecycle service
  - session과 foreground/background 전환 추적
  - app-open은 flag가 켜졌을 때만 기회 평가

### 호출부

- `lib/core/widgets/expense_management/expense_add_form.dart`
  - validation 전 광고 호출 제거
  - `onSubmit`을 `Future<void> Function(Expense)`로 바꾸고 저장 성공 후 액션/노출 기회 평가
  - 리뷰 프롬프트와 광고 우선순위 적용
- `lib/widgets/bottom_nav_bar.dart`
  - 중복 탭 제외, 실제 목적지 변경만 기록
  - eligible이면 dismiss 후 라우팅하되 빠른 탭 연타 방지
- 캘린더/필터/통계의 현재 호출 6개
  - 즉시 show 호출을 의미 행동 기록으로 교체
- 지출 삭제 성공 경로
  - 저장소 성공 이후 의미 행동 추가

### 배너·다국어

- `lib/core/widgets/ads/ad_banner_widget.dart`
  - 화면 너비 기반 adaptive size, visibility, cache/lifecycle, 이벤트, 정책 여백 처리
- 설정의 privacy options entry point와 app-open loading copy가 필요할 때만 14개 `lib/l10n/app_*.arb`를 수정하고 `flutter gen-l10n`으로 생성물을 갱신한다.
- 광고 자체 creative는 AdMob이 로케일에 맞추므로 빈도 숫자만 바꾸는 작업에는 번역이 필요 없다.

## 10. 다국어·접근성 검증

지원 언어는 `ko`, `en`, `es`, `pl`, `uk`, `cs`, `de`, `it`, `ro`, `sk`, `bg`, `id`, `ms`, `fil`의 14개다(`lib/core/config/locale_config.dart:40-149`).

- UMP 메시지는 AdMob Privacy & messaging에서 대상 지역과 번역 상태를 확인한다.
- privacy options 진입점, 광고 로딩/실패 안내처럼 앱이 소유하는 문구는 14개 ARB에 모두 추가한다.
- 독일어·우크라이나어 등 긴 문구, 큰 글꼴, 작은 화면에서 배너가 버튼을 밀거나 덮지 않는지 확인한다.
- RTL 로케일은 현재 없지만 광고 creative 자체 방향과 앱 레이아웃의 충돌을 확인한다.
- 스크린 리더 포커스가 광고 뒤의 버튼으로 새거나, 광고 dismiss 후 원래 화면 포커스를 잃지 않게 한다.
- 저사양 기기·느린 네트워크에서 빈 광고 영역이 핵심 콘텐츠를 가리거나 layout shift를 만들지 않게 한다.
- 지역별 fill 차이를 빈도 실패로 오판하지 않도록 국가/로케일과 광고 serving country를 구분해 집계한다.

## 11. 테스트 계획

### 11.1 단위 테스트

fake clock, fake storage, fake Remote Config, fake ad gateway를 사용한다.

- 11번째/12번째, 7번째/8번째 행동 경계
- 599/600초 및 479/480초 쿨다운 경계
- 신규 2/3세션, session age 119/120초 경계
- 세션/rolling 24시간 상한과 정확한 만료
- 프로세스 재시작 후 마지막 노출/cap 유지
- 기기 시간 역행·시간대 변경에서도 음수 duration으로 광고가 열리지 않음
- invalid Remote Config 값 clamp/기본값 폴백
- 동일 trigger debounce와 동일 상태 중복 제외
- 광고 미준비, 로드 실패, 표시 실패가 action/cap을 잘못 소비하지 않음
- 동시에 두 opportunity가 들어와도 한 광고만 표시
- interstitial과 app-open이 통합 cap 및 fullscreen lock 공유
- master/format kill switch가 새 요청과 late show를 모두 차단

### 11.2 위젯 테스트

- 잘못된 지출 폼 제출은 액션/광고를 만들지 않고 오류만 표시
- 저장 성공을 await한 뒤에만 eligibility 평가
- 리뷰/의견/동의 모달 예정 시 광고가 defer 또는 suppress됨
- 상위 탭 이동 광고 dismiss 후 정확한 목적지로 한 번만 이동
- 배너 load 전후 콘텐츠 위치가 갑자기 이동하지 않음
- 배너와 탭/버튼 사이 정책 여백 유지
- 모든 14개 로케일과 text scale에서 overflow 없음

### 11.3 기기 통합·수동 테스트

- Android emulator/실기기와 iOS simulator/실기기에서 각각 공식 플랫폼 테스트 ID 사용
- debug/profile/release 빌드별 운영 ID 유출 방지: 테스트 기기에는 항상 `Test Ad` 표시 확인
- Ad Inspector로 request, response info, mediation adapter 확인
- cold start, warm resume, 광고 클릭 후 복귀, 30초/2분/4시간 background 시나리오
- 오프라인 시작, Remote Config timeout, 광고 no-fill, load/show failure
- EEA 동의 필요, 동의 불필요, 동의 철회/privacy options 시나리오
- 강제 업데이트, 알림 권한, 리뷰 프롬프트, 의견 모달과 광고 충돌
- dark/light theme, 소형/대형 화면, 가로 회전 허용 iOS 레이아웃
- Analytics DebugView와 Amplitude live event에서 이벤트 중복·속성·실험군 확인

운영 광고를 개발자가 직접 클릭하지 않는다. 운영형 creative 검증이 필요하면 테스트 기기를 명시적으로 등록한다.

## 12. 배포·모니터링·롤백

### 배포 전

- AdMob/Firebase console 변경 전 스크린샷과 값을 기록한다.
- AdMob app/ad unit frequency cap을 먼저 설정하고 최대 24시간 반영 시간을 둔다.
- Remote Config 앱 내 defaults와 서버 defaults가 동일한지 확인한다.
- `ads_app_open_enabled=false`를 확인한다.
- UMP 메시지, privacy policy, App Store privacy label, Play Data safety를 함께 검토한다.
- Policy center에 기존 이슈가 있으면 빈도 실험 전에 해결한다.

### 실시간 모니터링

- 첫 24시간: 시간 단위 load failure, impressions/DAU, post-dismiss exit, crashes, 저장 완료율
- 이후 매일: 군별 수익/DAU, retention, cap 분포, suppress reason, 국가별 이상치
- CTR이 갑자기 오르면 수익 개선으로 보지 않고 accidental click/layout부터 중지·조사한다.
- 광고 요청은 늘었는데 impression이 늘지 않으면 threshold보다 consent, no-fill, cap, load latency를 먼저 본다.

### 자동/수동 중단 기준

다음 중 하나면 후보군을 즉시 중지한다.

- crash-free sessions 0.5%p 이상 하락 또는 광고 관련 크래시 급증
- 지출 저장 완료율 10% 이상 상대 하락
- dismiss 후 30초 종료율 5%p 이상 증가
- 광고 중복 표시, 콘텐츠 진입 후 late app-open, 동의 전 요청 재현
- Policy center 경고, confirmed click, invalid traffic 징후
- 문의/부정 의견의 광고 관련 비율 급증

### 롤백 순서

1. Firebase A/B experiment를 중지하고 모든 사용자를 control 값으로 돌린다.
2. 긴급하면 `ads_interstitial_enabled=false`, `ads_app_open_enabled=false`를 publish한다.
3. 더 넓은 문제면 `ads_master_enabled=false`로 모든 새 광고 요청을 막는다.
4. AdMob 콘솔에서 해당 광고 단위를 pause하거나 cap을 더 엄격하게 적용한다.
5. 이미 로드된 광고도 show 시점에 최신 kill switch를 다시 확인해 늦게 표시되지 않게 한다.
6. Remote Config 장애 시 앱 내 control defaults로 돌아가므로 별도 긴급 앱 심사가 필요 없어야 한다.

롤백 후에도 원인 분석용 이벤트는 유지하되 광고 SDK 요청은 발생시키지 않는다.

## 13. 완료 기준

- [ ] 현재 AdMob console 설정과 최근 28일 baseline 보고서를 보존했다.
- [ ] UMP 동의 전 광고 요청이 0건이다.
- [ ] iOS/Android 공식 테스트 ID가 분리되고 양 플랫폼에서 `Test Ad`를 확인했다.
- [ ] 폼 검증/저장 실패, 문의, 의견, 개인정보 화면에서 광고가 뜨지 않는다.
- [ ] 행동 누적과 노출 기회가 분리되었다.
- [ ] Remote Config defaults, clamp, kill switch, 공용 초기화가 구현되었다.
- [ ] session/rolling 24시간 cap이 앱 재시작 후에도 유지된다.
- [ ] 광고 lifecycle·paid·suppress 이벤트가 Firebase/Amplitude에서 중복 없이 보인다.
- [ ] 14개 로케일, 큰 글꼴, 작은 화면에서 배너·동의 UI가 깨지지 않는다.
- [ ] 전면 광고 대조군/후보군 실험과 가드레일 대시보드가 준비되었다.
- [ ] app-open은 1차 실험 종료 전까지 off다.
- [ ] Remote Config와 AdMob 양쪽 롤백 리허설을 완료했다.

## 14. 공식 참고자료

- [Google Mobile Ads Flutter: Interstitial ads](https://developers.google.com/admob/flutter/interstitial)
- [AdMob interstitial guidance](https://support.google.com/admob/answer/6066980)
- [Recommended interstitial implementations](https://support.google.com/admob/answer/6201350)
- [Google Mobile Ads Flutter: App open ads](https://developers.google.com/admob/flutter/app-open)
- [Google Mobile Ads Flutter: Banner ads](https://developers.google.com/admob/flutter/banner)
- [Recommended banner implementations](https://support.google.com/admob/answer/6275335)
- [AdMob banner automatic refresh](https://support.google.com/admob/answer/3245199)
- [AdMob app/ad unit frequency caps](https://support.google.com/admob/answer/6244508)
- [Google Mobile Ads Flutter: Enable test ads](https://developers.google.com/admob/flutter/test-ads)
- [Google Mobile Ads Flutter: UMP privacy setup](https://developers.google.com/admob/flutter/privacy)
- [Firebase Remote Config for Flutter](https://firebase.google.com/docs/remote-config/flutter/get-started)
- [Firebase Remote Config A/B Testing](https://firebase.google.com/docs/ab-testing/abtest-config)
