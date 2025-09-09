import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/services/data_reset_service.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// "데이터 관리" 섹션
class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(l10n.dataManagement, textTheme),
        buildSettingsCard([
          buildSettingsItem(
            icon: Icons.restore,
            iconColor: iconColor,
            title: l10n.resetInformation,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      l10n.resetInformation,
                      style: textTheme.displaySmall,
                    ),
                    content: Text(
                      l10n.resetDataConfirmation,
                      style: textTheme.bodyLarge,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.reset),
                      ),
                    ],
                  );
                },
              );

              try {
                if (confirmed == true) {
                  // 데이터 초기화
                  await DataResetService.resetAllData();
                  // 앱 재시작
                  Phoenix.rebirth(context);
                }
              } catch (e) {
                log(e.toString());
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
