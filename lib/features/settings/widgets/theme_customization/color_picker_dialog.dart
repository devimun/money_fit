/// ColorPickerDialog - Complete color selection dialog
/// Integrates preset colors, recent colors, HSV picker, and theme preview
library;

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/hsv_color_picker.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/preset_colors_grid.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/recent_colors_grid.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/theme_preview_card.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Dialog for selecting theme colors
/// 
/// Features:
/// - Preset colors section (8 predefined colors)
/// - Recent colors section (up to 8 most recent, conditional)
/// - HSV color picker for custom colors
/// - Real-time theme preview
/// - Automatic favorite colors management
class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    required this.initialColor,
    required this.recentColors,
    required this.onColorSelected,
    super.key,
  });

  /// Initial color to display
  final Color initialColor;

  /// List of recently used colors (from ThemeSettings.favoriteColors)
  final List<Color> recentColors;

  /// Callback when color is confirmed
  /// Returns the selected color and updated favorite colors list
  final void Function(Color selectedColor, List<Color> updatedFavorites)
      onColorSelected;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Add selected color to favorites (max 8, most recent first)
  List<Color> _updateFavorites(Color newColor) {
    final List<Color> updated = List.from(widget.recentColors);

    // Remove if already exists
    updated.removeWhere(
      (color) => color.toARGB32() == newColor.toARGB32(),
    );

    // Add to front
    updated.insert(0, newColor);

    // Keep only 8 most recent
    if (updated.length > 8) {
      updated.removeRange(8, updated.length);
    }

    return updated;
  }

  void _handleConfirm() {
    final List<Color> updatedFavorites = _updateFavorites(_selectedColor);
    widget.onColorSelected(_selectedColor, updatedFavorites);
    Navigator.of(context).pop();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _DialogHeader(onClose: _handleCancel),

            // Content (scrollable)
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  crossAxisMargin: 4,
                  mainAxisMargin: 8,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Theme Preview
                      ThemePreviewCard(seedColor: _selectedColor),

                      const SizedBox(height: 24),

                      // Preset Colors Section
                      _SectionTitle(title: l10n.quickSelect),
                      const SizedBox(height: 12),
                      PresetColorsGrid(
                        selectedColor: _selectedColor,
                        onColorSelected: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),

                      // Recent Colors Section (conditional)
                      if (widget.recentColors.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionTitle(title: l10n.recentColors),
                        const SizedBox(height: 12),
                        RecentColorsGrid(
                          recentColors: widget.recentColors,
                          selectedColor: _selectedColor,
                          onColorSelected: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // HSV Color Picker Section
                      _SectionTitle(title: l10n.customSelect),
                      const SizedBox(height: 12),
                      HSVColorPicker(
                        initialColor: _selectedColor,
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            // Footer with action buttons
            _DialogFooter(
              onCancel: _handleCancel,
              onConfirm: _handleConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog header with title and close button
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.border.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ResponsiveTitleText(
              text: l10n.selectThemeColor,
              style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: l10n.close,
          ),
        ],
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ResponsiveTitleText(
      text: title,
      style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

/// Dialog footer with cancel and confirm buttons
class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colors.border.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onCancel,
              child: ResponsiveButtonText(text: l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                foregroundColor: context.colors.textOnBrand,
              ),
              child: ResponsiveButtonText(text: l10n.apply),
            ),
          ),
        ],
      ),
    );
  }
}
