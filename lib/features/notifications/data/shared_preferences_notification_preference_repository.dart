import 'package:money_fit/features/notifications/domain/notification_preference_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// v6 notification intent storage.
///
/// Notification preference is local device behaviour, not financial ledger
/// data, so it deliberately stays outside the normalized SQLite ledger schema.
class SharedPreferencesNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  const SharedPreferencesNotificationPreferenceRepository(this._preferences);

  static const _keyPrefix = 'notifications.enabled.v1.';

  final SharedPreferences _preferences;

  @override
  Future<void> clear(String ownerId) async {
    await _preferences.remove(_keyFor(ownerId));
  }

  @override
  Future<bool> isEnabled(String ownerId) async {
    return _preferences.getBool(_keyFor(ownerId)) ?? false;
  }

  @override
  Future<void> setEnabled(String ownerId, bool enabled) async {
    await _preferences.setBool(_keyFor(ownerId), enabled);
  }

  String _keyFor(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'must not be blank');
    }
    return '$_keyPrefix$ownerId';
  }
}
