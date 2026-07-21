# MoneyFit 1.2.7 작업 진행 프롬프트

아래 프롬프트를 새 Codex 작업에 그대로 전달한다.

---

당신은 Flutter 앱 **MoneyFit 1.2.7**의 리드 구현 에이전트다. 이번 작업은 계획을 다시 작성하는 일이 아니라, 저장소를 조사한 뒤 아래 계획을 실제 코드·테스트·로컬 배포 자산으로 구현하고 검증하는 일이다.

작업 저장소:

```text
/Users/jun/Desktop/DEV/money_fit
```

반드시 처음에 아래 문서 5개를 **끝까지 모두 읽고**, 상충하거나 중복되는 요구사항을 정리한 뒤 작업하라.

```text
docs/update/1.2.7/01_slack_inquiry_alert.md
docs/update/1.2.7/02_ad_frequency.md
docs/update/1.2.7/03_amplitude_setup.md
docs/update/1.2.7/04_feedback_prompt.md
docs/update/1.2.7/05_aso_localization.md
```

## 최종 목표

다음 다섯 작업을 하나의 안정적인 1.2.7 릴리스로 통합한다.

1. 사용자가 기존 문의하기로 문의하면 DB 저장 성공 뒤 서버에서 Slack 알림이 전달되게 한다.
2. 광고 노출 기회를 늘리되 저장·문의·의견 같은 핵심 작업을 방해하지 않고, Remote Config·동의·빈도 상한·kill switch·측정이 가능한 구조로 바꾼다.
3. Amplitude를 Firebase Analytics와 dual-write로 도입하고 PII 없는 공통 이벤트 taxonomy를 구현한다.
4. 사용자가 앱을 충분히 경험한 뒤 가끔 자유 의견 모달을 볼 수 있게 하고, 리뷰·광고·권한·업데이트 모달과 겹치지 않게 한다. 제출된 의견도 DB 저장 후 Slack으로 알린다.
5. Fastlane의 iOS/Android 스토어 메타데이터를 14개 제품 언어의 최종 ASO안으로 갱신하고 자동 검증한다. 영어 이름은 `MoneyFit - Expense Tracker`, 한국어 이름은 `MoneyFit - 하루 예산 가계부`다. 나머지는 ASO 문서의 최종 표를 그대로 따른다.

## 작업 원칙

- 먼저 `git status`, 현재 브랜치, Flutter/Dart 버전, 기존 테스트 상태, 로컬/원격 설정 파일 존재 여부를 확인한다. 사용자의 기존 변경과 관련 없는 파일을 수정·삭제·되돌리지 않는다.
- 계획서의 파일명이나 현재 코드가 달라졌다면 현재 저장소를 기준으로 가장 가까운 책임 위치를 찾되, 요구사항의 의미는 유지한다.
- 새 계획 문서만 만들고 멈추지 말라. 안전하게 로컬에서 구현할 수 있는 코드, migration, Edge Function, 테스트, ARB, Fastlane metadata와 validation은 실제로 완료하라.
- Slack Webhook URL, Supabase service-role key, 공유 secret, Amplitude API key, Fastlane credential 같은 값을 코드·migration·`.env`·문서·로그에 넣지 않는다. 모바일 앱에는 service-role/관리자 secret을 절대 포함하지 않는다.
- 운영 Supabase migration/Function/Webhook/Cron 배포, Slack App 생성, Firebase/AdMob/Amplitude 콘솔 변경, App Store Connect/Play Console 업로드·출시·심사 제출은 외부 상태를 바꾸므로 **사용자가 별도로 승인하고 자격증명을 제공하기 전에는 실행하지 않는다**. 대신 배포 가능한 파일과 정확한 명령·순서를 준비한다.
- 실제 운영 schema를 확인할 수 없다면 추정 migration을 운영에 적용하지 않는다. additive·후방 호환 migration 초안을 만들고, 확인이 필요한 DDL/RLS/GRANT 항목을 명시한다.
- 외부 설정이 없어도 다른 구현과 테스트를 계속한다. 키가 없을 때는 안전한 no-op 또는 보수적 off 기본값을 사용하며 production build preflight만 명확히 실패하게 한다.
- 앱의 저장·문의·의견 제출 성공 여부는 광고나 Analytics 성공 여부에 의존하지 않아야 한다.
- 사용자 입력, 이메일, 문의/의견 본문, 예산·지출 금액, 사용자 정의 카테고리명, 원시 UUID를 Analytics로 보내지 않는다.
- 새 사용자 문구는 한국어·영어만 추가하고 끝내지 말고 지원하는 14개 ARB 모두에 반영한다. 생성 파일은 직접 수정하지 않고 `flutter gen-l10n`으로 만든다.
- 사용 가능한 경우 서브에이전트로 각 계획의 현황 조사와 독립 파일 작업을 병렬화해도 된다. 다만 `pubspec.yaml`, `main.dart`, 공용 Remote Config, Analytics taxonomy, ARB, `ExpenseAddForm`, Fastlane처럼 겹치는 파일은 메인 에이전트가 통합 책임을 지고 충돌·중복 구현을 직접 해결한다.
- 작업 중 확인한 보안 취약점이나 계획과 다른 운영 위험은 숨기지 말고 증거와 함께 보고하되, 요청 범위를 벗어난 대규모 리팩터링은 하지 않는다.

