import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

abstract interface class ReviewPromptPreferences {
  Future<DateTime?> readFirstRunAt();
  Future<void> writeFirstRunAt(DateTime value);

  Future<bool> readOptedOut();
  Future<void> writeOptedOut(bool value);

  Future<DateTime?> readSnoozeUntil();
  Future<void> writeSnoozeUntil(DateTime value);

  Future<void> markPrompted(DateTime value);

  /// Shared with the proactive feedback policy, so the two experiences do not
  /// immediately follow one another on a completed ledger action.
  Future<DateTime?> readEngagementPromptAt();
}

abstract interface class ReviewPromptPresenter {
  Future<BinaryExperience?> askExperience();
  Future<PositiveAction?> askForReview();

  /// The dialog owns retries. It receives one submission identity so repeated
  /// taps after a transient failure stay idempotent at the RPC boundary.
  Future<NegativeResult?> collectNegativeFeedback({
    required FeedbackSubmission submission,
    required Future<FeedbackSubmitResult> Function(FeedbackSubmission) submit,
  });
  Future<void> showThanks();
}

abstract interface class ReviewStoreLauncher {
  Future<void> launch();
}

enum BinaryExperience { good, bad }

enum PositiveAction { reviewNow, later, never }

enum NegativeAction { send, later, never }

class NegativeResult {
  const NegativeResult(this.action, this.detail);

  final NegativeAction action;
  final String? detail;
}
