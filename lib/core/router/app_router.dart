import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_fit/features/auth/view/splash_screen.dart';
import 'package:money_fit/features/statistics/view/statistics.dart';
import 'package:money_fit/widgets/bottom_nav_bar.dart';
import 'package:money_fit/features/home/view/home_screen.dart';
import 'package:money_fit/features/calendar/view/calendar_screen.dart';
import 'package:money_fit/features/expense/view/expense_list_screen.dart';
import 'package:money_fit/features/settings/view/settings_screen.dart';
import 'package:money_fit/features/onboarding/view/onboarding_screen.dart';
import 'package:money_fit/features/onboarding/view/budget_setup_screen.dart';
import 'package:money_fit/core/widgets/update_check_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/update-check',
    routes: [
      GoRoute(
        path: '/update-check',
        builder: (context, state) => const UpdateCheckScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/daily_budget_setup',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const BudgetSetupScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) {
              bool showNoti = false;
              final extras = state.extra as Map<String, dynamic>?;
              if (extras != null) {
                showNoti = extras['showNotificationPrompt'] == true;
              }

              return NoTransitionPage(
                key: state.pageKey,
                child: HomeScreen(showNotificationPrompt: showNoti),
              );
            },
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StatisticsScreen(),
            ),
          ),
          GoRoute(
            path: '/expense_list',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ExpenseListScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const MainBottomNavBar());
  }
}
