import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';

/// Clears engagement state whose policy must not outlive an explicit reset.
/// Review keys intentionally remain here (rather than a presentation class) so
/// the reset covers every decision and counter even when no dialog is built.
class EngagementResetter {
  const EngagementResetter(this._ref);

  static const _reviewKeys = <String>[
    'review_first_run_at',
    'review_opted_out',
    'review_last_prompt_at',
    'review_prompt_count',
    'review_snooze_until',
  ];

  static const _feedbackPromptKeys = <String>[
    'app_first_run_at',
    'app_session_count',
    'app_last_session_started_at',
    'feedback_prompt_bucket_v1',
    'feedback_meaningful_action_count',
    'feedback_meaningful_action_days',
    'feedback_prompt_last_opportunity_day',
    'feedback_prompt_opted_out',
    'feedback_prompt_snooze_until',
    'feedback_prompt_last_shown_at',
    'feedback_prompt_last_submitted_at',
    'feedback_prompt_show_history',
    'engagement_prompt_last_shown_at',
  ];

  static const _adPolicyKeys = <String>[
    'ads_session_started_at',
    'ads_session_number',
    'ads_fullscreen_session_shown',
    'ads_pending_meaningful_actions',
    'ads_last_fullscreen_at',
    'ads_fullscreen_history',
  ];

  final Ref _ref;

  Future<void> clear() async {
    final preferences = _ref.read(sharedPreferencesProvider);
    for (final key in [
      ..._reviewKeys,
      ..._feedbackPromptKeys,
      ..._adPolicyKeys,
    ]) {
      await preferences.remove(key);
    }
    // Resetting engagement deliberately restores the new-install analytics
    // choice. Keep this explicit: tracker.reset() clears identity/buffers, but
    // never changes the collection setting by itself.
    final analyticsConsent = AnalyticsConsentRepository(preferences);
    await analyticsConsent.clear();
    try {
      await _ref
          .read(analyticsTrackerProvider)
          .setCollectionEnabled(analyticsConsent.isEnabled);
    } catch (_) {
      // Persisted state is already correct; optional SDK synchronization is
      // best-effort and must not block a destructive local reset.
    }
    for (final key in preferences.getKeys()) {
      if (key.startsWith('ads_last_trigger_')) {
        await preferences.remove(key);
      }
    }
    try {
      await _ref.read(monetizationStateClearerProvider)();
    } catch (_) {
      // The local preference sweep above still resets the persisted ad policy
      // state if the composition layer is temporarily unavailable.
    }
    try {
      await _ref.read(analyticsTrackerProvider).reset();
    } catch (_) {
      // Resetting a remote identity cannot make a local reset fail. Collection
      // was synchronized separately above so this remains analytics-only.
    }
  }
}

final engagementResetterProvider = Provider<EngagementResetter>(
  EngagementResetter.new,
);
