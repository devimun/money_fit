# MoneyFit 아키텍처 리팩터링 분석

> 분석 기준: 2026-07-21, `main` 브랜치 `4ebbddd`  
> 범위: `lib/`, `test/`, 모바일 빌드·배포 설정, 자산, 기존 아키텍처 문서  
> 성격: 현재 코드에 대한 정적 분석과 개선 설계 문서이며, 이 작업에서는 제품 코드를 변경하지 않았다.

## 결론

현재 MoneyFit은 **폴더는 Feature-first지만 실행 구조는 `core` 중심의 혼합형 Layer-first**에 가깝다.

지출 조회의 주 흐름은 실제로 다음과 같다.

```text
View
  → Feature ViewModel
  → core 전역 AsyncNotifier
  → concrete Repository
  → DatabaseHelper singleton
  → SQLite
```

여기에 화면과 ViewModel이 Firebase, Supabase, AdMob, 권한 플러그인을 직접 호출하고, `core`가 다시 feature ViewModel을 import한다. 따라서 기능 폴더가 존재해도 데이터·상태·유스케이스의 소유권은 기능 안에 닫혀 있지 않다. 한 기능을 수정하면 전역 날짜, 전역 월 캐시, 사용자 설정, 광고·알림 코드까지 함께 영향을 받는다.

가장 먼저 해결해야 할 것은 폴더 이동이 아니라 다음 세 가지다.

1. **데이터 정확성 고정**: 저장소 오류 삼키기, 월 캐시 식별자, 비동기 지출 저장·수정 의미를 바로잡는다.
2. **소유권 정리**: Expense·Category·CRUD·월 조회를 하나의 `ledger` 기능이 소유하고, 홈·캘린더·통계는 그 공개 read model만 소비한다.
3. **회귀 방지**: 깨끗한 checkout에서 analyze/test가 실행되게 만들고, 핵심 도메인·DB migration·provider invalidation 테스트와 import 경계 검사를 추가한다.

디렉터리만 먼저 옮기는 대규모 변경은 현재 버그와 결합을 새 폴더에 그대로 복제하므로 권장하지 않는다.

## 현재 상태 요약

| 영역 | 판정 | 핵심 근거 |
| --- | --- | --- |
| Feature-first 응집도 | 미달 | Expense/Category 모델·저장소·CRUD·폼이 `core`에 분산 |
| MVVM 책임 분리 | 부분 적용 | ViewModel은 있으나 UI 색상, `BuildContext`, SDK, navigation side effect가 침투 |
| 의존성 방향 | 위험 | file-level import cycle 2개, `core → feature` 역참조, feature presentation 간 참조 |
| 상태 소유권 | 위험 | `dateManager` 하나가 홈·캘린더·통계·목록의 서로 다른 날짜 의미를 공유 |
| 데이터 무결성 | 위험 | 오류→빈 Map 변환, FK/index/check 부재, `double/REAL`, 통화 snapshot 부재 |
| 시작·라우팅 | 취약 | 선택 기능이 startup gate에 결합; 일부 오류는 onboarding 오인, update gate 정지, 일부는 무시 |
| 테스트 | 매우 취약 | 128개 테스트가 theme/settings에 편중; ledger/DB/startup/navigation 테스트 없음 |
| 재현 가능성 | 실패 | `.env`가 필수 asset이지만 부재하여 test가 수집 전에 중단 |
| 저장소 위생 | 취약 | 잘못된 폰트 자산, 75MB 빌드 산출물 추적, 최소 1,151 LOC 미도달 코드 |

## 우선순위

### P0 — 구조 변경 전에 막아야 할 위험

