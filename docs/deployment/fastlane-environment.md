# Fastlane deployment environment

Deployment credentials and personal account identifiers are supplied only at
execution time. They must not be committed to the repository or placed in a
Flutter runtime asset.

## Android

Set these variables before running a lane from `android/`:

```sh
export GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/secure/path/google-play-service-account.json
export ANDROID_APPLICATION_ID=com.moneyfitapp.app # optional; this is the default
bundle exec fastlane android beta
```

`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` is required. The JSON file remains outside
the repository.

## iOS

Set these variables before running a lane from `ios/`:

```sh
export APPLE_ID=release-account@example.com
export APP_STORE_CONNECT_TEAM_ID=123456789
export APPLE_DEVELOPER_TEAM_ID=ABCDE12345
export IOS_APPLICATION_ID=com.moneyfitapp.app # optional; this is the default
bundle exec fastlane ios beta
```

Use the CI secret store or the release operator's environment for these values.
Never add a `.env`, key, provisioning profile, or Fastlane session to version
control.
