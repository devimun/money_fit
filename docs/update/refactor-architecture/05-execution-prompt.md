# 아키텍처 리팩터링 작업 진행 프롬프트

아래 프롬프트는 새 Codex 작업에서 그대로 복사해 사용할 수 있다. 기본 실행 범위는 **로드맵의 다음 미완료 작업 패키지 하나**다. 여러 단계를 한 번에 진행하려면 실행 범위만 명시적으로 바꾼다.

## 권장 첫 실행 프롬프트

~~~~text
MoneyFit 아키텍처 리팩터링을 시작해주세요.

작업 저장소:
/Users/jun/Desktop/DEV/money_fit

이번 실행 범위:
PR 0.1 — config·font·test bootstrap 복구

반드시 먼저 아래 문서를 모두 읽고, 문서의 결정과 순서를 source of truth로 사용하세요.

1. docs/update/refactor-architecture/README.md
2. docs/update/refactor-architecture/01-current-architecture.md
3. docs/update/refactor-architecture/02-findings.md
4. docs/update/refactor-architecture/03-target-architecture.md
5. docs/update/refactor-architecture/04-migration-roadmap.md

현재 확인된 기준선:

- flutter analyze는 pubspec.yaml의 누락된 .env asset warning 1개로 실패합니다.
- flutter test는 .env asset bundle 오류로 test 수집 전에 중단됩니다.
- assets/fonts/PretendardVariable.ttf는 실제 TTF가 아니라 GitHub HTML 문서입니다.
- 제품 코드는 아직 아키텍처 리팩터링되지 않았습니다.
- 기존 사용자 변경과 관련 없는 dirty file은 절대 되돌리거나 덮어쓰지 마세요.

이번 작업 목표:

1. .env가 없는 clean checkout에서도 analyze와 test가 실행되도록 만드세요.
2. Supabase/Firebase 설정 누락을 앱 전체 실패와 remote capability unavailable로 구분할 수 있는 최소 AppEnvironment 경계를 만드세요.
3. 실제 Pretendard font와 license를 올바르게 설치하거나, 추가 자산 없이 안전한 system font를 사용하도록 정리하세요. 선택 근거를 남기세요.
4. stale Counter widget test와 현재 구현에서 이미 어긋난 설정 widget test를 실제 코드에 맞게 복구하세요.
5. router analytics observer를 주입 가능하게 만들어 test가 실제 Firebase SDK 없이 실행되게 하세요.
6. format/analyze/test가 모두 통과하는 green baseline을 만드세요.

작업 원칙:

- 이번 범위 밖의 feature 이동, DB schema 변경, UI 재설계는 하지 마세요.
- Riverpod, SQLite, GoRouter는 유지하세요.
- 실제 secret이나 운영 key를 repository에 추가하지 마세요.
- Supabase anon key와 Firebase client config는 배포 앱에서 추출 가능한 public client configuration임을 전제로 하되, 실제 값은 문서나 test output에 노출하지 마세요.
- remote config가 없더라도 local UI test는 가능해야 합니다.
- 새 dependency는 기존 도구로 해결할 수 없고 명확한 이득이 있을 때만 추가하세요.
- 오류를 catch 후 빈 값이나 성공으로 바꾸지 마세요.
- 파일 이동과 동작 변경을 불필요하게 섞지 마세요.
- 테스트를 삭제해서 green으로 만들지 말고 현재 production 계약에 맞게 수정하세요.
- stage, commit, push는 별도 요청이 없으면 하지 마세요.

진행 순서:

1. git status와 관련 파일을 확인하고 기존 변경을 보존하세요.
2. PR 0.1의 구체적인 변경 범위와 exit criteria를 짧게 선언하세요.
3. 실패를 재현하고 원인을 증거와 함께 확인하세요.
4. 필요한 최소 변경을 구현하세요.
5. 관련 unit/widget test를 추가하거나 복구하세요.
6. 아래 검증을 실행하세요.

   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test

7. 문서의 사실이나 계획이 구현 결과와 달라졌다면 해당 문서만 함께 갱신하세요.
8. 완료 후 다음 내용을 보고하고 멈추세요.

   - 변경한 파일과 핵심 동작
   - 해결한 기준선 문제
   - 실행한 검증 명령과 결과
   - 남은 위험 또는 의사결정
   - 다음 권장 작업 패키지

완료 조건:

- secret 없는 clean checkout에서 test가 수집·실행됩니다.
- flutter analyze warning이 0개입니다.
- flutter test가 모두 통과합니다.
- font asset이 실제 font이거나 pubspec/theme에서 완전히 제거됐습니다.
- test가 Supabase/Firebase network에 의존하지 않습니다.
- 이번 범위와 무관한 제품 동작과 사용자 변경은 보존됩니다.

