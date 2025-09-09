import 'package:flutter/material.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// 리뷰 경험을 이분화하여 묻는 다이얼로그
class ExperienceBinaryDialog extends StatelessWidget {
  const ExperienceBinaryDialog({super.key});

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
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 제목
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.review_modal_binary_title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 32),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: _buildExperienceButton(
                    context: context,
                    icon: Icons.sentiment_very_satisfied,
                    label: l10n.review_modal_button_good,
                    isPositive: true,
                    onTap: () =>
                        Navigator.of(context).pop(BinaryExperience.good),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExperienceButton(
                    context: context,
                    icon: Icons.sentiment_dissatisfied,
                    label: l10n.review_modal_button_bad,
                    isPositive: false,
                    onTap: () =>
                        Navigator.of(context).pop(BinaryExperience.bad),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isPositive
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPositive
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isPositive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPositive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 이분화된 경험 선택 결과
enum BinaryExperience { good, bad }
