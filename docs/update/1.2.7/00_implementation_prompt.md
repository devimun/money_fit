# MoneyFit 1.2.7 작업 진행 프롬프트

아래 프롬프트를 새 Codex 작업에 그대로 전달한다.

---

당신은 Flutter 앱 **MoneyFit 1.2.7** 작업의 **메인 오케스트레이터**다. 메인 작업은 사용자에게 진행 상황과 결과를 보고하고 서브에이전트를 조율하는 역할만 맡는다. 코드 수정, 문서 수정, migration 작성, metadata 변경, 테스트·빌드 명령 실행, commit, cherry-pick, merge, 충돌 해결은 모두 서브에이전트에게 맡겨라. 메인 작업이 직접 구현이나 Git 통합을 대신해서는 안 된다.

이번 작업은 계획을 다시 작성하는 일이 아니라, 저장소를 조사한 뒤 아래 계획을 서브에이전트들이 실제 코드·테스트·로컬 배포 자산으로 구현하고 검증하게 만드는 일이다.

작업 저장소:

```text
/Users/jun/Desktop/DEV/money_fit
```

반드시 처음에 `repo_audit` 서브에이전트가 아래 문서 5개를 **끝까지 모두 읽고**, 상충하거나 중복되는 요구사항을 메인에게 보고하게 한 뒤 작업하라. 메인은 문서 조사나 구현을 대신하지 않고 그 보고를 다음 task envelope와 통합 순서에 반영한다.

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

- `repo_audit` 서브에이전트가 먼저 `git status`, 현재 브랜치, Flutter/Dart 버전, 기존 테스트 상태, 로컬/원격 설정 파일 존재 여부를 확인한다. 사용자의 기존 변경과 관련 없는 파일을 수정·삭제·되돌리지 않는다.
- 계획서의 파일명이나 현재 코드가 달라졌다면 현재 저장소를 기준으로 가장 가까운 책임 위치를 찾되, 요구사항의 의미는 유지한다.
- 새 계획 문서만 만들고 멈추지 말라. 안전하게 로컬에서 구현할 수 있는 코드, migration, Edge Function, 테스트, ARB, Fastlane metadata와 validation은 실제로 완료하라.
- Slack Webhook URL, Supabase service-role key, 공유 secret, Amplitude API key, Fastlane credential 같은 값을 코드·migration·`.env`·문서·로그에 넣지 않는다. 모바일 앱에는 service-role/관리자 secret을 절대 포함하지 않는다.
- 운영 Supabase migration/Function/Webhook/Cron 배포, Slack App 생성, Firebase/AdMob/Amplitude 콘솔 변경, App Store Connect/Play Console 업로드·출시·심사 제출은 외부 상태를 바꾸므로 **사용자가 별도로 승인하고 자격증명을 제공하기 전에는 실행하지 않는다**. 대신 배포 가능한 파일과 정확한 명령·순서를 준비한다.
- 실제 운영 schema를 확인할 수 없다면 추정 migration을 운영에 적용하지 않는다. additive·후방 호환 migration 초안을 만들고, 확인이 필요한 DDL/RLS/GRANT 항목을 명시한다.
- 외부 설정이 없어도 다른 구현과 테스트를 계속한다. 키가 없을 때는 안전한 no-op 또는 보수적 off 기본값을 사용하며 production build preflight만 명확히 실패하게 한다.
- 앱의 저장·문의·의견 제출 성공 여부는 광고나 Analytics 성공 여부에 의존하지 않아야 한다.
- 사용자 입력, 이메일, 문의/의견 본문, 예산·지출 금액, 사용자 정의 카테고리명, 원시 UUID를 Analytics로 보내지 않는다.
- 새 사용자 문구는 한국어·영어만 추가하고 끝내지 말고 지원하는 14개 ARB 모두에 반영한다. 생성 파일은 직접 수정하지 않고 `flutter gen-l10n`으로 만든다.
- **서브에이전트 사용은 선택이 아니라 필수다.** 모든 저장소 조사, 구현, 파일 수정, 테스트, 빌드, diff 검토는 서브에이전트가 수행한다.
- 메인 작업은 `spawn_agent`, `send_message`, `followup_task`, `wait_agent`, `list_agents` 같은 조율 수단과 진행 보고만 사용한다. 구현을 위한 shell 실행이나 `apply_patch`를 직접 사용하지 않는다.
- `pubspec.yaml`, `main.dart`, 공용 Remote Config, Analytics taxonomy, ARB, `ExpenseAddForm`, Fastlane처럼 겹치는 파일은 **통합·검증 전담 서브에이전트**가 integration worktree에서 충돌·중복을 해결한다. 메인 작업이 직접 병합하거나 수정하지 않는다.
- 작업 중 확인한 보안 취약점이나 계획과 다른 운영 위험은 숨기지 말고 증거와 함께 보고하되, 요청 범위를 벗어난 대규모 리팩터링은 하지 않는다.

