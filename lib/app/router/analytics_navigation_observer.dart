import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

/// Shared state behind root and StatefulShell navigator observers.
///
/// A StatefulShell owns several Navigator instances, so each Navigator needs
/// its own observer. Keeping the current canonical screen here prevents the
/// same transition from being emitted by both the root and a branch observer.
class AnalyticsScreenViewTracker {
  AnalyticsScreenViewTracker(this._analytics);

  final AnalyticsTracker _analytics;
  String? _currentScreenName;

  void trackRoute(Route<dynamic> route, {required String navigationType}) {
    final screenName = AnalyticsNavigatorObserver.canonicalRouteName(
      route.settings.name,
    );
    if (screenName == null) return;
    trackScreen(screenName, navigationType: navigationType);
  }

  /// StatefulShell retains each branch's Navigator stack. Returning to an
  /// already-built branch therefore does not push a route and its navigator
  /// observer has nothing to report. The shell calls this after an actual
  /// branch change so restored destinations remain visible in analytics.
  void trackScreen(String screenName, {required String navigationType}) {
    if (screenName == _currentScreenName) return;
    final previousScreenName = _currentScreenName;
    _currentScreenName = screenName;
    unawaited(
      _ignoreFailure(
        () => _analytics.trackScreenView(
          screenName: screenName,
          previousScreenName: previousScreenName,
          navigationType: navigationType,
        ),
      ),
    );
  }

  Future<void> _ignoreFailure(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Navigation must never depend on observational analytics.
    }
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
