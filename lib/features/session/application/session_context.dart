import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';
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

/// The durable, device-local association between a ledger owner and a remote
/// account.  The remote value is metadata only: it is never used as a ledger
/// owner key.
class LocalSessionMapping {
  const LocalSessionMapping({required this.ownerId, this.remoteUserId});

  final String ownerId;
  final String? remoteUserId;

  Map<String, Object?> toJson() => {
    'ownerId': ownerId,
    'remoteUserId': remoteUserId,
  };

  static LocalSessionMapping? tryParse(String? encoded) {
    if (encoded == null) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return null;
      final ownerId = decoded['ownerId'];
      final remoteUserId = decoded['remoteUserId'];
      if (ownerId is! String || ownerId.isEmpty) return null;
      if (remoteUserId != null &&
          (remoteUserId is! String || remoteUserId.isEmpty)) {
        return null;
      }
      return LocalSessionMapping(
        ownerId: ownerId,
        remoteUserId: remoteUserId as String?,
      );
    } catch (_) {
      return null;
    }
  }
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
  static const _mappingKey = 'session.local_remote_mapping_v1';
  static const _migrationCompleteKey = 'session.local_owner_migrated_v1';

  @override
  Future<SessionState> build() => _load();

  Future<SessionState> _load() async {
    try {
      final preferences = ref.read(sharedPreferencesProvider);
      final owners = ref.read(localOwnerRepositoryProvider);
      final mapping = LocalSessionMapping.tryParse(
        preferences.getString(_mappingKey),
      );
      final persistedOwnerId = preferences.getString(_ownerIdKey);

      if (mapping != null) {
        final existing = await owners.get(mapping.ownerId);
        if (existing != null) {
          // Old app versions may have written the mapping before the marker.
          // Completing it here is safe because the single mapping value was
          // already written atomically by SharedPreferences.
          await _persistMapping(preferences, mapping);
          return SessionReady(
            SessionContext(
              ownerId: existing.id,
              remoteUserId: mapping.remoteUserId,
            ),
          );
        }
        await _clearPersistedMapping(preferences);
      }

      if (persistedOwnerId != null) {
        final existing = await owners.get(persistedOwnerId);
        if (existing != null) {
          await _persistMapping(
            preferences,
            LocalSessionMapping(
              ownerId: existing.id,
              remoteUserId: existing.remoteUserId,
            ),
          );
          return SessionReady(
            SessionContext(
              ownerId: existing.id,
              remoteUserId: existing.remoteUserId,
            ),
          );
        }
        await _clearPersistedMapping(preferences);
      }

      final existingOwners = await owners.getAll();
      if (existingOwners.length == 1) {
        final existing = existingOwners.single;
        final ownerId = existing.id;
        await _persistMapping(
          preferences,
          LocalSessionMapping(
            ownerId: ownerId,
            remoteUserId: existing.remoteUserId,
          ),
        );
        return SessionReady(
          SessionContext(ownerId: ownerId, remoteUserId: existing.remoteUserId),
        );
      }
      if (existingOwners.length > 1) {
        throw StateError(
          'Multiple local users require recovery before a ledger can be selected.',
        );
      }

      final now = ref.read(clockProvider).now();
      final ownerId = ref.read(idGeneratorProvider).next();
      await owners.create(LocalOwner(id: ownerId, createdAt: now));
      await _persistMapping(preferences, LocalSessionMapping(ownerId: ownerId));
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
    await _clearPersistedMapping(preferences);
    await retry();
  }

  /// Records a remote identity without ever changing the local ledger owner.
  /// Authentication integrations should call this after their session changes.
  Future<void> linkRemoteUser(String? remoteUserId) async {
    final current = await ref.read(sessionContextProvider.future);
    final normalizedRemoteId = remoteUserId?.trim();
    final mapping = LocalSessionMapping(
      ownerId: current.ownerId,
      remoteUserId: normalizedRemoteId == null || normalizedRemoteId.isEmpty
          ? null
          : normalizedRemoteId,
    );
    await ref
        .read(localOwnerRepositoryProvider)
        .setRemoteUserId(mapping.ownerId, mapping.remoteUserId);
    await _persistMapping(ref.read(sharedPreferencesProvider), mapping);
    state = AsyncData(
      SessionReady(
        SessionContext(
          ownerId: mapping.ownerId,
          remoteUserId: mapping.remoteUserId,
        ),
      ),
    );
  }

  Future<void> _persistMapping(
    SharedPreferences preferences,
    LocalSessionMapping mapping,
  ) async {
    // A single JSON document prevents a partial local/remote association. The
    // legacy owner key remains for compatibility with an installed older app.
    await preferences.setString(_mappingKey, jsonEncode(mapping.toJson()));
    await preferences.setString(_ownerIdKey, mapping.ownerId);
    await preferences.setBool(_migrationCompleteKey, true);
  }

  Future<void> _clearPersistedMapping(SharedPreferences preferences) async {
    await preferences.remove(_mappingKey);
    await preferences.remove(_ownerIdKey);
    await preferences.remove(_migrationCompleteKey);
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
