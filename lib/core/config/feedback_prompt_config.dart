import 'package:money_fit/core/config/remote_config_service.dart';

class FeedbackPromptConfig {
  const FeedbackPromptConfig({
    required this.enabled,
    required this.rolloutPercent,
    required this.minInstallDays,
    required this.minSessions,
    required this.minActions,
    required this.minActiveDays,
  });
  final bool enabled;
  final int rolloutPercent;
  final int minInstallDays;
  final int minSessions;
  final int minActions;
  final int minActiveDays;

  factory FeedbackPromptConfig.fromRemoteConfig(
    RemoteConfigService remote,
  ) => FeedbackPromptConfig(
    enabled: remote.boolValue('feedback_prompt_enabled'),
    rolloutPercent: remote
        .intValue('feedback_prompt_rollout_percent')
        .clamp(0, 100),
    minInstallDays: remote
        .intValue('feedback_prompt_min_install_days')
        .clamp(3, 60),
    minSessions: remote.intValue('feedback_prompt_min_sessions').clamp(2, 30),
    minActions: remote.intValue('feedback_prompt_min_actions').clamp(5, 100),
    minActiveDays: remote
        .intValue('feedback_prompt_min_active_days')
        .clamp(2, 30),
  );
}
