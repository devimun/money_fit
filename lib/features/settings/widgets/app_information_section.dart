import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

  // 스토어 리뷰를 위한 URL 실행 함수
  void _launchReviewURL() async {
    // TODO: 앱 출시 후 실제 ID로 교체해야 합니다.
    const androidAppId = 'com.moneyfit.app'; // 예시 ID
    const iOSAppId = '1234567890'; // 예시 ID

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
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('기타', textTheme),
        buildSettingsCard([
          // buildSettingsItem(
          //   icon: Icons.campaign_outlined,
          //   iconColor: iconColor,
          //   title: '공지사항',
          //   onTap: () {
          //     // TODO: 공지사항 페이지로 이동
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
            title: '리뷰 작성',
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
            title: '앱 버전',
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
            title: '개인정보 처리방침',
            onTap: () {
              launchUrl(Uri.parse('https://lucky-dev.notion.site/moneyfit-pp'));
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