- [등록된 폰트 파일](../../../assets/fonts/PretendardVariable.ttf)이 실제 TTF가 아니라 GitHub HTML 문서다.
- [`.env`를 필수 asset으로 선언](../../../pubspec.yaml#L77-L80)했지만 샘플·fallback이 없고 현재 파일도 없어 테스트와 clean build가 재현되지 않는다.
- [월 조회 오류를 `{}`로 바꾸고](../../../lib/core/repositories/expense_repository.dart#L68-L104), [update 실패도 삼킨다](../../../lib/core/repositories/expense_repository.dart#L107-L130).
- [월 캐시 키가 사용자 없이 `year-month`뿐](../../../lib/core/providers/expenses_provider.dart#L11-L36)이고, 빈 달은 정상 이동할 수 없다.
- [지출 form이 async submit을 기다리지 않으며](../../../lib/core/widgets/expense_management/expense_add_form.dart#L15-L24), 수정 시 기존 날짜와 `createdAt`을 현재 시각으로 덮어쓴다.
- SQLite에 FK, index, enum·금액 check가 없고 currency 의미도 보존하지 않는다.
- GoRouter redirect가 없어 protected deep link가 업데이트 검사와 setup/startup gate를 우회할 수 있다.

### P1 — Feature-first MVVM 경계 회복

- `ledger`, `session`, `budget`, `preferences`의 단일 소유자를 만든다.
- `core → feature`, feature View/ViewModel 간 직접 import, SDK global 접근을 제거한다.
- 홈·캘린더·통계·목록의 날짜 상태를 분리하고 `MonthKey` family query로 조회한다.
- 성공일·연속 성공·평균·예산 반올림을 순수 도메인 정책 하나로 통합한다.
- startup을 critical과 best-effort로 나누고 router가 상태를 반영하도록 바꾼다.

### P2 — 단순화와 운영 품질

- 미도달·중복·주석 파일, 사용하지 않는 패키지와 자산을 정리한다.
- superfile을 책임 기준으로 나누되, 파일 수를 늘리는 목적의 계층은 만들지 않는다.
- `StatefulShellRoute.indexedStack`, typed route argument, 단일 preferences state를 적용한다.
- CI에 format/analyze/test/architecture boundary 검사를 넣는다.

## 문서 구성

1. [현재 아키텍처](./01-current-architecture.md)  
   실제 부팅, routing, provider, 데이터 저장, 기능별 책임과 의존 흐름을 설명한다.

2. [문제 진단](./02-findings.md)  
   데이터 무결성, 책임 혼합, superfile, 하드코딩, 테스트·저장소 부채를 근거와 함께 우선순위화한다.

3. [목표 Feature-first MVVM](./03-target-architecture.md)  
   목표 폴더 구조, 기능 소유권, MVVM 역할, 상태·캐시·오류·외부 SDK 경계를 정의한다.

4. [단계별 이행 계획](./04-migration-roadmap.md)  
   big-bang 없이 옮기는 PR 순서, 현재→목표 파일 매핑, 테스트 전략, 완료 조건과 rollback 기준을 제시한다.

5. [작업 진행 프롬프트](./05-execution-prompt.md)  
   첫 작업과 이후 작업에서 그대로 복사해 사용할 실행 지시문, 검증 규칙, 완료 보고 형식을 제공한다.

## 분석 기준선

| 항목 | 결과 |
| --- | --- |
| Flutter / Dart | Flutter 3.44.2 / Dart 3.12.2 |
| 앱 선언 SDK / 버전 | Dart `^3.8.1`, MoneyFit `1.2.6+17` |
| Dart source | 전체 127개; 생성 l10n·Firebase option 제외 수기 111개 / 13,289 LOC |
| Test | 15개 파일 / 3,409 LOC / 선언된 test case 128개 |
| 정적 분석 | warning 1개: `.env` asset 부재 |
| 테스트 실행 | asset bundle 단계에서 `.env` 부재로 중단; 0개 실행 |
| 직접 import cycle | Notification ↔ UserSettings, AdService ↔ AdBannerWidget |
| 미도달 코드 후보 | 7개 파일 / 1,151 LOC |
| 추적 중인 빌드 산출물 | IPA + dSYM + fastlane report 약 75MB |

테스트가 실행되지 않았으므로 이 문서는 코드 경로를 직접 추적한 정적 분석을 기준으로 한다. 실행 기준선 복구 자체를 마이그레이션 0단계로 포함했다.

## 유지할 기반

전부 다시 만들 필요는 없다. 다음은 목표 구조에서도 유지할 가치가 있다.

- Riverpod과 `AsyncValue`를 도입해 비동기 상태 표현의 기반이 있다.
- SQLite query 대부분이 `whereArgs`를 사용한다.
- UUID 기반 식별자와 DB 최초 생성 Batch가 적용되어 있다.
- Repository 생성자 주입과 provider composition의 흔적이 있다.
- theme/settings 영역에는 SharedPreferences override를 이용한 테스트 사례가 있다.
- l10n, theme extension, 기능별 화면 분할은 재사용할 수 있다.

핵심은 기술을 교체하는 것이 아니라 **상태와 데이터의 단일 소유권, 단방향 의존성, 실패의 명시적 표현**을 회복하는 것이다.
