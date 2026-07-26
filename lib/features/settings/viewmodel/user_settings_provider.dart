import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// 사용자 설정을 관리하는 AsyncNotifier입니다.
import 'package:money_fit/l10n/app_localizations.dart';

class UserSettingsNotifier extends AsyncNotifier<User> {
  late final UserRepository _userRepository;
  late final NotificationService _notificationService;

  @override
  Future<User> build() async {
    _userRepository = ref.read(userRepositoryProvider);
    _notificationService = ref.read(notificationServiceProvider);

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

  Future<void> updateBudget(BudgetType budgetType, double newBudget) async {
    final currentUser = state.value;
    if (currentUser == null) return;

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
    }
  }

  // Note: toggleDarkMode has been moved to themeModeProvider in theme_provider.dart
  // Dark mode is now managed by ThemeSettings instead of User model

  Future<void> enableNotifications(AppLocalizations l10n) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    await _notificationService.scheduleDailyNotifications(l10n);
    final updatedUser = currentUser.copyWith(
      notificationsEnabled: true,
      updatedAt: ref.read(clockProvider).now(),
    );

    state = AsyncValue.data(updatedUser);
    try {
      await _userRepository.updateUser(updatedUser);
    } catch (e, st) {
      log('Failed to enable notifications: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUser);
    }
  }

  Future<void> disableNotifications() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    await _notificationService.cancelAllNotifications();
    final updatedUser = currentUser.copyWith(
      notificationsEnabled: false,
      updatedAt: ref.read(clockProvider).now(),
    );

    state = AsyncValue.data(updatedUser);
    try {
      await _userRepository.updateUser(updatedUser);
    } catch (e, st) {
      log('Failed to disable notifications: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUser);
    }
  }

  /// 사용자의 언어/화폐 설정을 업데이트합니다.
  Future<void> updateLocale(String languageCode, String currencyCode) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      languageCode: languageCode,
      currencyCode: currencyCode,
      updatedAt: ref.read(clockProvider).now(),
    );

    state = AsyncValue.data(updatedUser);
    try {
      await _userRepository.updateUser(updatedUser);
      log('User locale updated: $languageCode / $currencyCode');
    } catch (e, st) {
      log('Failed to update locale: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUser);
    }
  }

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
