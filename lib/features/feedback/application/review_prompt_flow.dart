import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';

class ReviewPromptFlow {
  ReviewPromptFlow({
    required FeedbackRepository feedback,
    required ReviewPromptPreferences preferences,
    required ReviewPromptPresenter presenter,
    required ReviewStoreLauncher reviewStoreLauncher,
    DateTime Function()? now,
  }) : _feedback = feedback,
       _preferences = preferences,
       _presenter = presenter,
       _reviewStoreLauncher = reviewStoreLauncher,
       _now = now ?? DateTime.now;

  final FeedbackRepository _feedback;
  final ReviewPromptPreferences _preferences;
  final ReviewPromptPresenter _presenter;
  final ReviewStoreLauncher _reviewStoreLauncher;
  final DateTime Function() _now;

  Duration minInstallAge = const Duration(days: 2);
  bool _requestedThisSession = false;

  Future<void> ensureFirstRunTimestamp() async {
    if (await _preferences.readFirstRunAt() == null) {
      await _preferences.writeFirstRunAt(_now());
    }
  }

  Future<bool> get isOptedOut => _preferences.readOptedOut();

  Future<void> setOptedOut(bool value) => _preferences.writeOptedOut(value);

  Future<bool> get isEligible async {
    if (await isOptedOut) return false;
    final firstRun = await _preferences.readFirstRunAt();
    if (firstRun == null || _now().difference(firstRun) < minInstallAge) {
      return false;
    }
    final snoozeUntil = await _preferences.readSnoozeUntil();
    return snoozeUntil == null || !_now().isBefore(snoozeUntil);
  }

  Future<void> maybePromptReview() async {
    await ensureFirstRunTimestamp();
    if (!await isEligible || _requestedThisSession) return;
    _requestedThisSession = true;

    final experience = await _presenter.askExperience();
    if (experience == null) return;
    await _preferences.markPrompted(_now());

    if (experience == BinaryExperience.good) {
      await _handlePositiveResponse(await _presenter.askForReview());
      return;
    }
    await _handleNegativeResponse(await _presenter.collectNegativeFeedback());
  }

  Future<void> _handlePositiveResponse(PositiveAction? action) async {
    switch (action) {
      case PositiveAction.reviewNow:
        await setOptedOut(true);
        await _reviewStoreLauncher.launch();
      case PositiveAction.later:
        await _setSnoozeUntil(_now().add(const Duration(days: 7)));
      case PositiveAction.never:
        await setOptedOut(true);
      case null:
        return;
    }
  }

  Future<void> _handleNegativeResponse(NegativeResult? result) async {
    switch (result?.action) {
      case NegativeAction.send:
        await submitNegativeFeedback(result!.detail);
        await _presenter.showThanks();
      case NegativeAction.later:
        await _setSnoozeUntil(_now().add(const Duration(days: 7)));
      case NegativeAction.never:
        await setOptedOut(true);
      case null:
        return;
    }
  }

  Future<void> _setSnoozeUntil(DateTime dateTime) {
    return _preferences.writeSnoozeUntil(dateTime);
  }

  Future<void> submitNegativeFeedback(String? detail) async {
    try {
      await _feedback.submitReviewFeedback(detail ?? '');
    } catch (_) {
      // Feedback is optional and must not block the completed expense command.
    }
  }
}
