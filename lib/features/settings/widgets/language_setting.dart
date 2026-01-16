// LanguageSetting - 언어/화폐 설정 위젯
// 현재 선택된 언어/화폐를 표시하고, 탭 시 선택 바텀시트를 표시합니다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/language_currency_selector.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class LanguageSetting extends ConsumerWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return buildSettingsItem(
      icon: Icons.language,
      iconColor: context.colors.brandPrimary,
      title: l10n.languageSetting,
      trailing: ResponsiveLabelText(
        text: '${currentLocale.displayName} / ${currentLocale.currencySymbol}',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.brandPrimary,
        ),
      ),
      onTap: () => _showLanguageSelector(context, ref, currentLocale),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    LocaleConfig currentLocale,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LanguageCurrencySelector(
        currentLocale: currentLocale,
        onSelect: (config) => _changeLocale(ref, config),
      ),
    );
  }

  /// 로케일 변경 - LocaleProvider와 UserSettings 둘 다 업데이트
  Future<void> _changeLocale(WidgetRef ref, LocaleConfig config) async {
    // 1. LocaleProvider 업데이트 (즉시 UI 반영)
    await ref.read(localeProvider.notifier).setLocaleConfig(config);

    // 2. UserSettings 업데이트 (DB 영속화)
    await ref.read(userSettingsProvider.notifier).updateLocale(
          config.languageCode,
          config.currencyCode,
        );
  }
}
