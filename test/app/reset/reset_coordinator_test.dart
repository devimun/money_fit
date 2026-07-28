import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/app/reset/reset_coordinator.dart';
import 'package:money_fit/app/router/app_router.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';

void main() {
  for (final expectation in <(ResetScope, List<String>)>[
    (
      ResetScope.localData,
      ['local-data', 'data-reset', 'session', 'invalidate'],
    ),
    (ResetScope.preferences, ['preferences', 'invalidate']),
    (ResetScope.session, ['session', 'invalidate']),
    (ResetScope.notifications, ['notifications', 'invalidate']),
    (ResetScope.engagement, ['engagement', 'invalidate']),
    (
      ResetScope.all,
      [
        'local-data',
        'data-reset',
        'preferences',
        'notifications',
        'engagement',
        'session',
        'in-process-engagement',
        'invalidate',
        'bootstrap',
      ],
    ),
  ]) {
    test(
      '${expectation.$1.name} executes only its declared reset boundary',
      () async {
        final calls = <String>[];

        await runResetScope(
          scope: expectation.$1,
          operations: _operations(calls),
        );

        expect(calls, expectation.$2);
      },
    );
  }

  test(
    'failed persistent reset does not invalidate stale derived state',
    () async {
      final calls = <String>[];

      await expectLater(
        runResetScope(
          scope: ResetScope.localData,
          operations: _operations(calls, failingOperation: 'local-data'),
        ),
        throwsStateError,
      );

      expect(calls, ['local-data']);
    },
  );

  test(
    'data-reset telemetry is fail-open after a successful database reset',
    () async {
      final calls = <String>[];

      await runResetScope(
        scope: ResetScope.localData,
        operations: _operations(calls, failingOperation: 'data-reset'),
      );

      expect(calls, ['local-data', 'data-reset', 'session', 'invalidate']);
    },
  );

  test('a failed full reset never re-enters bootstrap', () async {
    final calls = <String>[];

    await expectLater(
      runResetScope(
        scope: ResetScope.all,
        operations: _operations(calls, failingOperation: 'session'),
      ),
      throwsStateError,
    );

    expect(calls, [
      'local-data',
      'data-reset',
      'preferences',
      'notifications',
      'engagement',
      'session',
    ]);
  });

  testWidgets(
    'a successful full reset redirects protected Home and Settings routes to setup',
    (tester) async {
      for (final origin in const ['/home', '/settings']) {
        final gate = ValueNotifier(BootstrapGateState.ready);
        final router = _router(gate, origin);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        expect(find.text(origin), findsOneWidget);

        await runResetScope(
          scope: ResetScope.all,
          operations: _operations(
            <String>[],
            reenterBootstrap: () async {
              gate.value = BootstrapGateState.needsSetup;
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('budget-setup'), findsOneWidget);
        expect(find.text(origin), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        gate.dispose();
      }
    },
  );

  testWidgets('partial reset keeps the current protected route', (
    tester,
  ) async {
    final gate = ValueNotifier(BootstrapGateState.ready);
    final router = _router(gate, '/settings');
    addTearDown(router.dispose);
    addTearDown(gate.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await runResetScope(
      scope: ResetScope.notifications,
      operations: _operations(<String>[]),
    );
    await tester.pumpAndSettle();

    expect(find.text('/settings'), findsOneWidget);
    expect(gate.value, BootstrapGateState.ready);
  });
}

ResetOperations _operations(
  List<String> calls, {
  String? failingOperation,
  Future<void> Function()? reenterBootstrap,
}) => ResetOperations(
  resetLocalData: _operation(calls, 'local-data', failingOperation),
  recordDataReset: _operation(calls, 'data-reset', failingOperation),
  clearPreferences: _operation(calls, 'preferences', failingOperation),
  clearSession: _operation(calls, 'session', failingOperation),
  cancelNotifications: _operation(calls, 'notifications', failingOperation),
  clearEngagement: _operation(calls, 'engagement', failingOperation),
  resetInProcessEngagement: _operation(
    calls,
    'in-process-engagement',
    failingOperation,
  ),
  invalidateDependentState: _operation(calls, 'invalidate', failingOperation),
  reenterBootstrap:
      reenterBootstrap ?? _operation(calls, 'bootstrap', failingOperation),
);

GoRouter _router(ValueNotifier<BootstrapGateState> gate, String initialPath) =>
    GoRouter(
      initialLocation: initialPath,
      refreshListenable: gate,
      redirect: (context, state) =>
          redirectForBootstrapGate(gate.value, state.uri),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('/home')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('/settings')),
        ),
        GoRoute(
          path: '/budget_setup',
          builder: (context, state) =>
              const Scaffold(body: Text('budget-setup')),
        ),
      ],
    );

Future<void> Function() _operation(
  List<String> calls,
  String name,
  String? failingOperation,
) => () async {
  calls.add(name);
  if (name == failingOperation) throw StateError(name);
};