## Git worktree 격리와 기준선 — 강제

원본 worktree는 조사 전용이며 전체 작업 동안 읽기 전용으로 취급한다.

```text
/Users/jun/Desktop/DEV/money_fit
```

메인 작업과 어떤 writer도 이 경로에서 파일 수정, format, code generation, dependency 설치, 테스트·빌드, stage, commit, stash, reset, clean, merge, cherry-pick을 실행하지 않는다. `repo_audit`는 이 경로에서 읽기 전용 명령만 실행하고, worktree 생성 같은 Git 관리 작업은 전담 `worktree_manager` 서브에이전트만 맡는다.

### Dirty 기준선과 BASE_SHA 승인 gate

1. `repo_audit`는 가장 먼저 원본에서 `git status --porcelain=v1 --untracked-files=all`, 현재 branch, `git rev-parse HEAD`를 읽는다.
2. tracked 수정, staged 수정, untracked 파일 중 하나라도 있으면 **모든 쓰기 작업과 worktree 생성을 중단**하고 해당 경로를 사용자에게 보고한다. dirty/uncommitted 변경은 새 worktree에 상속되지 않는다.
3. 메인이나 서브에이전트가 사용자의 변경을 자동 commit, stash, reset, checkout, clean, 복사하거나 patch로 재현해서는 안 된다. 사용자가 기준선을 정리하고 다시 시작해야 한다.
4. 원본이 clean이면 `repo_audit`가 현재 HEAD의 40자리 SHA를 후보 `BASE_SHA`로 보고한다. 메인은 그 정확한 SHA를 사용자에게 제시하고 명시적 승인을 받은 뒤에만 writer worktree 생성을 지시한다. 최초 요청에 정확한 SHA 승인이 이미 포함돼 있으면 그 승인을 재사용할 수 있다.
5. 승인 뒤 원본 HEAD나 branch가 바뀌거나 원본이 다시 dirty가 되면 즉시 중단하고 재감사·재승인을 요청한다. 모든 Wave 1 branch와 integration branch는 승인된 동일 `BASE_SHA`에서 시작한다.

### Worktree manager

`worktree_manager`는 소스 writer가 아니다. 승인 gate 뒤 아래 작업만 수행한다.

- `git worktree list --porcelain`, branch ref, 대상 디렉터리 존재 여부를 먼저 검사한다.
- 권장 root `/Users/jun/Desktop/DEV/money_fit-worktrees` 아래에 worktree를 만들고 `codex/1.2.7-*` branch를 사용한다.
- 이미 같은 path나 branch가 있으면 삭제·재사용·덮어쓰기·강제 이동하지 않는다. `-2`, `-3`처럼 충돌하지 않는 suffix를 붙여 고유 path와 branch를 만들고 실제 값을 보고한다.
- 정확한 승인 SHA 또는 최신 integration checkpoint SHA에서만 새 branch/worktree를 만든다.
- 한 worktree에는 동시에 writer 한 명만 배정한다. 다른 에이전트는 해당 worktree에서 읽기와 쓰기를 모두 하지 않는다.
- writer가 시작한 뒤 같은 worktree를 다른 writer에게 넘기지 않는다. 후속 수정이 필요하면 최신 integration checkpoint에서 새 고유 worktree/branch를 만든다.

권장 배치는 다음과 같다. 실제 path/branch가 충돌해 manager가 suffix를 붙였다면 이후 모든 지시는 그 실제 값을 사용한다.

| 역할 | 권장 worktree | 권장 branch | 시작 commit | 쓰기 소유 범위 |
| --- | --- | --- | --- | --- |
| `repo_audit` | 원본 worktree, read-only | 기존 branch, read-only | 후보 `BASE_SHA` | 없음 |
| `integration_verification` | `/Users/jun/Desktop/DEV/money_fit-worktrees/integration` | `codex/1.2.7-integration` | 승인 `BASE_SHA` | cherry-pick, 충돌 해결, 공용 파일, 최종 통합 수정·검증 |
| `analytics_foundation` | `/Users/jun/Desktop/DEV/money_fit-worktrees/analytics-foundation` | `codex/1.2.7-analytics-foundation` | 승인 `BASE_SHA` | Analytics/Config/coordinator, `pubspec*`, `main.dart`, router, 관련 테스트 |
| `slack_backend` | `/Users/jun/Desktop/DEV/money_fit-worktrees/slack-backend` | `codex/1.2.7-slack-backend` | 승인 `BASE_SHA` | `supabase/**`, 문의 repository/dialog와 관련 테스트 |
| `aso_fastlane` | `/Users/jun/Desktop/DEV/money_fit-worktrees/aso-fastlane` | `codex/1.2.7-aso-fastlane` | 승인 `BASE_SHA` | Android/iOS Fastlane metadata·validation |
| `ad_policy` | `/Users/jun/Desktop/DEV/money_fit-worktrees/ad-policy` | `codex/1.2.7-ad-policy` | Wave 1 integration checkpoint | 광고 정책·UI·호출부와 관련 테스트 |
| `feedback_prompt` | `/Users/jun/Desktop/DEV/money_fit-worktrees/feedback-prompt` | `codex/1.2.7-feedback-prompt` | Wave 2 integration checkpoint | 의견 UI/repository/ARB와 관련 테스트 |

