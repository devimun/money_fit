import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/onboarding/widgets/budget_setup_form.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BudgetType _budgetType = BudgetType.daily;

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
          .updateBudget(_budgetType, newBudget);

      // Onboarding complete event log
      await FirebaseAnalytics.instance.logEvent(name: 'first_budget_setting');

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
            child: BudgetSetupForm(
              formKey: _formKey,
              budgetController: _budgetController,
              onSubmitted: _submitBudget,
              selectedType: _budgetType,
              onTypeChanged: (type) {
                if (type != null) {
                  setState(() {
                    _budgetType = type;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
