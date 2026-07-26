abstract interface class ReviewPromptPreferences {
  Future<DateTime?> readFirstRunAt();
  Future<void> writeFirstRunAt(DateTime value);

  Future<bool> readOptedOut();
  Future<void> writeOptedOut(bool value);

  Future<DateTime?> readSnoozeUntil();
  Future<void> writeSnoozeUntil(DateTime value);

  Future<void> markPrompted(DateTime value);
}

abstract interface class ReviewPromptPresenter {
  Future<BinaryExperience?> askExperience();
  Future<PositiveAction?> askForReview();
  Future<NegativeResult?> collectNegativeFeedback();
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
