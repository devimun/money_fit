import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
