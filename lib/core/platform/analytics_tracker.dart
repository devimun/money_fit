import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_sanitizer.dart';

/// Consent-aware analytics facade used outside the SDK boundary.
///
/// Callers can only submit a named event and a reviewed property map. SDK
/// failures remain observational and must not reverse a completed command.
abstract interface class AnalyticsTracker {
  Future<void> initialize();

  Future<void> track(String name, {Map<String, Object> parameters = const {}});

  Future<void> setUserId(String? userId);
  Future<void> setCollectionEnabled(bool enabled);
  Future<void> setAmplitudeCollectionEnabled(bool enabled);

  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  });

  Future<void> reset();
}

abstract interface class FirebaseAnalyticsClient {
  Future<void> setAnalyticsCollectionEnabled(bool enabled);
  Future<void> setUserId({String? id});
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });
  Future<void> logScreenView({String? screenName, String? screenClass});
}

class FirebaseAnalyticsSdkClient implements FirebaseAnalyticsClient {
  FirebaseAnalyticsSdkClient(this._analytics);

  final FirebaseAnalytics Function() _analytics;

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) =>
      _analytics().setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> setUserId({String? id}) => _analytics().setUserId(id: id);

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) => _analytics().logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView({String? screenName, String? screenClass}) =>
      _analytics().logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
}

/// Dual Firebase/Amplitude implementation. Firebase collection follows the
/// user's privacy choice; the Remote Config Amplitude switch affects only
/// Amplitude and never disables Firebase Analytics.
class DualAnalyticsTracker implements AnalyticsTracker {
  DualAnalyticsTracker(
    this._configuration, {
    FirebaseAnalyticsClient? firebase,
    bool collectionEnabled = false,
  }) : _firebase = firebase ?? const NoopFirebaseAnalyticsClient(),
       _collectionEnabled = collectionEnabled;

  final AnalyticsConfiguration _configuration;
  final FirebaseAnalyticsClient _firebase;
  final AnalyticsSanitizer _sanitizer = AnalyticsSanitizer();
  Amplitude? _amplitude;
  bool _collectionEnabled;
  bool _amplitudeCollectionEnabled = true;
  String? _userId;
  Future<void>? _initializeFuture;
  bool _isReady = false;
  final _pendingCalls = <_PendingAnalyticsCall>[];

  // Optional Firebase startup must not let an indefinitely unavailable SDK
  // retain an unbounded in-memory history. The first root and shell views fit
  // comfortably within this small, FIFO buffer.
  static const _maxPendingCalls = 50;

  bool get _isAmplitudeEnabled =>
      _collectionEnabled && _amplitudeCollectionEnabled;

  @override
  Future<void> initialize() => _initializeFuture ??= _initialize();

  Future<void> _initialize() async {
    if (_configuration.isAmplitudeEnabled) {
      try {
        final amplitude = Amplitude(
          Configuration(
            apiKey: _configuration.amplitudeApiKey,
            optOut: !_isAmplitudeEnabled,
            serverZone: _configuration.amplitudeServerZone == 'eu'
                ? ServerZone.eu
                : ServerZone.us,
            locationListening: false,
            useAdvertisingIdForDeviceId: false,
            useAppSetIdForDeviceId: false,
            logLevel: LogLevel.warn,
          ),
        );
        if (await amplitude.isBuilt) _amplitude = amplitude;
      } catch (_) {
        // Amplitude is an optional enhancement.
      }
    }

    // Firebase is intentionally untouched until the optional runtime reports
    // readiness. Route observers can run before then, so their events are
    // flushed only after the persisted consent has reached both SDKs.
    final initialCollectionEnabled = _collectionEnabled;
    final initialAmplitudeCollectionEnabled = _amplitudeCollectionEnabled;
    final initialUserId = _userId;
    await _applyCollectionEnabled();
    await _applyAmplitudeCollectionEnabled();
    await _applyUserId();
    await _flushPendingCalls();
    _isReady = true;

    // Consent or Remote Config can change while an optional SDK is starting.
    // Reapply only when needed before allowing direct sends.
    if (initialCollectionEnabled != _collectionEnabled ||
        initialAmplitudeCollectionEnabled != _amplitudeCollectionEnabled ||
        initialUserId != _userId) {
      await _applyCollectionEnabled();
      await _applyAmplitudeCollectionEnabled();
      await _applyUserId();
    }
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    _collectionEnabled = enabled;
    if (!enabled) _pendingCalls.clear();
    if (!_isReady) return;
    await _applyCollectionEnabled();
  }

  Future<void> _applyCollectionEnabled() async {
    try {
      await _firebase.setAnalyticsCollectionEnabled(_collectionEnabled);
    } catch (_) {
      // Firebase can initialize after local bootstrap.
    }
    try {
      await _amplitude?.setOptOut(!_isAmplitudeEnabled);
    } catch (_) {}
  }

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {
    _amplitudeCollectionEnabled = enabled;
    if (!_isReady) return;
    await _applyAmplitudeCollectionEnabled();
  }

