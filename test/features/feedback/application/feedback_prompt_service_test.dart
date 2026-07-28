import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_config.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_service.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_state.dart';

void main() {
  final now = DateTime.utc(2026, 7, 28, 12);
  final config = FeedbackPromptConfig(
    enabled: true,
    rolloutPercent: 50,
    minInstallDays: 3,
    minSessions: 2,
    minActions: 5,
    minActiveDays: 2,
    laterDays: 7,
    dismissDays: 3,
    submittedDays: 30,
    maxShowsPer180Days: 3,
    engagementCooldownDays: 30,
    quietPeriodSeconds: 120,
    policyVersion: 'test',
  );

  test('requires an eligible stable cohort and all local thresholds', () async {
    final state = _State(
      firstRunAt: now.subtract(const Duration(days: 3)),
      sessions: 2,
      actions: 5,
      activeDays: 2,
    );
    final service = FeedbackPromptService(state, config, now: () => now);

    expect(await service.evaluate(), FeedbackPromptDecision.eligible);

    state.bucket = 9999;
    expect(await service.evaluate(), FeedbackPromptDecision.controlCohort);
    state.bucket = 0;
    state.engagementPromptAt = now.subtract(const Duration(days: 29));
    expect(await service.evaluate(), FeedbackPromptDecision.engagementCooldown);
  });

  test('marks a submission before applying its cooldown', () async {
    final state = _State();
    final service = FeedbackPromptService(state, config, now: () => now);

    await service.submitted();

    expect(state.submitted, isTrue);
    expect(state.snoozedFor, const Duration(days: 30));
  });
}

class _State implements FeedbackPromptStateStore {
  _State({
    this.firstRunAt,
    this.sessions = 0,
    this.actions = 0,
    this.activeDays = 0,
  });

  DateTime? firstRunAt;
  int bucket = 0;
  int sessions;
  int actions;
  int activeDays;
  DateTime? engagementPromptAt;
  bool submitted = false;
  Duration? snoozedFor;

  @override
  Future<void> initializeSession() async {}
  @override
  Future<DateTime?> readFirstRunAt() async => firstRunAt;
  @override
  Future<int> readSessionCount() async => sessions;
  @override
  Future<int> readMeaningfulActionCount() async => actions;
  @override
  Future<int> readActiveDayCount() async => activeDays;
  @override
  Future<int> readStableCohortBucket() async => bucket;
  @override
  Future<bool> readOptedOut() async => false;
  @override
  Future<DateTime?> readSnoozeUntil() async => null;
  @override
  Future<DateTime?> readEngagementPromptAt() async => engagementPromptAt;
  @override
  Future<bool> readShownThisSession() async => false;
  @override
  Future<bool> readShownToday() async => false;
  @override
  Future<List<DateTime>> readShowHistory() async => const [];
  @override
  Future<void> recordMeaningfulAction() async => actions++;
  @override
  Future<void> markShown() async {}
  @override
  Future<void> snooze(Duration duration) async => snoozedFor = duration;
  @override
  Future<void> optOut() async {}
  @override
  Future<void> markSubmitted() async => submitted = true;
}
