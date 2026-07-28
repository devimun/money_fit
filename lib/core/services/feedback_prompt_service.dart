import 'package:money_fit/core/config/feedback_prompt_config.dart';
import 'package:money_fit/core/repositories/prompt_state_repository.dart';

enum FeedbackPromptDecision {
  eligible,
  remoteDisabled,
  controlCohort,
  optedOut,
  installAge,
  sessionCount,
  actionCount,
  activeDays,
  snoozed,
  dailyCap,
  sessionCap,
  rollingCap,
  reviewCooldown,
}

class FeedbackPromptService {
  FeedbackPromptService(this._state, this._config, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final PromptStateRepository _state;
  final FeedbackPromptConfig _config;
  final DateTime Function() _now;

  FeedbackPromptConfig get config => _config;

  FeedbackPromptDecision evaluate() {
    if (!_config.enabled) {
      return FeedbackPromptDecision.remoteDisabled;
    }
    if (_state.bucket() >= _config.rolloutPercent * 100) {
      return FeedbackPromptDecision.controlCohort;
    }
    if (_state.optedOut) {
      return FeedbackPromptDecision.optedOut;
    }
    final firstRun = _state.firstRunAt;
    final now = _now().toUtc();
    if (firstRun == null ||
        now.isBefore(firstRun) ||
        now.difference(firstRun).inDays < _config.minInstallDays) {
      return FeedbackPromptDecision.installAge;
    }
    if (_state.sessions < _config.minSessions) {
      return FeedbackPromptDecision.sessionCount;
    }
    if (_state.actions < _config.minActions) {
      return FeedbackPromptDecision.actionCount;
    }
    if (_state.activeDays < _config.minActiveDays) {
      return FeedbackPromptDecision.activeDays;
    }
    final snooze = _state.snoozeUntil;
    if (snooze != null && now.isBefore(snooze)) {
      return FeedbackPromptDecision.snoozed;
    }
    if (_state.shownThisSession) {
      return FeedbackPromptDecision.sessionCap;
    }
    if (_state.shownToday) {
      return FeedbackPromptDecision.dailyCap;
    }
    if (_state.showHistory
            .where((v) => now.difference(v).inDays <= 180)
            .length >=
        _config.maxShowsPer180Days) {
      return FeedbackPromptDecision.rollingCap;
    }
    final engagement = _state.engagementShownAt;
    if (engagement != null &&
        (now.isBefore(engagement) ||
            now.difference(engagement).inDays <
                _config.engagementCooldownDays)) {
      return FeedbackPromptDecision.reviewCooldown;
    }
    return FeedbackPromptDecision.eligible;
  }

  Future<void> recordCreatedExpense() => _state.recordCreatedExpense();
  Future<void> markShown() => _state.markShown();
  Future<void> later() => _state.snooze(Duration(days: _config.laterDays));
  Future<void> dismiss() => _state.snooze(Duration(days: _config.dismissDays));
  Future<void> submitted() async {
    await _state.markSubmitted();
    await _state.snooze(Duration(days: _config.submittedDays));
  }

  Future<void> never() => _state.setOptedOut();
}
