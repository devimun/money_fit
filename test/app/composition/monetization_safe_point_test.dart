import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';

void main() {
  test(
    'interstitial gate cannot overlap a prompt and respects its quiet period',
    () async {
      var now = DateTime.utc(2026, 7, 28, 12);
      final coordinator = PromptCoordinator(now: () => now);
      const quietPeriod = Duration(seconds: 120);
      final gate = PromptCoordinatorInterstitialGate(
        coordinator,
        quietPeriod: quietPeriod,
      );

      final review = coordinator.tryAcquire(PromptSurface.review)!;
      expect(await gate.tryAcquireInterstitial(), isNull);

      review.release();
      expect(await gate.tryAcquireInterstitial(), isNull);

      now = now.add(quietPeriod);
      final interstitial = await gate.tryAcquireInterstitial();
      expect(interstitial, isNotNull);
      expect(coordinator.activeSurface, PromptSurface.interstitialAd);

      interstitial!.release();
      expect(coordinator.activeSurface, isNull);
    },
  );

  test(
    'interstitial gate reads the latest quiet-period policy at acquisition',
    () async {
      var now = DateTime.utc(2026, 7, 28, 12);
      var quietPeriod = const Duration(seconds: 120);
      final coordinator = PromptCoordinator(now: () => now);
      final gate = PromptCoordinatorInterstitialGate(
        coordinator,
        quietPeriodProvider: () => quietPeriod,
      );

      final review = coordinator.tryAcquire(PromptSurface.review)!;
      review.release();
      now = now.add(const Duration(seconds: 30));
      quietPeriod = const Duration(seconds: 30);

      final interstitial = await gate.tryAcquireInterstitial();
      expect(interstitial, isNotNull);
      interstitial!.release();
    },
  );
}
