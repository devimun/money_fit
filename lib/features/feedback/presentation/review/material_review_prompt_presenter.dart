import 'package:flutter/material.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
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
  Future<NegativeResult?> collectNegativeFeedback() {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showNegativeFeedbackDialog(_context);
  }

  @override
  Future<void> showThanks() {
    if (!_mounted) return Future.value();
    return ReviewDialogFactory.showThanksDialog(_context);
  }
}
