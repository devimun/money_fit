import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/session/application/session_context.dart';

void main() {
  test(
    'ready context keeps the local owner independent from remote identity',
    () {
      const context = SessionContext(
        ownerId: 'local-owner',
        remoteUserId: 'remote-account',
      );

      expect(context.ownerId, 'local-owner');
      expect(context.ownerId, isNot(context.remoteUserId));
    },
  );

  test('multiple local users are represented as a recoverable state', () {
    final state = SessionRecoverableFailure(
      StateError('Multiple local users require recovery.'),
      StackTrace.empty,
    );

    expect(state.error, isA<StateError>());
  });
}
