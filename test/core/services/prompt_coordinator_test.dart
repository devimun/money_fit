import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/services/prompt_coordinator.dart';

void main() {
  test('only one full-screen lease is active and release is idempotent', () {
    final coordinator = PromptCoordinator();
    final first = coordinator.tryAcquire(PromptSurface.review);
    expect(first, isNotNull);
    expect(coordinator.tryAcquire(PromptSurface.interstitialAd), isNull);
    first!.release();
    first.release();
    expect(coordinator.tryAcquire(PromptSurface.interstitialAd), isNotNull);
  });

  test('notification and update surfaces share the same lease', () {
    final coordinator = PromptCoordinator();
    final notification = coordinator.tryAcquire(
      PromptSurface.notificationPermission,
    );
    expect(notification, isNotNull);
    expect(coordinator.tryAcquire(PromptSurface.update), isNull);
    notification!.release();
    final update = coordinator.tryAcquire(PromptSurface.update);
    expect(update, isNotNull);
    update!.release();
  });

  test('respects a requested quiet period after a surface is dismissed', () {
    var now = DateTime.utc(2026, 7, 21, 12);
    final coordinator = PromptCoordinator(now: () => now);
    final review = coordinator.tryAcquire(PromptSurface.review);
    review!.release();

    expect(
      coordinator.tryAcquire(
        PromptSurface.productFeedback,
        quietPeriod: const Duration(seconds: 120),
      ),
      isNull,
    );
    now = now.add(const Duration(seconds: 120));
    final feedback = coordinator.tryAcquire(
      PromptSurface.productFeedback,
      quietPeriod: const Duration(seconds: 120),
    );
    expect(feedback, isNotNull);
    feedback!.release();
  });
}
