import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time settings that are needed before the application composition is
/// available.
///
/// The app currently has no externally supplied local setting: SQLite and
/// preferences use their existing platform defaults.  [flavor] is still
/// validated here so a future local-required setting has one explicit failure
/// boundary instead of being force-unwrapped during startup.
class AppEnvironment {
  const AppEnvironment({
    required this.local,
    required this.supabase,
    required this.firebase,
    required this.analytics,
    this.iosAppId,
  });

  factory AppEnvironment.fromDartDefines() {
    return AppEnvironment.fromValues(
      flavor: const String.fromEnvironment(
        'MONEY_FIT_APP_FLAVOR',
        defaultValue: 'production',
      ),
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      firebaseEnabled: const String.fromEnvironment(
        'FIREBASE_ENABLED',
        defaultValue: 'true',
      ),
      amplitudeApiKey: const String.fromEnvironment('AMPLITUDE_API_KEY'),
      amplitudeEnabled: const String.fromEnvironment(
        'AMPLITUDE_ENABLED',
        defaultValue: 'false',
      ),
      analyticsEnvironment: const String.fromEnvironment(
        'ANALYTICS_ENV',
        defaultValue: 'dev',
      ),
      amplitudeServerZone: const String.fromEnvironment(
        'AMPLITUDE_SERVER_ZONE',
        defaultValue: 'us',
      ),
      iosAppId: const String.fromEnvironment('IOS_APP_ID'),
    );
  }

  factory AppEnvironment.fromValues({
    String flavor = 'production',
    String supabaseUrl = '',
    String supabaseAnonKey = '',
    String firebaseEnabled = 'true',
    String amplitudeApiKey = '',
    String amplitudeEnabled = 'false',
    String analyticsEnvironment = 'dev',
    String amplitudeServerZone = 'us',
    String iosAppId = '',
  }) {
    return AppEnvironment(
      local: LocalEnvironment.parse(flavor),
      supabase: _parseSupabase(supabaseUrl, supabaseAnonKey),
      firebase: _parseFirebase(firebaseEnabled),
      analytics: AnalyticsConfiguration.fromValues(
        amplitudeApiKey: amplitudeApiKey,
        amplitudeEnabled: amplitudeEnabled,
        analyticsEnvironment: analyticsEnvironment,
        amplitudeServerZone: amplitudeServerZone,
      ),
      iosAppId: iosAppId.trim().isEmpty ? null : iosAppId.trim(),
    );
  }

  /// Settings needed by local application functions.
  final LocalEnvironment local;

  /// The optional Supabase session and feedback capability.
  final CapabilityState<SupabaseConfiguration> supabase;

  /// The optional Firebase analytics and remote-config capability.
  final CapabilityState<FirebaseConfiguration> firebase;

  /// Build-time analytics configuration. The key is supplied only by a Dart
  /// define and never makes local bootstrap unavailable.
  final AnalyticsConfiguration analytics;

  /// Optional App Store identifier used only when opening the iOS store page.
  final String? iosAppId;

  /// A local configuration error prevents local application bootstrap.
  ConfigurationFailure? get localConfigurationFailure => local.failure;

  bool get hasValidLocalConfiguration => localConfigurationFailure == null;

  static CapabilityState<SupabaseConfiguration> _parseSupabase(
    String urlValue,
    String anonKeyValue,
  ) {
    final url = urlValue.trim();
    final anonKey = anonKeyValue.trim();
    if (url.isEmpty || anonKey.isEmpty) {
      return CapabilityUnavailable(
        RemoteCapability.supabase,
        reason: RemoteCapabilityUnavailableReason.missingConfiguration,
        message: 'SUPABASE_URL and SUPABASE_ANON_KEY must both be provided.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return CapabilityUnavailable(
        RemoteCapability.supabase,
        reason: RemoteCapabilityUnavailableReason.invalidConfiguration,
        message: 'SUPABASE_URL must be an absolute HTTP(S) URL.',
      );
    }

    return CapabilityAvailable(
      SupabaseConfiguration(url: uri, anonKey: anonKey),
    );
  }

  static CapabilityState<FirebaseConfiguration> _parseFirebase(
    String enabledValue,
  ) {
    switch (enabledValue.trim().toLowerCase()) {
      case 'true':
        return const CapabilityAvailable(FirebaseConfiguration());
      case 'false':
        return CapabilityUnavailable(
          RemoteCapability.firebase,
          reason: RemoteCapabilityUnavailableReason.disabled,
          message: 'Firebase is disabled by FIREBASE_ENABLED.',
        );
      default:
        return CapabilityUnavailable(
          RemoteCapability.firebase,
          reason: RemoteCapabilityUnavailableReason.invalidConfiguration,
          message: 'FIREBASE_ENABLED must be either true or false.',
        );
    }
  }

