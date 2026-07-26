import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/home/application/home_projection.dart';
import 'package:money_fit/features/home/widgets/home_date_header.dart';
import 'package:money_fit/features/home/widgets/home_main_card.dart';
import 'package:money_fit/features/home/widgets/home_action_buttons.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/widgets/custom_notification_dialog.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.showNotificationPrompt});
  final bool showNotificationPrompt;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.showNotificationPrompt && !_hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hasShownDialog = true;
        _showNotificationDialog();
      });
    }
  }

  Future<void> _showNotificationDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomNotificationDialog(
          onConfirm: () async {
            Navigator.of(context).pop();
            await ref
                .read(notificationServiceProvider)
                .setupNotifications(l10n, ref);
          },
          onDeny: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
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
                const AdBannerWidget(screenType: ScreenType.home),
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
