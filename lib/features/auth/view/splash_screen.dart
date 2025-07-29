import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<HomeState>>(homeViewModelProvider, (previous, next) {
      next.when(
        data: (home) {
          if (home.dailyBudget == 0) {
            context.go('/onboarding');
          } else {
            context.go('/home');
          }
        },
        error: (err, stack) {
          // 에러 발생 시 (예: 사용자 설정 누락) 온보딩 화면으로 이동

          context.go('/onboarding');
        },
        loading: () {
          // 로딩 중에는 아무것도 하지 않음 (계속 스피너 표시)
        },
      );
    });

    // homeViewModelProvider를 구독하여 로딩을 시작하도록 합니다.
    ref.watch(homeViewModelProvider);

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
