import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/router/app_routes.dart';
import 'package:money_fit/app/router/app_router.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';

void main() {
  test(
    'protected routes redirect to the update gate before bootstrap is ready',
    () {
      for (final path in const [
        '/home',
        '/calendar',
        '/stats',
        '/expense_list',
        '/settings',
      ]) {
        final destination = Uri.parse(
          redirectForBootstrapGate(
            BootstrapGateState.checkingUpdate,
            Uri.parse(path),
          )!,
        );
        expect(destination.path, '/update-check');
        expect(destination.queryParameters['from'], path);
      }
    },
  );

  test('ready bootstrap restores the requested protected route', () {
    expect(
      redirectForBootstrapGate(
        BootstrapGateState.ready,
        Uri.parse('/?from=%2Fcalendar'),
      ),
      '/calendar',
    );
  });

  test('typed home arguments encode and decode the notification prompt', () {
    final location = AppRoutes.home(
      const HomeRouteArguments(showNotificationPrompt: true),
    );

    expect(location, '/home?showNotificationPrompt=true');
    expect(
      HomeRouteArguments.fromUri(Uri.parse(location)).showNotificationPrompt,
      isTrue,
    );
    expect(
      HomeRouteArguments.fromUri(
        Uri.parse('/home?showNotificationPrompt=1'),
      ).showNotificationPrompt,
      isFalse,
    );
  });

  test('bootstrap return target preserves local query routes only', () {
    final returnTo = AppRouteReturnTarget.tryParse(
      '/home?showNotificationPrompt=true',
    );

    expect(
      AppRoutes.withBootstrapReturnTo(AppRoutes.updateCheck, returnTo),
      '/update-check?from=%2Fhome%3FshowNotificationPrompt%3Dtrue',
    );
    expect(AppRouteReturnTarget.tryParse('https://example.com'), isNull);
  });

  test('setup, force-update, and failure states gate protected routes', () {
    for (final expectation in [
      (BootstrapGateState.needsSetup, '/budget_setup'),
      (BootstrapGateState.forceUpdate, '/update-check'),
      (BootstrapGateState.recoverableFailure, '/bootstrap-failure'),
    ]) {
      expect(
        Uri.parse(
          redirectForBootstrapGate(expectation.$1, Uri.parse('/settings'))!,
        ).path,
        expectation.$2,
      );
    }
  });

  test('disabled Firebase uses no router analytics observer', () {
    final container = ProviderContainer(
      overrides: [
        appEnvironmentProvider.overrideWithValue(AppEnvironment.test()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(appRouterObserversProvider), isEmpty);
  });

  testWidgets('analytics observer ignores an unavailable Firebase app', (
    tester,
  ) async {
    final observer = FailOpenFirebaseAnalyticsObserver(
      analytics: () => throw StateError('Firebase not initialized'),
      nameExtractor: (settings) => settings.name,
    );
    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'HomeScreen'),
      builder: (_) => const SizedBox(),
    );

    observer.didPush(route, null);
    await tester.pump();
  });
}
