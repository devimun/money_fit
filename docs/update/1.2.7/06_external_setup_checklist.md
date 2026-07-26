# MoneyFit 1.2.7 외부 설정·출시 체크리스트

이 문서는 1.2.7 로컬 구현 이후 운영자가 수행할 외부 콘솔·secret·법적 작업의 순서다. 이 저장소에는 Slack URL, service-role key, Amplitude API key, Fastlane credential를 기록하거나 커밋하지 않는다. 아래 작업은 **개발/스테이징에서 먼저** 확인하고, 소유자 승인과 백업이 완료된 경우에만 운영에 적용한다.

## 0. 출시 전 공통 게이트

- [ ] `dart run tool/validate_store_metadata.dart`, `flutter analyze`, `flutter test`, `git diff --check`의 통과 결과를 release ticket에 남긴다.
- [ ] `pubspec.yaml`이 `1.2.7+18`인지 확인하고, App Store Connect 및 Play Console의 가장 높은 build/version code가 17 이하인지 읽기 전용으로 확인한다. 더 높다면 build number를 그보다 큰 값으로 다시 결정한다.
- [ ] 운영 설정·콘솔 화면·현재 스토어 metadata의 날짜 포함 snapshot을 보관한다. 현재 live 상태를 덮어쓰지 않도록 ASC/Play metadata를 임시 디렉터리에 다운로드하여 로컬 diff를 검토한다.
- [ ] production 변경 권한, rollback 담당자, 비상 연락 채널과 배포 창을 ticket에 지정한다.

## 1. Supabase schema, RLS, Function, Slack

### 읽기 전용 확인·백업

- [ ] 운영 `user_contact`, `app_feedback`의 실제 DDL, index, trigger, RLS policy, role GRANT, 기존 payload와 데이터량을 읽기 전용으로 export한다.
- [ ] migration 적용 전 schema backup과 최근 행의 익명화된 표본을 보관한다. 구버전 1.2.6 INSERT가 nullable/default 추가 뒤에도 동작함을 staging에서 확인한다.
- [ ] 앱 역할은 자기 UID의 `user_contact` INSERT와 승인된 feedback RPC만 가능하고, delivery 상태 column의 SELECT/UPDATE/DELETE 또는 다른 사용자의 row 접근은 불가능한지 확인한다.

### 적용 순서와 rollback

1. [ ] additive migration을 staging에 적용하고 DDL/RLS/GRANT 및 idempotency·retry 테스트를 실행한다.
2. [ ] Edge Function을 staging에 배포한다. secret은 Supabase project의 Function secret/Vault에만 등록하고 앱 `--dart-define`이나 migration에 넣지 않는다.
3. [ ] staging DB Webhook 또는 scheduled retry를 활성화하고, 새 row 한 건이 canonical row 재조회 → Slack delivery status 기록으로 끝나는지 확인한다.
4. [ ] production backup 후 같은 migration → Function → DB Webhook/Cron 순서로 적용한다. 과거 행은 `suppressed`여서 일괄 알림이 발생하지 않는지 먼저 확인한다.
5. [ ] rollback은 Webhook/Cron 비활성화 → Function traffic/secret 폐기 → 새 delivery column 사용 중지 순서로 한다. 이미 생성한 additive column/table은 구버전 호환을 위해 즉시 drop하지 않는다. DDL rollback은 backup과 운영 schema 검토 후 별도 승인으로만 한다.

### Slack

- [ ] dev/prod 전용 private channel을 분리하고 최소 인원만 멤버로 둔다. Incoming Webhook의 scope와 channel을 다시 확인한다.
- [ ] Webhook URL은 Supabase secret/Vault에만 저장하고, 로그·migration·클라이언트·문서에 넣지 않는다. 적용 후 URL 노출 여부를 secret scanner와 git history로 점검한다.
- [ ] 본문은 plain text 및 최소 필요 정보만 전송되고 raw UID, JWT, 이메일, 계좌정보, secret은 전송·로그에 없음을 확인한다.
- [ ] 분기별 또는 담당자 변경 시 Webhook을 회전한다: 새 URL 등록 → 테스트 delivery → 기존 URL 폐기 → audit log 확인.

## 2. Analytics와 개인정보

- [ ] Amplitude Dev/Prod project를 분리하고 project timezone, US/EU data residency zone, event naming/속성 allowlist, dashboard owner를 확정한다.
- [ ] API key는 CI 또는 secure build environment에서만 `--dart-define`으로 전달한다. build log에서 값이 마스킹되는지 확인하고, source·`.env`·Fastlane lane에 저장하지 않는다.
- [ ] Remote Config의 analytics kill switch와 consent 기본값을 production에서 비활성/opt-in 상태로 시작한다.
- [ ] Firebase Analytics와 Amplitude가 opt-in 뒤 동일한 P0 event만 받고, opt-out 뒤 둘 다 중단·identity reset하는지 실제 기기에서 검증한다.
- [ ] 개인정보처리방침에 analytics 목적, 법적 근거/동의, vendor, 보유 기간, 철회 방법, 데이터 삭제 요청 경로를 반영한다. 국가별 법률 및 동의 문구는 법무/개인정보 담당자가 승인한다.
- [ ] event payload에 이메일, 문의·의견 본문, 금액, 사용자 카테고리명, raw UUID가 없음을 Amplitude Debugger/Firebase DebugView에서 확인한다.

