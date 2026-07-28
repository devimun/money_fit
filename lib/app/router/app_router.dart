import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/auth/view/splash_screen.dart';
import 'package:money_fit/features/statistics/view/statistics.dart';
import 'package:money_fit/app/shell/app_shell.dart';
import 'package:money_fit/features/home/view/home_screen.dart';
import 'package:money_fit/features/calendar/view/calendar_screen.dart';
import 'package:money_fit/features/ledger/presentation/history/view/expense_list_screen.dart';
import 'package:money_fit/features/settings/view/settings_screen.dart';
// 온보딩 과정을 줄이기 위해 제거
// import 'package:money_fit/features/onboarding/view/onboarding_screen.dart';
import 'package:money_fit/features/budget/presentation/setup/budget_setup_screen.dart';
import 'package:money_fit/features/app_update/presentation/update_check_screen.dart';

import 'app_routes.dart';
import 'analytics_navigation_observer.dart';
import 'bootstrap_failure_screen.dart';
import 'bootstrap_gate.dart';
import 'package:money_fit/app/bootstrap/bootstrap_controller.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigation observers used by the root navigator. Branch navigators receive
/// fresh observer instances below, all sharing this tracker for de-duplication.
final analyticsScreenViewTrackerProvider = Provider<AnalyticsScreenViewTracker>(
  (ref) => AnalyticsScreenViewTracker(ref.watch(analyticsTrackerProvider)),
);

final appRouterObserversProvider = Provider<List<NavigatorObserver>>(
  (ref) => [
    AnalyticsNavigatorObserver(ref.watch(analyticsScreenViewTrackerProvider)),
  ],
);

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(bootstrapGateProvider);
  ref.read(bootstrapControllerProvider).start();
  List<NavigatorObserver> branchObservers() => [
    AnalyticsNavigatorObserver(ref.read(analyticsScreenViewTrackerProvider)),
  ];

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.updateCheck,
    redirect: (context, state) {
      return redirectForBootstrapGate(
        ref.read(bootstrapGateProvider),
        state.uri,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.updateCheck,
        name: 'UpdateCheckScreen',
        builder: (context, state) => const UpdateCheckScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        name: 'SplashScreen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.bootstrapFailure,
        name: 'BootstrapFailureScreen',
        builder: (context, state) => BootstrapFailureScreen(
          arguments: BootstrapRouteArguments.fromUri(state.uri),
        ),
      ),
      // 온보딩 과정을 줄이기 위해 바로 BudgetSetup 화면으로 이동
      // GoRoute(
      //   path: '/onboarding',
      //   name: 'OnboardingScreen',
      //   pageBuilder: (context, state) => NoTransitionPage(
      //     key: state.pageKey,
      //     child: const OnboardingScreen(),
      //   ),
      // ),
      GoRoute(
        path: AppRoutes.budgetSetup,
        name: 'BudgetSetupScreen',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const BudgetSetupScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          screenViewTracker: ref.read(analyticsScreenViewTrackerProvider),
        ),
        branches: [
          StatefulShellBranch(
            observers: branchObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: 'HomeScreen',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: HomeScreen(
                      showNotificationPrompt: HomeRouteArguments.fromUri(
                        state.uri,
                      ).showNotificationPrompt,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            observers: branchObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                name: 'CalendarScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CalendarScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: branchObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.statistics,
                name: 'StatisticsScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const StatisticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: branchObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.expenseList,
                name: 'ExpenseListScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ExpenseListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: branchObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'SettingsScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    observers: ref.watch(appRouterObserversProvider),
  );
});

String? redirectForBootstrapGate(BootstrapGateState gate, Uri uri) {
  final path = uri.path;
  final arguments = BootstrapRouteArguments.fromUri(uri);
  final isProtected = _protectedPaths.contains(path);
  final intendedPath = isProtected
      ? AppRouteReturnTarget.fromUri(uri)
      : arguments.returnTo;

  switch (gate) {
    case BootstrapGateState.checkingUpdate:
    case BootstrapGateState.initializing:
      if (path == AppRoutes.updateCheck || path == AppRoutes.splash) {
        return null;
      }
      return AppRoutes.withBootstrapReturnTo(
        AppRoutes.updateCheck,
        intendedPath,
      );
    case BootstrapGateState.forceUpdate:
      if (path == AppRoutes.updateCheck) return null;
      return AppRoutes.withBootstrapReturnTo(
        AppRoutes.updateCheck,
        intendedPath,
      );
    case BootstrapGateState.needsSetup:
      if (path == AppRoutes.budgetSetup) return null;
      return AppRoutes.withBootstrapReturnTo(
        AppRoutes.budgetSetup,
        intendedPath,
      );
    case BootstrapGateState.recoverableFailure:
      if (path == AppRoutes.bootstrapFailure) return null;
      return AppRoutes.withBootstrapReturnTo(
        AppRoutes.bootstrapFailure,
        intendedPath,
      );
    case BootstrapGateState.ready:
      if (path == AppRoutes.updateCheck ||
          path == AppRoutes.splash ||
          path == AppRoutes.budgetSetup) {
        return arguments.returnTo?.location ?? AppRoutes.home();
      }
      return null;
  }
}

const _protectedPaths = {
  AppRoutes.homePath,
  AppRoutes.calendar,
  AppRoutes.statistics,
  AppRoutes.expenseList,
  AppRoutes.settings,
};
