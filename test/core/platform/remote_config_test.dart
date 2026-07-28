import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/platform/remote_config.dart';

void main() {
  test(
    'one owner installs canonical defaults and falls back per failed key',
    () async {
      final client = _FakeRemoteConfigClient(
        values: {'ads_interstitial_actions_required': 9},
      );
      final service = RemoteConfigService(client);

      await service.initialize();

      expect(client.defaults, remoteConfigDefaults);
      expect(client.fetchTimeout, const Duration(seconds: 10));
      expect(client.minimumFetchInterval, const Duration(minutes: 30));
      expect(service.intValue('ads_interstitial_actions_required'), 9);
      client.throwFor.add('ads_interstitial_actions_required');
      expect(service.intValue('ads_interstitial_actions_required'), 6);
      client.throwFor.add('amplitude_collection_enabled');
      expect(service.boolValue('amplitude_collection_enabled'), isTrue);
      await service.dispose();
    },
  );

  test(
    'real-time activation publishes updates without replacing defaults',
    () async {
      final client = _FakeRemoteConfigClient();
      final service = RemoteConfigService(client);
      await service.initialize();
      final update = service.updates.first;

      client.updatesController.add(null);

      await update;
      expect(client.activateCalls, 1);
      expect(service.intValue('ads_interstitial_cooldown_seconds'), 300);
      await service.dispose();
    },
  );
}

class _FakeRemoteConfigClient implements RemoteConfigClient {
  _FakeRemoteConfigClient({Map<String, Object>? values})
    : values = values ?? {};

  final Map<String, Object> values;
  final throwFor = <String>{};
  final updatesController = StreamController<void>.broadcast();
  Map<String, Object>? defaults;
  Duration? fetchTimeout;
  Duration? minimumFetchInterval;
  var activateCalls = 0;

  @override
  Future<bool> activate() async {
    activateCalls += 1;
    return true;
  }

  @override
  bool boolValue(String key) => _read<bool>(key, false);

  @override
  Future<void> configure({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  }) async {
    this.fetchTimeout = fetchTimeout;
    this.minimumFetchInterval = minimumFetchInterval;
  }

  @override
  Future<bool> fetchAndActivate() async => true;

  @override
  int intValue(String key) => _read<int>(key, 0);

  @override
  bool isRemoteValue(String key) => values.containsKey(key);

  @override
  Future<void> setDefaults(Map<String, Object> defaults) async {
    this.defaults = defaults;
    for (final entry in defaults.entries) {
      values.putIfAbsent(entry.key, () => entry.value);
    }
  }

  @override
  String stringValue(String key) => _read<String>(key, '');

  @override
  Stream<void> get updates => updatesController.stream;

  T _read<T>(String key, T fallback) {
    if (throwFor.contains(key)) throw StateError(key);
    return values[key] as T? ?? fallback;
  }
}
