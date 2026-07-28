import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

void main() {
  test(
    'settings budget write tracks exactly once after persistence succeeds',
    () async {
      final repository = _FakeUserRepository(_user());
      final tracker = _RecordingAnalyticsTracker();
      final container = _container(repository: repository, tracker: tracker);
      addTearDown(container.dispose);

      await container.read(userSettingsProvider.future);
      final persisted = await container
          .read(userSettingsProvider.notifier)
          .updateBudget(BudgetType.monthly, 500000);

      expect(persisted, isTrue);
      expect(repository.updateCalls, 1);
      expect(tracker.events, hasLength(1));
      expect(tracker.events.single.$1, 'Budget Set');
      expect(tracker.events.single.$2, {
        'is_initial': false,
        'budget_period': 'monthly',
        'previous_budget_period': 'daily',
      });
    },
  );

  test(
    'failed settings budget write rolls back and emits no telemetry',
    () async {
      final original = _user();
      final repository = _FakeUserRepository(original, failUpdates: true);
      final tracker = _RecordingAnalyticsTracker();
      final container = _container(repository: repository, tracker: tracker);
      addTearDown(container.dispose);

      await container.read(userSettingsProvider.future);
      final persisted = await container
          .read(userSettingsProvider.notifier)
          .updateBudget(BudgetType.monthly, 500000);

      expect(persisted, isFalse);
      expect(repository.updateCalls, 1);
      expect(tracker.events, isEmpty);
      expect(container.read(userSettingsProvider).valueOrNull, original);
    },
  );
}

ProviderContainer _container({
  required _FakeUserRepository repository,
  required AnalyticsTracker tracker,
}) => ProviderContainer(
  overrides: [
    userRepositoryProvider.overrideWithValue(repository),
    analyticsTrackerProvider.overrideWithValue(tracker),
    currentOwnerIdProvider.overrideWith((ref) async => 'owner'),
  ],
);

User _user() => User(
  id: 'owner',
  budget: 100000,
  budgetType: BudgetType.daily,
  isDarkMode: false,
  notificationsEnabled: true,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _FakeUserRepository implements IUserRepository {
  _FakeUserRepository(this.user, {this.failUpdates = false});

  User user;
  final bool failUpdates;
  int updateCalls = 0;

  @override
  Future<void> createUser(User user) async => this.user = user;

  @override
  Future<void> deleteUser(String id) async {}

  @override
  Future<List<User>> getAllUsers() async => [user];

  @override
  Future<User?> getUser(String id) async => id == user.id ? user : null;

  @override
  Future<void> updateUser(User user) async {
    updateCalls++;
    if (failUpdates) throw StateError('write failed');
    this.user = user;
  }
}

class _RecordingAnalyticsTracker extends NoopAnalyticsTracker {
  final events = <(String, Map<String, Object>)>[];

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    events.add((name, Map<String, Object>.from(parameters)));
  }
}
