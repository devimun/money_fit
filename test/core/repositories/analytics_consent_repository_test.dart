import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/repositories/analytics_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'analytics collection defaults to enabled and persists opt-out',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = AnalyticsConsentRepository(prefs);
      expect(repository.isEnabled, isTrue);

      await repository.setEnabled(true, version: '1.2.7');
      expect(repository.isEnabled, isTrue);
      expect(prefs.getString(AnalyticsConsentRepository.versionKey), '1.2.7');

      await repository.setEnabled(false);
      expect(repository.isEnabled, isFalse);

      SharedPreferences.setMockInitialValues({
        AnalyticsConsentRepository.collectionKey: false,
      });
      final optedOutPrefs = await SharedPreferences.getInstance();
      expect(AnalyticsConsentRepository(optedOutPrefs).isEnabled, isFalse);
    },
  );
}
