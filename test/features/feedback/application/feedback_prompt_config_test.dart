import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_config.dart';

void main() {
  test(
    'uses canonical local defaults for every invalid remote policy value',
    () {
      final config = FeedbackPromptConfig.fromRemoteConfig(
        _RemoteValues(
          values: const {
            'feedback_prompt_enabled': true,
            'feedback_prompt_rollout_percent': 123,
            'feedback_prompt_min_install_days': -1,
            'feedback_prompt_min_sessions': 31,
            'feedback_prompt_min_actions': 4,
            'feedback_prompt_min_active_days': 15,
            'feedback_prompt_later_days': 6,
            'feedback_prompt_dismiss_days': 91,
            'feedback_prompt_submitted_days': 29,
            'feedback_prompt_max_shows_180d': 7,
            'feedback_prompt_max_shows_180_days': 1,
            'feedback_prompt_global_cooldown_days': 366,
            'feedback_prompt_engagement_cooldown_days': 7,
            'proactive_fullscreen_quiet_seconds': 20,
            'feedback_prompt_quiet_period_seconds': 30,
            'feedback_prompt_policy_version': 'not valid!',
          },
          remoteKeys: const {
            'feedback_prompt_enabled',
            'feedback_prompt_rollout_percent',
            'feedback_prompt_min_install_days',
            'feedback_prompt_min_sessions',
            'feedback_prompt_min_actions',
            'feedback_prompt_min_active_days',
            'feedback_prompt_later_days',
            'feedback_prompt_dismiss_days',
            'feedback_prompt_submitted_days',
            'feedback_prompt_max_shows_180d',
            'feedback_prompt_global_cooldown_days',
            'proactive_fullscreen_quiet_seconds',
            'feedback_prompt_policy_version',
          },
        ),
      );

      expect(config.enabled, isTrue);
      expect(config.rolloutPercent, 0);
      expect(config.minInstallDays, 7);
      expect(config.minSessions, 3);
      expect(config.minActions, 10);
      expect(config.minActiveDays, 3);
      expect(config.laterDays, 30);
      expect(config.dismissDays, 14);
      expect(config.submittedDays, 120);
      expect(config.maxShowsPer180Days, 3);
      expect(config.engagementCooldownDays, 30);
      expect(config.quietPeriodSeconds, 120);
      expect(config.policyVersion, 'feedback_v1');
    },
  );

  test('uses a published legacy key only when its canonical key is local', () {
    final config = FeedbackPromptConfig.fromRemoteConfig(
      _RemoteValues(
        values: const {
          'feedback_prompt_enabled': true,
          'feedback_prompt_max_shows_180d': 3,
          'feedback_prompt_max_shows_180_days': 5,
          'feedback_prompt_engagement_cooldown_days': 42,
          'feedback_prompt_quiet_period_seconds': 90,
        },
        remoteKeys: const {
          'feedback_prompt_max_shows_180_days',
          'feedback_prompt_engagement_cooldown_days',
          'feedback_prompt_quiet_period_seconds',
        },
      ),
    );

    expect(config.maxShowsPer180Days, 5);
    expect(config.engagementCooldownDays, 42);
    expect(config.quietPeriodSeconds, 90);
  });

  test(
    'uses the canonical quiet-period fallback for an invalid legacy value',
    () {
      final config = FeedbackPromptConfig.fromRemoteConfig(
        _RemoteValues(
          values: const {'feedback_prompt_quiet_period_seconds': 601},
          remoteKeys: const {'feedback_prompt_quiet_period_seconds'},
        ),
      );

      expect(config.quietPeriodSeconds, proactiveFullscreenQuietSecondsDefault);
    },
  );
}

class _RemoteValues implements RemoteConfigReader {
  const _RemoteValues({required this.values, this.remoteKeys = const {}});

  final Map<String, Object> values;
  final Set<String> remoteKeys;

  @override
  bool boolValue(String key) => values[key] as bool? ?? false;

  @override
  int intValue(String key) => values[key] as int? ?? 0;

  @override
  String stringValue(String key) => values[key] as String? ?? '';

  @override
  bool isRemoteValue(String key) => remoteKeys.contains(key);
}