표의 범위는 상한이다. `repo_audit` 결과를 바탕으로 각 task envelope에서 실제 수정 가능 경로를 더 좁혀야 하며, writer가 임의로 확장해서는 안 된다.

### 모든 에이전트의 시작 검증

모든 에이전트는 최초 작업과 각 follow-up의 읽기나 쓰기를 시작하기 전에 자신의 할당 경로에서 아래를 실행하고 결과를 첫 상태 보고에 포함한다.

```bash
pwd
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch
git rev-parse HEAD
```

writer는 다음 조건을 모두 만족해야 한다.

- `pwd`와 top-level이 task envelope의 정확한 worktree 절대경로와 같다.
- branch가 할당된 고유 `codex/1.2.7-*` branch와 같다.
- status가 clean이다.
- HEAD가 task envelope의 `EXPECTED_HEAD`와 같다.

하나라도 다르면 수정·테스트·commit을 시작하지 말고 `BLOCKED_START_CHECK`로 보고한다. 자동 checkout, reset, stash, clean으로 맞추지 않는다. `repo_audit`와 `worktree_manager`도 원본 경로·branch·HEAD·status를 같은 방식으로 검증하되, 원본을 고치지 않는다.

### Writer task envelope — 필수

메인은 writer를 시작시킬 때 자유 형식의 모호한 지시를 보내지 않는다. 모든 쓰기 task에는 다음 필드를 정확히 포함한다.

```text
ROLE: <workstream 이름>
WORKTREE: <절대경로>
BRANCH: <정확한 branch>
BASE_SHA: <사용자가 승인한 40자리 SHA>
EXPECTED_HEAD: <BASE_SHA 또는 최신 integration checkpoint SHA>
DEPENDENCIES: <이미 통합된 checkpoint/계약/선행 commit>
ALLOWED_PATHS: <수정 가능한 정확한 파일 또는 디렉터리 목록>
FORBIDDEN_PATHS: <원본 worktree와 다른 workstream 소유 경로>
REQUIRED_TESTS: <이 task가 실행해야 할 정확한 명령>
COMMIT_POLICY: <stage 범위, commit 수, 금지 작업>
HANDOFF_FORMAT: <아래 상태 보고 형식>
```

`ALLOWED_PATHS`, `REQUIRED_TESTS`, commit policy가 없는 writer는 시작시키지 않는다. task 도중 범위 확장이 필요하면 writer는 멈춰 메인에 요청하고, 메인은 Agent 0·integration 전담과 조율해 새 envelope를 보낸다. writer가 스스로 공용 파일을 추가 소유하지 않는다.

### Commit과 handoff

- writer는 할당 경로만 명시적으로 stage한다. `git add -A`로 다른 경로를 포괄하지 않는다.
- 기본은 task당 하나의 coherent implementation commit이다. 불가피하게 여러 commit이 필요하면 task envelope가 순서와 이유를 미리 허용해야 한다.
- merge commit, 다른 workstream cherry-pick, rebase, push, force-push, commit amend는 금지한다.
- 필수 테스트와 `git diff --check`를 실행하고, commit 뒤 status가 clean인지 확인한다.
- 완료 handoff에는 commit의 40자리 SHA, 변경 파일, 실행한 검증 명령과 exit/result, 미실행 항목, blocker, integration 주의사항을 포함한다.
- handoff 뒤 commit을 rewrite하지 않는다. commit SHA가 없거나 worktree가 dirty한 결과는 integration 대상으로 인정하지 않는다.

### Integration 전담과 checkpoint 흐름

`integration_verification`은 integration worktree의 유일한 writer다. 이 에이전트는 최초 worktree 생성 직후 시작 검증과 baseline 검증을 수행하고, 각 wave 뒤 follow-up으로 재사용한다. 메인은 integration worktree에서 어떤 Git 명령도 실행하지 않으며 commit, cherry-pick, merge, 충돌 해결을 직접 하지 않는다.

```text
승인 BASE_SHA
  ├─ analytics_foundation ─┐
  ├─ slack_backend ────────┼─ integration이 dependency order로 cherry-pick → I1
  └─ aso_fastlane ─────────┘

I1 ─ ad_policy ────────────── integration이 cherry-pick·검증 → I2
I2 ─ feedback_prompt ───────── integration이 cherry-pick·검증 → I3
I3 ─ 최종 공용 충돌 해결·생성물·버전·전체 검증 ───────────→ IFINAL
```

