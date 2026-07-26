import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_sanitizer.dart';

void main() {
  final sanitizer = AnalyticsSanitizer();

  test('uses an event-specific allowlist and strips identifiers and PII', () {
    final result = sanitizer.sanitize(AnalyticsEvent.transactionCreated, {
      'transaction_type': 'essential',
      'category_key': 'b5f9e6c8-90ee-4d53-89f1-cfe9934c78a2',
      'amount': 42.50,
      'name': 'coffee with alice@example.com',
      'uid': '123e4567-e89b-12d3-a456-426614174000',
      'entry_point': 'home',
      'unknown': 'high-cardinality-value',
    }, analyticsEnvironment: 'prod');

    expect(result, {
      'schema_version': analyticsSchemaVersion,
      'analytics_env': 'prod',
      'transaction_type': 'essential',
      'category_key': 'custom',
      'entry_point': 'home',
    });
  });

  test('keeps only safe properties for the requested event', () {
    final result = sanitizer.sanitize(AnalyticsEvent.adLoadCompleted, {
      'ad_format': 'interstitial',
      'placement': 'natural_break',
      'result': 'success',
      'latency_ms': 123,
      'details': 'raw provider response',
      'screen_name': 'settings',
      'error_domain': 'google_mobile_ads',
    });

    expect(result['ad_format'], 'interstitial');
    expect(result['latency_ms'], 123);
    expect(result.containsKey('details'), isFalse);
    expect(result.containsKey('screen_name'), isFalse);
  });

  test(
    'canonicalizes route and category values while rejecting raw routes',
    () {
      final screen = sanitizer.sanitize(AnalyticsEvent.screenViewed, {
        'screen_name': '/settings?user=123e4567-e89b-12d3-a456-426614174000',
        'previous_screen_name': 'home',
        'navigation_type': 'push',
      });
      expect(screen.containsKey('screen_name'), isFalse);
      expect(screen['previous_screen_name'], 'home');

      final category = sanitizer.sanitize(AnalyticsEvent.transactionDeleted, {
        'transaction_type': 'discretionary',
        'category_key': 'food',
        'source_screen': 'settings',
      });
      expect(category['category_key'], 'food');
      expect(category['source_screen'], 'settings');
    },
  );
}
