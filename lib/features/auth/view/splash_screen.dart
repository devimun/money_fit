import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/services/app_initializer.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitialization = ref.watch(appInitializerProvider);

    return appInitialization.when(
      data: (_) {
        // App Open Ad를 표시합니다.

        // 초기화가 완료되면 홈 화면의 상태를 확인합니다.
        ref.listen<AsyncValue<HomeState>>(homeViewModelProvider, (
          previous,
          next,
        ) {
          next.when(
            data: (home) async {
              if (home.dailyBudget == 0) {
                context.go('/onboarding');
              } else {
                await AppOpenAdManager.instance.showAdIfAvailable();
                await Future.delayed(Duration(milliseconds: 800), () {
                  context.go('/home');
                });
              }
            },
            error: (err, stack) {
              context.go('/onboarding');
            },
            loading: () {},
          );
        });

        // homeViewModelProvider와 categoryProvider를 구독하여 로딩을 시작합니다.
        ref.watch(homeViewModelProvider);
        ref.watch(categoryProvider);

        // 로딩 중 화면을 계속 표시하기 위해
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
