fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

pubspec.yaml 버전을 기준으로 TestFlight 배포

### ios update_metadata

```sh
[bundle exec] fastlane ios update_metadata
```

앱 빌드 없이 스토어 정보(설명+이미지)만 업데이트

### ios release

```sh
[bundle exec] fastlane ios release
```

메타데이터 업로드 + TestFlight 최신 빌드 선택 + 심사 요청

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
