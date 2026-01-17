import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

class HomeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: context.boxDecoration,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
