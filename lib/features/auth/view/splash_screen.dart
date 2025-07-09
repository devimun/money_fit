import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(userSettingsProvider, (previous, next) async {
      if (next.isLoading || next.isRefreshing) return;

      if (next.hasError ||
          next.value == null ||
          next.value!.dailyBudget == 0.0) {
        context.go('/onboarding');
        return;
      }

      final user = next.value!;
      final success = await ref
          .read(homeViewModelProvider.notifier)
          .initialize(user);

      if (success) {
        if (context.mounted) {
          context.go('/home');
        }
      } else {
        if (context.mounted) {
          context.go('/onboarding');
        }
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
