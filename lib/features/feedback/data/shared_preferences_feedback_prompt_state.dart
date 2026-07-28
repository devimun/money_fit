import 'dart:convert';
import 'dart:math';

import 'package:money_fit/features/feedback/application/feedback_prompt_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesFeedbackPromptState implements FeedbackPromptStateStore {
  SharedPreferencesFeedbackPromptState(
    this._preferences, {
    DateTime Function()? now,
    int Function(int)? nextInt,
  }) : _now = now ?? DateTime.now,
       _nextInt = nextInt ?? Random.secure().nextInt;

  final SharedPreferences _preferences;
  final DateTime Function() _now;
  final int Function(int) _nextInt;

  static const _firstRunAt = 'app_first_run_at';
  static const _sessionCount = 'app_session_count';
  static const _lastSessionAt = 'app_last_session_started_at';
  static const _cohortBucket = 'feedback_prompt_bucket_v1';
  static const _meaningfulActionCount = 'feedback_meaningful_action_count';
  static const _meaningfulActionDays = 'feedback_meaningful_action_days';
  static const _lastOpportunityDay = 'feedback_prompt_last_opportunity_day';
  static const _optedOut = 'feedback_prompt_opted_out';
  static const _snoozeUntil = 'feedback_prompt_snooze_until';
  static const _lastShownAt = 'feedback_prompt_last_shown_at';
  static const _showHistory = 'feedback_prompt_show_history';
  static const _engagementPromptAt = 'engagement_prompt_last_shown_at';
  static const _legacyReviewFirstRunAt = 'review_first_run_at';

  bool _shownThisSession = false;

  @override
  Future<void> initializeSession() async {
    final now = _now().toUtc();
    final legacyFirstRun = _readDate(_legacyReviewFirstRunAt);
    final currentFirstRun = _readDate(_firstRunAt);
    if (currentFirstRun == null ||
        (legacyFirstRun != null && legacyFirstRun.isBefore(currentFirstRun))) {
      await _preferences.setString(
        _firstRunAt,
        (legacyFirstRun ?? now).toIso8601String(),
      );
    }

    final lastSessionAt = _readDate(_lastSessionAt);
    if (lastSessionAt == null ||
        now.difference(lastSessionAt) >= const Duration(minutes: 30)) {
      await _preferences.setInt(
        _sessionCount,
        (_preferences.getInt(_sessionCount) ?? 0) + 1,
      );
      await _preferences.setString(_lastSessionAt, now.toIso8601String());
    }
  }

  @override
  Future<DateTime?> readFirstRunAt() async => _readDate(_firstRunAt);

  @override
  Future<int> readSessionCount() async =>
      _preferences.getInt(_sessionCount) ?? 0;

  @override
  Future<int> readMeaningfulActionCount() async =>
      _preferences.getInt(_meaningfulActionCount) ?? 0;

  @override
  Future<int> readActiveDayCount() async =>
      _readStringList(_meaningfulActionDays).toSet().length;

  @override
  Future<int> readStableCohortBucket() async {
    final existing = _preferences.getInt(_cohortBucket);
    if (existing != null && existing >= 0 && existing <= 9999) {
      return existing;
    }
    final bucket = _nextInt(10000);
    await _preferences.setInt(_cohortBucket, bucket);
    return bucket;
  }

  @override
  Future<bool> readOptedOut() async => _preferences.getBool(_optedOut) ?? false;

  @override
  Future<DateTime?> readSnoozeUntil() async => _readDate(_snoozeUntil);

  @override
  Future<DateTime?> readEngagementPromptAt() async =>
      _readDate(_engagementPromptAt);

  @override
  Future<bool> readShownThisSession() async => _shownThisSession;

  @override
  Future<bool> readShownToday() async =>
      _preferences.getString(_lastOpportunityDay) == _day(_now());

  @override
  Future<List<DateTime>> readShowHistory() async =>
      _readStringList(_showHistory)
          .map(DateTime.tryParse)
          .whereType<DateTime>()
          .map((value) => value.toUtc())
          .toList();

  @override
  Future<void> recordMeaningfulAction() async {
    await _preferences.setInt(
      _meaningfulActionCount,
      (_preferences.getInt(_meaningfulActionCount) ?? 0) + 1,
    );
    final days = _readStringList(_meaningfulActionDays).toSet()
      ..add(_day(_now()));
    final retained = days.toList()..sort();
    final start = retained.length > 30 ? retained.length - 30 : 0;
    await _preferences.setString(
      _meaningfulActionDays,
      jsonEncode(retained.sublist(start)),
    );
  }

  @override
  Future<void> markShown() async {
    final now = _now().toUtc();
    _shownThisSession = true;
    final history =
        (await readShowHistory())
            .where(
              (shownAt) => now.difference(shownAt) <= const Duration(days: 180),
            )
            .toList()
          ..add(now);
    await _preferences.setString(_lastShownAt, now.toIso8601String());
    await _preferences.setString(_lastOpportunityDay, _day(now));
    await _preferences.setString(_engagementPromptAt, now.toIso8601String());
    await _preferences.setString(
      _showHistory,
      jsonEncode(history.map((value) => value.toIso8601String()).toList()),
    );
  }

  @override
  Future<void> snooze(Duration duration) => _preferences.setString(
    _snoozeUntil,
    _now().toUtc().add(duration).toIso8601String(),
  );

  @override
  Future<void> optOut() => _preferences.setBool(_optedOut, true);

  @override
  Future<void> markSubmitted() => _preferences.setString(
    'feedback_prompt_last_submitted_at',
    _now().toUtc().toIso8601String(),
  );

  DateTime? _readDate(String key) {
    final value = _preferences.getString(key);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  List<String> _readStringList(String key) {
    try {
      final decoded = jsonDecode(_preferences.getString(key) ?? '[]');
      return decoded is List ? decoded.whereType<String>().toList() : const [];
    } catch (_) {
      return const [];
    }
  }

  static String _day(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
