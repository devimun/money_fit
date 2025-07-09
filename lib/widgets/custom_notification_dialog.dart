import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';

class CustomNotificationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onDeny;

  const CustomNotificationDialog({
    super.key,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, theme),
    );
  }

  Widget contentBox(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '지출 기록을 잊지 않게 도와드려요',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '지출 기록,어렵진 않지만 잊어버리기 쉽죠.\n잊지 않도록 매일 알림으로 도와드릴게요. \n알림을 받아 보시겠어요?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: LightAppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onDeny,
                  child: Text(
                    '괜찮아요',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text('네, 좋아요', style: theme.textTheme.labelLarge),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
