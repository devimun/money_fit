import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/router/app_router.dart';

void main() {
  test(
    'current_bug_R12_protected_routes_bypass_bootstrap_gate_remove_in_PR_1_6',
    () {
      final container = ProviderContainer(
        overrides: [appRouterObserversProvider.overrideWithValue(const [])],
      );
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);
      addTearDown(router.dispose);

      for (final path in const [
        '/home',
        '/calendar',
        '/stats',
        '/expense_list',
        '/settings',
      ]) {
        router.go(path);

        expect(router.routeInformationProvider.value.uri.path, path);
      }
    },
  );
}