완료 조건을 충족하지 못하면 성공으로 보고하지 마세요. 발견한 blocker가 정말 외부 결정이 필요한 경우에만, 이미 시도한 내용과 선택지를 제시하고 사용자에게 질문하세요.
~~~~

## 이후 작업용 재사용 프롬프트

아래에서 실행 범위만 바꿔 사용한다. 예: PR 1.1, PR 3.2, 또는 “4단계 전체”. 기본값은 다음 미완료 작업 패키지 하나다.

~~~~text
MoneyFit 아키텍처 리팩터링을 계속 진행해주세요.

저장소:
/Users/jun/Desktop/DEV/money_fit

실행 범위:
<04-migration-roadmap.md의 정확한 PR 번호와 제목>

source of truth:

- docs/update/refactor-architecture/README.md
- docs/update/refactor-architecture/01-current-architecture.md
- docs/update/refactor-architecture/02-findings.md
- docs/update/refactor-architecture/03-target-architecture.md
- docs/update/refactor-architecture/04-migration-roadmap.md

작업 전 필수 확인:

1. 위 문서를 모두 읽으세요.
2. git status, 현재 구현, 기존 test와 직전 단계 완료 여부를 확인하세요.
3. 선행 작업의 exit criteria가 충족되지 않았다면 후속 단계부터 구현하지 말고 선행 결함을 먼저 보고하세요.
4. 기존 사용자 변경과 범위 밖 dirty file을 보존하세요.

실행 규칙:

- 지정한 작업 패키지만 완료하고 자동으로 다음 패키지까지 확장하지 마세요.
- 현재 → 목표 경계 사이에는 필요한 최소 compatibility facade만 두고 제거 단계를 기록하세요.
- DB schema migration, source-of-truth 전환, 대규모 파일 이동은 별도 변경 단위로 유지하세요.
- core → feature, feature presentation 간 직접 import, SDK singleton 직접 접근을 새로 만들지 마세요.
- domain은 Flutter/Riverpod/sqflite/Firebase/Supabase를 import하지 않게 하세요.
- View와 service/data method 사이에 BuildContext나 WidgetRef를 전달하지 마세요.
- empty와 error, local failure와 optional remote failure를 구분하세요.
- user/month/date/cache identity를 완전하게 모델링하세요.
- write 성공 후 old/new query invalidation을 test로 증명하세요.
- analytics, ads, review, notification failure가 ledger command 성공을 뒤집지 않게 하세요.
- speculative abstraction과 빈 layer를 만들지 마세요.
- stage, commit, push는 별도 요청이 없으면 하지 마세요.

진행 방식:

1. 선택한 작업의 현재 호출 흐름과 실패 재현을 확인합니다.
2. 작업 범위, 유지할 behavior, 바꿀 behavior, exit criteria를 선언합니다.
3. 가능하면 characterization 또는 failing regression test를 먼저 준비하되 main에 의도적인 failing/skip test를 남기지 않습니다.
4. 최소 구현으로 변경합니다.
5. format/analyze/관련 test/전체 test를 실행합니다.
6. architecture allowlist와 문서를 실제 결과에 맞춰 줄이거나 갱신합니다.
7. exit criteria를 항목별로 확인한 뒤 결과를 보고합니다.

최종 보고 형식:

- 완료한 작업 패키지:
- 핵심 변경:
- 변경 파일:
- 검증 결과:
- architecture 지표 변화:
- 남은 위험/결정:
- 다음 권장 작업:

완료 조건을 충족하지 못한 작업을 완료로 표시하지 마세요.
~~~~

## 연속 실행을 요청할 때 추가할 문장

여러 패키지를 연속으로 맡길 때도 각 패키지의 검증과 checkpoint를 생략하지 않는다.

~~~~text
지정한 단계가 끝날 때까지 작업 패키지를 순서대로 진행하세요. 각 패키지마다 exit criteria와 전체 test를 확인하고, 실패하면 다음 패키지로 넘어가지 마세요. DB schema 변경이나 사용자 결정이 필요한 ADR에 도달하면 임의로 결정하지 말고 현재 상태와 선택지를 보고한 뒤 멈추세요.
~~~~

## 권장 실행 순서

첫 10개 선행 backlog는 다음 순서다.

1. PR 0.1 — config·font·test bootstrap
2. PR 0.2 — characterization harness
3. PR 0.3 — ADR·architecture guard·최소 CI
4. PR 0.4 — foundation/관측 seam
5. PR 1.1 — repository failure 계약
6. PR 1.2 — async form command
7. PR 1.3 — 월 identity와 invalidation
8. PR 1.4 — category/reset 안전성
9. PR 1.5 — 통화별 budget rounding
10. PR 1.6 — protected route guard

이후 app composition, ledger vertical slice, projection, session/preferences, startup/router, SQLite v6 순서로 진행한다.
