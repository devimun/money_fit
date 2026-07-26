import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/feedback/application/review_prompt_flow.dart';
import 'package:money_fit/features/feedback/data/supabase_feedback_repository.dart';
import 'package:money_fit/features/feedback/data/shared_preferences_review_prompt_preferences.dart';
import 'package:money_fit/features/feedback/data/url_review_store_launcher.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/presentation/review/material_review_prompt_presenter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => SupabaseFeedbackRepository(Supabase.instance.client),
);

/// UI-capable composition belongs at the app boundary, so ledger presentation
/// can trigger the optional engagement flow without importing another
/// feature's presentation layer.
final reviewPromptProvider = Provider<Future<void> Function(BuildContext)>(
  (ref) => (context) {
    return ReviewPromptFlow(
      feedback: ref.read(feedbackRepositoryProvider),
      preferences: SharedPreferencesReviewPromptPreferences(),
      presenter: MaterialReviewPromptPresenter(context),
      reviewStoreLauncher: const UrlReviewStoreLauncher(),
    ).maybePromptReview();
  },
);
