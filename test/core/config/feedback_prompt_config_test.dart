import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/feedback_prompt_config.dart';
import 'package:money_fit/core/config/remote_config_service.dart';

void main() {
  test(
    'canonical feedback keys win over legacy remote keys and clamp values',
    () {
      final config = FeedbackPromptConfig.fromRemoteConfig(
        _FakeRemoteConfigReader(
          values: {
            'feedback_prompt_enabled': 1,
            'feedback_prompt_rollout_percent': 100,
            'feedback_prompt_min_install_days': 7,
            'feedback_prompt_min_sessions': 3,
            'feedback_prompt_min_actions': 10,
            'feedback_prompt_min_active_days': 99,
            'feedback_prompt_dismiss_days': 1,
            'feedback_prompt_submitted_days': 120,
            'feedback_prompt_later_days': 30,
            'feedback_prompt_global_cooldown_days': 1,
            'feedback_prompt_engagement_cooldown_days': 99,
            'feedback_prompt_max_shows_180d': 99,
            'feedback_prompt_max_shows_180_days': 1,
            'proactive_fullscreen_quiet_seconds': 999,
            'feedback_prompt_quiet_period_seconds': 30,
          },
          remoteKeys: {
            'feedback_prompt_global_cooldown_days',
            'feedback_prompt_engagement_cooldown_days',
            'feedback_prompt_max_shows_180d',
            'feedback_prompt_max_shows_180_days',
            'proactive_fullscreen_quiet_seconds',
            'feedback_prompt_quiet_period_seconds',
          },
        ),
      );

      expect(config.minActiveDays, 14);
      expect(config.dismissDays, 3);
      expect(config.engagementCooldownDays, 7);
      expect(config.maxShowsPer180Days, 6);
      expect(config.quietPeriodSeconds, 600);
    },
  );

  test(
    'uses a legacy remote key only while its canonical key is not remote',
    () {
      final config = FeedbackPromptConfig.fromRemoteConfig(
        _FakeRemoteConfigReader(
          values: {
            'feedback_prompt_enabled': 0,
            'feedback_prompt_rollout_percent': 0,
            'feedback_prompt_min_install_days': 7,
            'feedback_prompt_min_sessions': 3,
            'feedback_prompt_min_actions': 10,
            'feedback_prompt_min_active_days': 3,
            'feedback_prompt_later_days': 30,
            'feedback_prompt_dismiss_days': 14,
            'feedback_prompt_submitted_days': 120,
            'feedback_prompt_global_cooldown_days': 30,
            'feedback_prompt_engagement_cooldown_days': 45,
            'feedback_prompt_max_shows_180d': 3,
            'feedback_prompt_max_shows_180_days': 4,
            'proactive_fullscreen_quiet_seconds': 120,
            'feedback_prompt_quiet_period_seconds': 240,
          },
          remoteKeys: {
            'feedback_prompt_engagement_cooldown_days',
            'feedback_prompt_max_shows_180_days',
            'feedback_prompt_quiet_period_seconds',
          },
        ),
      );

      expect(config.engagementCooldownDays, 45);
      expect(config.maxShowsPer180Days, 4);
      expect(config.quietPeriodSeconds, 240);
    },
  );
}

class _FakeRemoteConfigReader implements RemoteConfigReader {
  _FakeRemoteConfigReader({required this.values, required this.remoteKeys});

  final Map<String, Object> values;
  final Set<String> remoteKeys;

  @override
  bool boolValue(String key) => values[key] == true || values[key] == 1;

  @override
  int intValue(String key) => values[key] as int? ?? 0;

  @override
  bool isRemoteValue(String key) => remoteKeys.contains(key);

  @override
  String stringValue(String key) => values[key] as String? ?? '';
}
