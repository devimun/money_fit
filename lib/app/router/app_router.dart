import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_fit/core/config/app_environment.dart';
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

import 'bootstrap_failure_screen.dart';
import 'bootstrap_gate.dart';
import 'package:money_fit/app/bootstrap/bootstrap_controller.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigation observers used by the application router.
///
/// Production records navigation with Firebase Analytics. Tests can override
/// this provider with a regular no-op [NavigatorObserver] without initializing
/// the Firebase SDK.
final appRouterObserversProvider = Provider<List<NavigatorObserver>>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (!environment.firebase.isAvailable) return const [];
  return [
    FailOpenFirebaseAnalyticsObserver(
      analytics: () => FirebaseAnalytics.instance,
      nameExtractor: (settings) => settings.name,
    ),
  ];
});

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(bootstrapGateProvider);
  ref.read(bootstrapControllerProvider).start();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/update-check',
    redirect: (context, state) {
      return redirectForBootstrapGate(
        ref.read(bootstrapGateProvider),
        state.uri,
      );
    },
    routes: [
      GoRoute(
        path: '/update-check',
        name: 'UpdateCheckScreen',
        builder: (context, state) => const UpdateCheckScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'SplashScreen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/bootstrap-failure',
        name: 'BootstrapFailureScreen',
        builder: (context, state) =>
            BootstrapFailureScreen(returnTo: state.uri.queryParameters['from']),
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
        path: '/budget_setup',
        name: 'BudgetSetupScreen',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const BudgetSetupScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'HomeScreen',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: HomeScreen(
                      showNotificationPrompt:
                          state.uri.queryParameters['showNotificationPrompt'] ==
                          'true',
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'CalendarScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CalendarScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'StatisticsScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const StatisticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expense_list',
                name: 'ExpenseListScreen',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ExpenseListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
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
  final from = uri.queryParameters['from'];
  final isProtected = _protectedPaths.contains(path);
  final intendedPath = isProtected ? uri.toString() : from;

  switch (gate) {
    case BootstrapGateState.checkingUpdate:
    case BootstrapGateState.initializing:
      if (path == '/update-check' || path == '/') return null;
      return _withFrom('/update-check', intendedPath);
    case BootstrapGateState.forceUpdate:
      if (path == '/update-check') return null;
      return _withFrom('/update-check', intendedPath);
    case BootstrapGateState.needsSetup:
      if (path == '/budget_setup') return null;
      return _withFrom('/budget_setup', intendedPath);
    case BootstrapGateState.recoverableFailure:
      if (path == '/bootstrap-failure') return null;
      return _withFrom('/bootstrap-failure', intendedPath);
    case BootstrapGateState.ready:
      if (path == '/update-check' || path == '/' || path == '/budget_setup') {
        return from ?? '/home';
      }
      return null;
  }
}

const _protectedPaths = {
  '/home',
  '/calendar',
  '/stats',
  '/expense_list',
  '/settings',
};

String _withFrom(String destination, String? from) {
  if (from == null || from.isEmpty) return destination;
  return '$destination?from=${Uri.encodeComponent(from)}';
}

/// Firebase analytics is optional and can initialize after the local UI.
/// This observer turns every unavailable or plugin failure into a no-op so
/// route transitions never depend on a remote SDK being ready.
class FailOpenFirebaseAnalyticsObserver extends NavigatorObserver {
  FailOpenFirebaseAnalyticsObserver({
    required FirebaseAnalytics Function() analytics,
    required this.nameExtractor,
  }) : _analytics = analytics;

  final FirebaseAnalytics Function() _analytics;
  final String? Function(RouteSettings settings) nameExtractor;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _sendScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _sendScreenView(previousRoute);
  }

  void _sendScreenView(Route<dynamic> route) {
    final screenName = nameExtractor(route.settings);
    if (screenName == null || screenName.isEmpty) return;
    unawaited(_logScreenView(screenName));
  }

  Future<void> _logScreenView(String screenName) async {
    try {
      await _analytics().logScreenView(screenName: screenName);
    } catch (_) {
      // Remote analytics is observational and therefore deliberately ignored.
    }
  }
}