통합 순서는 `analytics_foundation` → `slack_backend` → `aso_fastlane` → `ad_policy` → `feedback_prompt`다. integration 전담은 각 commit을 추적 가능한 방식으로 하나씩 cherry-pick하고, 충돌이 나면 해당 writer의 handoff와 계획서를 확인해 integration worktree에서 해결한다. 공용 계약을 임의로 중복 구현하지 않는다.

각 wave 통합 후 integration 전담은 targeted 검증, `git diff --check`, clean status를 확인하고 새 40자리 checkpoint SHA(`I1`, `I2`, `I3`)를 보고한다. 다음 wave worktree는 반드시 이 최신 checkpoint에서 생성한다. checkpoint가 없거나 검증이 실패하면 다음 wave를 시작하지 않는다.

integration 전담이 충돌 해결, generated file, 버전, 공용 wiring을 수정했다면 그 변경도 integration branch에 coherent commit으로 남긴다. `IFINAL`은 모든 cherry-pick과 통합 전용 commit, 최종 검증이 끝난 clean integration worktree의 HEAD여야 한다. 원본 branch로 자동 merge하거나 원본 worktree를 갱신하지 않고, 최종 branch와 `IFINAL` SHA를 사용자에게 인계한다.

기능 자체의 결함이 발견돼 원 담당에게 돌려보내야 하면 기존 stale worktree를 재사용하지 않는다. `worktree_manager`가 최신 checkpoint에서 `<workstream>-fix-N` 고유 worktree/branch를 만들고, 정확한 repair envelope를 받은 writer가 새 commit을 인계한다. integration 전담이 그 commit을 다시 cherry-pick하고 검증한다. 단순 merge conflict, generated file, 버전, 공용 wiring 문제만 integration 전담이 integration branch에서 직접 수정한다.

### 비파괴 cleanup

- 작업 중에는 worktree나 branch를 삭제하지 않는다. handoff와 통합 검증을 위해 그대로 보존한다.
- 최종 완료 뒤에도 기본값은 보존이다. 사용자가 cleanup을 요청한 경우에만 `worktree_manager`가 자신이 만든 worktree 중 clean하고 IFINAL에 반영된 것만 일반 `git worktree remove <path>`로 제거할 수 있다.
- `--force`, `rm -rf`, `git clean`, `git reset`, `git stash`, branch 강제 삭제, 기존 path/branch 재사용은 금지한다.
- dirty worktree, 미통합 commit, 출처가 불명확한 기존 worktree/branch는 제거하지 않고 경로와 상태만 보고한다.

### 강제 상태 보고 형식

각 서브에이전트는 시작, blocker, commit handoff, integration checkpoint마다 다음 형식을 사용한다. 메인은 이를 모아 사용자에게 요약한다.

```text
STATUS: STARTED | IN_PROGRESS | BLOCKED_START_CHECK | BLOCKED | COMMITTED | INTEGRATED | VERIFIED
ROLE: <agent/workstream>
WORKTREE: <절대경로>
BRANCH: <branch 또는 read-only>
BASE_SHA: <승인 SHA>
EXPECTED_HEAD: <시작 시 기대 SHA>
ACTUAL_HEAD: <현재 40자리 SHA>
START_CHECK: pwd=<...>; top_level=<...>; status=<clean/dirty>; result=<PASS/FAIL>
ALLOWED_PATHS: <요약>
CHANGED_FILES: <없음 또는 목록>
COMMIT_SHA: <없음 또는 40자리 SHA>
VALIDATION: <명령별 PASS/FAIL/NOT_RUN>
BLOCKERS: <없음 또는 증거와 필요한 결정>
INTEGRATION: <not_ready/pending/cherry-picked/checkpoint SHA>
```

## 서브에이전트 오케스트레이션 — 강제

메인 작업은 아래 구조를 반드시 따른다. 가용 동시 실행 수를 넘지 않게 wave로 나누며, 각 서브에이전트에는 담당 문서, 수정 가능 범위, 수정 금지 범위, 선행 결과와 완료 조건을 구체적으로 전달한다.

### 메인 작업의 역할

- 시작 시 사용자에게 전체 작업이 서브에이전트 wave로 진행된다고 알린다.
- 원본의 clean 상태와 후보 SHA를 보고받고, 정확한 `BASE_SHA` 사용자 승인을 받기 전에는 write worktree 생성을 지시하지 않는다.
- 각 에이전트의 상태, 변경 파일, 테스트 결과, blocker를 수집해 60초 이내 간격으로 필요한 진행 보고를 한다.
- 에이전트끼리 공유 계약이나 파일 소유권을 합의해야 하면 직접 코드를 고치지 말고 서로 메시지를 보내 조율한다.
- 한 에이전트가 완료했다고 바로 전체 완료로 판단하지 않는다. 전담 통합·검증 에이전트의 최종 검증 결과를 기다린다.
- secret, 콘솔 설정, 법적 결정, 운영 배포 승인처럼 사용자만 해결할 수 있는 blocker만 사용자에게 보고한다. 한 workstream이 막혀도 다른 에이전트 작업은 계속 진행한다.
- shell, `apply_patch`, worktree 생성, stage, commit, cherry-pick, merge, rebase, 충돌 해결, 테스트를 직접 실행하지 않는다. 전담 서브에이전트의 증거를 수집하고 보고만 한다.
- 최종적으로 사용자에게 구현 결과, 테스트, 미완료 외부 작업, rollout/rollback을 보고한다.

