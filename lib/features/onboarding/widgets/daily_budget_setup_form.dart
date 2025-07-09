import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyBudgetSetupForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController budgetController;
  final VoidCallback onSubmitted;

  const DailyBudgetSetupForm({
    super.key,
    required this.formKey,
    required this.budgetController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('예산 설정하기', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 20),
          Text(
            '하루 자유 지출 예산을 설정해주세요.\n자유 지출이란, 공과금,의료비,주거비,보험 등 필수 지출을 제외한 자유롭게 사용할 수 있는 금액을 말해요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: budgetController,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmitted,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                '시작하기',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
