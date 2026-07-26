import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
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
        await _ref.read(appDatabaseProvider).executor;
        _ref.read(appPreferencesProvider);
        await _ref.read(sessionContextProvider.future);
      },
      hasCurrentBudget: () async =>
          await _ref.read(currentBudgetProvider.future) != null,
    );
    gate.set(outcome.gateState);
    if (outcome.startsOptionalCapabilities) {
      unawaited(_startBestEffortCapabilities());
    }
    return outcome;
  }

  Future<BootstrapOutcome> retry() {
    _startFuture = null;
    return start();
  }

  Future<UpdateStatus> _checkForUpdate(AppEnvironment environment) async {
    if (!environment.firebase.isAvailable) return UpdateStatus.none;

    try {
      return UpdateService.fetchUpdateStatus(
        environment: environment,
        remoteConfig: FirebaseRemoteConfig.instance,
      );
    } catch (_) {
      // Firebase can be configured but still unavailable while its optional
      // initialization is in progress. Update checks must never block local UI.
      return UpdateStatus.none;
    }
  }

  Future<void> _startBestEffortCapabilities() async {
    await Future.wait([
      _ignoreFailure(
        () => _ref.read(notificationSchedulerProvider).initialize(),
      ),
      _ignoreFailure(AdService.initialize),
      _ignoreFailure(InterstitialAdManager.instance.loadAd),
    ]);
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
