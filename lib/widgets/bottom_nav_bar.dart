import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/providers/navigation_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.shifting,
      onTap: (index) {
        ref.read(navigationIndexProvider.notifier).state = index;
        switch (index) {
          case 0:
            ref.read(dateManager.notifier).changeDate(DateTime.now());
            context.go('/home');
            break;
          case 1:
            ref.read(dateManager.notifier).changeDate(DateTime.now());
            context.go('/calendar');
            break;
          case 2:
            ref.read(dateManager.notifier).changeDate(DateTime.now());
            context.go('/expense_list');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: AppLocalizations.of(context)!.calendar,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long),
          label: AppLocalizations.of(context)!.expense,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }
}
