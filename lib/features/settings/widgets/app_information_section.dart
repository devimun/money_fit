import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';

class AppInformationSection extends StatelessWidget {
  const AppInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;
    return Column(
      children: [
        buildSectionTitle('앱 정보', textTheme),
        buildSettingsCard([
          buildSettingsItem(
            icon: Icons.campaign_outlined,
            iconColor: iconColor,
            title: '공지사항',
            onTap: () {
              // TODO: 공지사항 페이지로 이동
            },
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          buildSettingsItem(
            icon: Icons.rate_review_outlined,
            iconColor: iconColor,
            title: '리뷰 작성',
            onTap: () {
              // TODO: 스토어 리뷰 페이지로 이동
            },
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
              '1.0.0', // TODO: 앱 버전 정보 연동
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
              // TODO: 개인정보 처리방침 페이지로 이동
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
