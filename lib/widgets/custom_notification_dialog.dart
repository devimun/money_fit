import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, theme, l10n),
    );
  }

  Widget contentBox(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(30),
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
            l10n.notificationDialogTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.notificationDialogDescription,
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
                    l10n.notificationDialogDeny,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text(
                    l10n.notificationDialogConfirm,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
