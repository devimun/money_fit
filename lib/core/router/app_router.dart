import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/features/auth/view/splash_screen.dart';
import 'package:money_fit/widgets/bottom_nav_bar.dart';
import 'package:money_fit/features/home/view/home_screen.dart';
import 'package:money_fit/features/calendar/view/calendar_screen.dart';
import 'package:money_fit/features/expense/view/expense_list_screen.dart';
import 'package:money_fit/features/settings/view/settings_screen.dart';
import 'package:money_fit/features/onboarding/view/onboarding_screen.dart';
import 'package:money_fit/features/onboarding/view/daily_budget_setup_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/daily_budget_setup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const DailyBudgetSetupScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPageWithTransition(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => _buildPageWithTransition(
              key: state.pageKey,
              child: const CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/expense_list',
            pageBuilder: (context, state) => _buildPageWithTransition(
              key: state.pageKey,
              child: const ExpenseListScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _buildPageWithTransition(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<T> _buildPageWithTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const MainBottomNavBar());
  }
}

