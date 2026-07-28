import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/app_update/application/update_presentation.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/l10n/app_localizations.dart';

typedef UpdateDetailsPresenter =
    Future<void> Function(BuildContext context, UpdateStatus status);

/// Presents the advisory update notification only after the router has reached
/// the usable shell. It deliberately leaves routing and forced-update blocking
/// to bootstrap.
class RecommendedUpdatePrompt extends ConsumerStatefulWidget {
  const RecommendedUpdatePrompt({
    required this.child,
    this.presentDetails,
    this.openStore,
    this.retryDelay = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;
  final UpdateDetailsPresenter? presentDetails;
  final UpdateStoreLauncher? openStore;
  final Duration retryDelay;

  @override
  ConsumerState<RecommendedUpdatePrompt> createState() =>
      _RecommendedUpdatePromptState();
}

class _RecommendedUpdatePromptState
    extends ConsumerState<RecommendedUpdatePrompt> {
  bool _retryScheduled = false;
  bool _retryAttempted = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(updateStatusProvider);
    ref.listen<UpdateStatus>(updateStatusProvider, (_, next) {
      _scheduleNotification(next);
    });
    _scheduleNotification(status);
    return widget.child;
  }

  void _scheduleNotification(UpdateStatus status) {
    if (!status.isUpdateRecommended) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_showNotification(status));
    });
  }

  Future<void> _showNotification(UpdateStatus status) async {
    final shown = await ref
        .read(recommendedUpdatePromptControllerProvider)
        .presentNotificationIfNeeded(
          status: status,
          promptCoordinator: ref.read(promptCoordinatorProvider),
          establishPresentation: () async {
            if (!mounted) {
              throw StateError('Update prompt is no longer mounted');
            }
            final messenger = ScaffoldMessenger.maybeOf(context);
            if (messenger == null) {
              throw StateError('No ScaffoldMessenger is available');
            }
            final l10n = AppLocalizations.of(context)!;
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 10),
                content: Text(_message(l10n, status)),
                action: SnackBarAction(
                  label: l10n.updateDetails,
                  onPressed: () => unawaited(_showDetails(status)),
                ),
              ),
            );
          },
        );
    if (!shown) _scheduleSingleRetry();
  }

  /// A competing full-screen surface can legitimately win the first
  /// opportunity. Retry exactly once after a short delay rather than polling
  /// or queueing a stale advisory notification indefinitely.
  void _scheduleSingleRetry() {
    if (_retryScheduled || _retryAttempted) return;
    _retryScheduled = true;
    Future<void>.delayed(widget.retryDelay, () {
      _retryScheduled = false;
      _retryAttempted = true;
      if (!mounted || !ref.read(updateStatusProvider).isUpdateRecommended) {
        return;
      }
      unawaited(_showNotification(ref.read(updateStatusProvider)));
    });
  }

  Future<void> _showDetails(UpdateStatus status) async {
    if (!mounted) return;
    await ref
        .read(recommendedUpdatePromptControllerProvider)
        .presentDetailsWhenAvailable(
          status: status,
          promptCoordinator: ref.read(promptCoordinatorProvider),
          establishPresentation: () =>
              (widget.presentDetails ?? _presentDetails)(context, status),
        );
  }

  Future<void> _presentDetails(BuildContext context, UpdateStatus status) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveTitleText(
                text: l10n.updateSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ResponsiveDescriptionText(text: _message(l10n, status)),
              if (status.changelogLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                ResponsiveDescriptionText(
                  text: l10n.updateChangelogTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...status.changelogLines.map(_ChangelogRow.new),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => unawaited(_openStore(status.storeUri)),
                  child: ResponsiveButtonText(text: l10n.updateButtonGo),
                ),
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
      // A store application may be unavailable. The advisory sheet remains.
    }
  }

  Future<void> _defaultOpenStore(Uri? storeUri) => UpdateService.openStorePage(
    storeUri,
    environment: ref.read(appEnvironmentProvider),
  );
}

String _message(AppLocalizations l10n, UpdateStatus status) =>
    status.messageToDisplay.isEmpty
    ? l10n.updateAvailableBody
    : status.messageToDisplay;

class _ChangelogRow extends StatelessWidget {
  const _ChangelogRow(this.text);

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
