import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Local privacy control. This deliberately does not use a monetization safe
/// point: changing consent must never create a full-screen ad opportunity.
class AnalyticsConsentSetting extends ConsumerStatefulWidget {
  const AnalyticsConsentSetting({super.key});

  @override
  ConsumerState<AnalyticsConsentSetting> createState() =>
      _AnalyticsConsentSettingState();
}

class _AnalyticsConsentSettingState
    extends ConsumerState<AnalyticsConsentSetting> {
  late bool _enabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _enabled = ref.read(analyticsConsentRepositoryProvider).isEnabled;
  }

  Future<void> _setEnabled(bool enabled) async {
    if (_isSaving || enabled == _enabled) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(analyticsConsentRepositoryProvider).setEnabled(enabled);
      await ref.read(analyticsTrackerProvider).setCollectionEnabled(enabled);
      if (mounted) setState(() => _enabled = enabled);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return buildSwitchItem(
      icon: Icons.analytics_outlined,
      iconColor: context.colors.brandPrimary,
      title: l10n.analyticsCollection,
      value: _enabled,
      onChanged: _isSaving ? null : _setEnabled,
      context: context,
    );
  }
}
