import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/notifications/data/shared_preferences_notification_preference_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('notification intent is independent for each local owner', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesNotificationPreferenceRepository(
      await SharedPreferences.getInstance(),
    );

    expect(await repository.isEnabled('one'), isFalse);
    await repository.setEnabled('one', true);

    expect(await repository.isEnabled('one'), isTrue);
    expect(await repository.isEnabled('two'), isFalse);
    await repository.clear('one');
    expect(await repository.isEnabled('one'), isFalse);
  });
}
