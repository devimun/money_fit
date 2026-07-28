import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/notifications/application/notification_permission_prompt.dart';

void main() {
  test(
    'holds the notification lease through a successful permission flow',
    () async {
      final coordinator = PromptCoordinator();
      final controller = NotificationPermissionPromptController(coordinator);
      var presented = 0;

      final shown = await controller.showOnce(() async {
        presented += 1;
        expect(coordinator.activeSurface, PromptSurface.notificationPermission);
      });

      expect(shown, isTrue);
      expect(presented, 1);
      expect(coordinator.activeSurface, isNull);
    },
  );

  test(
    'suppresses notification permission while another prompt owns lease',
    () async {
      for (final surface in const [
        PromptSurface.productFeedback,
        PromptSurface.review,
        PromptSurface.interstitialAd,
        PromptSurface.update,
      ]) {
        final coordinator = PromptCoordinator();
        final active = coordinator.tryAcquire(surface)!;
        final controller = NotificationPermissionPromptController(coordinator);
        var presented = 0;

        final shown = await controller.showOnce(() async => presented += 1);

        expect(shown, isFalse, reason: '$surface should suppress notification');
        expect(presented, 0);
        expect(coordinator.activeSurface, surface);
        active.release();
      }
    },
  );

  test('releases its lease after a dismissed or failed dialog', () async {
    final coordinator = PromptCoordinator();
    final dismissed = NotificationPermissionPromptController(coordinator);

    expect(await dismissed.showOnce(() async {}), isTrue);
    expect(coordinator.activeSurface, isNull);

    final failed = NotificationPermissionPromptController(coordinator);
    expect(
      await failed.showOnce(() => Future<void>.error(StateError('dialog'))),
      isFalse,
    );
    expect(coordinator.activeSurface, isNull);
    expect(
      coordinator.tryAcquire(PromptSurface.review),
      isNotNull,
      reason: 'an error must not leave notification permission active',
    );
  });

  test('does not duplicate an in-flight notification prompt', () async {
    final coordinator = PromptCoordinator();
    final controller = NotificationPermissionPromptController(coordinator);
    final completion = Completer<void>();
    var presented = 0;

    final first = controller.showOnce(() {
      presented += 1;
      return completion.future;
    });
    final second = await controller.showOnce(() async => presented += 1);

    expect(second, isFalse);
    expect(presented, 1);
    expect(coordinator.activeSurface, PromptSurface.notificationPermission);

    completion.complete();
    expect(await first, isTrue);
    expect(coordinator.activeSurface, isNull);
  });

  test('uses the shared quiet period before opening the prompt', () async {
    var now = DateTime.utc(2026, 7, 28, 12);
    final coordinator = PromptCoordinator(now: () => now);
    final review = coordinator.tryAcquire(PromptSurface.review)!;
    review.release();

    final blocked = NotificationPermissionPromptController(
      coordinator,
      quietPeriod: () => const Duration(seconds: 120),
    );
    var presented = 0;
    expect(await blocked.showOnce(() async => presented += 1), isFalse);
    expect(presented, 0);

    now = now.add(const Duration(seconds: 120));
    final allowed = NotificationPermissionPromptController(
      coordinator,
      quietPeriod: () => const Duration(seconds: 120),
    );
    expect(await allowed.showOnce(() async => presented += 1), isTrue);
    expect(presented, 1);
  });
}
