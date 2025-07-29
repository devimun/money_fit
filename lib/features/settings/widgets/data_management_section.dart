import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/services/data_reset_service.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:restart_app/restart_app.dart';

/// "데이터 관리" 섹션
class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('데이터 관리', textTheme),
        buildSettingsCard([
          buildSettingsItem(
            icon: Icons.restore,
            iconColor: iconColor,
            title: '정보 초기화',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('정보 초기화', style: textTheme.displaySmall),
                    content: Text(
                      '모든 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
                      style: textTheme.bodyLarge,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('초기화'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true && context.mounted) {
                // 데이터 초기화
                await DataResetService.resetAllData();
                // 앱 재시작
                Restart.restartApp(
                  notificationTitle: 'MoneyFit',
                  notificationBody: '머니핏을 이용해주셔서 감사합ㄴ다.',
                );
              }
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
