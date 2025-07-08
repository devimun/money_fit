import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

/// 전체 설정 화면 (정적 UI 담당)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          // 상태 변경이 필요한 부분은 별도 위젯으로 분리
          const _BasicSettingsSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('데이터 관리', textTheme),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.restore,
              iconColor: iconColor,
              title: '정보 초기화',
              onTap: () {
                // TODO: 정보 초기화 확인 다이얼로그 표시
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('앱 정보', textTheme),
          _buildSettingsCard([
            _buildSettingsItem(
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
            _buildSettingsItem(
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
            _buildSettingsItem(
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
            _buildSettingsItem(
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
      ),
    );
  }
}

/// "기본 설정" 섹션 (상태 변경 UI 담당)
class _BasicSettingsSection extends ConsumerStatefulWidget {
  const _BasicSettingsSection();

  @override
  ConsumerState<_BasicSettingsSection> createState() =>
      _BasicSettingsSectionState();
}

class _BasicSettingsSectionState extends ConsumerState<_BasicSettingsSection> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _showDailyBudgetDialog(
    double currentBudget,
    UserSettingsNotifier notifier,
  ) async {
    _budgetController.text = currentBudget.toInt().toString();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('일일 예산 설정'),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '예산을 입력하세요',
              suffixText: '원',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                final newBudget = double.tryParse(_budgetController.text);
                if (newBudget != null) {
                  notifier.updateDailyBudget(newBudget);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;
    final userSettings = ref.watch(userSettingsProvider);
    final userSettingsNotifier = ref.read(userSettingsProvider.notifier);

    return userSettings.when(
      data: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('기본 설정', textTheme),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: iconColor,
              title: '일일 예산 설정',
              onTap: () => _showDailyBudgetDialog(
                user.dailyBudget,
                userSettingsNotifier,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₩${NumberFormat('#,###').format(user.dailyBudget)}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF825A3D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              iconColor: iconColor,
              title: '다크 모드',
              value: user.isDarkMode,
              onChanged: (value) => userSettingsNotifier.toggleDarkMode(),
            ),
            _buildSwitchItem(
              icon: Icons.notifications_outlined,
              iconColor: iconColor,
              title: '알림 설정',
              value: user.notificationsEnabled,
              onChanged: (value) => userSettingsNotifier.toggleNotifications(),
            ),
          ]),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

// --- Helper Widgets ---

Widget _buildSectionTitle(String title, TextTheme textTheme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
    child: Text(
      title,
      style: textTheme.titleSmall?.copyWith(color: const Color(0xFF6B7280)),
    ),
  );
}

Widget _buildSettingsCard(List<Widget> children) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: Column(children: children),
  );
}

Widget _buildSettingsItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Icon(icon, size: 24, color: iconColor),
    title: Text(title),
    trailing: trailing,
    onTap: onTap,
  );
}

Widget _buildSwitchItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return _buildSettingsItem(
    icon: icon,
    iconColor: iconColor,
    title: title,
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF825A3D),
      inactiveTrackColor: const Color(0xFFD1D5DB),
    ),
  );
}
