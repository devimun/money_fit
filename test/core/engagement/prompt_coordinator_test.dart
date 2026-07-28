import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';

void main() {
  test(
    'reset clears active lease and quiet state without stale lease effects',
    () {
      var now = DateTime.utc(2026, 7, 28, 12);
      final coordinator = PromptCoordinator(now: () => now);
      final staleLease = coordinator.tryAcquire(PromptSurface.productFeedback)!;

      coordinator.reset();

      final currentLease = coordinator.tryAcquire(
        PromptSurface.productFeedback,
        quietPeriod: const Duration(minutes: 10),
      );
      expect(currentLease, isNotNull);
      staleLease.release();
      expect(coordinator.activeSurface, PromptSurface.productFeedback);

      currentLease!.release();
      expect(
        coordinator.tryAcquire(
          PromptSurface.review,
          quietPeriod: const Duration(minutes: 10),
        ),
        isNull,
      );

      now = now.add(const Duration(seconds: 1));
      coordinator.reset();
      expect(
        coordinator.tryAcquire(
          PromptSurface.review,
          quietPeriod: const Duration(minutes: 10),
        ),
        isNotNull,
      );
    },
  );
}
