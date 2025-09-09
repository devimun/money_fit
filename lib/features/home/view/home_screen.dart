import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/home_date_header.dart';
import 'package:money_fit/features/home/widgets/home_main_card.dart';
import 'package:money_fit/features/home/widgets/home_action_buttons.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
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
    final userAsync = ref.watch(userSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    if (homeStateAsync.isLoading || userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (homeStateAsync.hasError || userAsync.hasError) {
      final error = homeStateAsync.error ?? userAsync.error;
      return Scaffold(
        body: Center(child: Text(l10n.errorOccurred(error.toString()))),
      );
    }

    final homeState = homeStateAsync.value!;
    final user = userAsync.value!;

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
                HomeActionButtons(homeState: homeState, userId: user.id),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
