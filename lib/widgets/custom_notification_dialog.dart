import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context, l10n),
    );
  }

  Widget contentBox(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: context.colors.cardBackground,
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
          ResponsiveTitleText(
            text: l10n.notificationDialogTitle,
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveDescriptionText(
            text: l10n.notificationDialogDescription,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onDeny,
                  child: ResponsiveButtonText(
                    text: l10n.notificationDialogDeny,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: ResponsiveButtonText(
                    text: l10n.notificationDialogConfirm,
                    style: context.textTheme.labelLarge,
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
