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
  Future<void> reset();
}

class DualAnalyticsService implements AnalyticsService {
  DualAnalyticsService(this._config, {FirebaseAnalytics? firebase})
    : _firebase = firebase ?? FirebaseAnalytics.instance;

  final AnalyticsConfig _config;
  final FirebaseAnalytics _firebase;
  final _sanitizer = AnalyticsSanitizer();
  Amplitude? _amplitude;
  bool _enabled = false;

  @override
  Future<void> initialize() async {
    if (_config.enabled) {
      try {
        final amplitude = Amplitude(
          Configuration(
            apiKey: _config.apiKey,
            optOut: !_enabled,
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
      await _amplitude?.setOptOut(!enabled);
    } catch (_) {}
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;
    try {
      await _firebase.setUserId(id: userId);
    } catch (_) {}
    try {
      await _amplitude?.setUserId(userId);
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
      await _amplitude?.track(BaseEvent(event.name, eventProperties: values));
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
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> track(
    AnalyticsEvent event, [
    Map<String, Object?> properties = const {},
  ]) async {}
}

/// Route tracking must use the same consent-aware facade as all other events.
/// This prevents a Firebase navigator observer from writing screen views while
/// the user has opted out.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route, navigationType: 'push');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _trackRoute(newRoute, navigationType: 'replace');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _trackRoute(Route<dynamic> route, {required String navigationType}) {
    final name = _canonicalRouteName(route.settings.name);
    if (name == null) return;
    _analytics.track(AnalyticsEvent.screenViewed, {
      'screen_name': name,
      'navigation_type': navigationType,
    });
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

  String? _canonicalRouteName(String? name) =>
      name == null ? null : _routes[name];
}
