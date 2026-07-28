import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

class ReviewPromptFlow {
  ReviewPromptFlow({
    required FeedbackRepository feedback,
    required ReviewPromptPreferences preferences,
    required ReviewPromptPresenter presenter,
    required ReviewStoreLauncher reviewStoreLauncher,
    required FeedbackSubmission Function() reviewSubmission,
    PromptCoordinator? promptCoordinator,
    Duration engagementCooldown = const Duration(days: 30),
    Duration quietPeriod = const Duration(seconds: 120),
    DateTime Function()? now,
  }) : _feedback = feedback,
       _preferences = preferences,
       _presenter = presenter,
       _reviewStoreLauncher = reviewStoreLauncher,
       _reviewSubmission = reviewSubmission,
       _promptCoordinator = promptCoordinator,
       _engagementCooldown = engagementCooldown,
       _quietPeriod = quietPeriod,
       _now = now ?? DateTime.now;

  final FeedbackRepository _feedback;
  final ReviewPromptPreferences _preferences;
  final ReviewPromptPresenter _presenter;
  final ReviewStoreLauncher _reviewStoreLauncher;
  final FeedbackSubmission Function() _reviewSubmission;
  final PromptCoordinator? _promptCoordinator;

  /// Persisted cross-engagement cooldown. This is intentionally distinct from
  /// the process-local full-screen [PromptCoordinator] quiet period below.
  final Duration _engagementCooldown;
  final Duration _quietPeriod;
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
    if (snoozeUntil != null && _now().isBefore(snoozeUntil)) return false;
    final engagementPromptAt = await _preferences.readEngagementPromptAt();
    return engagementPromptAt == null ||
        (!_now().isBefore(engagementPromptAt) &&
            _now().difference(engagementPromptAt) >= _engagementCooldown);
  }

  Future<void> maybePromptReview() async {
    await ensureFirstRunTimestamp();
    if (!await isEligible || _requestedThisSession) return;
    final lease = _promptCoordinator?.tryAcquire(
      PromptSurface.review,
      quietPeriod: _quietPeriod,
    );
    if (_promptCoordinator != null && lease == null) return;
    _requestedThisSession = true;

    try {
      final experience = await _presenter.askExperience();
      await _preferences.markPrompted(_now());
      if (experience == null) return;

      if (experience == BinaryExperience.good) {
        await _handlePositiveResponse(await _presenter.askForReview());
        return;
      }
      await _handleNegativeResponse(
        await _presenter.collectNegativeFeedback(
          submission: _reviewSubmission(),
          submit: _feedback.submitFeedback,
        ),
      );
    } finally {
      lease?.release();
    }
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
}