### Agent 0 — 저장소 감사·통합 설계

가장 먼저 하나의 서브에이전트를 `repo_audit` 역할로 실행한다.

- 다섯 계획서를 모두 끝까지 읽는다.
- dirty worktree, 의존성, 기존 구조, 공유 파일, 기존 테스트 구성과 결과 기록, 실제 충돌 지점을 읽기 전용으로 조사한다. 원본을 변경할 수 있는 dependency 설치·format·codegen·테스트·빌드는 실행하지 않고, 실행 baseline은 승인 뒤 integration worktree에서 측정한다.
- 각 workstream의 파일 소유권과 공용 API 계약을 제안한다.
- 사용자 변경으로 보이는 파일과 건드리면 안 되는 범위를 표시한다.
- 이 단계에서는 파일을 수정하지 않는다.

원본이 dirty면 여기서 전체 작업을 중단한다. clean이고 사용자가 정확한 `BASE_SHA`를 승인하면 메인은 `worktree_manager`에게 표의 integration/Wave 1 worktree 생성을 지시하고, 실제 path·branch를 받은 뒤 다음 에이전트들에게 task envelope를 전달한다. integration 전담은 integration worktree의 유일한 writer로 먼저 시작해 baseline을 기록한다.

### Wave 1 — 공용 기반·Backend·ASO

가용 슬롯 안에서 다음 세 에이전트를 병렬 실행한다.

1. `analytics_foundation`
   - 주 문서: `03_amplitude_setup.md`
   - Amplitude/Firebase facade, taxonomy, sanitizer, consent, identity, 공용 Remote Config 초기화, 전면 UI coordinator 계약을 구현한다.
   - `pubspec.yaml`, `main.dart`, router와 공용 Analytics/Config 파일의 1차 소유자다.
   - 광고·의견의 전체 기능은 구현하지 않고 사용할 공용 API와 fake/test 기반만 제공한다.

2. `slack_backend`
   - 주 문서: `01_slack_inquiry_alert.md`
   - 보조 문서: `04_feedback_prompt.md`의 Supabase/RLS/Slack 구간
   - `user_contact`와 `app_feedback` additive migration/RPC/RLS 초안, 공용 Slack delivery helper, Edge Functions, backend 테스트를 구현한다.
   - Flutter에서는 문의 enum/repository/dialog 전송 안정성까지 담당하되 의견 모달 UI는 건드리지 않는다.
   - 운영 Supabase나 실제 Slack에는 배포하지 않는다.

3. `aso_fastlane`
   - 주 문서: `05_aso_localization.md`
   - iOS/Android metadata, locale 정리, Fastlane metadata-only validation/preview, 길이·byte·금칙어 검사를 구현한다.
   - 스토어 업로드·publish·심사 제출은 하지 않는다.
   - 앱 런타임 코드와 다른 기능 파일은 건드리지 않는다.

Wave 1 writer들은 각자 clean commit SHA와 검증 결과를 인계한다. `integration_verification` 전담이 세 commit을 정해진 순서로 integration branch에 cherry-pick하고 targeted 검증을 통과한 `I1` checkpoint SHA를 만든 뒤에만 메인 작업이 결과를 사용자에게 요약 보고하고 다음 wave를 시작한다.

### Wave 2 — 광고

`ad_policy` 서브에이전트를 실행한다.

- 주 문서: `02_ad_frequency.md`
- `I1` checkpoint에서 만든 새 ad worktree/branch에서 시작하고 Wave 1의 Analytics, Remote Config, coordinator 계약을 재사용한다.
- 광고 서비스, eligibility/cap, UMP, 앱 lifecycle, 배너, 호출부와 관련 테스트를 구현한다.
- 공용 파일 변경이 필요하면 먼저 `analytics_foundation` 에이전트에 메시지로 계약을 확인하거나, 변경 필요 사항을 통합 에이전트용 handoff에 남긴다.
- 의견 모달 기능과 번역은 건드리지 않는다.

광고 작업을 먼저 끝내는 이유는 지출 저장 이후 의미 행동과 전면 UI opportunity의 실제 호출 계약을 의견 모달이 재사용해야 하기 때문이다.

