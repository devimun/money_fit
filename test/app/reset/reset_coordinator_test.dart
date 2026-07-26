import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/reset/reset_coordinator.dart';

void main() {
  for (final expectation in <(ResetScope, List<String>)>[
    (ResetScope.localData, ['local-data', 'session', 'invalidate']),
    (ResetScope.preferences, ['preferences', 'invalidate']),
    (ResetScope.session, ['session', 'invalidate']),
    (ResetScope.notifications, ['notifications', 'invalidate']),
    (ResetScope.engagement, ['engagement', 'invalidate']),
    (
      ResetScope.all,
      [
        'local-data',
        'preferences',
        'notifications',
        'engagement',
        'session',
        'invalidate',
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
}

ResetOperations _operations(List<String> calls, {String? failingOperation}) =>
    ResetOperations(
      resetLocalData: _operation(calls, 'local-data', failingOperation),
      clearPreferences: _operation(calls, 'preferences', failingOperation),
      clearSession: _operation(calls, 'session', failingOperation),
      cancelNotifications: _operation(calls, 'notifications', failingOperation),
      clearEngagement: _operation(calls, 'engagement', failingOperation),
      invalidateDependentState: _operation(
        calls,
        'invalidate',
        failingOperation,
      ),
    );

Future<void> Function() _operation(
  List<String> calls,
  String name,
  String? failingOperation,
) => () async {
  calls.add(name);
  if (name == failingOperation) throw StateError(name);
};
