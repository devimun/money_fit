import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/providers/navigation_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
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
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: '지출 내역'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
