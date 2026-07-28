import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/app_update/application/update_presentation.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';

void main() {
  const recommended = UpdateStatus(
    isForceUpdateRequired: false,
    isUpdateRecommended: true,
    messageToDisplay: '',
    storeUri: null,
    changelogLines: ['Faster startup'],
  );

  test(
    'force, current, and failed checks never present a recommendation',
    () async {
      final statuses = [
        const UpdateStatus(
          isForceUpdateRequired: true,
          isUpdateRecommended: false,
          messageToDisplay: '',
          storeUri: null,
          changelogLines: [],
        ),
        UpdateStatus.none,
        UpdateStatus(
          isForceUpdateRequired: false,
          isUpdateRecommended: false,
          messageToDisplay: '',
          storeUri: null,
          changelogLines: const [],
          remoteCheckError: StateError('offline'),
        ),
      ];

      for (final status in statuses) {
        var presentations = 0;
        final shown = await RecommendedUpdatePromptController()
            .presentNotificationIfNeeded(
              status: status,
              promptCoordinator: PromptCoordinator(),
              establishPresentation: () async => presentations++,
            );

        expect(shown, isFalse);
        expect(presentations, 0);
      }
    },
  );

  test(
    'recommended notification is shown once and respects lease contention',
    () async {
      final coordinator = PromptCoordinator();
      final controller = RecommendedUpdatePromptController();
      var presentations = 0;

      final reviewLease = coordinator.tryAcquire(PromptSurface.review)!;
      expect(
        await controller.presentNotificationIfNeeded(
          status: recommended,
          promptCoordinator: coordinator,
          establishPresentation: () async => presentations++,
        ),
        isFalse,
      );
      expect(presentations, 0);

      reviewLease.release(applyQuietPeriod: false);
      expect(
        await controller.presentNotificationIfNeeded(
          status: recommended,
          promptCoordinator: coordinator,
          establishPresentation: () async => presentations++,
        ),
        isTrue,
      );
      expect(
        await controller.presentNotificationIfNeeded(
          status: recommended,
          promptCoordinator: coordinator,
          establishPresentation: () async => presentations++,
        ),
        isFalse,
      );
      expect(presentations, 1);
      expect(coordinator.activeSurface, isNull);
    },
  );

  test(
    'details release on dismissal and then observe the quiet period',
    () async {
      var now = DateTime.utc(2026, 7, 28, 12);
      final coordinator = PromptCoordinator(now: () => now);
      final controller = RecommendedUpdatePromptController();
      final dismissed = Completer<void>();

      final presentation = controller.presentDetailsWhenAvailable(
        status: recommended,
        promptCoordinator: coordinator,
        quietPeriod: const Duration(minutes: 2),
        establishPresentation: () => dismissed.future,
      );
      expect(coordinator.activeSurface, PromptSurface.update);

      dismissed.complete();
      expect(await presentation, isTrue);
      expect(coordinator.activeSurface, isNull);
      expect(
        await controller.presentDetailsWhenAvailable(
          status: recommended,
          promptCoordinator: coordinator,
          quietPeriod: const Duration(minutes: 2),
          establishPresentation: () async {},
        ),
        isFalse,
      );

      now = now.add(const Duration(minutes: 2));
      expect(
        await controller.presentDetailsWhenAvailable(
          status: recommended,
          promptCoordinator: coordinator,
          quietPeriod: const Duration(minutes: 2),
          establishPresentation: () async {},
        ),
        isTrue,
      );
    },
  );

  test(
    'details callback receives changelog and presentation errors fail open',
    () async {
      final coordinator = PromptCoordinator();
      final controller = RecommendedUpdatePromptController();
      List<String>? receivedChangelog;

      final shown = await controller.presentDetailsWhenAvailable(
        status: recommended,
        promptCoordinator: coordinator,
        establishPresentation: () async {
          receivedChangelog = recommended.changelogLines;
        },
      );

      expect(shown, isTrue);
      expect(receivedChangelog, ['Faster startup']);
      expect(
        await presentUpdateSurfaceWhenAvailable(
          promptCoordinator: coordinator,
          quietPeriod: Duration.zero,
          establishPresentation: () => Future<void>.error(StateError('dialog')),
        ),
        isFalse,
      );
      expect(coordinator.activeSurface, isNull);
    },
  );
}