## 3. AdMob, UMP, ATT, Remote Config

- [ ] AdMob UMP privacy message와 대상 지역, privacy options entry point를 설정한다. `canRequestAds` 전 SDK 초기화/광고 요청이 0건인지 Android/iOS 테스트 기기에서 확인한다.
- [ ] iOS ATT 필요 여부, personalized/non-personalized ads 정책, privacy manifest 및 store privacy disclosure를 법적 판단과 함께 확정한다.
- [ ] AdMob Policy Center, app-ads.txt, 테스트 광고 단위 ID, production ad unit ID를 확인한다. 테스트 빌드에서 production 광고를 클릭하지 않는다.
- [ ] Remote Config 기본값과 담당자를 등록한다: `ads_master_enabled=false`(긴급 kill switch), interstitial control `12 actions / 600 seconds`, 후보 `8 / 480`, app-open 기본 false, feedback rollout 기본 off 또는 승인된 5% cohort.
- [ ] Remote Config A/B parameter, fetch/cache 정책, staged rollout과 rollback 담당자를 정한다. 장애 시 로컬 보수적 기본값으로 돌아가는지 확인한다.
- [ ] frequency cap(신규 사용자/세션/24시간), protected screen suppression, 광고·리뷰·의견·동의·업데이트의 단일 전면 UI coordinator를 실제 기기에서 확인한다.

## 4. 브랜드·ASO·스토어 draft

- [ ] `MoneyFit` 유지 전 USPTO, KIPRIS, EUIPO, WIPO에서 software/finance 지정상품까지 상표·동명 앱을 검토하고, 법무/브랜드 담당자의 유지 또는 변경 결정을 기록한다. 보류면 metadata를 업로드하지 않는다.
- [ ] 1.2.7 App Store Connect draft에서 12개 제품 locale(`en-US`, `ko`, `es-ES`, `pl`, `uk`, `cs`, `de-DE`, `it`, `ro`, `sk`, `id`, `ms`)과 `en-GB` fallback, Play 14 locale을 현지 원어민에게 검수받는다. iOS `bg`/`fil`은 만들지 않고 `en-GB` fallback을 사용한다.
- [ ] 로컬에서 `dart run tool/validate_store_metadata.dart`를 실행한다. `fastlane ios preview_metadata`와 `fastlane android validate_metadata`는 외부 인증을 사용하므로 별도 승인된 draft 환경에서만 실행하며, validation 결과와 console diff를 ticket에 첨부한다.
- [ ] iOS `update_metadata`는 binary upload·심사 제출·자동 publish를 하지 않으며, preview를 건너뛰는 `force: true`를 사용하지 않는지 확인한다. Play `validate_only`가 성공한 뒤에도 Managed publishing/변경 목록을 사람이 검토한다.
- [ ] 14개 앱 언어의 실제 archive localization, `Runner.app/Info.plist`, App Store Connect Languages 표시는 metadata locale과 별도로 확인한다. TestFlight/Internal testing에서 display name, 앱 문자열, 큰 글꼴, dark mode, screenshot 문구를 QA한다.
- [ ] 지원 URL·marketing URL·privacy URL이 공개 접근 가능하고 지속 가능한 MoneyFit 연락처로 연결되는지 검증한다. 현재 Kakao/Blogspot/Notion URL의 소유권·접근성·법정 연락정보는 출시 전 별도로 확인하거나 교체한다.

## 5. 단계적 publish, 측정, rollback

- [ ] 출시 전 28일 baseline을 저장한다: Apple Search impression → product page view → first-time download, Play listing visitor → acquisition, locale/country별 conversion, activation, D1/D7 retention, crash-free rate, uninstall rate.
- [ ] iOS metadata는 1.2.7 version review와 함께 제출하고, Play은 Wave 1(`en-US`, `ko-KR`) → Wave 2(`es-ES`, `pl-PL`, `uk`, `cs-CZ`) → Wave 3(나머지)로 14~28일씩 관찰한다.
- [ ] locale당 누적 100 visitors 이상에서 7일 연속 conversion이 baseline 대비 15% 이상 하락하거나 activation이 10% 이상 하락하면 해당 Play locale을 이전 metadata snapshot으로 되돌린다.
- [ ] iOS name/subtitle rollback은 새 편집 가능 version/심사가 필요할 수 있으므로 1.2.6 snapshot과 ASC 상태를 보존한다. 광고/feedback/analytics 문제가 있으면 Remote Config kill switch를 먼저 끈다.
- [ ] 실제 기기, TestFlight, Play Internal testing, consent, Slack retry, network-off/first-run, store preview를 이 저장소에서 자동 실행하지 못했다면 담당자·기기·결과·차단 사유를 release ticket에 남긴다.
