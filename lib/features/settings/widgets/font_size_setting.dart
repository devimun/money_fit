// FontSizeSetting - Widget for adjusting app font size
// Provides three font size options: Small, Medium, Large
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/theme/theme_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class FontSizeSetting extends ConsumerWidget {
  const FontSizeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentScale = ref.watch(fontSizeProvider);
    final currentOption = FontSizeOption.fromScale(currentScale);

    return buildSettingsItem(
      icon: Icons.text_fields,
      iconColor: context.colors.brandPrimary,
      title: l10n.fontSize,
      trailing: Text(
        _getFontSizeLabel(currentOption, l10n),
        style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.brandPrimary,
            ),
      ),
      onTap: () => _showFontSizeDialog(context, ref, currentOption),
    );
  }

  String _getFontSizeLabel(FontSizeOption option, AppLocalizations l10n) {
    switch (option) {
      case FontSizeOption.small:
        return l10n.fontSizeSmall;
      case FontSizeOption.medium:
        return l10n.fontSizeMedium;
      case FontSizeOption.large:
        return l10n.fontSizeLarge;
    }
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref, FontSizeOption currentOption) {
    showDialog<void>(
      context: context,
      builder: (context) => _FontSizeDialog(
        currentOption: currentOption,
        onApply: (option) {
          ref.read(fontSizeProvider.notifier).setFontSizeOption(option);
        },
      ),
    );
  }
}

class _FontSizeDialog extends StatefulWidget {
  const _FontSizeDialog({
    required this.currentOption,
    required this.onApply,
  });

  final FontSizeOption currentOption;
  final ValueChanged<FontSizeOption> onApply;

  @override
  State<_FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<_FontSizeDialog> {
  late FontSizeOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentOption;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.fontSize),
      content: RadioGroup<FontSizeOption>(
        groupValue: _selectedOption,
        onChanged: (FontSizeOption? value) {
          if (value != null) {
            setState(() {
              _selectedOption = value;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FontSizeOption.values.map((option) {
            return ListTile(
              leading: Radio<FontSizeOption>(value: option),
              title: Text(
                _getFontSizeLabel(option, l10n),
                style: TextStyle(fontSize: 16 * option.scale),
              ),
              onTap: () {
                setState(() {
                  _selectedOption = option;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(_selectedOption);
            Navigator.of(context).pop();
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }

  String _getFontSizeLabel(FontSizeOption option, AppLocalizations l10n) {
    switch (option) {
      case FontSizeOption.small:
        return l10n.fontSizeSmall;
      case FontSizeOption.medium:
        return l10n.fontSizeMedium;
      case FontSizeOption.large:
        return l10n.fontSizeLarge;
    }
  }
}