## 통합 설계에서 반드시 하나로 합칠 것

다섯 계획은 독립 문서지만 다음은 중복 구현하지 말고 공용 구조로 만든다.

1. **Remote Config 초기화**
   - `UpdateService`, 광고, Amplitude kill switch, 의견 모달이 각자 Firebase 설정을 덮어쓰지 않게 공용 초기화 서비스를 둔다.
   - fetch timeout·캐시·기본값·실시간 update를 한 곳에서 관리한다.
   - 잘못된 숫자나 조합은 clamp 또는 보수적 기본값으로 되돌린다.

2. **Analytics facade와 이벤트 계약**
   - 화면이나 기능 코드에서 `amplitude_flutter`와 `firebase_analytics`를 직접 호출하지 않는다.
   - 하나의 `AnalyticsService`/provider를 통해 Firebase와 Amplitude에 동일한 이벤트 계약으로 dual-write한다.
   - SDK별 실패는 서로와 사용자 기능을 막지 않는다.
   - `03_amplitude_setup.md`의 Title Case 이벤트명, 속성 allowlist, sanitizer, consent/opt-out, identity reset 순서를 기준으로 한다.

3. **전면 UI coordinator**
   - 광고, 앱 오프닝 광고, 리뷰, 자유 의견, 알림/동의, 업데이트 다이얼로그가 한 번에 하나만 열리게 하나의 coordinator/lease를 사용한다.
   - Future가 끝난 시점이 아니라 실제 dismiss 완료까지 lease를 유지한다.
   - 한 지출 저장 뒤 광고가 닫히자마자 의견/리뷰가 연달아 뜨는 일이 없어야 한다.

4. **지출 저장 완료 지점**
   - `ExpenseAddForm`은 validation과 SQLite 저장 성공을 `await`한 뒤 닫힌다.
   - 성공한 신규 지출만 Analytics, 광고 의미 행동, 리뷰/의견 eligibility에 반영한다.
   - 검증 실패·저장 실패·중복 탭은 카운트나 광고를 만들지 않는다.

5. **Supabase → Slack 전달 기반**
   - `user_contact`와 `app_feedback`은 별도 테이블/기능으로 유지하되, canonical row 재조회, 조건부 선점, plain-text 안전 처리, 상태 기록, 429/5xx backoff, stale processing 회수, bounded retry를 공용 helper로 재사용한다.
   - 앱에서 Slack을 직접 호출하지 않는다.
   - DB commit 성공이 사용자 성공 기준이며 Slack 장애는 앱 제출을 실패로 바꾸지 않는다.

## 구현 순서

### Phase 0 — 기준 상태와 충돌 확인

