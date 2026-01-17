// LanguageCurrencySelector - 언어/화폐 선택 바텀시트
// 14개 언어/화폐 조합 목록을 표시하고 선택 시 콜백을 호출합니다.
import 'package:flutter/material.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class LanguageCurrencySelector extends StatelessWidget {
  const LanguageCurrencySelector({
    super.key,
    required this.currentLocale,
    required this.onSelect,
  });

  final LocaleConfig currentLocale;
  final ValueChanged<LocaleConfig> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: supportedLocaleConfigs.length,
                itemBuilder: (context, index) {
                  final config = supportedLocaleConfigs[index];
                  final isSelected = config == currentLocale;
                  return _buildLocaleItem(context, config, isSelected);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40), // 균형을 위한 공간
          Expanded(
            child: ResponsiveTitleText(
              text: l10n.selectLanguage,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleItem(
    BuildContext context,
    LocaleConfig config,
    bool isSelected,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: _buildLanguageFlag(config.languageCode),
      title: ResponsiveLabelText(
        text: config.displayName,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '${config.currencySymbol} (${config.currencyCode})',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.colors.brandPrimary)
          : null,
      onTap: () {
        onSelect(config);
        Navigator.of(context).pop();
      },
    );
  }

  /// 언어 코드에 따른 국기 이모지 반환
  Widget _buildLanguageFlag(String languageCode) {
    final flag = _getFlagEmoji(languageCode);
    return Text(flag, style: const TextStyle(fontSize: 24));
  }

  String _getFlagEmoji(String languageCode) {
    const flags = {
      'ko': '🇰🇷',
      'en': '🇺🇸',
      'es': '🇪🇸',
      'pl': '🇵🇱',
      'uk': '🇺🇦',
      'cs': '🇨🇿',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'ro': '🇷🇴',
      'sk': '🇸🇰',
      'bg': '🇧🇬',
      'id': '🇮🇩',
      'ms': '🇲🇾',
      'fil': '🇵🇭',
    };
    return flags[languageCode] ?? '🌐';
  }
}
