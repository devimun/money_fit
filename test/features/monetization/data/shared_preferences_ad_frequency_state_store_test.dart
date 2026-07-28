import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/monetization/data/shared_preferences_ad_frequency_state_store.dart';
import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late SharedPreferencesAdFrequencyStateStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    store = SharedPreferencesAdFrequencyStateStore(preferences);
  });

  test(
    'round-trips persistent caps, timestamps, and trigger debounce state',
    () async {
      final shownAt = DateTime.utc(2026, 7, 28, 12);
      await store.write(
        AdFrequencyState(
          sessionStartedAt: shownAt.subtract(const Duration(minutes: 5)),
          sessionNumber: 4,
          fullscreenShownThisSession: 2,
          pendingMeaningfulActions: 5,
          lastFullscreenShownAt: shownAt,
          fullscreenHistory: <DateTime>[shownAt],
          lastTriggerAt: <String, DateTime>{'transaction_saved': shownAt},
        ),
      );

      final restored = await store.read();
      expect(restored.sessionNumber, 4);
      expect(restored.fullscreenShownThisSession, 2);
      expect(restored.pendingMeaningfulActions, 5);
      expect(restored.lastFullscreenShownAt, shownAt);
      expect(restored.fullscreenHistory, <DateTime>[shownAt]);
      expect(restored.lastTriggerAt['transaction_saved'], shownAt);
    },
  );

  test('corrupt persisted state fails open to an empty policy state', () async {
    await preferences.setString(
      SharedPreferencesAdFrequencyStateStore.storageKey,
      '{not-json',
    );

    final restored = await store.read();

    expect(restored.sessionNumber, 0);
    expect(restored.fullscreenHistory, isEmpty);
  });

  test('clear removes all persisted frequency state', () async {
    await store.write(const AdFrequencyState(sessionNumber: 2));
    await store.clear();

    expect(
      preferences.getString(SharedPreferencesAdFrequencyStateStore.storageKey),
      isNull,
    );
  });
}
