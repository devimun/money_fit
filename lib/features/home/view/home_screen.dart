import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/monetization/widgets/ad_banner_widget.dart';
import 'package:money_fit/features/home/application/home_projection.dart';
import 'package:money_fit/features/home/widgets/home_date_header.dart';
import 'package:money_fit/features/home/widgets/home_main_card.dart';
import 'package:money_fit/features/home/widgets/home_action_buttons.dart';
import 'package:money_fit/features/notifications/application/notification_permission_prompt.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/widgets/custom_notification_dialog.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.showNotificationPrompt});
  final bool showNotificationPrompt;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final NotificationPermissionPromptController _notificationPrompt;

  @override
  void initState() {
    super.initState();
    _notificationPrompt = NotificationPermissionPromptController(
      ref.read(promptCoordinatorProvider),
      quietPeriod: () => Duration(
        seconds: readValidatedProactiveFullscreenQuietSeconds(
          ref.read(remoteConfigReaderProvider),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.showNotificationPrompt && !_notificationPrompt.hasAttempted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotificationDialog();
      });
    }
  }

  Future<void> _showNotificationDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await _notificationPrompt.showOnce(() async {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return CustomNotificationDialog(
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            onDeny: () => Navigator.of(dialogContext).pop(false),
          );
        },
      );
      if (confirmed != true || !mounted) return;
      final notifier = ref.read(notificationControllerProvider.notifier);
      final permission = await notifier.enable(
        NotificationText(
          title: l10n.notificationTitleDaily,
          morning: l10n.notificationBodyMorning,
          afternoon: l10n.notificationBodyAfternoon,
          night: l10n.notificationBodyNight,
        ),
      );
      if (permission != NotificationPermissionResult.permanentlyDenied ||
          !mounted) {
        return;
      }
      await _showPermanentDeniedFallback(notifier, l10n);
    });
  }

  /// This stays inside [NotificationPermissionPromptController.showOnce]'s
  /// presentation callback, so the shared notification lease covers the app
  /// dialog, OS request, fallback choice, and any settings handoff.
  Future<void> _showPermanentDeniedFallback(
    NotificationController notifier,
    AppLocalizations l10n,
  ) async {
    if (!mounted) return;
    final action = await showDialog<_HomePermissionDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationPermissionRequired),
        content: Text(l10n.notificationPermissionDescription),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _HomePermissionDialogAction.cancel),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              _HomePermissionDialogAction.openSettings,
            ),
            child: Text(l10n.goToSettings),
          ),
        ],
      ),
    );
    if (action == _HomePermissionDialogAction.openSettings) {
      await notifier.openPermissionSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeStateAsync = ref.watch(homeViewModelProvider);
    final sessionAsync = ref.watch(sessionContextProvider);
    final l10n = AppLocalizations.of(context)!;

    if (homeStateAsync.isLoading || sessionAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (homeStateAsync.hasError || sessionAsync.hasError) {
      final error = homeStateAsync.error ?? sessionAsync.error;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred(error.toString())),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => ref.invalidate(coreExpensesProvider),
                icon: const Icon(Icons.refresh),
                tooltip: MaterialLocalizations.of(
                  context,
                ).refreshIndicatorSemanticLabel,
              ),
            ],
          ),
        ),
      );
    }

    final homeState = homeStateAsync.value!;
    final session = sessionAsync.value!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AdBannerWidget(placement: AdPlacement.home),
                const SizedBox(height: 10),
                const HomeDateHeader(),
                const SizedBox(height: 10),
                HomeMainCard(homeState: homeState),
                const SizedBox(height: 20),
                HomeActionButtons(
                  homeState: homeState,
                  userId: session.ownerId,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _HomePermissionDialogAction { cancel, openSettings }
