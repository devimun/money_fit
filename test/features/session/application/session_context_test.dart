import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'ready context keeps the local owner independent from remote identity',
    () {
      const context = SessionContext(
        ownerId: 'local-owner',
        remoteUserId: 'remote-account',
      );

      expect(context.ownerId, 'local-owner');
      expect(context.ownerId, isNot(context.remoteUserId));
    },
  );

  test('multiple local users are represented as a recoverable state', () {
    final state = SessionRecoverableFailure(
      StateError('Multiple local users require recovery.'),
      StackTrace.empty,
    );

    expect(state.error, isA<StateError>());
  });

  test(
    'adopts a legacy owner and persists a single local/remote mapping',
    () async {
      final owner = LocalOwner(id: 'legacy-owner', createdAt: DateTime(2026));
      final preferences = await _preferences();
      final container = _container(preferences, _FakeOwners([owner]));
      addTearDown(container.dispose);

      final initial = await container.read(sessionProvider.future);
      expect((initial as SessionReady).context.ownerId, owner.id);

      await container.read(sessionProvider.notifier).linkRemoteUser('remote-a');
      final linked =
          (container.read(sessionProvider).valueOrNull as SessionReady).context;
      expect(linked.ownerId, owner.id);
      expect(linked.remoteUserId, 'remote-a');

      final mapping =
          jsonDecode(preferences.getString('session.local_remote_mapping_v1')!)
              as Map<String, dynamic>;
      expect(mapping, {'ownerId': owner.id, 'remoteUserId': 'remote-a'});
      expect(preferences.getBool('session.local_owner_migrated_v1'), isTrue);
    },
  );

  test(
    'remote mapping recovery never replaces the local ledger owner',
    () async {
      SharedPreferences.setMockInitialValues({
        'session.local_remote_mapping_v1': jsonEncode({
          'ownerId': 'local-owner',
          'remoteUserId': 'remote-before',
        }),
      });
      final preferences = await SharedPreferences.getInstance();
      final container = _container(
        preferences,
        _FakeOwners([LocalOwner(id: 'local-owner', createdAt: DateTime(2026))]),
      );
      addTearDown(container.dispose);

      final recovered = await container.read(sessionProvider.future);
      expect((recovered as SessionReady).context.ownerId, 'local-owner');
      expect(recovered.context.remoteUserId, 'remote-before');

      await container
          .read(sessionProvider.notifier)
          .linkRemoteUser('remote-after');
      final changed =
          (container.read(sessionProvider).valueOrNull as SessionReady).context;
      expect(changed.ownerId, 'local-owner');
      expect(changed.remoteUserId, 'remote-after');
    },
  );
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

ProviderContainer _container(
  SharedPreferences preferences,
  _FakeOwners owners,
) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      localOwnerRepositoryProvider.overrideWithValue(owners),
      clockProvider.overrideWithValue(FakeClock(DateTime.utc(2026))),
      idGeneratorProvider.overrideWithValue(FakeIds(['new-owner'])),
    ],
  );
}

class _FakeOwners implements LocalOwnerRepository {
  _FakeOwners(Iterable<LocalOwner> initial) {
    for (final owner in initial) {
      _owners[owner.id] = owner;
    }
  }

  final Map<String, LocalOwner> _owners = {};

  @override
  Future<void> create(LocalOwner owner) async => _owners[owner.id] = owner;

  @override
  Future<void> delete(String id) async => _owners.remove(id);

  @override
  Future<List<LocalOwner>> getAll() async => _owners.values.toList();

  @override
  Future<LocalOwner?> get(String id) async => _owners[id];

  @override
  Future<void> setRemoteUserId(String ownerId, String? remoteUserId) async {
    final owner = _owners[ownerId];
    if (owner == null) throw StateError('Missing owner: $ownerId');
    _owners[ownerId] = owner.copyWith(remoteUserId: remoteUserId);
  }
}