  /// A deterministic environment for tests that must not contact remote SDKs.
  factory AppEnvironment.test({
    String flavor = 'test',
    CapabilityState<SupabaseConfiguration>? supabase,
    CapabilityState<FirebaseConfiguration>? firebase,
    String? iosAppId,
  }) {
    return AppEnvironment(
      local: LocalEnvironment.parse(flavor),
      supabase:
          supabase ??
          CapabilityUnavailable(
            RemoteCapability.supabase,
            reason: RemoteCapabilityUnavailableReason.disabled,
            message: 'Supabase is disabled for this test.',
          ),
      firebase:
          firebase ??
          CapabilityUnavailable(
            RemoteCapability.firebase,
            reason: RemoteCapabilityUnavailableReason.disabled,
            message: 'Firebase is disabled for this test.',
          ),
      analytics: const AnalyticsConfiguration(),
      iosAppId: iosAppId,
    );
  }
}

/// The only local build setting currently understood by the app.
enum AppFlavor { development, staging, production, test }

class LocalEnvironment {
  const LocalEnvironment._({required this.flavor, this.failure});

  factory LocalEnvironment.parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final flavor in AppFlavor.values) {
      if (flavor.name == normalized) {
        return LocalEnvironment._(flavor: flavor);
      }
    }
    return LocalEnvironment._(
      flavor: AppFlavor.production,
      failure: ConfigurationFailure(
        key: 'MONEY_FIT_APP_FLAVOR',
        message:
            'Expected development, staging, production, or test; received "$value".',
      ),
    );
  }

  final AppFlavor flavor;
  final ConfigurationFailure? failure;
}

class ConfigurationFailure implements Exception {
  const ConfigurationFailure({required this.key, required this.message});

  final String key;
  final String message;

  @override
  String toString() => 'ConfigurationFailure($key): $message';
}

enum RemoteCapability { supabase, firebase }

enum RemoteCapabilityUnavailableReason {
  missingConfiguration,
  invalidConfiguration,
  disabled,
  notInitialized,
  initializationFailed,
}

class RemoteCapabilityUnavailable {
  const RemoteCapabilityUnavailable({
    required this.capability,
    required this.reason,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final RemoteCapability capability;
  final RemoteCapabilityUnavailableReason reason;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

sealed class CapabilityState<T> {
  const CapabilityState();

  bool get isAvailable => this is CapabilityAvailable<T>;

  T? get value => switch (this) {
    CapabilityAvailable<T>(:final value) => value,
    CapabilityUnavailable<T>() => null,
  };

  RemoteCapabilityUnavailable? get unavailable => switch (this) {
    CapabilityAvailable<T>() => null,
    CapabilityUnavailable<T>(:final unavailable) => unavailable,
  };
}

class CapabilityAvailable<T> extends CapabilityState<T> {
  const CapabilityAvailable(this.value);

  @override
  final T value;
}

class CapabilityUnavailable<T> extends CapabilityState<T> {
  CapabilityUnavailable(
    RemoteCapability capability, {
    required RemoteCapabilityUnavailableReason reason,
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) : unavailable = RemoteCapabilityUnavailable(
         capability: capability,
         reason: reason,
         message: message,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  final RemoteCapabilityUnavailable unavailable;
}

class SupabaseConfiguration {
  const SupabaseConfiguration({required this.url, required this.anonKey});

  final Uri url;
  final String anonKey;
}

/// FirebaseOptions remain in the FlutterFire-generated platform file.
///
/// This marker controls whether that generated client configuration should be
/// initialized for the current build; it deliberately contains no credentials.
class FirebaseConfiguration {
  const FirebaseConfiguration();
}

/// Analytics build settings. Supplying an API key alone never starts Amplitude:
/// production builds must explicitly set `AMPLITUDE_ENABLED=true`.
class AnalyticsConfiguration {
  const AnalyticsConfiguration({
    this.amplitudeApiKey = '',
    this.amplitudeEnabled = false,
    this.analyticsEnvironment = 'dev',
    this.amplitudeServerZone = 'us',
  });

  factory AnalyticsConfiguration.fromValues({
    required String amplitudeApiKey,
    required String amplitudeEnabled,
    required String analyticsEnvironment,
    required String amplitudeServerZone,
  }) {
    final key = amplitudeApiKey.trim();
    final enabled = amplitudeEnabled.trim().toLowerCase() == 'true';
    return AnalyticsConfiguration(
      amplitudeApiKey: key,
      amplitudeEnabled: enabled,
      analyticsEnvironment: analyticsEnvironment.trim().toLowerCase() == 'prod'
          ? 'prod'
          : 'dev',
      amplitudeServerZone: amplitudeServerZone.trim().toLowerCase() == 'eu'
          ? 'eu'
          : 'us',
    );
  }

  final String amplitudeApiKey;
  final bool amplitudeEnabled;
  final String analyticsEnvironment;
  final String amplitudeServerZone;

  bool get isAmplitudeEnabled => amplitudeEnabled && amplitudeApiKey.isNotEmpty;

  @override
  String toString() =>
      'AnalyticsConfiguration(amplitudeEnabled: $isAmplitudeEnabled, '
      'analyticsEnvironment: $analyticsEnvironment, '
      'amplitudeServerZone: $amplitudeServerZone)';
}

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromDartDefines(),
);
