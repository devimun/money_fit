import 'dart:convert';

import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAdFrequencyStateStore implements AdFrequencyStateStore {
  SharedPreferencesAdFrequencyStateStore(this._preferences);

  static const storageKey = 'monetization.ad_frequency_state.v1';

  final SharedPreferences _preferences;

  @override
  Future<AdFrequencyState> read() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const AdFrequencyState();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AdFrequencyState();
      return AdFrequencyState(
        sessionStartedAt: _date(decoded['sessionStartedAt']),
        sessionNumber: _nonNegativeInt(decoded['sessionNumber']),
        fullscreenShownThisSession: _nonNegativeInt(
          decoded['fullscreenShownThisSession'],
        ),
        pendingMeaningfulActions: _nonNegativeInt(
          decoded['pendingMeaningfulActions'],
        ),
        lastFullscreenShownAt: _date(decoded['lastFullscreenShownAt']),
        fullscreenHistory: _dates(decoded['fullscreenHistory']),
        lastTriggerAt: _triggerDates(decoded['lastTriggerAt']),
      );
    } catch (_) {
      // Corrupt local frequency state must not block local app startup.
      return const AdFrequencyState();
    }
  }

  @override
  Future<void> write(AdFrequencyState state) async {
    final saved = await _preferences.setString(
      storageKey,
      jsonEncode(<String, Object?>{
        'sessionStartedAt': state.sessionStartedAt?.toUtc().toIso8601String(),
        'sessionNumber': state.sessionNumber,
        'fullscreenShownThisSession': state.fullscreenShownThisSession,
        'pendingMeaningfulActions': state.pendingMeaningfulActions,
        'lastFullscreenShownAt': state.lastFullscreenShownAt
            ?.toUtc()
            .toIso8601String(),
        'fullscreenHistory': state.fullscreenHistory
            .map((value) => value.toUtc().toIso8601String())
            .toList(),
        'lastTriggerAt': state.lastTriggerAt.map(
          (key, value) => MapEntry(key, value.toUtc().toIso8601String()),
        ),
      }),
    );
    if (!saved) throw StateError('Unable to persist ad frequency state.');
  }

  @override
  Future<void> clear() async {
    final cleared = await _preferences.remove(storageKey);
    if (!cleared) throw StateError('Unable to clear ad frequency state.');
  }

  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  static int _nonNegativeInt(Object? value) =>
      value is int && value >= 0 ? value : 0;

  static List<DateTime> _dates(Object? value) {
    if (value is! List<Object?>) return const <DateTime>[];
    return value.map(_date).whereType<DateTime>().toList(growable: false);
  }

  static Map<String, DateTime> _triggerDates(Object? value) {
    if (value is! Map<Object?, Object?>) return const <String, DateTime>{};
    final dates = <String, DateTime>{};
    for (final entry in value.entries) {
      final date = _date(entry.value);
      if (entry.key is String && date != null) {
        dates[entry.key as String] = date;
      }
    }
    return dates;
  }
}
