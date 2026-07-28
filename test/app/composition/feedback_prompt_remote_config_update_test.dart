import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/feedback_providers.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_config.dart';

void main() {
  test(
    'feedback prompt policy rebuilds after a Remote Config activation',
    () async {
      final client = _RemoteConfigClient(
        values: {'feedback_prompt_enabled': true},
        remoteKeys: {'feedback_prompt_enabled'},
      );
      final service = RemoteConfigService(client);
      await service.initialize();
      final container = ProviderContainer(
        overrides: [remoteConfigServiceProvider.overrideWithValue(service)],
      );
      addTearDown(() async {
        container.dispose();
        await service.dispose();
        await client.dispose();
      });

      expect(container.read(feedbackPromptConfigProvider).enabled, isTrue);

      final updated = Completer<FeedbackPromptConfig>();
      final subscription = container.listen<FeedbackPromptConfig>(
        feedbackPromptConfigProvider,
        (_, next) {
          if (!next.enabled && !updated.isCompleted) updated.complete(next);
        },
      );
      addTearDown(subscription.close);
      client.values['feedback_prompt_enabled'] = false;
      client.updatesController.add(null);

      expect((await updated.future).enabled, isFalse);
    },
  );
}

class _RemoteConfigClient implements RemoteConfigClient {
  _RemoteConfigClient({required this.values, required this.remoteKeys});

  final Map<String, Object> values;
  final Set<String> remoteKeys;
  final updatesController = StreamController<void>.broadcast();

  @override
  Future<bool> activate() async => true;

  @override
  bool boolValue(String key) => values[key] as bool;

  @override
  Future<void> configure({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  }) async {}

  @override
  Future<bool> fetchAndActivate() async => true;

  @override
  int intValue(String key) => values[key] as int;

  @override
  bool isRemoteValue(String key) => remoteKeys.contains(key);

  @override
  Future<void> setDefaults(Map<String, Object> defaults) async {
    for (final entry in defaults.entries) {
      values.putIfAbsent(entry.key, () => entry.value);
    }
  }

  @override
  String stringValue(String key) => values[key] as String;

  @override
  Stream<void> get updates => updatesController.stream;

  Future<void> dispose() => updatesController.close();
}
