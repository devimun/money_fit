import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/notifications/application/notification_permission_prompt.dart';

void main() {
  test(
    'settings success holds the notification lease through OS permission',
    () async {
      final coordinator = PromptCoordinator();
      final controller = NotificationPermissionSettingsRequestController(
        coordinator,
      );
      final permission = Completer<NotificationPermissionResult>();
      var fallbackCalls = 0;

      final request = controller.request(
        requestPermission: () => permission.future,
        presentDeniedFallback: (_) async => fallbackCalls++,
      );

      expect(coordinator.activeSurface, PromptSurface.notificationPermission);
      permission.complete(NotificationPermissionResult.granted);

      expect(await request, isTrue);
      expect(fallbackCalls, 0);
      expect(coordinator.activeSurface, isNull);
    },
  );

  test(
    'settings denied fallback retains its lease until it is dismissed',
    () async {
      final coordinator = PromptCoordinator();
      final controller = NotificationPermissionSettingsRequestController(
        coordinator,
      );
      final dismissed = Completer<void>();
      NotificationPermissionResult? fallbackPermission;

      final request = controller.request(
        requestPermission: () async =>
            NotificationPermissionResult.permanentlyDenied,
        presentDeniedFallback: (permission) {
          fallbackPermission = permission;
          return dismissed.future;
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        fallbackPermission,
        NotificationPermissionResult.permanentlyDenied,
      );
      expect(coordinator.activeSurface, PromptSurface.notificationPermission);

      dismissed.complete();
      expect(await request, isTrue);
      expect(coordinator.activeSurface, isNull);
    },
  );

  test(
    'settings request skips while another prompt or quiet period is active',
    () async {
      var now = DateTime.utc(2026, 7, 28, 12);
      final coordinator = PromptCoordinator(now: () => now);
      final reviewLease = coordinator.tryAcquire(PromptSurface.review)!;
      final controller = NotificationPermissionSettingsRequestController(
        coordinator,
        quietPeriod: () => const Duration(seconds: 120),
      );
      var permissionCalls = 0;

      Future<bool> request() => controller.request(
        requestPermission: () async {
          permissionCalls++;
          return NotificationPermissionResult.granted;
        },
        presentDeniedFallback: (_) async {},
      );

      expect(await request(), isFalse);
      expect(permissionCalls, 0);
      expect(coordinator.activeSurface, PromptSurface.review);

      reviewLease.release();
      expect(await request(), isFalse);
      expect(permissionCalls, 0);

      now = now.add(const Duration(seconds: 120));
      expect(await request(), isTrue);
      expect(permissionCalls, 1);
    },
  );

  test(
    'settings failure or duplicate request releases the lease fail-open',
    () async {
      final coordinator = PromptCoordinator();
      final controller = NotificationPermissionSettingsRequestController(
        coordinator,
      );
      final completion = Completer<NotificationPermissionResult>();
      var permissionCalls = 0;

      final first = controller.request(
        requestPermission: () {
          permissionCalls++;
          return completion.future;
        },
        presentDeniedFallback: (_) async {},
      );
      expect(
        await controller.request(
          requestPermission: () async {
            permissionCalls++;
            return NotificationPermissionResult.granted;
          },
          presentDeniedFallback: (_) async {},
        ),
        isFalse,
      );
      expect(permissionCalls, 1);

      completion.completeError(StateError('permission API failed'));
      expect(await first, isFalse);
      expect(coordinator.activeSurface, isNull);
      expect(coordinator.tryAcquire(PromptSurface.productFeedback), isNotNull);
    },
  );
}
