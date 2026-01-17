import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/services/app_initializer.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateOnce();
  }

  Future<void> _navigateOnce() async {
    try {
      // appInitializer에서 homeViewModelProvider도 초기화됨
      await ref.read(appInitializerProvider.future);
      
      // 이미 초기화되었으므로 동기적으로 현재 값 읽기
      final homeState = ref.read(homeViewModelProvider).valueOrNull;

      if (!mounted) return;
      if (homeState == null || homeState.dailyBudget == 0) {
        context.go('/budget_setup');
      } else {
        context.go('/home');
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (!mounted) return;
      context.go('/budget_setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 단순히 로딩 표시만 - watch로 인한 중복 호출 제거
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
