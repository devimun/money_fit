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
  var initializeCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> reset() async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {
    amplitudeEnabled.add(enabled);
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled.add(enabled);
  }

  @override
  Future<void> setUserId(String? userId) async {}

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
