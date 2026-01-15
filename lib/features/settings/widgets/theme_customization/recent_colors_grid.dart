/// RecentColorsGrid - Displays recently used colors from favoriteColors
/// Shows up to 8 most recent colors, hidden if no colors exist
library;

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

/// Widget that displays recently used colors in a grid
/// 
/// Retrieves colors from ThemeSettings.favoriteColors and displays
/// up to 8 most recent colors. If no colors exist, the widget is hidden.
class RecentColorsGrid extends StatelessWidget {
  const RecentColorsGrid({
    required this.recentColors,
    required this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  /// List of recently used colors (from ThemeSettings.favoriteColors)
  /// Maximum 8 colors, ordered by most recent first
  final List<Color> recentColors;

  /// Currently selected color
  final Color selectedColor;

  /// Callback when a color is selected
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    // Hide widget if no recent colors
    if (recentColors.isEmpty) {
      return const SizedBox.shrink();
    }

    // Limit to maximum 8 colors
    final displayColors = recentColors.take(8).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayColors.length,
      itemBuilder: (context, index) {
        final color = displayColors[index];
        final isSelected = selectedColor.toARGB32() == color.toARGB32();

        return _ColorButton(
          color: color,
          isSelected: isSelected,
          onTap: () => onColorSelected(color),
        );
      },
    );
  }
}

/// Individual color button in the grid
class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.textPrimary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              )
            : null,
      ),
    );
  }
}
