import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// 사용자 설정을 관리하는 StateNotifier입니다.
class UserSettingsNotifier extends StateNotifier<AsyncValue<User>> {
  final UserRepository _userRepository;
  final NotificationService _notificationService;
  final sb.SupabaseClient _supabaseClient;

  UserSettingsNotifier(
    this._userRepository,
    this._notificationService,
    this._supabaseClient,
  ) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    log('Attempting to load user...');
    state = const AsyncValue.loading();
    try {
      final supabaseUser = await _getSupabaseUser();
      final currentUserId = supabaseUser.id;
      log('Current User ID: $currentUserId');

      User? user = await _userRepository.getUser(currentUserId);
      user ??= await _createNewUser(currentUserId);

      state = AsyncValue.data(user);
      log('User loaded successfully: ${user.toJson()}');
    } catch (e, st) {
      log('Error in _loadUser: $e', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
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
      dailyBudget: 0.0,
      isDarkMode: false,
      notificationsEnabled: false, // 기본값 false로 변경
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _userRepository.createUser(newUser);
    log('New user created and saved to local DB.');
    return newUser;
  }

  /// 일일 예산을 업데이트합니다.
  Future<void> updateDailyBudget(double newBudget) async {
    await _updateUserState((user) => user.copyWith(dailyBudget: newBudget));
  }

  /// 다크 모드 설정을 토글합니다.
  Future<void> toggleDarkMode() async {
    await _updateUserState(
      (user) => user.copyWith(isDarkMode: !user.isDarkMode),
    );
  }

  Future<void> enableNotifications() async {
    await _notificationService.scheduleDailyNotifications();
    await _updateUserState((u) => u.copyWith(notificationsEnabled: true));
  }

  Future<void> disableNotifications() async {
    await _notificationService.cancelAllNotifications();
    await _updateUserState((u) => u.copyWith(notificationsEnabled: false));
  }

  Future<void> _updateUserState(User Function(User) updater) async {
    if (state.hasValue) {
      final currentUser = state.value!;
      final updatedUser = updater(
        currentUser,
      ).copyWith(updatedAt: DateTime.now());
      state = AsyncValue.data(updatedUser);
      try {
        await _userRepository.updateUser(updatedUser);
      } catch (e, st) {
        log('Failed to update user: $e', stackTrace: st);
        state = AsyncValue.error(e, st);
        state = AsyncValue.data(currentUser); // Rollback on failure
      }
    }
  }

  /// Resets the user settings and re-initializes the user.
  Future<void> reset() async {
    log('Resetting user settings...');
    try {
      await _supabaseClient.auth.signOut();
      state = const AsyncValue.loading();
      await _loadUser();
      log('User settings reset successfully.');
    } catch (e, st) {
      log('Error resetting user settings: $e', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// UserSettingsNotifier를 제공하는 StateNotifierProvider입니다.
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, AsyncValue<User>>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      final supabaseClient = sb.Supabase.instance.client;
      return UserSettingsNotifier(
        userRepository,
        notificationService,
        supabaseClient,
      );
    });