1. 저장소 구조, dirty worktree, 현재 앱 버전(`1.2.6+17`), 의존성, 테스트와 Fastlane lane을 확인한다.
2. `user_contact`, `app_feedback` 관련 기존 코드와 저장 payload, 인증 초기화 순서, RLS를 로컬에서 확인한다.
3. 광고 호출 위치를 전수 검색해 validation/저장 전에 광고가 실행되는 경로를 표시한다.
4. Firebase Analytics, Remote Config, 리뷰 프롬프트, 앱 오프닝/전면 광고, route observer, ARB locale 목록을 확인한다.
5. 계획과 현재 코드가 충돌하면 구현 전 짧은 작업 계획을 갱신하되, 발견 가능한 질문 때문에 사용자에게 멈춰서 묻지 말고 안전한 가정으로 진행한다.

### Phase 1 — 공용 기반과 Amplitude

1. 구현 시점의 공식 호환 버전을 확인한 뒤 `amplitude_flutter` 4.x를 추가하고 lockfile을 갱신한다.
2. `AnalyticsConfig`, event taxonomy, sanitizer, dual-write service, Riverpod provider, Navigator observer, consent repository/settings UI를 구현한다.
3. Amplitude key/zone/env/enabled는 `--dart-define`으로만 받고 로그에서 가린다. key가 없으면 앱은 Noop으로 정상 실행한다.
4. 개인정보 우선 기본값은 명시적 동의 전 수집 off다. 동의 철회 시 Amplitude와 Firebase 모두 중단한다.
5. P0 이벤트를 실제 성공 지점에 연결하고 이벤트 literal·PII·고카디널리티 값이 새지 않게 테스트한다.
6. Fastlane beta build가 dart-define을 받을 수 있게 만들되 실제 key는 저장소에 넣지 않는다.

### Phase 2 — 문의/의견 Backend 자산과 Slack

1. `supabase/config.toml`, additive migrations, 두 Edge Function 또는 공용 delivery helper 구조를 추가한다.
2. 기존 1.2.6 payload가 계속 동작하도록 nullable/default/backfill 순서를 지킨다. 과거 행은 `suppressed`로 처리해 일괄 알림을 막는다.
3. `user_contact`는 자기 UID의 INSERT만, `app_feedback` 신규 제출은 idempotent RPC를 사용하도록 RLS/GRANT 초안을 구현한다. 앱은 운영 delivery 필드를 지정하거나 SELECT/UPDATE/DELETE할 수 없어야 한다.
4. 문의 유형은 `bug_report`, `feature_suggestion`, `general_inquiry`, `other` 고정 코드로 저장하고 화면에서만 번역한다.
5. Slack payload에는 안전한 ID, 서버 시각, platform, locale, app version/build와 필요한 본문만 plain text로 넣는다. raw UID·secret·JWT를 로그/메시지에 노출하지 않는다.
6. 200/400/403/404/429/5xx/timeout, 동시 중복 호출, 재시도 소진, stale processing을 테스트한다.
7. `ContactUsDialog`는 repository를 주입받고 전송 중 중복 탭 방지, 실패 시 입력 보존, 성공 시에만 닫힘을 구현한다.

### Phase 3 — 광고 정책 리팩터링

1. `recordMeaningfulAction()`과 `maybeShowInterstitial()`을 분리한다.
2. control 기본값은 기존과 같은 **12회 행동 + 600초**로 유지하고, 후보 **8회 + 480초**는 Remote Config/A-B 값으로만 둔다.
3. 신규 사용자 3세션 유예, 세션 120초 유예, 세션 최대 3회, rolling 24시간 최대 8회와 interstitial/app-open 공용 cap을 영속화한다.
4. Android/iOS 공식 테스트 ID를 플랫폼별로 분리한다. 테스트 빌드에서 운영 광고를 클릭하지 않는다.
5. UMP `canRequestAds` 전에는 SDK 초기화/요청을 하지 않고 privacy options 진입점을 제공한다.
6. 앱 오프닝 광고는 기본 `false`로 유지한다. 늦게 로드된 광고가 이미 진입한 콘텐츠 위에 뜨지 않게 한다.
7. 문의, 의견, 개인정보, 동의, 데이터 삭제, 업데이트 화면과 검증/저장 실패에서는 광고를 금지한다.
8. 배너는 visible 상태, adaptive size, 캐시/재요청, 여백, layout shift를 검증한다.
9. load/show/impression/click/dismiss/paid/suppress/config-invalid 이벤트를 공용 Analytics facade에 연결한다.

