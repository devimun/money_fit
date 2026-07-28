import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/home/application/home_projection.dart';
import 'package:money_fit/features/home/view/home_screen.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'Home permanent denial keeps the notification lease through settings handoff',
    (tester) async {
      final coordinator = PromptCoordinator();
      final harness = await _pumpHome(tester, coordinator: coordinator);
      final notification = harness.notification;

      expect(
        find.text("We'll help you remember to log your expenses"),
        findsOneWidget,
      );
      expect(coordinator.activeSurface, PromptSurface.notificationPermission);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes, please'));
      await tester.pumpAndSettle();

      expect(notification.enableCalls, 1);
      expect(find.text('Notification Permission Required'), findsOneWidget);
      expect(notification.openSettingsCalls, 0);
      expect(coordinator.activeSurface, PromptSurface.notificationPermission);

      await tester.tap(find.text('Go to Settings'));
      await tester.pump();

      expect(notification.openSettingsCalls, 1);
      expect(coordinator.activeSurface, PromptSurface.notificationPermission);

      notification.settingsCompletion.complete();
      await tester.pump();

      expect(coordinator.activeSurface, isNull);
    },
  );

  testWidgets('Home permanent-denied fallback requires an explicit decision', (
    tester,
  ) async {
    final coordinator = PromptCoordinator();
    final harness = await _pumpHome(tester, coordinator: coordinator);
    final notification = harness.notification;

    await tester.tap(find.widgetWithText(ElevatedButton, 'Yes, please'));
    await tester.pumpAndSettle();
    expect(find.text('Notification Permission Required'), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.text('Notification Permission Required'), findsOneWidget);
    expect(notification.openSettingsCalls, 0);
    expect(coordinator.activeSurface, PromptSurface.notificationPermission);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(notification.openSettingsCalls, 0);
    expect(coordinator.activeSurface, isNull);
  });

  testWidgets(
    'Home settings handoff failure releases the notification lease fail-open',
    (tester) async {
      final coordinator = PromptCoordinator();
      final harness = await _pumpHome(tester, coordinator: coordinator);
      final notification = harness.notification;

      await tester.tap(find.widgetWithText(ElevatedButton, 'Yes, please'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to Settings'));
      await tester.pump();

      notification.settingsCompletion.completeError(StateError('settings'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(coordinator.activeSurface, isNull);
    },
  );

  testWidgets(
    'Home notification onboarding skips while another prompt owns lease',
    (tester) async {
      final coordinator = PromptCoordinator();
      final reviewLease = coordinator.tryAcquire(PromptSurface.review)!;
      final harness = await _pumpHome(tester, coordinator: coordinator);

      expect(
        find.text("We'll help you remember to log your expenses"),
        findsNothing,
      );
      expect(harness.notification.enableCalls, 0);
      expect(coordinator.activeSurface, PromptSurface.review);

      reviewLease.release();
    },
  );
}

Future<_HomeHarness> _pumpHome(
  WidgetTester tester, {
  required PromptCoordinator coordinator,
}) async {
  final container = ProviderContainer(
    overrides: [
      homeViewModelProvider.overrideWith(_FixedHomeViewModel.new),
      sessionContextProvider.overrideWith(
        (ref) async => const SessionContext(ownerId: 'home-test-owner'),
      ),
      notificationControllerProvider.overrideWith(
        _PermanentDeniedNotificationController.new,
      ),
      promptCoordinatorProvider.overrideWithValue(coordinator),
      remoteConfigReaderProvider.overrideWithValue(const _RemoteReader()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(showNotificationPrompt: true),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  return _HomeHarness(container);
}

class _HomeHarness {
  const _HomeHarness(this._container);

  final ProviderContainer _container;

  _PermanentDeniedNotificationController get notification =>
      _container.read(notificationControllerProvider.notifier)
          as _PermanentDeniedNotificationController;
}

class _FixedHomeViewModel extends HomeViewModel {
  @override
  Future<HomeState> build() async => const HomeState(
    budget: 100,
    dailyBudget: 10,
    monthlyDiscretionarySpending: 0,
    todayExpenseList: <Expense>[],
    monthlyDiscretionaryExpenseAvg: 0,
    consecutiveAchievementDays: 0,
  );
}

class _PermanentDeniedNotificationController extends NotificationController {
  final settingsCompletion = Completer<void>();
  var enableCalls = 0;
  var openSettingsCalls = 0;

  @override
  Future<bool> build() async => false;

  @override
  Future<NotificationPermissionResult> enable(NotificationText text) async {
    enableCalls += 1;
    return NotificationPermissionResult.permanentlyDenied;
  }

  @override
  Future<void> openPermissionSettings() {
    openSettingsCalls += 1;
    return settingsCompletion.future;
  }
}

class _RemoteReader implements RemoteConfigReader {
  const _RemoteReader();

  @override
  bool boolValue(String key) => false;

  @override
  int intValue(String key) => proactiveFullscreenQuietSecondsDefault;

  @override
  bool isRemoteValue(String key) => false;

  @override
  String stringValue(String key) => '';
}
