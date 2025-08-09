import 'package:flutter/material.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/settings/widgets/app_information_section.dart';
import 'package:money_fit/features/settings/widgets/basic_setting_section.dart';
import 'package:money_fit/features/settings/widgets/data_management_section.dart';

/// 전체 설정 화면 (정적 UI 담당)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          const AdBannerWidget(screenType: ScreenType.settings),
          const SizedBox(height: 16),
          // 상태 변경이 필요한 부분은 별도 위젯으로 분리
          const BasicSettingsSection(),
          const SizedBox(height: 24),
          const DataManagementSection(),
          const SizedBox(height: 24),
          const AppInformationSection(),
        ],
      ),
    );
  }
}