`ad_policy`가 clean commit을 인계하면 integration 전담이 이를 `I1` 위에 cherry-pick하고 targeted 검증을 통과한 `I2` checkpoint SHA를 만든다. `I2` 전에는 Wave 3를 시작하지 않는다.

### Wave 3 — 자유 의견 모달

`feedback_prompt` 서브에이전트를 실행한다.

- 주 문서: `04_feedback_prompt.md`
- `I2` checkpoint에서 만든 새 feedback worktree/branch에서 시작하고 Wave 1 backend와 Analytics, Wave 2의 저장 성공/전면 UI coordinator 계약을 재사용한다.
- eligibility, stable cohort, cooldown/cap, UI, repository/RPC 연결, 14개 ARB, 접근성, 테스트를 구현한다.
- 기존 리뷰 흐름을 보존하고 광고·리뷰·의견이 연달아 뜨지 않게 통합한다.
- backend delivery 로직을 복제하지 않는다. 필요한 변경은 `slack_backend` 결과 위에 최소 범위로 적용한다.

`feedback_prompt`가 clean commit을 인계하면 integration 전담이 이를 `I2` 위에 cherry-pick하고 targeted 검증을 통과한 `I3` checkpoint SHA를 만든다.

### Wave 4 — 통합·검증 전담

초기부터 integration worktree를 단독 소유해 각 wave를 통합해 온 `integration_verification` 서브에이전트에게 최종 검증 follow-up을 보낸다. Agent 0이나 다른 writer가 integration worktree에 들어가거나 그 branch를 수정해서는 안 된다.

- 다섯 계획서와 모든 서브에이전트의 완료 보고를 다시 읽는다.
- 전체 `git diff`를 검토하고 공유 파일 충돌, 중복 service, event 명칭 불일치, import/DI 문제를 직접 수정한다.
- ARB 통합과 `flutter gen-l10n`, 버전 갱신, external setup checklist 작성도 이 에이전트가 담당한다.
- 전체 formatting, analyze, test, 가능한 platform build, Supabase/Edge Function test, Fastlane validation을 실행하고 실패를 수정한다.
- 관련 없는 사용자 변경을 되돌리지 않는다.
- 구현 완료 조건별 PASS/FAIL과 증거, 실행하지 않은 외부 작업을 메인 작업에 보고한다.

메인 작업은 이 에이전트가 `IFINAL` SHA와 PASS를 보고하기 전에는 “완료”라고 말하지 않는다. FAIL이 남으면 최신 integration checkpoint에서 새 repair worktree/branch를 만든 뒤 담당 에이전트에게 follow-up을 보내 수정하게 하고, integration 전담이 repair commit을 cherry-pick한 뒤 다시 전체 검증한다. 메인이 직접 병합하거나 기존 stale worktree에서 수정을 계속하게 해서는 안 된다.

`IFINAL` 검증 뒤 `repo_audit`는 원본 worktree에서 처음과 같은 read-only 명령을 다시 실행해 branch, HEAD, clean status가 최초 감사와 같은지 확인한다. `worktree_manager`는 모든 관리 대상 worktree의 실제 path, branch, HEAD, clean/dirty, 통합 여부를 읽기 전용으로 목록화한다. 메인은 integration PASS와 이 최종 원본·worktree 감사가 모두 도착한 뒤에만 완료 보고를 한다.

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

## Workstream별 상세 구현 명세

실제 실행 순서는 앞의 강제 wave 구성을 따른다. 아래 항목은 메인 작업이 직접 수행할 단계가 아니라 각 담당 서브에이전트에 전달할 상세 완료 명세다.

### Agent 0 명세 — 기준 상태와 충돌 확인

1. 저장소 구조, dirty worktree, 현재 앱 버전(`1.2.6+17`), 의존성, 테스트와 Fastlane lane을 확인한다.
2. `user_contact`, `app_feedback` 관련 기존 코드와 저장 payload, 인증 초기화 순서, RLS를 로컬에서 확인한다.
3. 광고 호출 위치를 전수 검색해 validation/저장 전에 광고가 실행되는 경로를 표시한다.
4. Firebase Analytics, Remote Config, 리뷰 프롬프트, 앱 오프닝/전면 광고, route observer, ARB locale 목록을 확인한다.
5. 계획과 현재 코드가 충돌하면 파일을 수정하지 말고 메인에게 읽기 전용 보고로 짧은 작업 계획 갱신안을 제안한다. 단, dirty 기준선, `BASE_SHA` 승인, secret·법적 결정·운영 배포 승인처럼 강제 중단하거나 사용자 권한이 필요한 항목을 안전한 가정으로 넘기지 않는다.

### `analytics_foundation` 명세 — 공용 기반과 Amplitude

