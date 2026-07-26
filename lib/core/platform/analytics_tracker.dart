import 'package:firebase_analytics/firebase_analytics.dart';

abstract interface class AnalyticsTracker {
  Future<void> track(String name, {Map<String, Object> parameters = const {}});
}

class FirebaseAnalyticsAdapter implements AnalyticsTracker {
  const FirebaseAnalyticsAdapter(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> track(String name, {Map<String, Object> parameters = const {}}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}

class NoopAnalyticsTracker implements AnalyticsTracker {
  const NoopAnalyticsTracker();

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}
}

class ThrowingAnalyticsTracker implements AnalyticsTracker {
  const ThrowingAnalyticsTracker(this.error);

  final Object error;

  @override
  Future<void> track(String name, {Map<String, Object> parameters = const {}}) {
    return Future<void>.error(error);
  }
}
