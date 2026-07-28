import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/platform/analytics_telemetry.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// Compatibility state for the remaining v5 user fields. Notification
/// preferences are owned by NotificationController.

class UserSettingsNotifier extends AsyncNotifier<User> {
  late final IUserRepository _userRepository;

  @override
  Future<User> build() async {
    _userRepository = ref.read(userRepositoryProvider);

    return await _loadUser();
  }

  Future<User> _loadUser() async {
    log('Attempting to load user...');
    try {
      final currentUserId = await ref.read(currentOwnerIdProvider.future);
      final user = await _userRepository.getUser(currentUserId);
      if (user == null) {
        throw StateError(
          'Session owner is missing from the local users table.',
        );
      }

      log('User loaded successfully: ${user.toJson()}');
      return user;
    } catch (e, st) {
      log('Error in _loadUser: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Returns whether the repository accepted the write. Telemetry is emitted
  /// only after that durable write succeeds.
  Future<bool> updateBudget(BudgetType budgetType, double newBudget) async {
    final currentUser = state.value;
    if (currentUser == null) return false;

    final updatedUser = currentUser.copyWith(
      budgetType: budgetType,
      budget: newBudget,
      updatedAt: ref.read(clockProvider).now(),
    );
    state = AsyncValue.data(updatedUser);

    try {
      await _userRepository.updateUser(updatedUser);
    } catch (e, st) {
      log('Failed to update user: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUser); // rollback
      return false;
    }

    await ref
        .read(analyticsTrackerProvider)
        .trackBudgetSetBestEffort(
          isInitial: false,
          budgetPeriod: budgetType,
          previousBudgetPeriod: currentUser.budgetType,
        );
    return true;
  }

  // Note: toggleDarkMode has been moved to themeModeProvider in theme_provider.dart
  // Dark mode is now managed by ThemeSettings instead of User model

  /// 사용자 설정을 초기화합니다.
  Future<void> reset() async {
    log('Resetting user settings...');
    try {
      state = const AsyncValue.loading();
      await ref.read(sessionProvider.notifier).clearLocalOwner();
      state = AsyncValue.data(await _loadUser());
      log('User settings reset successfully.');
    } catch (e, st) {
      log('Error resetting user settings: $e', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// UserSettingsNotifier를 제공하는 StateNotifierProvider입니다.
final userSettingsProvider = AsyncNotifierProvider<UserSettingsNotifier, User>(
  () {
    return UserSettingsNotifier();
  },
);
