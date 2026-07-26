import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/bootstrap/bootstrap_controller.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';

void main() {
  test('a forced update stops before local initialization', () async {
    var localInitialized = false;

    final outcome = await resolveBootstrapOutcome(
      checkForUpdate: () async => _forceUpdate(),
      initializeLocalData: () async => localInitialized = true,
      hasCurrentBudget: () async => true,
    );

    expect(outcome, BootstrapOutcome.forceUpdate);
    expect(localInitialized, isFalse);
  });

  test(
    'a remote update failure still starts a ready local application',
    () async {
      final outcome = await resolveBootstrapOutcome(
        checkForUpdate: () => Future<UpdateStatus>.error(StateError('offline')),
        initializeLocalData: () async {},
        hasCurrentBudget: () async => true,
      );

      expect(outcome, BootstrapOutcome.ready);
    },
  );

  test('a missing budget routes to setup after local initialization', () async {
    final outcome = await resolveBootstrapOutcome(
      checkForUpdate: () async => UpdateStatus.none,
      initializeLocalData: () async {},
      hasCurrentBudget: () async => false,
    );

    expect(outcome, BootstrapOutcome.needsSetup);
  });

  test('a local initialization failure is recoverable', () async {
    var budgetChecked = false;

    final outcome = await resolveBootstrapOutcome(
      checkForUpdate: () async => UpdateStatus.none,
      initializeLocalData: () => Future<void>.error(StateError('database')),
      hasCurrentBudget: () async {
        budgetChecked = true;
        return true;
      },
    );

    expect(outcome, BootstrapOutcome.recoverableFailure);
    expect(budgetChecked, isFalse);
  });

  test(
    'critical local bootstrap opens database before owner resolution',
    () async {
      final calls = <String>[];

      await initializeCriticalLocalState(
        openDatabase: () async => calls.add('database'),
        readPreferences: () async => calls.add('preferences'),
        loadSession: () async => calls.add('session'),
      );

      expect(calls, ['database', 'preferences', 'session']);
    },
  );

  test('session resolution failure prevents setup status evaluation', () async {
    var budgetChecked = false;

    final outcome = await resolveBootstrapOutcome(
      checkForUpdate: () async => UpdateStatus.none,
      initializeLocalData: () => initializeCriticalLocalState(
        openDatabase: () async {},
        readPreferences: () async {},
        loadSession: () => Future<void>.error(StateError('session')),
      ),
      hasCurrentBudget: () async {
        budgetChecked = true;
        return true;
      },
    );

    expect(outcome, BootstrapOutcome.recoverableFailure);
    expect(budgetChecked, isFalse);
  });
}

UpdateStatus _forceUpdate() => const UpdateStatus(
  isForceUpdateRequired: true,
  isUpdateRecommended: false,
  messageToDisplay: '',
  storeUri: null,
  changelogLines: [],
);
