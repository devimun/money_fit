import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('new installations collect analytics by default', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    expect(AnalyticsConsentRepository(preferences).isEnabled, isTrue);
  });

  test('a stored opt-out remains an opt-out', () async {
    SharedPreferences.setMockInitialValues({
      AnalyticsConsentRepository.collectionKey: false,
    });
    final preferences = await SharedPreferences.getInstance();

    expect(AnalyticsConsentRepository(preferences).isEnabled, isFalse);
  });
}
