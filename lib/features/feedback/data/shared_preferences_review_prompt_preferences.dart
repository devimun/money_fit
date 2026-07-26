import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesReviewPromptPreferences
    implements ReviewPromptPreferences {
  static const _firstRunAt = 'review_first_run_at';
  static const _optedOut = 'review_opted_out';
  static const _lastPromptAt = 'review_last_prompt_at';
  static const _promptCount = 'review_prompt_count';
  static const _snoozeUntil = 'review_snooze_until';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<DateTime?> readFirstRunAt() async {
    return DateTime.tryParse((await _prefs).getString(_firstRunAt) ?? '');
  }

  @override
  Future<void> writeFirstRunAt(DateTime value) async {
    await (await _prefs).setString(_firstRunAt, value.toIso8601String());
  }

  @override
  Future<bool> readOptedOut() async =>
      (await _prefs).getBool(_optedOut) ?? false;

  @override
  Future<void> writeOptedOut(bool value) async {
    await (await _prefs).setBool(_optedOut, value);
  }

  @override
  Future<DateTime?> readSnoozeUntil() async {
    return DateTime.tryParse((await _prefs).getString(_snoozeUntil) ?? '');
  }

  @override
  Future<void> writeSnoozeUntil(DateTime value) async {
    await (await _prefs).setString(_snoozeUntil, value.toIso8601String());
  }

  @override
  Future<void> markPrompted(DateTime value) async {
    final prefs = await _prefs;
    await prefs.setString(_lastPromptAt, value.toIso8601String());
    await prefs.setInt(_promptCount, (prefs.getInt(_promptCount) ?? 0) + 1);
  }
}
