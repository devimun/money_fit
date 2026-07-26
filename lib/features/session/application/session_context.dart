import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The local identity which owns the on-device ledger.
///
/// It is deliberately independent from a remote authentication session. A
/// remote account may later be linked to this owner, but losing network access
/// must never select a different ledger or prevent startup.
class SessionContext {
  const SessionContext({required this.ownerId, this.remoteUserId});

  final String ownerId;
  final String? remoteUserId;
}

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionReady extends SessionState {
  const SessionReady(this.context);

  final SessionContext context;
}

class SessionRecoverableFailure extends SessionState {
  const SessionRecoverableFailure(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

/// Owns the stable local user ID used by all local feature data.
///
/// Existing v5 installations are adopted only when exactly one users row is
/// present. Multiple rows are an ambiguity, not a reason to silently open an
/// arbitrary person's ledger.
class SessionController extends AsyncNotifier<SessionState> {
  static const _ownerIdKey = 'session.local_owner_id';
  static const _migrationCompleteKey = 'session.local_owner_migrated_v1';

  @override
  Future<SessionState> build() => _load();

  Future<SessionState> _load() async {
    try {
      final preferences = ref.read(sharedPreferencesProvider);
      final users = ref.read(userRepositoryProvider);
      final persistedOwnerId = preferences.getString(_ownerIdKey);

      if (persistedOwnerId != null) {
        final existing = await users.getUser(persistedOwnerId);
        if (existing != null) {
          return SessionReady(SessionContext(ownerId: existing.id));
        }
        await preferences.remove(_ownerIdKey);
        await preferences.remove(_migrationCompleteKey);
      }

      final existingUsers = await users.getAllUsers();
      if (existingUsers.length == 1) {
        final ownerId = existingUsers.single.id;
        await _persistOwner(preferences, ownerId);
        return SessionReady(SessionContext(ownerId: ownerId));
      }
      if (existingUsers.length > 1) {
        throw StateError(
          'Multiple local users require recovery before a ledger can be selected.',
        );
      }

      final now = ref.read(clockProvider).now();
      final ownerId = ref.read(idGeneratorProvider).next();
      await users.createUser(
        User(
          id: ownerId,
          email: null,
          displayName: null,
          budget: 0,
          budgetType: BudgetType.daily,
          isDarkMode: false,
          notificationsEnabled: false,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _persistOwner(preferences, ownerId);
      return SessionReady(SessionContext(ownerId: ownerId));
    } catch (error, stackTrace) {
      return SessionRecoverableFailure(error, stackTrace);
    }
  }

  /// Re-runs local identity discovery after recovery or a scoped reset.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> clearLocalOwner() async {
    final preferences = ref.read(sharedPreferencesProvider);
    await preferences.remove(_ownerIdKey);
    await preferences.remove(_migrationCompleteKey);
    await retry();
  }

  Future<void> _persistOwner(
    SharedPreferences preferences,
    String ownerId,
  ) async {
    // Mark completion only after the owner mapping has been durably written.
    await preferences.setString(_ownerIdKey, ownerId);
    await preferences.setBool(_migrationCompleteKey, true);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

final sessionContextProvider = FutureProvider<SessionContext>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  return switch (session) {
    SessionReady(:final context) => context,
    SessionRecoverableFailure(:final error) => throw error,
    SessionLoading() => throw StateError('Session is still loading.'),
  };
});

final currentOwnerIdProvider = FutureProvider<String>((ref) async {
  return (await ref.watch(sessionContextProvider.future)).ownerId;
});
