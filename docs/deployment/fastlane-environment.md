# Fastlane deployment environment

Deployment credentials and build configuration are supplied only at execution
time. They must not be committed to the repository or placed in a Flutter
runtime asset.

Fastlane optionally reads a repository-root `.fastlane.env.local` for a local
release operator. CI environment variables take precedence over that file.
The file is ignored by Git; use the CI secret store for production values.

## Android

Set these credentials before running a lane from `android/`:

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

## Flutter build defines

Both release lanes derive the following build-time values from CI or
`.fastlane.env.local` and pass them through the refactor's `AppEnvironment`:

- `AMPLITUDE_PROD_API_KEY`, `AMPLITUDE_ENABLED`, `AMPLITUDE_SERVER_ZONE`, and
  `ANALYTICS_ENV`. The Amplitude key is never stored in source or printed in an
  Android Fastlane command.
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` for the optional remote feedback and
  contact capability. The anon key is public client configuration, but it is
  still supplied at build time so environments do not leak into source.
- `FIREBASE_ENABLED`, `MONEY_FIT_APP_FLAVOR`, and `IOS_APP_ID` when an
  environment needs to override their safe production defaults.

Do not add `flutter_dotenv`, a Flutter `.env` asset, a service-role key, a
Slack webhook, or a database password. Missing/invalid optional remote
configuration must leave the local app usable.

## Metadata lanes

Run the local validator from the repository root before any store operation:

```sh
dart run tool/validate_store_metadata.dart
```

The Fastlane `preview_metadata` (iOS) and `validate_metadata` (Android) lanes
run the same validator. They authenticate with the store consoles and must be
used only against an approved draft; neither lane is part of normal CI.

```sh
(cd ios && bundle exec fastlane ios preview_metadata)
(cd android && bundle exec fastlane android validate_metadata)
```

`update_images` and `release` can synchronize or overwrite remote assets.
Review the console diff, managed-publishing status, and rollback snapshot
before running either.
