import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_sanitizer.dart';
import 'package:money_fit/core/config/analytics_config.dart';

abstract interface class AnalyticsService {
  Future<void> initialize();
  Future<void> track(
    AnalyticsEvent event, [
    Map<String, Object?> properties = const {},
  ]);
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

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> setUserId({String? id}) => _analytics.setUserId(id: id);

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) => _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView({String? screenName, String? screenClass}) =>
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
}

class DualAnalyticsService implements AnalyticsService {
  DualAnalyticsService(this._config, {FirebaseAnalyticsClient? firebase})
    : _firebase =
          firebase ?? FirebaseAnalyticsSdkClient(FirebaseAnalytics.instance);

  final AnalyticsConfig _config;
  final FirebaseAnalyticsClient _firebase;
  final _sanitizer = AnalyticsSanitizer();
  Amplitude? _amplitude;
  bool _enabled = false;
  bool _amplitudeCollectionEnabled = true;
  String? _userId;

  @override
  Future<void> initialize() async {
    if (_config.enabled) {
      try {
        final amplitude = Amplitude(
          Configuration(
            apiKey: _config.apiKey,
            optOut: !_isAmplitudeEnabled,
            serverZone: _config.serverZone == 'eu'
                ? ServerZone.eu
                : ServerZone.us,
            locationListening: false,
            useAdvertisingIdForDeviceId: false,
            useAppSetIdForDeviceId: false,
            logLevel: LogLevel.warn,
          ),
        );
        if (await amplitude.isBuilt) _amplitude = amplitude;
      } catch (_) {}
    }
    await setCollectionEnabled(_enabled);
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    _enabled = enabled;
    try {
      await _firebase.setAnalyticsCollectionEnabled(enabled);
    } catch (_) {}
    try {
      await _amplitude?.setOptOut(!_isAmplitudeEnabled);
    } catch (_) {}
  }

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {
    _amplitudeCollectionEnabled = enabled;
    try {
      await _amplitude?.setOptOut(!_isAmplitudeEnabled);
      if (_isAmplitudeEnabled && _userId != null) {
        await _amplitude?.setUserId(_userId);
      }
    } catch (_) {}
  }

  bool get _isAmplitudeEnabled => _enabled && _amplitudeCollectionEnabled;

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (!_enabled) return;
    try {
      await _firebase.setUserId(id: userId);
    } catch (_) {}
    try {
      if (_amplitudeCollectionEnabled) {
        await _amplitude?.setUserId(userId);
      }
    } catch (_) {}
  }

  @override
  Future<void> track(
    AnalyticsEvent event, [
    Map<String, Object?> properties = const {},
  ]) async {
    if (!_enabled) return;
    final values = _sanitizer.sanitize(
      event,
      properties,
      analyticsEnvironment: _config.environment,
    );
    // Firebase legacy mappings are preserved for the three pre-1.2.7 events.
    final legacy = switch (event) {
      AnalyticsEvent.transactionCreated => 'create_transaction',
      AnalyticsEvent.budgetSet => 'first_budget_setting',
      AnalyticsEvent.dataReset => 'data_reset',
      _ => event.name.replaceAll(' ', '_').toLowerCase(),
    };
    try {
      await _firebase.logEvent(name: legacy, parameters: values);
    } catch (_) {}
    try {
      if (_amplitudeCollectionEnabled) {
        await _amplitude?.track(BaseEvent(event.name, eventProperties: values));
      }
    } catch (_) {}
  }

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {
    if (!_enabled) return;
    await track(AnalyticsEvent.screenViewed, {
      'screen_name': screenName,
      if (previousScreenName != null)
        'previous_screen_name': previousScreenName,
      'navigation_type': navigationType,
    });
    try {
      await _firebase.logScreenView(
        screenName: screenName,
        screenClass: 'moneyfit_$screenName',
      );
    } catch (_) {}
  }

  @override
  Future<void> reset() async {
    try {
      await _firebase.setUserId();
    } catch (_) {}
    try {
      await _amplitude?.flush();
      await _amplitude?.reset();
    } catch (_) {}
  }
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> reset() async {}
  @override
  Future<void> setCollectionEnabled(bool enabled) async {}
  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}
  @override
  Future<void> track(
    AnalyticsEvent event, [
    Map<String, Object?> properties = const {},
  ]) async {}
}

/// Route tracking must use the same consent-aware facade as all other events.
/// This prevents a Firebase navigator observer from writing screen views while
/// the user has opted out.
class AnalyticsScreenViewTracker {
  AnalyticsScreenViewTracker(this._analytics);

  final AnalyticsService _analytics;
  String? _currentScreenName;

  void trackRoute(Route<dynamic> route, {required String navigationType}) {
    final screenName = AnalyticsNavigatorObserver.canonicalRouteName(
      route.settings.name,
    );
    if (screenName == null || screenName == _currentScreenName) return;
    final previousScreenName = _currentScreenName;
    _currentScreenName = screenName;
    unawaited(
      _analytics.trackScreenView(
        screenName: screenName,
        previousScreenName: previousScreenName,
        navigationType: navigationType,
      ),
    );
  }
}

class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._screenViewTracker);

  final AnalyticsScreenViewTracker _screenViewTracker;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _screenViewTracker.trackRoute(route, navigationType: 'push');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _screenViewTracker.trackRoute(newRoute, navigationType: 'replace');
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _screenViewTracker.trackRoute(previousRoute, navigationType: 'pop');
    }
    super.didPop(route, previousRoute);
  }

  static const _routes = <String, String>{
    '/update-check': 'update_check',
    '/': 'splash',
    '/budget_setup': 'budget_setup',
    '/home': 'home',
    '/calendar': 'calendar',
    '/stats': 'statistics',
    '/expense_list': 'expense_list',
    '/settings': 'settings',
    'UpdateCheckScreen': 'update_check',
    'SplashScreen': 'splash',
    'BudgetSetupScreen': 'budget_setup',
    'HomeScreen': 'home',
    'CalendarScreen': 'calendar',
    'StatisticsScreen': 'statistics',
    'ExpenseListScreen': 'expense_list',
    'SettingsScreen': 'settings',
  };

  static String? canonicalRouteName(String? name) =>
      name == null ? null : _routes[name];
}
