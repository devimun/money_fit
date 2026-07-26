import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_fit/main.dart';

void main() {
  testWidgets('app root builds without remote SDKs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final observer = NavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.test()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          appRouterObserversProvider.overrideWithValue([observer]),
          goRouterProvider.overrideWith(
            (ref) => GoRouter(
              initialLocation: '/',
              observers: ref.watch(appRouterObserversProvider),
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('App root ready')),
                  ),
                ),
              ],
            ),
          ),
          userSettingsProvider.overrideWith(_TestUserSettingsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App root ready'), findsOneWidget);
  });
}

class _TestUserSettingsNotifier extends UserSettingsNotifier {
  @override
  Future<User> build() async {
    return User(
      id: 'test-user',
      budget: 0,
      budgetType: BudgetType.daily,
      isDarkMode: false,
      notificationsEnabled: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }
}
