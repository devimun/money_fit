import 'package:money_fit/core/platform/analytics_tracker.dart';

/// Ad event names are intentionally Firebase-safe. An application analytics
/// facade may map them to its cross-vendor canonical display names.
abstract interface class AdTelemetry {
  Future<void> track(String event, Map<String, Object> attributes);
}

class AnalyticsTrackerAdTelemetry implements AdTelemetry {
  const AnalyticsTrackerAdTelemetry(this._tracker);

  final AnalyticsTracker _tracker;

  @override
  Future<void> track(String event, Map<String, Object> attributes) {
    return _tracker.track(event, parameters: attributes);
  }
}

class NoopAdTelemetry implements AdTelemetry {
  const NoopAdTelemetry();

  @override
  Future<void> track(String event, Map<String, Object> attributes) async {}
}

abstract final class AdTelemetryEvent {
  static const actionRecorded = 'ad_action_recorded';
  static const opportunity = 'ad_opportunity';
  static const request = 'ad_request';
  static const loadCompleted = 'ad_load_completed';
  static const displayed = 'ad_displayed';
  static const impression = 'ad_impression';
  static const clicked = 'ad_clicked';
  static const dismissed = 'ad_dismissed';
  static const displayFailed = 'ad_display_failed';
  static const revenueTracked = 'ad_revenue_tracked';
  static const configInvalid = 'ad_config_invalid';
}
