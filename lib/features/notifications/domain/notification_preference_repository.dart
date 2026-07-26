/// Durable opt-in state for local notification scheduling.
///
/// Permission and schedules are platform concerns; this repository only owns
/// the user's intent, keyed by the local ledger owner.
abstract interface class NotificationPreferenceRepository {
  Future<bool> isEnabled(String ownerId);
  Future<void> setEnabled(String ownerId, bool enabled);
  Future<void> clear(String ownerId);
}
