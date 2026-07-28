import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/composition/feedback_providers.dart';
import 'package:money_fit/app/reset/reset_coordinator.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'full-reset in-process cleanup replaces feedback state and clears lease',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      );
      addTearDown(container.dispose);

      final oldState = container.read(feedbackPromptStateProvider);
      final oldService = container.read(feedbackPromptServiceProvider);
      final oldStartup = container.read(feedbackPromptStartupProvider);
      await oldState.markShown();
      expect(await oldState.readShownThisSession(), isTrue);

      final coordinator = container.read(promptCoordinatorProvider);
      final lease = coordinator.tryAcquire(PromptSurface.productFeedback)!;
      lease.release();
      expect(
        coordinator.tryAcquire(
          PromptSurface.review,
          quietPeriod: const Duration(days: 1),
        ),
        isNull,
      );

      container.read(_inProcessEngagementResetProvider);

      expect(
        container.read(feedbackPromptStateProvider),
        isNot(same(oldState)),
      );
      expect(
        container.read(feedbackPromptServiceProvider),
        isNot(same(oldService)),
      );
      expect(
        container.read(feedbackPromptStartupProvider),
        isNot(same(oldStartup)),
      );
      expect(
        coordinator.tryAcquire(
          PromptSurface.review,
          quietPeriod: const Duration(days: 1),
        ),
        isNotNull,
      );
    },
  );
}

final _inProcessEngagementResetProvider = Provider<void>(
  resetInProcessEngagement,
);
