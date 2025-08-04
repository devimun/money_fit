import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/onboarding/widgets/daily_budget_setup_form.dart';

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
      // 홈으로 이동시키고 알림 설정 요청 다이얼로그 띄우기
      if (mounted) {
        context.go('/home', extra: {'showNotificationPrompt': true});
      }
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
