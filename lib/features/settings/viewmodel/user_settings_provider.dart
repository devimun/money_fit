import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// 사용자 설정을 관리하는 AsyncNotifier입니다.
import 'package:money_fit/l10n/app_localizations.dart';

class UserSettingsNotifier extends AsyncNotifier<User> {
  late final UserRepository _userRepository;
  late final NotificationService _notificationService;
  late final sb.SupabaseClient _supabaseClient;

  @override
  Future<User> build() async {
    _userRepository = ref.read(userRepositoryProvider);
    _notificationService = ref.read(notificationServiceProvider);
    _supabaseClient = sb.Supabase.instance.client;

    return await _loadUser();
  }

  Future<User> _loadUser() async {
    log('Attempting to load user...');
    try {
      final supabaseUser = await _getSupabaseUser();
      final currentUserId = supabaseUser.id;
      log('Current User ID: $currentUserId');

      User? user = await _userRepository.getUser(currentUserId);
      user ??= await _createNewUser(currentUserId);

      log('User loaded successfully: ${user.toJson()}');
      return user;
    } catch (e, st) {
      log('Error in _loadUser: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<sb.User> _getSupabaseUser() async {
    sb.User? supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser == null) {
      log('No existing Supabase user. Attempting anonymous sign-in...');
      final sb.AuthResponse response = await _supabaseClient.auth
          .signInAnonymously();
      supabaseUser = response.user;
      if (supabaseUser == null) {
        log('Anonymous sign-in failed.');
        throw Exception('Failed to sign in anonymously.');
      }
      log('Anonymous sign-in successful. User ID: ${supabaseUser.id}');
    }
    return supabaseUser;
  }

  Future<User> _createNewUser(String userId) async {
    log('No user found in local DB for ID: $userId. Creating new user...');
    final newUser = User(
      id: userId,
      email: null,
      displayName: null,
      budget: 0.0,
      budgetType: BudgetType.daily,
      isDarkMode: false,
      notificationsEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _userRepository.createUser(newUser);
    log('New user created and saved to local DB.');
    return newUser;
  }

  Future<void> updateBudget(BudgetType budgetType, double newBudget) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      budgetType: budgetType,
      budget: newBudget,
      updatedAt: DateTime.now(),
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

  Future<void> toggleDarkMode() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      isDarkMode: !currentUser.isDarkMode,
      updatedAt: DateTime.now(),
    );
    state = AsyncValue.data(updatedUser);

    try {
      await _userRepository.updateUser(updatedUser);
    } catch (e, st) {
      log('Failed to toggle dark mode: $e', stackTrace: st);
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUser);
    }
  }

  Future<void> enableNotifications(AppLocalizations l10n) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    await _notificationService.scheduleDailyNotifications(l10n);
    final updatedUser = currentUser.copyWith(
      notificationsEnabled: true,
      updatedAt: DateTime.now(),
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
      updatedAt: DateTime.now(),
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

  /// 사용자 설정을 초기화합니다.
  Future<void> reset() async {
    log('Resetting user settings...');
    try {
      await _supabaseClient.auth.signOut();
      state = const AsyncValue.loading();
      final user = await _loadUser();
      state = AsyncValue.data(user);
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
