import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/feedback_prompt_config.dart';
import 'package:money_fit/core/repositories/prompt_state_repository.dart';
import 'package:money_fit/core/services/feedback_prompt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('conservative remote default suppresses a feedback prompt', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = PromptStateRepository(
      prefs,
      now: () => DateTime.utc(2026, 7, 21),
    );
    await state.initializeSession();
    final service = FeedbackPromptService(
      state,
      const FeedbackPromptConfig(
        enabled: false,
        rolloutPercent: 0,
        minInstallDays: 7,
        minSessions: 3,
        minActions: 10,
        minActiveDays: 3,
      ),
      now: () => DateTime.utc(2026, 7, 21),
    );
    expect(service.evaluate(), FeedbackPromptDecision.remoteDisabled);
  });

  test(
    'requires all engagement thresholds, then records daily and submit state',
    () async {
      DateTime now = DateTime.utc(2026, 7, 21);
      SharedPreferences.setMockInitialValues({
        'feedback_prompt_bucket_v1': 0,
        'app_first_run_at': now
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'app_session_count': 3,
      });
      final prefs = await SharedPreferences.getInstance();
      final state = PromptStateRepository(prefs, now: () => now);
      final service = FeedbackPromptService(
        state,
        const FeedbackPromptConfig(
          enabled: true,
          rolloutPercent: 100,
          minInstallDays: 7,
          minSessions: 3,
          minActions: 3,
          minActiveDays: 3,
        ),
        now: () => now,
      );

      for (var day = 0; day < 3; day++) {
        for (var action = 0; action < 1; action++) {
          await state.recordCreatedExpense();
        }
        now = now.add(const Duration(days: 1));
      }

      expect(service.evaluate(), FeedbackPromptDecision.eligible);
      await service.markShown();
      expect(service.evaluate(), FeedbackPromptDecision.sessionCap);
      await service.submitted();
      expect(state.lastSubmittedAt, now);
      expect(state.snoozeUntil, now.add(const Duration(days: 120)));
    },
  );

  test('keeps a stable control cohort out of the feedback treatment', () async {
    SharedPreferences.setMockInitialValues({'feedback_prompt_bucket_v1': 500});
    final prefs = await SharedPreferences.getInstance();
    final state = PromptStateRepository(prefs);
    final service = FeedbackPromptService(
      state,
      const FeedbackPromptConfig(
        enabled: true,
        rolloutPercent: 5,
        minInstallDays: 7,
        minSessions: 3,
        minActions: 10,
        minActiveDays: 3,
      ),
    );

    expect(service.evaluate(), FeedbackPromptDecision.controlCohort);
  });

  test(
    'uses configured cooldowns and rolling cap instead of hard-coded values',
    () async {
      var now = DateTime.utc(2026, 7, 21);
      SharedPreferences.setMockInitialValues({
        'feedback_prompt_bucket_v1': 0,
        'app_first_run_at': now
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'app_session_count': 3,
        'feedback_meaningful_action_count': 3,
        'feedback_meaningful_action_days':
            '["2026-07-19","2026-07-20","2026-07-21"]',
        'feedback_prompt_show_history': '["2026-07-01T00:00:00.000Z"]',
      });
      final prefs = await SharedPreferences.getInstance();
      final state = PromptStateRepository(prefs, now: () => now);
      final service = FeedbackPromptService(
        state,
        const FeedbackPromptConfig(
          enabled: true,
          rolloutPercent: 100,
          minInstallDays: 7,
          minSessions: 3,
          minActions: 3,
          minActiveDays: 3,
          laterDays: 45,
          dismissDays: 20,
          submittedDays: 150,
          maxShowsPer180Days: 1,
          engagementCooldownDays: 45,
        ),
        now: () => now,
      );

      expect(service.evaluate(), FeedbackPromptDecision.rollingCap);
      await service.later();
      expect(state.snoozeUntil, now.add(const Duration(days: 45)));
      now = now.add(const Duration(days: 45));
      await service.dismiss();
      expect(state.snoozeUntil, now.add(const Duration(days: 20)));
      await service.submitted();
      expect(state.snoozeUntil, now.add(const Duration(days: 150)));
    },
  );
}
