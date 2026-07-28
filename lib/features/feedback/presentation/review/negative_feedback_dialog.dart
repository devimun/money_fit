import 'package:flutter/material.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// 부정적인 경험에 대한 피드백 다이얼로그
class NegativeFeedbackDialog extends StatefulWidget {
  const NegativeFeedbackDialog({
    required this.submission,
    required this.submit,
    super.key,
  });

  final FeedbackSubmission submission;
  final Future<FeedbackSubmitResult> Function(FeedbackSubmission) submit;

  @override
  State<NegativeFeedbackDialog> createState() => _NegativeFeedbackDialogState();
}

class _NegativeFeedbackDialogState extends State<NegativeFeedbackDialog> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLen = 300;
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    final detail = _controller.text.trim();
    if (detail.length < 3) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        )!.review_negative_validation_error,
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.submit(
      widget.submission.copyWith(detail: detail),
    );
    if (!mounted) return;
    if (result is FeedbackSubmitSuccess) {
      Navigator.of(context).pop(NegativeResult(NegativeAction.send, detail));
      return;
    }
    setState(() {
      _submitting = false;
      _error = AppLocalizations.of(context)!.review_negative_submit_error;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 피드백 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.feedback_outlined,
                size: 40,
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 24),

            // 제목
            ResponsiveTitleText(
              text: l10n.review_negative_title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // 텍스트 입력 필드
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: _maxLen,
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.review_negative_hint,
                hintStyle: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.5),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Column(
              children: [
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.brandPrimary,
                    foregroundColor: context.colors.textOnBrand,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ResponsiveButtonText(
                          text: l10n.review_negative_button_send,
                          style: context.textTheme.labelLarge,
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(NegativeResult(NegativeAction.later, null)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ResponsiveButtonText(
                        text: l10n.review_button_later,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.textPrimary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(NegativeResult(NegativeAction.never, null)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ResponsiveButtonText(
                        text: l10n.review_button_never,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.textPrimary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