### Phase 4 — 자유 의견 모달

1. `04_feedback_prompt.md`의 기본 정책을 그대로 구현한다: 설치 7일, 3세션, 성공한 신규 지출 10회, 서로 다른 active day 3일 이후에만 eligibility가 생긴다.
2. 첫 production 기본 rollout은 off 또는 문서의 stable 5% cohort로 제어 가능해야 하며, Remote Config 실패와 캐시 부재 시에는 off다.
3. 한 세션/하루 1회, rolling 180일 최대 3회, `later=30일`, `dismiss=14일`, `submitted=120일`, 리뷰/의견 공통 cooldown 30일, `never` 영구 상태를 구현한다.
4. stable bucket과 clock/storage를 주입 가능하게 만들어 경계값을 단위 테스트한다.
5. 입력 3~1,000자, 중복 submit 방지, 동일 `client_submission_id` 재사용, 실패 시 내용 보존, PII 주의 문구, rate-limit 전용 UX를 구현한다.
6. 기존 부정 리뷰 피드백은 `review_negative`, 새 모달은 `proactive_prompt`로 저장한다. 한 액션에서 `user_contact`와 `app_feedback`을 동시에 만들지 않는다.
7. 14개 전용 번역 키를 모든 ARB에 추가하고 작은 화면, 키보드, text scale 200%, dark mode, 접근성 semantics를 검증한다.

### Phase 5 — ASO와 Fastlane metadata

1. `05_aso_localization.md`의 iOS/Android 최종 카피 표를 그대로 metadata 파일에 적용한다.
2. 영어권에서 `Daily Budget`을 가계부 번역으로 사용하지 않는다. 영어 앱 이름은 반드시 `MoneyFit - Expense Tracker`, subtitle은 `Know what you can spend today`로 둔다.
3. iOS는 Apple이 지원하는 12개 제품 locale와 `en-GB` fallback을 사용한다. Apple이 metadata locale로 지원하지 않는 `bg`, `fil` 폴더를 억지로 만들지 않는다.
4. Android는 비공식 중복 `ms`를 제거하고 `ms-MY`로 단일화하며 `fil`을 추가한다. 삭제 전 두 폴더의 차이를 확인하고 필요한 자산을 보존한다.
5. 긴 설명의 검증 불가능한 최상급을 제거하고, 검증 전 `offline`, `no login`, `100% private` 주장을 추가하지 않는다.
6. iOS name/subtitle 30자, keywords UTF-8 100 bytes, Android title 30자, short description 80자를 검사하는 validation을 추가한다. 14개 언어/locale 매핑, 필수 파일, 빈 URL, 금칙어도 검사한다.
7. iOS `force: true`로 preview를 건너뛰지 않게 하고, metadata-only lane은 바이너리 업로드·심사 제출·자동 publish를 하지 않게 검증한다.
8. 로컬 preview/validation까지만 수행하고 App Store Connect/Play Console에는 업로드하지 않는다.

### Phase 6 — 통합, 버전, 검증

1. 공용 coordinator, Remote Config, Analytics, 지출 저장 순서가 서로 다른 기능에서 중복 구현되지 않았는지 전체 diff를 리뷰한다.
2. 14개 ARB JSON/key/placeholder parity와 생성 getter를 검사한다.
3. 현재 원격 최신 build가 17 이하임을 확인할 수 있으면 `pubspec.yaml`을 `1.2.7+18`로 올린다. 더 높은 build가 확인되면 반드시 그보다 큰 번호를 사용한다. 확인할 수 없다면 `1.2.7+18`로 로컬 준비하고 외부 확인 필요 사항에 기록한다.
4. 가능한 범위에서 다음을 실행하고 실패를 실제로 수정한다.

