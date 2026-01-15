/// Theme color customization setting widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/theme/theme_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/color_picker_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Widget for theme color customization
class ThemeColorSetting extends ConsumerWidget {
  const ThemeColorSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentSeedColor = ref.watch(themeSeedColorProvider);

    return buildSettingsItem(
      icon: Icons.palette_outlined,
      iconColor: context.colors.brandPrimary,
      title: l10n.themeColor,
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: currentSeedColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colors.border,
            width: 2,
          ),
        ),
      ),
      onTap: () => _showColorPicker(context, ref, currentSeedColor),
    );
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    Color currentColor,
  ) {
    // Get favorite colors from repository
    final notifier = ref.read(themeSeedColorProvider.notifier);
    final favoriteColors = notifier.getFavoriteColors();

    showDialog<void>(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: currentColor,
        recentColors: favoriteColors,
        onColorSelected: (selectedColor, updatedFavorites) {
          // Update theme color and save to repository
          notifier.setSeedColor(selectedColor, updatedFavorites);
        },
      ),
    );
  }
}
