---
title: "Riverpod의 심장, ProviderContainer 파헤치기: 언제, 왜 사용할까?"
date: 2025-07-09
author: "Gemini"
tags: [Flutter, Riverpod, State Management, ProviderContainer]
---

## 들어가며

Flutter에서 Riverpod은 상태 관리를 위한 강력하고 유연한 도구로 많은 사랑을 받고 있습니다. 대부분의 개발자는 `ProviderScope`로 앱의 최상단을 감싸고, `ref.watch`나 `ref.read`를 사용하며 Riverpod의 마법을 경험합니다. 평소에는 `ProviderContainer`라는 존재를 직접 마주할 일이 거의 없죠.

하지만 가끔은 Riverpod의 내부 동작을 좀 더 깊이 이해하고, 특별한 상황에 대처해야 할 필요가 생깁니다. 바로 그럴 때 `ProviderContainer`가 등장합니다.

이 글에서는 Riverpod의 핵심 엔진인 `ProviderContainer`가 무엇인지, 그리고 어떤 특별한 경우에 이를 직접 생성하고 사용해야 하는지 구체적인 코드 예시와 함께 알아보겠습니다.

## ProviderContainer란 무엇인가?

**`ProviderContainer`는 모든 provider들의 상태(state)를 저장하고 관리하는 실체(Entity)입��다.**

비유하자면, `ProviderScope`가 우리 앱 위젯들이 사는 "집"이라면, `ProviderContainer`는 그 집에 전력을 공급하고 모든 시스템을 제어하는 "중앙 관제실" 또는 "엔진 룸"과 같습니다.

우리가 `ProviderScope`를 사용하면, 이 위젯이 내부적으로 `ProviderContainer`의 생성, 관리, 그리고 소멸에 이르는 모든 생명주기를 알아서 처리해 줍니다. 이것이 우리가 평소에 `ProviderContainer`를 직접 다루지 않아도 되는 이유입니다.

```dart
// 가장 일반적인 사용법
void main() {
  runApp(
    // ProviderScope가 내부적으로 ProviderContainer를 생성하고 관리합니다.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

이 코드는 95%의 상황에서 충분하며, 가장 권장되는 방식입니다.

## 그렇다면 언제 ProviderContainer가 필요할까?

결론부터 말하자면, **Flutter 앱의 위젯 트리가 빌드되기 전, 즉 `runApp()`이 호출되기 전에 provider와 상호작용해야 할 때** `ProviderContainer`를 직접 다루어야 합니다.

가장 대표적인 시나리오는 **앱의 비동기 초기화**입니다.

예를 들어, 앱이 시작되기 전에 다음과 같은 작업들이 완료되어야 한다고 상상해 보세요.

-   로컬 데이터베이스(sqflite, Hive 등) 연결
-   알림 서비스(FCM, `flutter_local_notifications`) 초기화
-   `SharedPreferences`에서 사용자 토큰 또는 설정 값 불러오기

만약 이러한 초기화 로직이 Riverpod의 provider에 의존하고 있다면 문제가 발생합니다. `main` 함수에서는 아직 `ProviderScope`가 없으므로 `ref.read`를 호출할 수 없기 때문입니다.

```dart
// 🚨 잘못된 코드 예시
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 이 시점에는 ProviderScope가 없으므로 ref가 존재하지 않습니다.
  // 따라서 이 코드는 동작하지 않습니다.
  await ref.read(notificationServiceProvider).initialize(); 

  runApp(const ProviderScope(child: MyApp()));
}
```

## 해결책: 수동으로 생성하고 주입하기

이 문제를 해결하는 방법은 `ProviderContainer`를 수동으로 생성하여 초기화 작업을 수행하고, 그 결과물을 위젯 트리에 주입하는 것입니다.

**1단계: `ProviderContainer` 수동 생성 및 초기화**

`main` 함수에서 `ProviderContainer`를 직접 생성하고, `.read()` 메서드를 사용해 provider에 접근하여 초기화 메서드를 호출합니다.

**2단계: `UncontrolledProviderScope`로 컨테이너 주입**

초기화가 완료된 컨테이너를 `UncontrolledProviderScope` 위젯의 `container` 속성에 전달하여 `runApp`을 실행합니다. `UncontrolledProviderScope`는 이름 그대로 개발자가 직접 제어하는 컨테이너를 받아 사용하는 특별한 `ProviderScope`입니다.

다음은 전체 코드 예시입니다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 예시: 알림 서비스를 제공하는 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  Future<void> init() async {
    print("알림 서비스 초기화 시작...");
    await Future.delayed(const Duration(seconds: 1)); // 비동기 작업 시뮬레이션
    print("알림 서비스 초기화 완료!");
  }
}

// 앱의 메인 진입점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ProviderContainer를 수동으로 생성합니다.
  final container = ProviderContainer();

  // 2. 생성된 컨테이너를 사용해 provider를 읽고, 비동기 초기화를 수행합니다.
  // 이 작업은 runApp이 호출되기 전에 완료됩니다.
  await container.read(notificationServiceProvider).init();

  // 3. 초기화가 완료된 컨테이너를 UncontrolledProviderScope�� 통해 주입합니다.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('앱 초기화 완료!'),
        ),
      ),
    );
  }
}
```

