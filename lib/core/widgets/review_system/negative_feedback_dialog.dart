import 'package:flutter/material.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// 부정적인 경험에 대한 피드백 다이얼로그
class NegativeFeedbackDialog extends StatefulWidget {
  const NegativeFeedbackDialog({super.key});

  @override
  State<NegativeFeedbackDialog> createState() => _NegativeFeedbackDialogState();
}

class _NegativeFeedbackDialogState extends State<NegativeFeedbackDialog> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLen = 300;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.feedback_outlined,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // 제목
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.review_negative_title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // 텍스트 입력 필드
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: _maxLen,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.review_negative_hint,
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    NegativeResult(
                      NegativeAction.send,
                      _controller.text.trim(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.review_negative_button_send,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(NegativeResult(NegativeAction.later, null)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.review_button_later,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(NegativeResult(NegativeAction.never, null)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.review_button_never,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
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

/// 부정적인 액션 선택 결과
enum NegativeAction { send, later, never }

/// 부정적인 피드백 결과
class NegativeResult {
  final NegativeAction action;
  final String? detail;
  const NegativeResult(this.action, this.detail);
}
