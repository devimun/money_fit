import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/onboarding/widgets/daily_budget_setup_form.dart';
import 'package:money_fit/widgets/custom_notification_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class DailyBudgetSetupScreen extends ConsumerStatefulWidget {
  const DailyBudgetSetupScreen({super.key});

  @override
  ConsumerState<DailyBudgetSetupScreen> createState() =>
      _DailyBudgetSetupScreenState();
}

class _DailyBudgetSetupScreenState
    extends ConsumerState<DailyBudgetSetupScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submitBudget() async {
    if (_formKey.currentState!.validate()) {
      final newBudget = double.parse(_budgetController.text);
      await ref
          .read(userSettingsProvider.notifier)
          .updateDailyBudget(newBudget);
      if (mounted) {
        await _showNotificationDialog();
      }
    }
  }

  Future<void> _showNotificationDialog() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomNotificationDialog(
          onConfirm: () async {
            Navigator.of(context).pop();
            log('User confirmed notification setup.');
            await setupNotifications(context);
          },
          onDeny: () {
            Navigator.of(context).pop();
            context.go('/home');
          },
        );
      },
    );
  }

  Future<void> setupNotifications(BuildContext conTEXT) async {
    log('Requesting notification permission...');
    final permissionStatus = await Permission.notification.request();
    log('Notification permission status: ${permissionStatus.toString()}');
    if (permissionStatus.isGranted) {
      log('Notification permission granted. Scheduling daily notifications...');
      await ref.read(userSettingsProvider.notifier).enableNotifications();
    } else if (permissionStatus.isDenied) {
      log('Notification permission denied by user.');
    } else if (permissionStatus.isPermanentlyDenied) {
      log(
        'Notification permission permanently denied. User needs to enable it from settings.',
      );
      await openAppSettings();
    } else if (permissionStatus.isRestricted) {
      log('Notification permission restricted.');
    }
    if (conTEXT.mounted) {
      conTEXT.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: DailyBudgetSetupForm(
              formKey: _formKey,
              budgetController: _budgetController,
              onSubmitted: _submitBudget,
            ),
          ),
        ),
      ),
    );
  }
}
