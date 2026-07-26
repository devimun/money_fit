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
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    final gate = _ref.read(bootstrapGateProvider.notifier);
    gate.set(BootstrapGateState.checkingUpdate);
    try {
      UpdateStatus update = UpdateStatus.none;
      try {
        update = await UpdateService.fetchUpdateStatus(
          environment: _ref.read(appEnvironmentProvider),
          remoteConfig: FirebaseRemoteConfig.instance,
        );
      } catch (_) {
        // Remote Config is observational; a local session can still start.
      }
      if (update.isForceUpdateRequired) {
        gate.set(BootstrapGateState.forceUpdate);
        return;
      }

      gate.set(BootstrapGateState.initializing);
      await _ref.read(appDatabaseProvider).executor;
      _ref.read(appPreferencesProvider);
      await _ref.read(sessionContextProvider.future);
      final budget = await _ref.read(currentBudgetProvider.future);
      gate.set(
        budget == null
            ? BootstrapGateState.needsSetup
            : BootstrapGateState.ready,
      );
      unawaited(_startBestEffortCapabilities());
    } catch (_) {
      gate.set(BootstrapGateState.recoverableFailure);
    }
  }

  Future<void> retry() {
    _started = false;
    return start();
  }

  Future<void> _startBestEffortCapabilities() async {
    await Future.wait([
      _ignoreFailure(() => _ref.read(notificationServiceProvider).init()),
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
