import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Route presentation for the bootstrap controller's update decision.
class UpdateCheckScreen extends ConsumerWidget {
  const UpdateCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(bootstrapGateProvider);
    if (gate != BootstrapGateState.forceUpdate) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveTitleText(text: l10n.updateRequiredTitle),
              const SizedBox(height: 12),
              ResponsiveDescriptionText(text: l10n.updateRequiredBody),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => UpdateService.openStorePage(
                  null,
                  environment: ref.read(appEnvironmentProvider),
                ),
                child: ResponsiveButtonText(text: l10n.updateButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
