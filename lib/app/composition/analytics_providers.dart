import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// App composition owns SDK construction. Features receive only
/// [RemoteConfigReader] and [AnalyticsTracker] contracts.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  final service = RemoteConfigService(
    FirebaseRemoteConfigClient(() => FirebaseRemoteConfig.instance),
  );
  ref.onDispose(service.dispose);
  return service;
});

final remoteConfigReaderProvider = Provider<RemoteConfigReader>(
  (ref) => ref.watch(remoteConfigServiceProvider),
);

final analyticsConsentRepositoryProvider = Provider<AnalyticsConsentRepository>(
  (ref) => AnalyticsConsentRepository(ref.watch(sharedPreferencesProvider)),
);

/// This provider constructs the concrete tracker but deliberately does not
/// initialize SDKs. [AnalyticsRuntime.start] is called only after optional
/// Firebase startup has completed, preserving local bootstrap fail-open.
final configuredAnalyticsTrackerProvider = Provider<AnalyticsTracker>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final consent = ref.watch(analyticsConsentRepositoryProvider);
  return DualAnalyticsTracker(
    environment.analytics,
    firebase: FirebaseAnalyticsSdkClient(() => FirebaseAnalytics.instance),
    collectionEnabled: consent.isEnabled,
  );
});

final analyticsRuntimeProvider = Provider<AnalyticsRuntime>((ref) {
  final runtime = AnalyticsRuntime(
    tracker: ref.read(configuredAnalyticsTrackerProvider),
    consent: ref.read(analyticsConsentRepositoryProvider),
    remoteConfig: ref.read(remoteConfigReaderProvider),
    remoteUpdates: ref.read(remoteConfigServiceProvider).updates,
  );
  ref.onDispose(runtime.dispose);
  return runtime;
});

/// Keeps the SDK-facing analytics identity tied only to the durable local
/// ledger owner. In particular, a linked remote account is intentionally not
/// used here: it may be an external identifier and it must never cross this
/// analytics boundary.
final analyticsLocalIdentitySynchronizerProvider =
    Provider<AnalyticsLocalIdentitySynchronizer>((ref) {
      final synchronizer = AnalyticsLocalIdentitySynchronizer(
        ref.read(analyticsTrackerProvider),
      );
      ref.listen<AsyncValue<SessionState>>(sessionProvider, (_, next) {
        final localOwnerId = switch (next.valueOrNull) {
          SessionReady(:final context) => context.ownerId,
          _ => null,
        };
        unawaited(synchronizer.synchronize(localOwnerId));
      });
      return synchronizer;
    });

/// Serializes local-owner changes into the consent-aware analytics facade.
///
/// The first synchronization is awaited by bootstrap before analytics SDKs
/// initialize. Later session transitions are best-effort so an analytics
/// failure cannot prevent a local owner reset or recovery.
class AnalyticsLocalIdentitySynchronizer {
  AnalyticsLocalIdentitySynchronizer(this._tracker);

  final AnalyticsTracker _tracker;
  String? _lastSynchronizedOwnerId;

  Future<void> synchronize(String? localOwnerId) async {
    final normalizedOwnerId = localOwnerId?.trim();
    final nextOwnerId = normalizedOwnerId == null || normalizedOwnerId.isEmpty
        ? null
        : normalizedOwnerId;
    if (_lastSynchronizedOwnerId == nextOwnerId) return;
    try {
      await _tracker.setUserId(nextOwnerId);
      _lastSynchronizedOwnerId = nextOwnerId;
    } catch (_) {
      // Analytics identity is observational and must remain fail-open.
    }
  }
}

/// Starts analytics only after the local owner is known. This preserves the
/// source release's user-identification behavior while allowing the optional
/// SDK runtime to initialize after critical local bootstrap.
Future<void> startAnalyticsForLocalOwner({
  required AnalyticsLocalIdentitySynchronizer identity,
  required AnalyticsRuntime runtime,
  required String localOwnerId,
}) async {
  await identity.synchronize(localOwnerId);
  await runtime.start();
}

/// Owns the small amount of analytics lifecycle state that must respond to
/// Remote Config updates without allowing a feature to overwrite Firebase
/// collection consent.
class AnalyticsRuntime {
  AnalyticsRuntime({
    required AnalyticsTracker tracker,
    required AnalyticsConsentRepository consent,
    required RemoteConfigReader remoteConfig,
    required Stream<void> remoteUpdates,
  }) : _tracker = tracker,
       _consent = consent,
       _remoteConfig = remoteConfig,
       _remoteUpdates = remoteUpdates;

  final AnalyticsTracker _tracker;
  final AnalyticsConsentRepository _consent;
  final RemoteConfigReader _remoteConfig;
  final Stream<void> _remoteUpdates;
  StreamSubscription<void>? _updatesSubscription;
  Future<void>? _startFuture;

  Future<void> start() => _startFuture ??= _start();

  Future<void> _start() async {
    await _tracker.setCollectionEnabled(_consent.isEnabled);
    await _tracker.setAmplitudeCollectionEnabled(
      _remoteConfig.boolValue('amplitude_collection_enabled'),
    );
    await _tracker.initialize();
    _updatesSubscription = _remoteUpdates.listen((_) {
      unawaited(
        _tracker.setAmplitudeCollectionEnabled(
          _remoteConfig.boolValue('amplitude_collection_enabled'),
        ),
      );
    });
  }

  Future<void> dispose() async {
    await _updatesSubscription?.cancel();
  }
}
