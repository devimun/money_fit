import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(userSettingsProvider, (previous, next) {
      // 로딩 중이거나 새로고침 중일 때는 아무것도 하지 않습니다.
      if (next.isLoading || next.isRefreshing) return;

      // 에러가 발생하면 온보딩 화면으로 이동합니다.
      if (next.hasError) {
        context.go('/onboarding');
        return;
      }

      // 데이터 로딩이 성공하면 예산 설정 여부를 확인합니다.
      if (next.hasValue) {
        final user = next.value;
        final dailyBudgetNotSet = user == null || user.dailyBudget == 0.0;

        if (dailyBudgetNotSet) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
