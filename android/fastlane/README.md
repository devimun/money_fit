fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

pubspec.yaml 버전을 기준으로 내부 테스트 배포

### android update_metadata

```sh
[bundle exec] fastlane android update_metadata
```

앱 빌드 없이 스토어 정보(설명+이미지)만 업데이트

### android release

```sh
[bundle exec] fastlane android release
```

내부 테스트의 최신 빌드를 정식 출시(Production)로 승격 + 스토어 정보 반영

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
