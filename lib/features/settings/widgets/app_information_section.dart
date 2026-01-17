import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/settings/widgets/contact_us_dialog.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInformationSection extends StatefulWidget {
  const AppInformationSection({super.key});

  @override
  State<AppInformationSection> createState() => _AppInformationSectionState();
}

class _AppInformationSectionState extends State<AppInformationSection> {
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _showContactUsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const ContactUsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor = context.colors.brandPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(l10n.information, context.textTheme),
        buildSettingsCard([
          buildSettingsItem(
            icon: Icons.rate_review_outlined,
            iconColor: iconColor,
            title: l10n.writeReview,
            onTap: launchReviewURL,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ),
          buildSettingsItem(
            icon: Icons.contact_support_outlined,
            iconColor: iconColor,
            title: l10n.contactUs,
            onTap: _showContactUsDialog,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ),
          buildSettingsItem(
            icon: Icons.info_outline,
            iconColor: iconColor,
            title: l10n.appVersion,
            trailing: Text(
              _appVersion, // 동적으로 가져온 버전 표시
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            iconColor: iconColor,
            title: l10n.privacyPolicy,
            onTap: () async {
              final locale = Localizations.localeOf(context);
              final languageCode = locale.languageCode;
              final countryCode = locale.countryCode ?? '';

              String url;

              if (languageCode == 'ko' || countryCode == 'KR') {
                url = 'https://lucky-dev.notion.site/money-fit-pp-kr';
              } else if (languageCode == 'en') {
                url = 'https://lucky-dev.notion.site/money-fit-pp-en';
              } else if (languageCode == 'fil' || countryCode == 'PH') {
                url = 'https://lucky-dev.notion.site/money-fit-pp-fil';
              } else if (languageCode == 'ms' || countryCode == 'MY') {
                url = 'https://lucky-dev.notion.site/money-fit-pp-ms';
              } else {
                // 기본 fallback (예: 영어)
                url = 'https://lucky-dev.notion.site/money-fit-pp-en';
              }

              await launchUrl(Uri.parse(url));
            },
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ),
        ]),
      ],
    );
  }
}
