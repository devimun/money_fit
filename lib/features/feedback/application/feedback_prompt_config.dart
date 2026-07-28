import 'package:money_fit/core/platform/remote_config.dart';

/// Validated feedback-prompt policy. Invalid Remote Config values fall back
/// per field so a malformed experiment cannot block local expense flows.
class FeedbackPromptConfig {
  const FeedbackPromptConfig({
    required this.enabled,
    required this.rolloutPercent,
    required this.minInstallDays,
    required this.minSessions,
    required this.minActions,
    required this.minActiveDays,
    required this.laterDays,
    required this.dismissDays,
    required this.submittedDays,
    required this.maxShowsPer180Days,
    required this.engagementCooldownDays,
    required this.quietPeriodSeconds,
    required this.policyVersion,
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

  factory FeedbackPromptConfig.fromRemoteConfig(RemoteConfigReader remote) {
    return FeedbackPromptConfig(
      enabled: _canonicalBool(remote, 'feedback_prompt_enabled'),
      rolloutPercent: _canonicalInt(
        remote,
        'feedback_prompt_rollout_percent',
        lower: 0,
        upper: 100,
      ),
      minInstallDays: _canonicalInt(
        remote,
        'feedback_prompt_min_install_days',
        lower: 3,
        upper: 60,
      ),
      minSessions: _canonicalInt(
        remote,
        'feedback_prompt_min_sessions',
        lower: 2,
        upper: 30,
      ),
      minActions: _canonicalInt(
        remote,
        'feedback_prompt_min_actions',
        lower: 5,
        upper: 100,
      ),
      minActiveDays: _canonicalInt(
        remote,
        'feedback_prompt_min_active_days',
        lower: 2,
        upper: 14,
      ),
      laterDays: _canonicalInt(
        remote,
        'feedback_prompt_later_days',
        lower: 7,
        upper: 365,
      ),
      dismissDays: _canonicalInt(
        remote,
        'feedback_prompt_dismiss_days',
        lower: 3,
        upper: 90,
      ),
      submittedDays: _canonicalInt(
        remote,
        'feedback_prompt_submitted_days',
        lower: 30,
        upper: 365,
      ),
      maxShowsPer180Days: _canonicalOrLegacyInt(
        remote,
        canonical: 'feedback_prompt_max_shows_180d',
        legacy: 'feedback_prompt_max_shows_180_days',
        lower: 1,
        upper: 6,
      ),
      engagementCooldownDays: _canonicalOrLegacyInt(
        remote,
        canonical: 'feedback_prompt_global_cooldown_days',
        legacy: 'feedback_prompt_engagement_cooldown_days',
        lower: 7,
        upper: 365,
      ),
      quietPeriodSeconds: _canonicalOrLegacyInt(
        remote,
        canonical: 'proactive_fullscreen_quiet_seconds',
        legacy: 'feedback_prompt_quiet_period_seconds',
        lower: 30,
        upper: 600,
      ),
      policyVersion: _canonicalPolicyVersion(
        remote,
        'feedback_prompt_policy_version',
      ),
    );
  }

  static bool _canonicalBool(RemoteConfigReader remote, String key) {
    if (!remote.isRemoteValue(key)) return _defaultValue<bool>(key);
    try {
      return remote.boolValue(key);
    } catch (_) {
      return _defaultValue<bool>(key);
    }
  }

  static int _canonicalInt(
    RemoteConfigReader remote,
    String key, {
    required int lower,
    required int upper,
  }) {
    if (!remote.isRemoteValue(key)) return _defaultValue<int>(key);
    return _validatedInt(
      remote,
      remoteKey: key,
      canonicalDefaultKey: key,
      lower: lower,
      upper: upper,
    );
  }

  /// A remote canonical key takes precedence even when invalid: it falls back
  /// to the canonical local default instead of a legacy experiment value.
  static int _canonicalOrLegacyInt(
    RemoteConfigReader remote, {
    required String canonical,
    required String legacy,
    required int lower,
    required int upper,
  }) {
    if (remote.isRemoteValue(canonical)) {
      return _validatedInt(
        remote,
        remoteKey: canonical,
        canonicalDefaultKey: canonical,
        lower: lower,
        upper: upper,
      );
    }
    if (remote.isRemoteValue(legacy)) {
      return _validatedInt(
        remote,
        remoteKey: legacy,
        canonicalDefaultKey: canonical,
        lower: lower,
        upper: upper,
      );
    }
    return _defaultValue<int>(canonical);
  }

  static int _validatedInt(
    RemoteConfigReader remote, {
    required String remoteKey,
    required String canonicalDefaultKey,
    required int lower,
    required int upper,
  }) {
    try {
      final value = remote.intValue(remoteKey);
      return value >= lower && value <= upper
          ? value
          : _defaultValue<int>(canonicalDefaultKey);
    } catch (_) {
      return _defaultValue<int>(canonicalDefaultKey);
    }
  }

  static String _canonicalPolicyVersion(RemoteConfigReader remote, String key) {
    if (!remote.isRemoteValue(key)) return _defaultValue<String>(key);
    try {
      final trimmed = remote.stringValue(key).trim();
      return RegExp(r'^[A-Za-z0-9_.-]{1,80}$').hasMatch(trimmed)
          ? trimmed
          : _defaultValue<String>(key);
    } catch (_) {
      return _defaultValue<String>(key);
    }
  }

  static T _defaultValue<T>(String key) => remoteConfigDefaults[key]! as T;
}
