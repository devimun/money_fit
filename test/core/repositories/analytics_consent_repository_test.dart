import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/repositories/analytics_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'analytics collection is opt-in and persists the consent version',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = AnalyticsConsentRepository(prefs);
      expect(repository.isEnabled, isFalse);

      await repository.setEnabled(true, version: '1.2.7');
      expect(repository.isEnabled, isTrue);
      expect(prefs.getString(AnalyticsConsentRepository.versionKey), '1.2.7');

      await repository.setEnabled(false);
      expect(repository.isEnabled, isFalse);
    },
  );
}
