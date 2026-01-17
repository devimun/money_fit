/// ThemePreviewCard - Displays a mini UI preview with selected theme
/// Shows how the theme looks with light/dark mode toggle
library;

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/app_theme_colors.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

/// Widget that displays a preview of the theme with sample UI elements
/// 
/// Features:
/// - Shows primary color, background, card, and text colors
/// - Light/Dark mode toggle
/// - Sample button, card, and text elements
/// - Real-time updates when color changes
class ThemePreviewCard extends StatefulWidget {
  const ThemePreviewCard({
    required this.seedColor,
    super.key,
  });

  /// Color seed to generate theme preview
  final Color seedColor;

  @override
  State<ThemePreviewCard> createState() => _ThemePreviewCardState();
}

class _ThemePreviewCardState extends State<ThemePreviewCard> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    // Generate theme colors from seed
    final AppThemeColors themeColors = _isDarkMode
        ? AppThemeGenerator.darkFromSeed(widget.seedColor)
        : AppThemeGenerator.lightFromSeed(widget.seedColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with mode toggle
          _PreviewHeader(
            isDarkMode: _isDarkMode,
            onToggle: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Preview content
          _PreviewContent(themeColors: themeColors),
        ],
      ),
    );
  }
}

/// Header section with light/dark mode toggle
class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.isDarkMode,
    required this.onToggle,
  });

  final bool isDarkMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Preview',
          style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Row(
          children: [
            Icon(
              Icons.light_mode,
              size: 18,
              color: !isDarkMode
                  ? context.colors.brandPrimary
                  : context.colors.textPrimary.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isDarkMode,
              onChanged: (_) => onToggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.dark_mode,
              size: 18,
              color: isDarkMode
                  ? context.colors.brandPrimary
                  : context.colors.textPrimary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ],
    );
  }
}

/// Preview content showing sample UI elements
class _PreviewContent extends StatelessWidget {
  const _PreviewContent({required this.themeColors});

  final AppThemeColors themeColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.screenBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sample Card
          _SampleCard(themeColors: themeColors),
          
          const SizedBox(height: 12),
          
          // Sample Button
          _SampleButton(themeColors: themeColors),
          
          const SizedBox(height: 12),
          
          // Sample Text
          _SampleText(themeColors: themeColors),
        ],
      ),
    );
  }
}

/// Sample card showing card background and text
class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.themeColors});

  final AppThemeColors themeColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Title',
            style: TextStyle(
              color: themeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Card content with secondary text',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sample button showing primary color
class _SampleButton extends StatelessWidget {
  const _SampleButton({required this.themeColors});

  final AppThemeColors themeColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: themeColors.brandPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Primary Button',
          style: TextStyle(
            color: themeColors.textOnBrand,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Sample text showing text colors
class _SampleText extends StatelessWidget {
  const _SampleText({required this.themeColors});

  final AppThemeColors themeColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Text',
          style: TextStyle(
            color: themeColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Secondary Text',
          style: TextStyle(
            color: themeColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
