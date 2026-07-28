import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Remote Config only changes the Amplitude switch, not Firebase consent',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final tracker = _RecordingAnalyticsTracker();
      final updates = StreamController<void>.broadcast();
      final remote = _RemoteReader(amplitudeEnabled: false);
      final runtime = AnalyticsRuntime(
        tracker: tracker,
        consent: AnalyticsConsentRepository(preferences),
        remoteConfig: remote,
        remoteUpdates: updates.stream,
      );

      await runtime.start();
      remote.amplitudeEnabled = true;
      updates.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(tracker.collectionEnabled, [true]);
      expect(tracker.amplitudeEnabled, [false, true]);
      expect(tracker.initializeCalls, 1);
      await runtime.dispose();
      await updates.close();
    },
  );

  test(
    'bootstrap synchronizes the local owner before optional analytics starts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final tracker = _RecordingAnalyticsTracker();
      final updates = StreamController<void>.broadcast();
      final runtime = AnalyticsRuntime(
        tracker: tracker,
        consent: AnalyticsConsentRepository(preferences),
        remoteConfig: _RemoteReader(amplitudeEnabled: false),
        remoteUpdates: updates.stream,
      );

      await startAnalyticsForLocalOwner(
        identity: AnalyticsLocalIdentitySynchronizer(tracker),
        runtime: runtime,
        localOwnerId: 'device-local-owner',
      );

      expect(tracker.userIds, ['device-local-owner']);
      expect(tracker.calls, [
        'user:device-local-owner',
        'collection:true',
        'amplitude:false',
        'initialize',
      ]);
      await runtime.dispose();
      await updates.close();
    },
  );

  test(
    'local identity synchronizer clears stale IDs and remains fail-open',
    () async {
      final tracker = _RecordingAnalyticsTracker();
      final synchronizer = AnalyticsLocalIdentitySynchronizer(tracker);

      await synchronizer.synchronize('device-local-owner');
      await synchronizer.synchronize('device-local-owner');
      await synchronizer.synchronize(null);

      expect(tracker.userIds, ['device-local-owner', null]);

      tracker.throwOnSetUserId = true;
      await expectLater(
        synchronizer.synchronize('replacement-owner'),
        completes,
      );
      expect(tracker.userIds, ['device-local-owner', null]);
    },
  );
}

class _RemoteReader implements RemoteConfigReader {
  _RemoteReader({required this.amplitudeEnabled});

  bool amplitudeEnabled;

  @override
  bool boolValue(String key) =>
      key == 'amplitude_collection_enabled' && amplitudeEnabled;

  @override
  int intValue(String key) => 0;

  @override
  bool isRemoteValue(String key) => false;

  @override
  String stringValue(String key) => '';
}

class _RecordingAnalyticsTracker implements AnalyticsTracker {
  final collectionEnabled = <bool>[];
  final amplitudeEnabled = <bool>[];
  final userIds = <String?>[];
  final calls = <String>[];
  var initializeCalls = 0;
  var throwOnSetUserId = false;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
    calls.add('initialize');
  }

  @override
  Future<void> reset() async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {
    amplitudeEnabled.add(enabled);
    calls.add('amplitude:$enabled');
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled.add(enabled);
    calls.add('collection:$enabled');
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (throwOnSetUserId) throw StateError('offline');
    userIds.add(userId);
    calls.add('user:$userId');
  }

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}
}