  Future<void> _applyAmplitudeCollectionEnabled() async {
    try {
      await _amplitude?.setOptOut(!_isAmplitudeEnabled);
      if (_isAmplitudeEnabled && _userId != null) {
        await _amplitude?.setUserId(_userId);
      }
    } catch (_) {}
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (!_isReady) return;
    await _applyUserId();
  }

  Future<void> _applyUserId() async {
    if (!_collectionEnabled) return;
    try {
      await _firebase.setUserId(id: _userId);
    } catch (_) {}
    try {
      if (_amplitudeCollectionEnabled) {
        await _amplitude?.setUserId(_userId);
      }
    } catch (_) {}
  }

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    if (!_collectionEnabled) return;
    final event = AnalyticsEvent.fromTrackingName(name);
    if (event == null) return;
    final values = _sanitizer.sanitize(
      event,
      parameters,
      analyticsEnvironment: _configuration.analyticsEnvironment,
    );
    if (!_isReady) {
      _enqueue(_PendingEvent(event, values));
      return;
    }
    await _sendEvent(event, values);
  }

  Future<void> _sendEvent(
    AnalyticsEvent event,
    Map<String, Object> values,
  ) async {
    if (!_collectionEnabled) return;
    try {
      await _firebase.logEvent(name: event.firebaseName, parameters: values);
    } catch (_) {}
    try {
      if (_amplitudeCollectionEnabled) {
        await _amplitude?.track(
          BaseEvent(event.canonicalName, eventProperties: values),
        );
      }
    } catch (_) {}
  }

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {
    if (!_collectionEnabled) return;
    final values = _sanitizer.sanitize(
      AnalyticsEvent.screenViewed,
      {
        'screen_name': screenName,
        if (previousScreenName != null)
          'previous_screen_name': previousScreenName,
        'navigation_type': navigationType,
      },
      analyticsEnvironment: _configuration.analyticsEnvironment,
    );
    if (!_isReady) {
      _enqueue(_PendingScreenView(values));
      return;
    }
    await _sendScreenView(values);
  }

  Future<void> _sendScreenView(Map<String, Object> values) async {
    await _sendEvent(AnalyticsEvent.screenViewed, values);
    if (!_collectionEnabled) return;
    final screenName = values['screen_name'];
    if (screenName is! String) return;
    try {
      await _firebase.logScreenView(
        screenName: screenName,
        screenClass: 'moneyfit_$screenName',
      );
    } catch (_) {}
  }

  void _enqueue(_PendingAnalyticsCall call) {
    if (_pendingCalls.length == _maxPendingCalls) {
      _pendingCalls.removeAt(0);
    }
    _pendingCalls.add(call);
  }

  Future<void> _flushPendingCalls() async {
    while (_collectionEnabled && _pendingCalls.isNotEmpty) {
      final call = _pendingCalls.removeAt(0);
      await call.send(this);
    }
    if (!_collectionEnabled) _pendingCalls.clear();
  }

  @override
  Future<void> reset() async {
    _userId = null;
    _pendingCalls.clear();
    if (!_isReady) return;
    try {
      await _firebase.setUserId();
    } catch (_) {}
    try {
      await _amplitude?.flush();
      await _amplitude?.reset();
    } catch (_) {}
  }
}

abstract interface class _PendingAnalyticsCall {
  Future<void> send(DualAnalyticsTracker tracker);
}

class _PendingEvent implements _PendingAnalyticsCall {
  const _PendingEvent(this.event, this.values);

  final AnalyticsEvent event;
  final Map<String, Object> values;

  @override
  Future<void> send(DualAnalyticsTracker tracker) =>
      tracker._sendEvent(event, values);
}

class _PendingScreenView implements _PendingAnalyticsCall {
  const _PendingScreenView(this.values);

  final Map<String, Object> values;

  @override
  Future<void> send(DualAnalyticsTracker tracker) =>
      tracker._sendScreenView(values);
}

class NoopAnalyticsTracker implements AnalyticsTracker {
  const NoopAnalyticsTracker();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}

  @override
  Future<void> reset() async {}
}

/// Safe default for tests and local-only composition. Production wiring
/// supplies [FirebaseAnalyticsSdkClient] from the app composition root.
class NoopFirebaseAnalyticsClient implements FirebaseAnalyticsClient {
  const NoopFirebaseAnalyticsClient();

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {}

  @override
  Future<void> logScreenView({String? screenName, String? screenClass}) async {}

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId({String? id}) async {}
}

class ThrowingAnalyticsTracker implements AnalyticsTracker {
  const ThrowingAnalyticsTracker(this.error);

  final Object error;

  @override
  Future<void> initialize() => Future<void>.error(error);

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) => Future<void>.error(error);

  @override
  Future<void> setUserId(String? userId) => Future<void>.error(error);

  @override
  Future<void> setCollectionEnabled(bool enabled) => Future<void>.error(error);

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) =>
      Future<void>.error(error);

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) => Future<void>.error(error);

  @override
  Future<void> reset() => Future<void>.error(error);
}
