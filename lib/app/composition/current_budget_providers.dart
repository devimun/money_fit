import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// Supplies the local ledger owner without involving remote authentication or
/// the settings presentation feature.
class SessionCurrentOwner implements CurrentOwner {
  const SessionCurrentOwner(this._ref);

  final Ref _ref;

  @override
  Future<String> get id async => _ref.read(currentOwnerIdProvider.future);
}
