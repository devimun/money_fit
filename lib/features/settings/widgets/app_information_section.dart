import 'dart:io';
import 'package:flutter/material.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:money_fit/l10n/app_localizations.dart';

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

  // 스토어 리뷰를 위한 URL 실행 함수
  void _launchReviewURL() async {
    const androidAppId = 'com.moneyfitapp.app'; // 예시 ID
    const iOSAppId = '6749416452';

    final Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse('market://details?id=$androidAppId');
    } else if (Platform.isIOS) {
      url = Uri.parse(
        'https://apps.apple.com/app/id$iOSAppId?action=write-review',
      );
    } else {
      // 지원하지 않는 플랫폼
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // 스토어 앱을 직접 열 수 없을 경우 웹 URL로 시도
        final webUrl = Uri.parse(
          'https://play.google.com/store/apps/details?id=$androidAppId',
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      // 에러 처리 (예: 사용자에게 알림 표시)
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(l10n.information, textTheme),
        buildSettingsCard([
          // buildSettingsItem(
          //   icon: Icons.campaign_outlined,
          //   iconColor: iconColor,
          //   title: '공지사항',
          //   onTap: () {

          //   },
          //   trailing: const Icon(
          //     Icons.arrow_forward_ios,
          //     size: 16,
          //     color: Color(0xFF9CA3AF),
          //   ),
          // ),
          buildSettingsItem(
            icon: Icons.rate_review_outlined,
            iconColor: iconColor,
            title: l10n.writeReview,
            onTap: _launchReviewURL,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          buildSettingsItem(
            icon: Icons.info_outline,
            iconColor: iconColor,
            title: l10n.appVersion,
            trailing: Text(
              _appVersion, // 동적으로 가져온 버전 표시
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B7280),
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ]),
      ],
    );
  }
}
