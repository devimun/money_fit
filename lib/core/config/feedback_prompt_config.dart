import 'package:money_fit/core/config/remote_config_service.dart';

class FeedbackPromptConfig {
  const FeedbackPromptConfig({
    required this.enabled,
    required this.rolloutPercent,
    required this.minInstallDays,
    required this.minSessions,
    required this.minActions,
    required this.minActiveDays,
    this.laterDays = 30,
    this.dismissDays = 14,
    this.submittedDays = 120,
    this.maxShowsPer180Days = 3,
    this.engagementCooldownDays = 30,
    this.quietPeriodSeconds = 120,
    this.policyVersion = 'feedback_v1',
  });
  final bool enabled;
  final int rolloutPercent;
  final int minInstallDays;
  final int minSessions;
  final int minActions;
  final int minActiveDays;
  final int laterDays;
  final int dismissDays;
  final int submittedDays;
  final int maxShowsPer180Days;
  final int engagementCooldownDays;
  final int quietPeriodSeconds;
  final String policyVersion;

  Duration get quietPeriod => Duration(seconds: quietPeriodSeconds);

  factory FeedbackPromptConfig.fromRemoteConfig(
    RemoteConfigReader remote,
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
        .clamp(2, 14),
    laterDays: remote.intValue('feedback_prompt_later_days').clamp(7, 365),
    dismissDays: remote.intValue('feedback_prompt_dismiss_days').clamp(3, 90),
    submittedDays: remote
        .intValue('feedback_prompt_submitted_days')
        .clamp(30, 365),
    maxShowsPer180Days: _canonicalOrLegacy(
      remote,
      'feedback_prompt_max_shows_180d',
      'feedback_prompt_max_shows_180_days',
    ).clamp(1, 6),
    engagementCooldownDays: _canonicalOrLegacy(
      remote,
      'feedback_prompt_global_cooldown_days',
      'feedback_prompt_engagement_cooldown_days',
    ).clamp(7, 365),
    quietPeriodSeconds: _canonicalOrLegacy(
      remote,
      'proactive_fullscreen_quiet_seconds',
      'feedback_prompt_quiet_period_seconds',
    ).clamp(30, 600),
    policyVersion: _policyVersion(
      remote.stringValue('feedback_prompt_policy_version'),
    ),
  );

  static String _policyVersion(String value) {
    final trimmed = value.trim();
    return RegExp(r'^[A-Za-z0-9_.-]{1,80}$').hasMatch(trimmed)
        ? trimmed
        : 'feedback_v1';
  }

  static int _canonicalOrLegacy(
    RemoteConfigReader remote,
    String canonical,
    String legacy,
  ) {
    if (remote.isRemoteValue(canonical)) return remote.intValue(canonical);
    if (remote.isRemoteValue(legacy)) return remote.intValue(legacy);
    return remote.intValue(canonical);
  }
}
