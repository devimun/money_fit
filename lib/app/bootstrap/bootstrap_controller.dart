import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/app/composition/feedback_providers.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/app/bootstrap/optional_remote_capabilities.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/ledger/application/ledger_currency_provider.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// Coordinates startup around the data needed to safely select a route.
/// Optional SDKs are started only after the local application is ready.
class BootstrapController {
  BootstrapController(this._ref);

  final Ref _ref;
  Future<BootstrapOutcome>? _startFuture;

  Future<BootstrapOutcome> start() => _startFuture ??= _start();

  Future<BootstrapOutcome> _start() async {
    final gate = _ref.read(bootstrapGateProvider.notifier);
    gate.set(BootstrapGateState.checkingUpdate);
    final environment = _ref.read(appEnvironmentProvider);
    final outcome = await resolveBootstrapOutcome(
      checkForUpdate: () => _checkForUpdate(environment),
      initializeLocalData: () async {
        gate.set(BootstrapGateState.initializing);
        await initializeCriticalLocalState(
          openDatabase: () async {
            await _ref.read(appDatabaseProvider).executor;
          },
          readPreferences: () async {
            _ref.read(appPreferencesProvider);
          },
          loadSession: () => _ref.read(sessionContextProvider.future),
        );
        // Currency is loaded only after the v6 database and stable owner are
        // available; SharedPreferences is never a financial source of truth.
        await _ref.read(ledgerCurrencyCommandsProvider).loadForCurrentOwner();
      },
      hasCurrentBudget: () async =>
          await _ref.read(currentBudgetProvider.future) != null,
    );
    gate.set(outcome.gateState);
    unawaited(
      startOptionalCapabilitiesForOutcome(
        outcome: outcome,
        start: () => _startBestEffortCapabilities(environment),
      ),
    );
    return outcome;
  }

  Future<BootstrapOutcome> retry() {
    _startFuture = null;
    return start();
  }

  Future<UpdateStatus> _checkForUpdate(AppEnvironment environment) async {
    if (!environment.firebase.isAvailable) return UpdateStatus.none;

    try {
      await _ref
          .read(optionalRemoteCapabilitiesProvider)
          .startFirebase(environment);
      final remoteConfig = _ref.read(remoteConfigServiceProvider);
      await remoteConfig.initialize();
      return UpdateService.fetchUpdateStatus(
        environment: environment,
        remoteConfig: remoteConfig,
      );
    } catch (_) {
      // Firebase can be configured but still unavailable while its optional
      // initialization is in progress. Update checks must never block local UI.
      return UpdateStatus.none;
    }
  }

  Future<void> _startBestEffortCapabilities(AppEnvironment environment) async {
    await Future.wait([
      _ignoreFailure(() => _startRemoteCapabilities(environment)),
      _ignoreFailure(
        () => _ref.read(notificationSchedulerProvider).initialize(),
      ),
      _ignoreFailure(() => _ref.read(feedbackPromptStartupProvider)()),
    ]);
    // The policy reader consumes the Remote Config snapshot initialized above.
    // Advertising remains optional: an SDK, consent, or policy failure cannot
    // affect the already usable local application.
    await _ignoreFailure(() => _ref.read(monetizationStartupProvider)());
  }

  Future<void> _startRemoteCapabilities(AppEnvironment environment) async {
    await _ref.read(optionalRemoteCapabilitiesProvider).start(environment);
    await _ref.read(remoteConfigServiceProvider).initialize();
    await _ref.read(analyticsRuntimeProvider).start();
  }

  Future<void> _ignoreFailure(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}

final bootstrapControllerProvider = Provider<BootstrapController>(
  BootstrapController.new,
);

typedef BootstrapUpdateCheck = Future<UpdateStatus> Function();
typedef BootstrapLocalInitializer = Future<void> Function();
typedef BootstrapBudgetCheck = Future<bool> Function();
typedef BootstrapCriticalStep = Future<void> Function();

/// The explicit result of the startup sequence, independent from presentation.
///
/// Remote update checks are advisory unless they positively report a forced
/// update. Local initialization is the only part that can route to recovery.
enum BootstrapOutcome { forceUpdate, needsSetup, ready, recoverableFailure }

extension BootstrapOutcomeGate on BootstrapOutcome {
  BootstrapGateState get gateState => switch (this) {
    BootstrapOutcome.forceUpdate => BootstrapGateState.forceUpdate,
    BootstrapOutcome.needsSetup => BootstrapGateState.needsSetup,
    BootstrapOutcome.ready => BootstrapGateState.ready,
    BootstrapOutcome.recoverableFailure =>
      BootstrapGateState.recoverableFailure,
  };

  bool get startsOptionalCapabilities => switch (this) {
    BootstrapOutcome.needsSetup || BootstrapOutcome.ready => true,
    BootstrapOutcome.forceUpdate ||
    BootstrapOutcome.recoverableFailure => false,
  };
}

Future<BootstrapOutcome> resolveBootstrapOutcome({
  required BootstrapUpdateCheck checkForUpdate,
  required BootstrapLocalInitializer initializeLocalData,
  required BootstrapBudgetCheck hasCurrentBudget,
}) async {
  try {
    final update = await checkForUpdate();
    if (update.isForceUpdateRequired) return BootstrapOutcome.forceUpdate;
  } catch (_) {
    // Remote Config is optional. Continue with the locally stored state.
  }

  try {
    await initializeLocalData();
    return await hasCurrentBudget()
        ? BootstrapOutcome.ready
        : BootstrapOutcome.needsSetup;
  } catch (_) {
    return BootstrapOutcome.recoverableFailure;
  }
}

/// Runs optional work only once local bootstrap has selected a usable route.
///
/// The callback is intentionally fail-open so callers can safely detach it
/// from the critical startup path.
Future<void> startOptionalCapabilitiesForOutcome({
  required BootstrapOutcome outcome,
  required Future<void> Function() start,
}) async {
  if (!outcome.startsOptionalCapabilities) return;
  try {
    await start();
  } catch (_) {
    // A remote integration cannot turn a ready local application into failure.
  }
}

/// Opens the locally owned state in the only safe startup order.
///
/// The database must be migrated before preferences can select a persisted
/// owner, and the owner must resolve before budget setup is evaluated.  This
/// small boundary also gives host tests evidence for the critical startup
/// sequence without loading platform SDKs.
Future<void> initializeCriticalLocalState({
  required BootstrapCriticalStep openDatabase,
  required BootstrapCriticalStep readPreferences,
  required BootstrapCriticalStep loadSession,
}) async {
  await openDatabase();
  await readPreferences();
  await loadSession();
}