1. 구현 시점의 공식 호환 버전을 확인한 뒤 `amplitude_flutter` 4.x를 추가하고 lockfile을 갱신한다.
2. `AnalyticsConfig`, event taxonomy, sanitizer, dual-write service, Riverpod provider, Navigator observer, consent repository/settings UI를 구현한다.
3. Amplitude key/zone/env/enabled는 `--dart-define`으로만 받고 로그에서 가린다. key가 없으면 앱은 Noop으로 정상 실행한다.
4. 개인정보 우선 기본값은 명시적 동의 전 수집 off다. 동의 철회 시 Amplitude와 Firebase 모두 중단한다.
5. P0 이벤트를 실제 성공 지점에 연결하고 이벤트 literal·PII·고카디널리티 값이 새지 않게 테스트한다.
6. Fastlane beta build가 dart-define을 받을 수 있게 만들되 실제 key는 저장소에 넣지 않는다.

### `slack_backend` 명세 — 문의/의견 Backend 자산과 Slack

1. `supabase/config.toml`, additive migrations, 두 Edge Function 또는 공용 delivery helper 구조를 추가한다.
2. 기존 1.2.6 payload가 계속 동작하도록 nullable/default/backfill 순서를 지킨다. 과거 행은 `suppressed`로 처리해 일괄 알림을 막는다.
3. `user_contact`는 자기 UID의 INSERT만, `app_feedback` 신규 제출은 idempotent RPC를 사용하도록 RLS/GRANT 초안을 구현한다. 앱은 운영 delivery 필드를 지정하거나 SELECT/UPDATE/DELETE할 수 없어야 한다.
4. 문의 유형은 `bug_report`, `feature_suggestion`, `general_inquiry`, `other` 고정 코드로 저장하고 화면에서만 번역한다.
5. Slack payload에는 안전한 ID, 서버 시각, platform, locale, app version/build와 필요한 본문만 plain text로 넣는다. raw UID·secret·JWT를 로그/메시지에 노출하지 않는다.
6. 200/400/403/404/429/5xx/timeout, 동시 중복 호출, 재시도 소진, stale processing을 테스트한다.
7. `ContactUsDialog`는 repository를 주입받고 전송 중 중복 탭 방지, 실패 시 입력 보존, 성공 시에만 닫힘을 구현한다.

### `ad_policy` 명세 — 광고 정책 리팩터링

1. `recordMeaningfulAction()`과 `maybeShowInterstitial()`을 분리한다.
2. control 기본값은 기존과 같은 **12회 행동 + 600초**로 유지하고, 후보 **8회 + 480초**는 Remote Config/A-B 값으로만 둔다.
3. 신규 사용자 3세션 유예, 세션 120초 유예, 세션 최대 3회, rolling 24시간 최대 8회와 interstitial/app-open 공용 cap을 영속화한다.
4. Android/iOS 공식 테스트 ID를 플랫폼별로 분리한다. 테스트 빌드에서 운영 광고를 클릭하지 않는다.
5. UMP `canRequestAds` 전에는 SDK 초기화/요청을 하지 않고 privacy options 진입점을 제공한다.
6. 앱 오프닝 광고는 기본 `false`로 유지한다. 늦게 로드된 광고가 이미 진입한 콘텐츠 위에 뜨지 않게 한다.
7. 문의, 의견, 개인정보, 동의, 데이터 삭제, 업데이트 화면과 검증/저장 실패에서는 광고를 금지한다.
8. 배너는 visible 상태, adaptive size, 캐시/재요청, 여백, layout shift를 검증한다.
9. load/show/impression/click/dismiss/paid/suppress/config-invalid 이벤트를 공용 Analytics facade에 연결한다.

### `feedback_prompt` 명세 — 자유 의견 모달

1. `04_feedback_prompt.md`의 기본 정책을 그대로 구현한다: 설치 7일, 3세션, 성공한 신규 지출 10회, 서로 다른 active day 3일 이후에만 eligibility가 생긴다.
2. 첫 production 기본 rollout은 off 또는 문서의 stable 5% cohort로 제어 가능해야 하며, Remote Config 실패와 캐시 부재 시에는 off다.
3. 한 세션/하루 1회, rolling 180일 최대 3회, `later=30일`, `dismiss=14일`, `submitted=120일`, 리뷰/의견 공통 cooldown 30일, `never` 영구 상태를 구현한다.
4. stable bucket과 clock/storage를 주입 가능하게 만들어 경계값을 단위 테스트한다.
5. 입력 3~1,000자, 중복 submit 방지, 동일 `client_submission_id` 재사용, 실패 시 내용 보존, PII 주의 문구, rate-limit 전용 UX를 구현한다.
6. 기존 부정 리뷰 피드백은 `review_negative`, 새 모달은 `proactive_prompt`로 저장한다. 한 액션에서 `user_contact`와 `app_feedback`을 동시에 만들지 않는다.
7. 14개 전용 번역 키를 모든 ARB에 추가하고 작은 화면, 키보드, text scale 200%, dark mode, 접근성 semantics를 검증한다.

