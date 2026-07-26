import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/session/application/session_context.dart';
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
      final user = _user('legacy-owner');
      final preferences = await _preferences();
      final container = _container(preferences, _FakeUsers([user]));
      addTearDown(container.dispose);

      final initial = await container.read(sessionProvider.future);
      expect((initial as SessionReady).context.ownerId, user.id);

      await container.read(sessionProvider.notifier).linkRemoteUser('remote-a');
      final linked =
          (container.read(sessionProvider).valueOrNull as SessionReady).context;
      expect(linked.ownerId, user.id);
      expect(linked.remoteUserId, 'remote-a');

      final mapping =
          jsonDecode(preferences.getString('session.local_remote_mapping_v1')!)
              as Map<String, dynamic>;
      expect(mapping, {'ownerId': user.id, 'remoteUserId': 'remote-a'});
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
        _FakeUsers([_user('local-owner')]),
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

ProviderContainer _container(SharedPreferences preferences, _FakeUsers users) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      userRepositoryProvider.overrideWithValue(users),
      clockProvider.overrideWithValue(FakeClock(DateTime.utc(2026))),
      idGeneratorProvider.overrideWithValue(FakeIds(['new-owner'])),
    ],
  );
}

User _user(String id) => User(
  id: id,
  budget: 0,
  budgetType: BudgetType.daily,
  isDarkMode: false,
  notificationsEnabled: false,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _FakeUsers implements IUserRepository {
  _FakeUsers(Iterable<User> initial) {
    for (final user in initial) {
      _users[user.id] = user;
    }
  }

  final Map<String, User> _users = {};

  @override
  Future<void> createUser(User user) async => _users[user.id] = user;

  @override
  Future<void> deleteUser(String id) async => _users.remove(id);

  @override
  Future<List<User>> getAllUsers() async => _users.values.toList();

  @override
  Future<User?> getUser(String id) async => _users[id];

  @override
  Future<void> updateUser(User user) async => _users[user.id] = user;
}
