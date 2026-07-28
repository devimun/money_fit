import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/bootstrap/optional_remote_capabilities.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_config.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_service.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_state.dart';
import 'package:money_fit/features/feedback/application/review_prompt_flow.dart';
import 'package:money_fit/features/feedback/data/capability_aware_feedback_repository.dart';
import 'package:money_fit/features/feedback/data/shared_preferences_feedback_prompt_state.dart';
import 'package:money_fit/features/feedback/data/shared_preferences_review_prompt_preferences.dart';
import 'package:money_fit/features/feedback/data/supabase_feedback_repository.dart';
import 'package:money_fit/features/feedback/data/url_review_store_launcher.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/features/feedback/presentation/review/material_review_prompt_presenter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote feedback is a progressive enhancement. The wrapper never touches
/// the Supabase singleton unless optional initialization succeeded, and it can
/// become available later without rebuilding the local form UI.
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  SupabaseFeedbackRepository? repository;
  return CapabilityAwareFeedbackRepository(
    currentRepository: () {
      if (!ref.read(optionalRemoteCapabilitiesProvider).supabase.isAvailable) {
        return null;
      }
      try {
        return repository ??= SupabaseFeedbackRepository(
          Supabase.instance.client,
        );
      } catch (_) {
        return null;
      }
    },
  );
});

/// Rebuilds the policy when Remote Config activates a real-time update.
/// The reader itself is a stable service instance, so watching it alone would
/// otherwise leave this feature with a process-lifetime snapshot.
final feedbackPromptRemoteConfigUpdatesProvider = StreamProvider<void>(
  (ref) => ref.watch(remoteConfigServiceProvider).updates,
);

final feedbackPromptConfigProvider = Provider<FeedbackPromptConfig>((ref) {
  ref.watch(feedbackPromptRemoteConfigUpdatesProvider);
  return FeedbackPromptConfig.fromRemoteConfig(
    ref.watch(remoteConfigReaderProvider),
  );
});

final feedbackPromptStateProvider = Provider<FeedbackPromptStateStore>(
  (ref) => SharedPreferencesFeedbackPromptState(
    ref.watch(sharedPreferencesProvider),
    now: ref.watch(clockProvider).now,
  ),
);

final feedbackPromptServiceProvider = Provider<FeedbackPromptService>(
  (ref) => FeedbackPromptService(
    ref.watch(feedbackPromptStateProvider),
    ref.watch(feedbackPromptConfigProvider),
    now: ref.watch(clockProvider).now,
  ),
);

/// Local preference initialization is deliberately independent of optional
/// remote capabilities. It is idempotent and establishes the first-run and
/// session counters used by the prompt policy.
final feedbackPromptStartupProvider = Provider<Future<void> Function()>((ref) {
  Future<void>? starting;
  return () =>
      starting ??= ref.read(feedbackPromptServiceProvider).initializeSession();
});

/// UI-capable composition belongs at the app boundary, so ledger presentation
/// can trigger the optional engagement flow without importing another
/// feature's presentation layer.
final reviewPromptProvider = Provider<Future<void> Function(BuildContext)>(
  (ref) => (context) {
    final config = ref.read(feedbackPromptConfigProvider);
    return ReviewPromptFlow(
      feedback: ref.read(feedbackRepositoryProvider),
      preferences: SharedPreferencesReviewPromptPreferences(),
      presenter: MaterialReviewPromptPresenter(context),
      reviewStoreLauncher: const UrlReviewStoreLauncher(),
      reviewSubmission: () => FeedbackSubmission(
        detail: '',
        source: FeedbackSource.reviewNegative,
        clientSubmissionId: ref.read(idGeneratorProvider).next(),
        locale: Localizations.localeOf(context).toString(),
      ),
      promptCoordinator: ref.read(promptCoordinatorProvider),
      engagementCooldown: Duration(days: config.engagementCooldownDays),
      quietPeriod: config.quietPeriod,
      now: ref.read(clockProvider).now,
    ).maybePromptReview();
  },
);