### `aso_fastlane` 명세 — ASO와 Fastlane metadata

1. `05_aso_localization.md`의 iOS/Android 최종 카피 표를 그대로 metadata 파일에 적용한다.
2. 영어권에서 `Daily Budget`을 가계부 번역으로 사용하지 않는다. 영어 앱 이름은 반드시 `MoneyFit - Expense Tracker`, subtitle은 `Know what you can spend today`로 둔다.
3. iOS는 Apple이 지원하는 12개 제품 locale와 `en-GB` fallback을 사용한다. Apple이 metadata locale로 지원하지 않는 `bg`, `fil` 폴더를 억지로 만들지 않는다.
4. Android는 비공식 중복 `ms`를 제거하고 `ms-MY`로 단일화하며 `fil`을 추가한다. 삭제 전 두 폴더의 차이를 확인하고 필요한 자산을 보존한다.
5. 긴 설명의 검증 불가능한 최상급을 제거하고, 검증 전 `offline`, `no login`, `100% private` 주장을 추가하지 않는다.
6. iOS name/subtitle 30자, keywords UTF-8 100 bytes, Android title 30자, short description 80자를 검사하는 validation을 추가한다. 14개 언어/locale 매핑, 필수 파일, 빈 URL, 금칙어도 검사한다.
7. iOS `force: true`로 preview를 건너뛰지 않게 하고, metadata-only lane은 바이너리 업로드·심사 제출·자동 publish를 하지 않게 검증한다.
8. 로컬 preview/validation까지만 수행하고 App Store Connect/Play Console에는 업로드하지 않는다.

### `integration_verification` 명세 — 통합, 버전, 검증

1. 승인된 `BASE_SHA`에서 시작한 integration branch에 각 writer의 clean commit을 정해진 dependency order로 하나씩 cherry-pick하고, wave마다 검증된 checkpoint SHA를 남긴다.
2. 공용 coordinator, Remote Config, Analytics, 지출 저장 순서가 서로 다른 기능에서 중복 구현되지 않았는지 전체 diff를 리뷰한다.
3. 14개 ARB JSON/key/placeholder parity와 생성 getter를 검사한다.
4. 현재 원격 최신 build가 17 이하임을 확인할 수 있으면 `pubspec.yaml`을 `1.2.7+18`로 올린다. 더 높은 build가 확인되면 반드시 그보다 큰 번호를 사용한다. 확인할 수 없다면 `1.2.7+18`로 로컬 준비하고 외부 확인 필요 사항에 기록한다.
5. 가능한 범위에서 다음을 실행하고 실패를 실제로 수정한다.

```bash
flutter pub get
flutter gen-l10n
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
git diff --check
```

6. 환경이 허용하면 Supabase migration/Function 테스트, Android debug 또는 release build, iOS simulator build, Fastlane metadata validation/preview도 실행한다. credential·Docker·Xcode 문제는 코드 실패와 구분해 보고한다.
7. 검증을 통과시키기 위해 기존 테스트를 삭제하거나 assertion을 약하게 만들지 않는다.
8. 통합 전용 수정은 coherent commit으로 남기고, 최종 status가 clean인 HEAD를 `IFINAL`로 보고한다. 원본 branch/worktree에는 merge, cherry-pick, 파일 복사를 하지 않는다.

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
- 모든 writer 결과가 고유 worktree/branch의 clean commit SHA로 인계되고 dependency order대로 integration branch에 반영돼 있다.
- 최종 integration worktree가 clean이고, 승인 `BASE_SHA`에서 이어지는 재현 가능한 `IFINAL` SHA가 보고돼 있다.
- 원본 worktree와 원본 branch는 전체 작업 동안 수정·merge·cherry-pick되지 않았다.

## 최종 보고 형식

작업을 마치면 다음 순서로 짧고 구체적으로 보고하라.

1. 승인된 `BASE_SHA`, 최종 integration worktree 절대경로, branch, `IFINAL` SHA
2. workstream별 worktree/branch/commit SHA와 integration checkpoint(`I1`, `I2`, `I3`) 표
3. 구현 완료 결과와 사용자에게 보이는 변화
4. 주요 변경 파일과 설계 결정
5. 실행한 테스트/빌드 명령과 PASS/FAIL/NOT_RUN 결과
6. 아직 필요한 외부 콘솔 작업·secret·법적 결정
7. 위험, 단계적 rollout 순서와 즉시 rollback 방법
8. 원본 worktree가 읽기 전용으로 유지됐고 관련 없는 기존 변경을 건드리지 않았다는 확인
9. 보존 중인 worktree/branch와 cleanup을 실행하지 않았거나 사용자 승인 아래 비파괴적으로 실행한 결과

단순히 “계획대로 구현했다”고 말하지 말고, 실제 파일·테스트 결과·미완료 외부 의존성을 증거로 제시하라.

---
