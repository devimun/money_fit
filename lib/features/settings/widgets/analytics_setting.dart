import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Collection is enabled for new installs and can be explicitly disabled here.
class AnalyticsSetting extends ConsumerWidget {
  const AnalyticsSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(analyticsConsentRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    return buildSwitchItem(
      icon: Icons.analytics_outlined,
      iconColor: context.colors.brandPrimary,
      title: l10n.analytics_collection,
      value: consent.isEnabled,
      context: context,
      onChanged: (enabled) async {
        await consent.setEnabled(enabled);
        await ref.read(analyticsProvider).setCollectionEnabled(enabled);
      },
    );
  }
}