```bash
flutter pub get
flutter gen-l10n
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
git diff --check
```

5. 환경이 허용하면 Supabase migration/Function 테스트, Android debug 또는 release build, iOS simulator build, Fastlane metadata validation/preview도 실행한다. credential·Docker·Xcode 문제는 코드 실패와 구분해 보고한다.
6. 검증을 통과시키기 위해 기존 테스트를 삭제하거나 assertion을 약하게 만들지 않는다.

## 외부 설정 체크리스트

로컬 구현이 끝나면 `docs/update/1.2.7/06_external_setup_checklist.md`를 만들어 다음을 실제 값 없이 정리한다.

- 운영 Supabase schema/RLS/GRANT read-only 확인 및 백업
- migration → Function → DB Webhook/Cron 순서와 rollback 명령
- Slack dev/prod 채널, Incoming Webhook, secret/Vault 등록 위치와 회전 절차
- Amplitude Dev/Prod project, US/EU zone, timezone, tracking plan, API key 전달 변수
- Analytics opt-in/opt-out 법적 근거, 개인정보처리방침, 보유 기간과 삭제 절차
- AdMob UMP, privacy options, ATT/비개인화 광고 결정, frequency cap, Policy Center 확인
- Firebase Remote Config defaults, A/B parameter, rollout, kill switch와 담당자
- MoneyFit 상표/동명 앱 확인 결과
- App Store/Play metadata draft 업로드, native copy QA, 단계적 publish와 rollback
- 실행하지 못한 실제 기기/TestFlight/Internal testing 항목

## 완료 조건

다음 조건을 모두 만족해야 완료로 보고한다.

- 앱이 key/네트워크/Analytics/광고/Slack 장애에도 핵심 지출·문의·의견 저장 흐름을 보존한다.
- 문의와 자유 의견이 DB에 저장된 뒤 서버 측 Slack 전달 상태와 bounded retry를 가진다.
- 구버전 1.2.6 INSERT payload의 후방 호환을 migration/테스트로 보존한다.
- 광고 행동 누적과 노출 기회가 분리되고, validation/저장 실패와 보호 화면에서는 광고가 나오지 않는다.
- 광고·리뷰·의견·동의·업데이트가 하나의 coordinator로 상호배제된다.
- Amplitude/Firebase dual-write, 동의/opt-out, identity reset, PII sanitizer와 P0 taxonomy 테스트가 통과한다.
- 의견 모달의 모든 eligibility/cooldown/cap 경계와 중복 제출이 테스트된다.
- 14개 언어에 새 문구가 존재하고 ARB/generated code/레이아웃 검증이 통과한다.
- Fastlane metadata가 최종 ASO 표와 일치하고 모든 글자/byte/locale validation이 통과한다.
- 앱 버전이 1.2.7로 갱신되고 `flutter analyze`, `flutter test`, formatting과 diff check가 통과한다.
- 운영 배포·스토어 publish를 몰래 실행하지 않았으며, 남은 외부 설정은 체크리스트로 재현 가능하게 정리돼 있다.

## 최종 보고 형식

작업을 마치면 다음 순서로 짧고 구체적으로 보고하라.

1. 구현 완료 결과와 사용자에게 보이는 변화
2. 주요 변경 파일과 설계 결정
3. 실행한 테스트/빌드와 결과
4. 아직 필요한 외부 콘솔 작업·secret·법적 결정
5. 위험, 단계적 rollout 순서와 즉시 rollback 방법
6. 관련 없는 기존 변경은 건드리지 않았다는 확인

단순히 “계획대로 구현했다”고 말하지 말고, 실제 파일·테스트 결과·미완료 외부 의존성을 증거로 제시하라.

---
