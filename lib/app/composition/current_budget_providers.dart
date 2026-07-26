import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

/// Bridges the legacy settings-owned user to the budget feature during the
/// v5 compatibility period. PR 5.1 replaces this with SessionContext.
class SettingsCurrentOwner implements CurrentOwner {
  const SettingsCurrentOwner(this._ref);

  final Ref _ref;

  @override
  Future<String> get id async =>
      (await _ref.read(userSettingsProvider.future)).id;
}
