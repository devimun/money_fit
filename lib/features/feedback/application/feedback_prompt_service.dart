import 'package:money_fit/features/feedback/application/feedback_prompt_config.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_state.dart';

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
  engagementCooldown,
}

/// Feature policy for proactive product feedback.
///
/// It has no SDK or presentation dependency, which keeps Remote Config and
/// prompt UI failures isolated from a completed ledger command.
class FeedbackPromptService {
  FeedbackPromptService(this._state, this._config, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FeedbackPromptStateStore _state;
  final FeedbackPromptConfig _config;
  final DateTime Function() _now;

  FeedbackPromptConfig get config => _config;

  Future<void> initializeSession() => _state.initializeSession();

  Future<FeedbackPromptDecision> evaluate() async {
    if (!_config.enabled) return FeedbackPromptDecision.remoteDisabled;
    if (await _state.readStableCohortBucket() >= _config.rolloutPercent * 100) {
      return FeedbackPromptDecision.controlCohort;
    }
    if (await _state.readOptedOut()) return FeedbackPromptDecision.optedOut;

    final now = _now().toUtc();
    final firstRunAt = await _state.readFirstRunAt();
    if (firstRunAt == null ||
        now.isBefore(firstRunAt) ||
        now.difference(firstRunAt).inDays < _config.minInstallDays) {
      return FeedbackPromptDecision.installAge;
    }
    if (await _state.readSessionCount() < _config.minSessions) {
      return FeedbackPromptDecision.sessionCount;
    }
    if (await _state.readMeaningfulActionCount() < _config.minActions) {
      return FeedbackPromptDecision.actionCount;
    }
    if (await _state.readActiveDayCount() < _config.minActiveDays) {
      return FeedbackPromptDecision.activeDays;
    }
    final snoozeUntil = await _state.readSnoozeUntil();
    if (snoozeUntil != null && now.isBefore(snoozeUntil)) {
      return FeedbackPromptDecision.snoozed;
    }
    if (await _state.readShownThisSession()) {
      return FeedbackPromptDecision.sessionCap;
    }
    if (await _state.readShownToday()) return FeedbackPromptDecision.dailyCap;

    final showsInWindow = (await _state.readShowHistory())
        .where((shownAt) => now.difference(shownAt).inDays <= 180)
        .length;
    if (showsInWindow >= _config.maxShowsPer180Days) {
      return FeedbackPromptDecision.rollingCap;
    }
    final engagementPromptAt = await _state.readEngagementPromptAt();
    if (engagementPromptAt != null &&
        (now.isBefore(engagementPromptAt) ||
            now.difference(engagementPromptAt).inDays <
                _config.engagementCooldownDays)) {
      return FeedbackPromptDecision.engagementCooldown;
    }
    return FeedbackPromptDecision.eligible;
  }

  Future<void> recordMeaningfulAction() => _state.recordMeaningfulAction();
  Future<void> markShown() => _state.markShown();
  Future<void> later() => _state.snooze(Duration(days: _config.laterDays));
  Future<void> dismiss() => _state.snooze(Duration(days: _config.dismissDays));

  Future<void> submitted() async {
    await _state.markSubmitted();
    await _state.snooze(Duration(days: _config.submittedDays));
  }

  Future<void> never() => _state.optOut();
}
