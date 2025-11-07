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
      await ref.read(appInitializerProvider.future);
      final homeState = await ref.read(homeViewModelProvider.future);

      if (!mounted) return;
      if (homeState.dailyBudget == 0) {
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
    final appInitialization = ref.watch(appInitializerProvider);
    return appInitialization.when(
      data: (_) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
