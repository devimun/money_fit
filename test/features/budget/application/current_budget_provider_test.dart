import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/budget_type.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/budget/domain/current_budget_repository.dart';

void main() {
  test(
    'setup status follows CurrentBudget presence rather than its amount',
    () async {
      final repository = _FakeBudgetRepository();
      final container = ProviderContainer(
        overrides: [
          currentOwnerProvider.overrideWithValue(const _Owner('owner')),
          currentBudgetRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentBudgetProvider.future);
      expect(container.read(budgetSetupCompleteProvider).valueOrNull, isFalse);

      await container
          .read(currentBudgetCommandsProvider)
          .save(const CurrentBudget(amount: 1, type: BudgetType.daily));

      await container.read(currentBudgetProvider.future);
      expect(container.read(budgetSetupCompleteProvider).valueOrNull, isTrue);
    },
  );

  test(
    'initial budget write emits one event only after persistence succeeds',
    () async {
      final repository = _FakeBudgetRepository();
      final tracker = _RecordingAnalyticsTracker();
      final container = ProviderContainer(
        overrides: [
          currentOwnerProvider.overrideWithValue(const _Owner('owner')),
          currentBudgetRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(currentBudgetCommandsProvider)
          .saveInitialBudget(
            const CurrentBudget(amount: 1, type: BudgetType.daily),
            analytics: tracker,
          );

      expect(repository.saveCalls, 1);
      expect(tracker.events, hasLength(1));
      expect(tracker.events.single.$1, 'Budget Set');
      expect(tracker.events.single.$2, {
        'is_initial': true,
        'budget_period': 'daily',
      });
    },
  );

  test('failed initial budget write emits no setup telemetry', () async {
    final repository = _FakeBudgetRepository(failSaves: true);
    final tracker = _RecordingAnalyticsTracker();
    final container = ProviderContainer(
      overrides: [
        currentOwnerProvider.overrideWithValue(const _Owner('owner')),
        currentBudgetRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(currentBudgetCommandsProvider)
          .saveInitialBudget(
            const CurrentBudget(amount: 1, type: BudgetType.daily),
            analytics: tracker,
          ),
      throwsStateError,
    );

    expect(repository.saveCalls, 1);
    expect(tracker.events, isEmpty);
  });
}

class _Owner implements CurrentOwner {
  const _Owner(this.value);

  final String value;

  @override
  Future<String> get id async => value;
}

class _FakeBudgetRepository implements CurrentBudgetRepository {
  _FakeBudgetRepository({this.failSaves = false});

  CurrentBudget? value;
  final bool failSaves;
  int saveCalls = 0;

  @override
  Future<CurrentBudget?> read(String ownerId) async => value;

  @override
  Future<void> save(String ownerId, CurrentBudget budget) async {
    saveCalls++;
    if (failSaves) throw StateError('write failed');
    value = budget;
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
