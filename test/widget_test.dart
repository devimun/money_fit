import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts with configured dependencies', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('MoneyFit test home')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          analyticsProvider.overrideWithValue(const NoopAnalyticsService()),
          goRouterProvider.overrideWithValue(router),
          userSettingsProvider.overrideWith(_TestUserSettingsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    expect(find.text('MoneyFit test home'), findsOneWidget);
  });
}

class _TestUserSettingsNotifier extends UserSettingsNotifier {
  @override
  Future<User> build() async => User(
    id: 'test-user',
    budget: 0,
    budgetType: BudgetType.daily,
    isDarkMode: false,
    notificationsEnabled: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}
