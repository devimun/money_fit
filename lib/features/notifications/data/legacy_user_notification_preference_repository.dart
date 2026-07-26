import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/notifications/domain/notification_preference_repository.dart';

/// v5 boundary while notification intent remains in `users`.
class LegacyUserNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  const LegacyUserNotificationPreferenceRepository(this._users, this._now);

  final IUserRepository _users;
  final DateTime Function() _now;

  @override
  Future<void> clear(String ownerId) => setEnabled(ownerId, false);

  @override
  Future<bool> isEnabled(String ownerId) async {
    final user = await _users.getUser(ownerId);
    if (user == null) throw StateError('Missing local session user.');
    return user.notificationsEnabled;
  }

  @override
  Future<void> setEnabled(String ownerId, bool enabled) async {
    final user = await _users.getUser(ownerId);
    if (user == null) throw StateError('Missing local session user.');
    await _users.updateUser(
      user.copyWith(notificationsEnabled: enabled, updatedAt: _now()),
    );
  }
}
