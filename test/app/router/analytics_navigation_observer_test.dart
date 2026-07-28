import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/router/analytics_navigation_observer.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

void main() {
  test(
    'root and StatefulShell observers de-duplicate routes and track pops',
    () async {
      final analytics = _RecordingAnalyticsTracker();
      final tracker = AnalyticsScreenViewTracker(analytics);
      final rootObserver = AnalyticsNavigatorObserver(tracker);
      final branchObserver = AnalyticsNavigatorObserver(tracker);
      final home = _route('HomeScreen');
      final calendar = _route('CalendarScreen');

      rootObserver.didPush(home, null);
      branchObserver.didPush(home, null);
      branchObserver.didPush(calendar, home);
      branchObserver.didPop(calendar, home);
      await Future<void>.delayed(Duration.zero);

      expect(analytics.screenViews, [
        (screenName: 'home', previousScreenName: null, navigationType: 'push'),
        (
          screenName: 'calendar',
          previousScreenName: 'home',
          navigationType: 'push',
        ),
        (
          screenName: 'home',
          previousScreenName: 'calendar',
          navigationType: 'pop',
        ),
      ]);
    },
  );

  test(
    'tracks restored StatefulShell branches while preserving push and pop',
    () async {
      final analytics = _RecordingAnalyticsTracker();
      final tracker = AnalyticsScreenViewTracker(analytics);
      final branchObserver = AnalyticsNavigatorObserver(tracker);
      final home = _route('HomeScreen');
      final calendar = _route('CalendarScreen');

      // First visits are still reported by their respective branch Navigator.
      branchObserver.didPush(home, null);
      branchObserver.didPush(calendar, home);

      // goBranch restores the retained Navigator stack without a didPush.
      tracker.trackScreen('home', navigationType: 'branch_switch');
      tracker.trackScreen('calendar', navigationType: 'branch_switch');
      branchObserver.didPop(calendar, home);
      await Future<void>.delayed(Duration.zero);

      expect(analytics.screenViews, [
        (screenName: 'home', previousScreenName: null, navigationType: 'push'),
        (
          screenName: 'calendar',
          previousScreenName: 'home',
          navigationType: 'push',
        ),
        (
          screenName: 'home',
          previousScreenName: 'calendar',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'calendar',
          previousScreenName: 'home',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'home',
          previousScreenName: 'calendar',
          navigationType: 'pop',
        ),
      ]);
    },
  );

  test(
    'StatefulShell restored tabs each emit one canonical screen view',
    () async {
      final analytics = _RecordingAnalyticsTracker();
      final tracker = AnalyticsScreenViewTracker(analytics);
      final branchObserver = AnalyticsNavigatorObserver(tracker);

      branchObserver.didPush(_route('HomeScreen'), null);
      tracker.trackScreen('calendar', navigationType: 'branch_switch');
      branchObserver.didPush(_route('CalendarScreen'), null);
      tracker.trackScreen('statistics', navigationType: 'branch_switch');
      branchObserver.didPush(_route('StatisticsScreen'), null);
      tracker.trackScreen('expense_list', navigationType: 'branch_switch');
      branchObserver.didPush(_route('ExpenseListScreen'), null);
      tracker.trackScreen('settings', navigationType: 'branch_switch');
      branchObserver.didPush(_route('SettingsScreen'), null);
      tracker.trackScreen('home', navigationType: 'branch_switch');
      branchObserver.didPush(_route('HomeScreen'), null);
      await Future<void>.delayed(Duration.zero);

      expect(analytics.screenViews, [
        (screenName: 'home', previousScreenName: null, navigationType: 'push'),
        (
          screenName: 'calendar',
          previousScreenName: 'home',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'statistics',
          previousScreenName: 'calendar',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'expense_list',
          previousScreenName: 'statistics',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'settings',
          previousScreenName: 'expense_list',
          navigationType: 'branch_switch',
        ),
        (
          screenName: 'home',
          previousScreenName: 'settings',
          navigationType: 'branch_switch',
        ),
      ]);
    },
  );
}

MaterialPageRoute<void> _route(String name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

class _RecordingAnalyticsTracker implements AnalyticsTracker {
  final screenViews =
      <
        ({String screenName, String? previousScreenName, String navigationType})
      >[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {
    screenViews.add((
      screenName: screenName,
      previousScreenName: previousScreenName,
      navigationType: navigationType,
    ));
  }
}
