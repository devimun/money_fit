<!-- @format -->

# ProviderContainer 활용 메모

## 배경
- 대부분의 화면은 `ProviderScope` + `ConsumerWidget` 조합만으로 충분했지만, 앱 부팅 전에 Provider 의존 초기화를 수행해야 하는 요구사항이 생겼습니다.
- 알림 서비스, DB, SharedPreferences 등의 비동기 init 로직이 Provider에 묶여 있어 `runApp()` 이전에 접근할 방법을 마련해야 했습니다.

## 개념 요약
| 요소 | 역할 |
| --- | --- |
| `ProviderScope` | 위젯 트리에 `ProviderContainer`를 주입하는 정석적인 위젯입니다. |
| `ProviderContainer` | 모든 Provider 상태를 저장·관리하는 실체입니다. |
| `UncontrolledProviderScope` | 개발자가 생성한 Container를 위젯 트리로 전달할 때 사용하는 위젯입니다. |

## 사용 시나리오
1. **부팅 전 초기화**
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     final container = ProviderContainer();
     await container.read(notificationServiceProvider).init();
     runApp(UncontrolledProviderScope(
       container: container,
       child: const MyApp(),
     ));
   }
   ```
2. **대안: FutureProvider 기반 초기화**
   - 초기화 로직을 `initializationProvider`로 만들고, 루트 위젯에서 `ref.watch(...).when(...)`으로 분기했습니다.
   - 로딩/에러 UI를 자연스럽게 표현할 수 있어 현재 프로젝트에서는 이 접근을 기본값으로 채택했습니다.

## 적용 기준
- `ProviderContainer` 직접 생성은 예외 케이스(테스트, 런타임 이전 로직)에만 사용하고, 나머지는 `ProviderScope`에 위임하도록 규정했습니다.
- 초기화 순서가 중요한 서비스는 `FutureProvider`를 통해 의존성을 명시하고, 순차 실행이 필요하면 `await ref.read(...)` 체이닝으로 관리했습니다.

## 회고
- `ProviderContainer` 구조를 이해하니 Riverpod이 상태를 어떻게 캐싱·폐기하는지 더 명확해졌고, 초기화/테스트 케이스 작성이 수월해졌습니다.
- 최신 버전에서는 `ProviderScope(parent: ...)` 방식이 deprecated 되었으므로, `UncontrolledProviderScope` 사용을 표준으로 문서화했습니다.