> **참고:** 과거에는 `ProviderScope`의 `parent` 속성을 사용했지만, 이 속성은 이제 사용되지 않는(deprecated) 방식입니다. 항상 `UncontrolledProviderScope`와 `container` 속성을 사용하는 것이 최신 모범 사례입니다.

## 더 나은 대안: `FutureProvider` 활용하기

사실, 위에서 설명한 비동기 초기화 문제는 `FutureProvider`를 사용하면 훨씬 더 우아하고 "Riverpod스럽게" 해결할 수 있습니다. `main` 함수를 복잡하게 만드는 대신, 초기화 로직 자체를 provider로 만드는 것입니다.

이 방식은 로딩 및 에러 상태를 UI에 명확하게 반영할 수 있다는 큰 장점이 있습니다.

```dart
// 1. 모든 초기화 로직을 담당하는 FutureProvider를 만듭니다.
final initializationProvider = FutureProvider<void>((ref) async {
  // 여기에 모든 비동기 초기화 로직을 넣습니다.
  await ref.read(notificationServiceProvider).init();
  // ... 다른 서비스 초기화 ...
});

// 2. main 함수는 다시 매우 단순해집니다.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 3. 앱의 루트 위젯에서 초기화 상태를 감시합니다.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInit = ref.watch(initializationProvider);

    // .when을 사용하여 로딩, 에러, 완료 상태에 따라 다른 UI를 보여줍니다.
    return asyncInit.when(
      loading: () => const SplashScreen(), // 로딩 중일 때
      error: (err, stack) => ErrorScreen(error: err), // 에러 발생 시
      data: (_) => const MainApplication(), // 초기화 완료 시
    );
  }
}
```

## 결론

-   **`ProviderContainer`**는 Riverpod의 모든 상태를 저장하는 핵심 엔진입니다.
-   일반적으로 **`ProviderScope`**가 `ProviderContainer`의 생명주기를 자동으로 관리해 줍니다.
-   `runApp`이 호출되기 전에 provider를 사용한 **비동기 초기화**가 필요할 때, `ProviderContainer`를 수동으로 생성하고 **`UncontrolledProviderScope`**로 주입하는 패턴을 사용할 수 있습니다.
-   하지만 많은 경우, **`FutureProvider`**를 사용하여 초기화 로직을 처리하는 것이 더 깔끔하고 권장되는 방법입니다.

`ProviderContainer`의 역할을 이해하면 Riverpod의 동작 방식을 더 깊이 파악하고, 복잡한 시나리오에 자신 있게 대처할 수 있게 될 것입니다.

---
