import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/app_update/application/update_presentation.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// Route presentation for the bootstrap controller's update decision.
class UpdateCheckScreen extends ConsumerStatefulWidget {
  const UpdateCheckScreen({this.openStore, super.key});

  final UpdateStoreLauncher? openStore;

  @override
  ConsumerState<UpdateCheckScreen> createState() => _UpdateCheckScreenState();
}

class _UpdateCheckScreenState extends ConsumerState<UpdateCheckScreen> {
  PromptLease? _lease;
  var _leaseAcquisitionScheduled = false;
  var _leaseAttempted = false;

  @override
  void initState() {
    super.initState();
    _scheduleLeaseAcquisition();
  }

  @override
  void dispose() {
    _lease?.release();
    super.dispose();
  }

  void _acquireLease() {
    if (!mounted ||
        _leaseAttempted ||
        ref.read(bootstrapGateProvider) != BootstrapGateState.forceUpdate) {
      return;
    }
    _leaseAttempted = true;
    final lease = ref
        .read(promptCoordinatorProvider)
        .tryAcquire(
          PromptSurface.update,
          quietPeriod: defaultUpdatePromptQuietPeriod,
        );
    if (!mounted) {
      lease?.release(applyQuietPeriod: false);
      return;
    }
    setState(() => _lease = lease);
  }

  /// The route is created while bootstrap is still checking Remote Config.
  /// A forced-update decision can therefore arrive after [initState]. Schedule
  /// one post-frame acquisition for that transition, while coalescing rebuilds
  /// so the same forced gate cannot acquire multiple leases.
  void _scheduleLeaseAcquisition() {
    if (_lease != null || _leaseAttempted || _leaseAcquisitionScheduled) {
      return;
    }
    _leaseAcquisitionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leaseAcquisitionScheduled = false;
      _acquireLease();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gate = ref.watch(bootstrapGateProvider);
    if (gate == BootstrapGateState.forceUpdate) {
      _scheduleLeaseAcquisition();
    }
    if (gate != BootstrapGateState.forceUpdate || _lease == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(updateStatusProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveTitleText(text: l10n.updateRequiredTitle),
              const SizedBox(height: 12),
              ResponsiveDescriptionText(
                text: status.messageToDisplay.isEmpty
                    ? l10n.updateRequiredBody
                    : status.messageToDisplay,
              ),
              if (status.changelogLines.isNotEmpty) ...[
                const SizedBox(height: 16),
                ResponsiveDescriptionText(
                  text: l10n.updateChangelogTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...status.changelogLines.map(_ForceChangelogRow.new),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => unawaited(_openStore(status.storeUri)),
                child: ResponsiveButtonText(text: l10n.updateButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(Uri? storeUri) async {
    try {
      await (widget.openStore ?? _defaultOpenStore)(storeUri);
    } catch (_) {
      // The mandatory gate remains in place even if the store cannot launch.
    }
  }

  Future<void> _defaultOpenStore(Uri? storeUri) => UpdateService.openStorePage(
    storeUri,
    environment: ref.read(appEnvironmentProvider),
  );
}

class _ForceChangelogRow extends StatelessWidget {
  const _ForceChangelogRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• '),
        Expanded(child: ResponsiveDescriptionText(text: text)),
      ],
    ),
  );
}
