import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '예산 설정하기',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        automaticallyImplyLeading: false, // 온보딩 과정이므로 뒤로가기 버튼 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '하루 자유 지출 예산을 설정해주세요.\n자유 지출이란, 공과금,의료비,주거비,보험 등 필수 지출을 제외한 자유롭게 사용할 수 있는 금액을 말해요.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '일일 예산 (원)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '예산을 입력해주세요.';
                  }
                  if (double.tryParse(value) == null) {
                    return '유효한 숫자를 입력해주세요.';
                  }
                  if (double.parse(value) <= 0) {
                    return '예산은 0보다 커야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newBudget = double.parse(_budgetController.text);
                    await ref
                        .read(userSettingsProvider.notifier)
                        .updateDailyBudget(newBudget);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  }
                },

                child: Text(
                  '설정 완료',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
