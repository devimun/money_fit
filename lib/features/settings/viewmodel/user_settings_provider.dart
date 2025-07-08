import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// 사용자 설정을 관리하는 StateNotifier입니다.
class UserSettingsNotifier extends StateNotifier<AsyncValue<User>> {
  final UserRepository _userRepository;
  final Ref _ref; // Ref 추가

  UserSettingsNotifier(this._userRepository, this._ref)
    : super(const AsyncValue.loading()) {
    _loadUser();
  }

  // 사용자 정보를 로드하거나, 없으면 Supabase에서 익명 계정을 생성하고 로컬에 저장합니다.
  Future<void> _loadUser() async {
    log('Attempting to load user...');
    state = const AsyncValue.loading();
    try {
      final sb.SupabaseClient supabaseClient = sb.Supabase.instance.client;
      sb.User? supabaseUser = supabaseClient.auth.currentUser;

      if (supabaseUser == null) {
        log('No existing Supabase user. Attempting anonymous sign-in...');
        final sb.AuthResponse response = await supabaseClient.auth.signInAnonymously();
        supabaseUser = response.user;
        if (supabaseUser != null) {
          log('Anonymous sign-in successful. User ID: ${supabaseUser.id}');
        } else {
          log('Anonymous sign-in failed.');
          throw Exception('Failed to sign in anonymously.');
        }
      }

      final currentUserId = supabaseUser.id;
      log('Current User ID: $currentUserId');

      User? user = await _userRepository.getUser(currentUserId);

      if (user == null) {
        log('No user found in local DB for ID: $currentUserId. Creating new user...');
        final newUser = User(
          id: currentUserId,
          email: null,
          displayName: null,
          dailyBudget: 0.0,
          isDarkMode: false,
          notificationsEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userRepository.createUser(newUser);
        user = newUser;
        log('New user created and saved to local DB.');
      } else {
        log('User found in local DB: ${user.toJson()}');
      }

      state = AsyncValue.data(user);
      log('User loaded successfully.');
    } catch (e, st) {
      log('Error in _loadUser: $e', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// 일일 예산을 업데이트합니다.
  Future<void> updateDailyBudget(double newBudget) async {
    if (state.hasValue) {
      final currentUser = state.value!;
      final updatedUser = currentUser.copyWith(
        dailyBudget: newBudget,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedUser);
      try {
        await _userRepository.updateUser(updatedUser);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
        // 업데이트 실패 시 이전 상태로 되돌릴 수 있습니다.
        state = AsyncValue.data(currentUser);
      }
    }
  }

  /// 다크 모드 설정을 토글합니다.
  Future<void> toggleDarkMode() async {
    if (state.hasValue) {
      final currentUser = state.value!;
      final updatedUser = currentUser.copyWith(
        isDarkMode: !currentUser.isDarkMode,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedUser);
      try {
        await _userRepository.updateUser(updatedUser);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
        state = AsyncValue.data(currentUser);
      }
    }
  }

  /// 알림 설정 토글합니다.
  Future<void> toggleNotifications() async {
    if (state.hasValue) {
      final currentUser = state.value!;
      final updatedUser = currentUser.copyWith(
        notificationsEnabled: !currentUser.notificationsEnabled,
        updatedAt: DateTime.now(),
      );
      state = AsyncValue.data(updatedUser);
      try {
        await _userRepository.updateUser(updatedUser);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
        state = AsyncValue.data(currentUser);
      }
    }
  }

  // TODO: 이메일, display_name 업데이트 메서드 추가
}

/// UserSettingsNotifier를 제공하는 StateNotifierProvider입니다.
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, AsyncValue<User>>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      return UserSettingsNotifier(userRepository, ref); // Ref를 전달
    });

