import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class PromptStateRepository {
  PromptStateRepository(this._prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  static const _firstRun = 'app_first_run_at';
  static const _sessions = 'app_session_count';
  static const _lastSession = 'app_last_session_started_at';
  static const _bucket = 'feedback_prompt_bucket_v1';
  static const _actions = 'feedback_meaningful_action_count';
  static const _actionDays = 'feedback_meaningful_action_days';
  static const _opportunityDay = 'feedback_prompt_last_opportunity_day';
  static const _optedOut = 'feedback_prompt_opted_out';
  static const _snoozeUntil = 'feedback_prompt_snooze_until';
  static const _shownAt = 'feedback_prompt_last_shown_at';
  static const _submittedAt = 'feedback_prompt_last_submitted_at';
  static const _history = 'feedback_prompt_show_history';
  static const _engagementShownAt = 'engagement_prompt_last_shown_at';

  Future<void> initializeSession() async {
    final now = _now().toUtc();
    final legacy = _date(_prefs.getString('review_first_run_at'));
    final first = _date(_prefs.getString(_firstRun));
    if (first == null || (legacy != null && legacy.isBefore(first))) {
      await _prefs.setString(_firstRun, (legacy ?? now).toIso8601String());
    }
    final last = _date(_prefs.getString(_lastSession));
    if (last == null || now.difference(last) >= const Duration(minutes: 30)) {
      await _prefs.setInt(_sessions, (_prefs.getInt(_sessions) ?? 0) + 1);
      await _prefs.setString(_lastSession, now.toIso8601String());
    }
  }

  DateTime? get firstRunAt => _date(_prefs.getString(_firstRun));
  int get sessions => _prefs.getInt(_sessions) ?? 0;
  int get actions => _prefs.getInt(_actions) ?? 0;
  bool get optedOut => _prefs.getBool(_optedOut) ?? false;
  DateTime? get snoozeUntil => _date(_prefs.getString(_snoozeUntil));
  DateTime? get engagementShownAt =>
      _date(_prefs.getString(_engagementShownAt));
  DateTime? get lastShownAt => _date(_prefs.getString(_shownAt));
  DateTime? get lastSubmittedAt => _date(_prefs.getString(_submittedAt));
  String? get lastOpportunityDay => _prefs.getString(_opportunityDay);

  int bucket() {
    final stored = _prefs.getInt(_bucket);
    if (stored != null && stored >= 0 && stored <= 9999) return stored;
    final next = Random.secure().nextInt(10000);
    _prefs.setInt(_bucket, next);
    return next;
  }

  Future<void> recordCreatedExpense() async {
    final now = _now();
    await _prefs.setInt(_actions, actions + 1);
    final days = _stringList(_actionDays).toSet()..add(_day(now));
    final retained = days.toList()..sort();
    // Keep the newest local days so a long-lived install does not retain
    // obsolete history forever while still bounding preference storage.
    final start = retained.length > 30 ? retained.length - 30 : 0;
    await _prefs.setString(_actionDays, jsonEncode(retained.sublist(start)));
  }

  int get activeDays => _stringList(_actionDays).toSet().length;
  bool shownThisSession = false;
  bool get shownToday => lastOpportunityDay == _day(_now());

  Future<void> markOpportunity() =>
      _prefs.setString(_opportunityDay, _day(_now()));
  Future<void> markShown() async {
    final now = _now().toUtc();
    shownThisSession = true;
    final history =
        showHistory
            .where((v) => now.difference(v) <= const Duration(days: 180))
            .toList()
          ..add(now);
    await _prefs.setString(_shownAt, now.toIso8601String());
    await _prefs.setString(_opportunityDay, _day(now));
    await _prefs.setString(
      _history,
      jsonEncode(history.map((v) => v.toIso8601String()).toList()),
    );
    await _prefs.setString(_engagementShownAt, now.toIso8601String());
  }

  List<DateTime> get showHistory =>
      _stringList(_history).map(_date).whereType<DateTime>().toList();
  Future<void> snooze(Duration duration) => _prefs.setString(
    _snoozeUntil,
    _now().toUtc().add(duration).toIso8601String(),
  );
  Future<void> setOptedOut() => _prefs.setBool(_optedOut, true);
  Future<void> markSubmitted() =>
      _prefs.setString(_submittedAt, _now().toUtc().toIso8601String());

  static DateTime? _date(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toUtc();
  List<String> _stringList(String key) {
    try {
      final value = jsonDecode(_prefs.getString(key) ?? '[]');
      return value is List ? value.whereType<String>().toList() : const [];
    } catch (_) {
      return const [];
    }
  }

  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
