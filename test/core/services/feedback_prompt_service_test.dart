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
}
