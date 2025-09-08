import 'package:flutter/material.dart';
import 'package:money_fit/core/widgets/review_system/experience_binary_dialog.dart';
import 'package:money_fit/core/widgets/review_system/negative_feedback_dialog.dart';
import 'package:money_fit/core/widgets/review_system/positive_confirm_dialog.dart';
import 'package:money_fit/core/widgets/review_system/thanks_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// 리뷰 다이얼로그들을 생성하는 팩토리 클래스
class ReviewDialogFactory {
  /// 이분화된 경험 질문 다이얼로그를 표시
  static Future<BinaryExperience?> showExperienceBinaryDialog(
    BuildContext context,
  ) {
    return showDialog<BinaryExperience>(
      context: context,
      builder: (ctx) => const ExperienceBinaryDialog(),
    );
  }

  /// 긍정적인 확인 다이얼로그를 표시
  static Future<PositiveAction?> showPositiveConfirmDialog(
    BuildContext context,
  ) {
    return showDialog<PositiveAction>(
      context: context,
      builder: (ctx) => const PositiveConfirmDialog(),
    );
  }

  /// 부정적인 피드백 다이얼로그를 표시
  static Future<NegativeResult?> showNegativeFeedbackDialog(
    BuildContext context,
  ) {
    return showDialog<NegativeResult>(
      context: context,
      builder: (ctx) => const NegativeFeedbackDialog(),
    );
  }

  /// 감사 다이얼로그를 표시
  static Future<void> showThanksDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (_) => ThanksDialog(l10n: l10n),
    );
  }
}
