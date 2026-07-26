# 기능 소유권과 공개 경계

이 문서는 PR 7.4 기준으로 다른 기능이 의존할 수 있는 MoneyFit의 공개 경계를
정리한다. 기능 밖에서 내부 `data/`, `domain/`, `presentation/` 구현을 직접 import하지
않고 아래의 provider, application facade, 또는 모델을 사용한다.

| 기능 | 소유 책임 | 공개 진입점 |
| --- | --- | --- |
| session | 로컬 사용자 식별자와 원격 계정 연결 | `features/session/application/session_context.dart`의 `sessionContextProvider`, `currentOwnerIdProvider` |
| preferences | theme, locale, text scale, 사용자 설정 저장 | `core/preferences`의 preferences provider와 settings presentation |
| ledger | 지출·카테고리 CRUD와 월별 조회 | `features/ledger/application/ledger_providers.dart`의 `ledgerRepositoryProvider`, `monthlyLedgerProvider`, `ledgerCategoriesProvider` |
| budget | 예산 설정과 setup flow | `features/budget/presentation/setup` 및 budget provider |
| projections | 홈·캘린더·통계 read model | `features/home`, `features/calendar`, `features/statistics`의 view model/provider |
| notifications | 권한 요청과 알림 예약 | `features/notifications/application/notification_controller.dart`의 `notificationControllerProvider` |
| app update | 강제/선택 업데이트 확인 | `features/app_update/application/update_service.dart`의 `UpdateService` |
| monetization | 광고 초기화와 표시 정책 | `features/monetization/data/google_mobile_ads_gateway.dart`의 `AdService` |
| feedback | 인앱 리뷰 요청 정책 | `features/feedback/application/review_prompt_flow.dart`의 `ReviewPromptFlow` |
| app database | 앱 차원의 DB executor와 reset lifecycle | `app/composition/database_providers.dart`의 `appDatabaseProvider` |

## 의존 규칙

```text
app composition → feature application/presentation → feature data → app database
core foundation  ← feature/application ports             external SDK adapters
```

- `app/`은 조립과 lifecycle만 소유하며 feature 구현 세부사항을 재수출하지 않는다.
- `core/`는 framework-independent foundation과 cross-cutting port만 둔다. `core → feature`
  import는 금지한다.
- 화면은 다른 기능의 view나 view model 대신 해당 기능의 공개 provider/read model을 소비한다.
- 저장 형식 변경은 `app/database/migrations`의 독립 migration과 audit fixture를 함께
  갱신하고, migration rollback/constraint 테스트를 통과해야 한다.

`test/architecture/import_boundaries_test.dart`가 이 규칙의 자동 검사 기준이다.
