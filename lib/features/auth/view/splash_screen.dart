import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/app/bootstrap/app_initializer.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';

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

      final currentBudget = await ref.read(currentBudgetProvider.future);

      if (!mounted) return;
      final gate = currentBudget == null
          ? BootstrapGateState.needsSetup
          : BootstrapGateState.ready;
      ref.read(bootstrapGateProvider.notifier).set(gate);
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from == null ? '/' : '/?from=${Uri.encodeComponent(from)}');
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (!mounted) return;
      ref
          .read(bootstrapGateProvider.notifier)
          .set(BootstrapGateState.recoverableFailure);
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(
        from == null
            ? '/bootstrap-failure'
            : '/bootstrap-failure?from=${Uri.encodeComponent(from)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 단순히 로딩 표시만 - watch로 인한 중복 호출 제거
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
