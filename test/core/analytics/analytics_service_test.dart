import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/config/analytics_config.dart';

void main() {
  test('screen views dual-write Firebase standard and custom events', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final analytics = DualAnalyticsService(
      const AnalyticsConfig(
        apiKey: '',
        enabled: false,
        environment: 'prod',
        serverZone: 'us',
      ),
      firebase: firebase,
    );

    await analytics.setCollectionEnabled(true);
    await analytics.trackScreenView(screenName: 'home', navigationType: 'push');

    expect(firebase.screenViews, [
      (screenName: 'home', screenClass: 'moneyfit_home'),
    ]);
    expect(firebase.events, hasLength(1));
    expect(firebase.events.single.name, 'screen_viewed');
    expect(
      firebase.events.single.parameters,
      containsPair('screen_name', 'home'),
    );
  });

  test('opt-out prevents Firebase events and standard screen views', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final analytics = DualAnalyticsService(
      const AnalyticsConfig(
        apiKey: '',
        enabled: false,
        environment: 'prod',
        serverZone: 'us',
      ),
      firebase: firebase,
    );

    await analytics.setCollectionEnabled(false);
    await analytics.trackScreenView(
      screenName: 'settings',
      navigationType: 'push',
    );

    expect(firebase.screenViews, isEmpty);
    expect(firebase.events, isEmpty);
  });

  test('Amplitude kill switch does not disable Firebase collection', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final analytics = DualAnalyticsService(
      const AnalyticsConfig(
        apiKey: '',
        enabled: false,
        environment: 'prod',
        serverZone: 'us',
      ),
      firebase: firebase,
    );

    await analytics.setCollectionEnabled(true);
    await analytics.setAmplitudeCollectionEnabled(false);
    await analytics.track(AnalyticsEvent.transactionCreated);

    expect(firebase.events.single.name, 'create_transaction');
  });

  test(
    'shared route tracker records shell routes once and tracks pops',
    () async {
      final analytics = _RecordingAnalyticsService();
      final tracker = AnalyticsScreenViewTracker(analytics);
      final rootObserver = AnalyticsNavigatorObserver(tracker);
      final shellObserver = AnalyticsNavigatorObserver(tracker);
      final home = _route('/home');
      final calendar = _route('/calendar');

      rootObserver.didPush(home, null);
      shellObserver.didPush(home, null);
      shellObserver.didPush(calendar, home);
      shellObserver.didPop(calendar, home);

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
}

MaterialPageRoute<void> _route(String name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

class _FakeFirebaseAnalyticsClient implements FirebaseAnalyticsClient {
  final events = <({String name, Map<String, Object>? parameters})>[];
  final screenViews = <({String? screenName, String? screenClass})>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> logScreenView({String? screenName, String? screenClass}) async {
    screenViews.add((screenName: screenName, screenClass: screenClass));
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId({String? id}) async {}
}

class _RecordingAnalyticsService implements AnalyticsService {
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
    AnalyticsEvent event, [
    Map<String, Object?> properties = const {},
  ]) async {}

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
