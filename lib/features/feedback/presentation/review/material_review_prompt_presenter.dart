import 'package:flutter/material.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/features/feedback/presentation/review/review_dialog_factory.dart';

class MaterialReviewPromptPresenter implements ReviewPromptPresenter {
  MaterialReviewPromptPresenter(this._context);

  final BuildContext _context;

  bool get _mounted => _context.mounted;

  @override
  Future<BinaryExperience?> askExperience() {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showExperienceBinaryDialog(_context);
  }

  @override
  Future<PositiveAction?> askForReview() {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showPositiveConfirmDialog(_context);
  }

  @override
  Future<NegativeResult?> collectNegativeFeedback({
    required FeedbackSubmission submission,
    required Future<FeedbackSubmitResult> Function(FeedbackSubmission) submit,
  }) {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showNegativeFeedbackDialog(
      _context,
      submission: submission,
      submit: submit,
    );
  }

  @override
  Future<void> showThanks() {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showThanksDialog(_context);
  }
}
