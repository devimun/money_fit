# Flutter에서 Supabase API 키 안전하게 관리하기: .env와 RLS의 모든 것

Flutter 프로젝트에 Supabase나 다른 백엔드 서비스를 연동하다 보면 필연적으로 API 키 같은 민감한 정보를 다루게 됩니다. 이 키를 코드에 그대로 하드코딩하고 GitHub에 올리는 것은 우리 집 열쇠를 인터넷에 공개하는 것과 같습니다. 이 글에서는 `.env` 파일과 Dart의 컴파일 타임 변수를 사용해 키를 안전하게 관리하는 방법부터, "앱 안에 키가 포함되면 결국 안전하지 않은 것 아닌가?"라는 근본적인 질문에 대한 해답까지 모두 다룹니다.

## 1. 문제: 민감한 정보의 유출 위험

Supabase 클라이언트를 초기화하는 코드는 보통 다음과 같습니다.

```dart
// lib/main.dart

await Supabase.initialize(
  url: 'https://your-project-url.supabase.co',
  anonKey: 'your-very-long-and-secret-anon-key',
);
```

이 코드를 그대로 Git에 커밋하면, 프로젝트 저장소에 접근할 수 있는 모든 사람이 우리의 Supabase URL과 `anonKey`를 알게 됩니다. 이는 심각한 보안 문제입니다.

## 2. 해결책: `.env`와 `--dart-define`

이 문제를 해결하는 표준적인 방법은 **환경 변수**를 사용하는 것입니다. 민감한 정보는 코드와 분리하여 별도의 파일에 저장하고, 앱을 빌드(컴파일)하는 시점에만 주입해주는 방식입니다.

### 단계 1: `.env` 파일 생성 및 Git 무시 처리

1.  **`.env` 파일 생성:** 프로젝트 최상위 폴더에 `.env` 파일을 만들고 그 안에 키를 저장합니다.
    ```
    # .env
    SUPABASE_URL=https://your-project-url.supabase.co
    SUPABASE_ANON_KEY=your-very-long-and-secret-anon-key
    ```

2.  **`.gitignore`에 추가:** 이 파일이 절대로 Git에 커밋되지 않도록 `.gitignore` 파일에 다음 한 줄을 추가합니다.
    ```
    # .gitignore

    # Secrets and environment variables
    .env
    ```

### 단계 2: 코드에서 환경 변수 사용하기

이제 `main.dart` 파일에서 `String.fromEnvironment`라는 특별한 상수를 사용해 외부에서 주입될 값의 "빈칸"을 만들어 둡니다.

```dart
// lib/main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // 'SUPABASE_URL'이라는 이름으로 컴파일 시점에 값이 주입될 것임
    url: const String.fromEnvironment('SUPABASE_URL'),
    // 'SUPABASE_ANON_KEY'라는 이름으로 컴파일 시점에 값이 주입될 것임
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // ...
}
```

### 단계 3: 앱 실행 시 값 주입하기

이제 앱을 실행할 때 `--dart-define-from-file` 옵션을 추가하여 `.env` 파일의 내용을 주입해줍니다.

```bash
flutter run --dart-define-from-file=.env
```

Flutter의 빌드 도구는 이 명령어를 보고 `.env` 파일을 읽은 뒤, 그 안의 `KEY=VALUE` 쌍을 `String.fromEnvironment`로 만들어둔 코드의 "빈칸"에 채워 넣어 최종 앱을 만듭니다.

> **팁:** VS Code 사용자는 `.vscode/launch.json` 파일을 설정하면 `F5` 키를 누르는 것만으로 이 옵션을 자동으로 적용할 수 있어 편리합니다.

## 3. "최종 앱에 키가 들어있으면 해킹될 수 있잖아요?"

여기까지 따라오셨다면 이런 의문이 드는 것이 당연합니다. "어차피 최종 결과물인 AAB/IPA 파일 안에 키 값이 들어간다면, 누군가 앱을 디컴파일해서 키를 훔쳐볼 수 있는 것 아닌가?"

**정답: 네, 맞습니다. 하지만 Supabase는 그것을 감안하고 설계되었습니다.**

클라이언트(사용자 기기)에 저장되는 정보는 원칙적으로 100% 안전할 수 없습니다. Supabase는 이 사실을 전제로 보안 모델을 구축했습니다. 핵심은 `anon key`의 역할과 **Row Level Security (RLS)**에 있습니다.

### `anon key`의 진실

*   `anon`은 "anonymous(익명)"의 약자입니다. 이 키는 **로그인하지 않은 익명 사용자에게 부여되는 매우 제한적인 권한**을 가집니다.
*   Supabase는 이 키가 클라이언트에 노출될 것을 가정합니다. 따라서 이 키 자체는 비밀 정보가 아닙니다.

### 진짜 보안: Row Level Security (RLS)

Supabase의 진짜 보안은 키를 숨기는 것이 아니라, **RLS 정책**을 통해 데이터베이스 테이블에 대한 접근을 통제하는 것에서 나옵니다. RLS는 "누가(Who) 무엇을(What) 할 수 있는가"를 정의하는 강력한 규칙입니다.

예를 들어, `posts` 테이블에 다음과 같은 정책을 설정할 수 있습니다.

*   **읽기 정책:** "로그인한 사용자(`authenticated`)만 모든 게시글을 읽을 수 있다."
*   **쓰기 정책:** "로그인한 사용자는 게시글을 작성할 수 있다. 단, `user_id` 칼럼에는 반드시 자기 자신의 ID만 넣을 수 있다."
*   **수정 정책:** "사용자는 자신이 작성한 게시글만 수정할 수 있다."

해커가 우리 앱을 해체해서 `anon key`를 훔치더라도, 이 RLS 정책 때문에 할 수 있는 것이 거의 없습니다. 로그인 없이는 데이터를 보거나 쓸 수 없기 때문입니다.

## 4. 배포는 어떻게?

배포 시에도 원리는 같습니다. GitHub Actions 같은 CI/CD 도구는 `.env` 파일을 사용하지 않는 대신, 자체적으로 제공하는 `Secrets` 저장소에 키 값을 저장합니다.

그리고 빌드 스크립트에서 이 `Secrets` 값을 읽어와 `--dart-define` 옵션으로 주입합니다.

```yaml
# GitHub Actions 워크플로우 예시
- name: Build Flutter App
  run: flutter build appbundle --release \
      --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
      --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## 결론

Flutter 프로젝트에서 API 키를 관리하는 것은 단순히 정보를 숨기는 행위가 아니라, 서비스의 보안 모델을 올바르게 이해하고 사용하는 과정입니다.

1.  민감한 정보는 `.env` 파일에 보관하고 `.gitignore`로 Git 추적을 막습니다.
2.  코드에서는 `String.fromEnvironment`를 사용해 컴파일 시점에 값을 주입받을 준비를 합니다.
3.  `anon key`의 노출 가능성을 인지하고, 진짜 보안은 Supabase의 **Row Level Security (RLS) 정책**을 통해 구축해야 합니다.

이 원칙들을 따르면 안전하고 확장 가능한 Flutter 애플리케이션을 만들 수 있습니다.
