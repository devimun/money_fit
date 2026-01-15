/// PresetColorsGrid - Displays 8 preset color options in a grid layout
/// Provides quick color selection for theme customization
library;

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

/// Widget that displays preset color options in a grid
/// 
/// Shows 8 predefined colors for quick theme selection:
/// - Brown (default)
/// - Blue
/// - Green
/// - Red
/// - Purple
/// - Orange
/// - Cyan
/// - Pink
class PresetColorsGrid extends StatelessWidget {
  const PresetColorsGrid({
    required this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  /// Currently selected color
  final Color selectedColor;

  /// Callback when a color is selected
  final ValueChanged<Color> onColorSelected;

  /// 8 preset colors for quick selection
  static const List<Color> presetColors = [
    Color(0xFF8D6E63), // Brown (default)
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFD32F2F), // Red
    Color(0xFF7B1FA2), // Purple
    Color(0xFFF57C00), // Orange
    Color(0xFF0097A7), // Cyan
    Color(0xFFC2185B), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: presetColors.length,
      itemBuilder: (context, index) {
        final color = presetColors[index];
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
