/// A local ledger owner. Its id is deliberately device-local; a remote account
/// identifier is optional metadata and must never be used as a ledger key.
class LocalOwner {
  const LocalOwner({
    required this.id,
    required this.createdAt,
    this.remoteUserId,
  });

  final String id;
  final DateTime createdAt;
  final String? remoteUserId;

  LocalOwner copyWith({String? remoteUserId}) {
    return LocalOwner(id: id, createdAt: createdAt, remoteUserId: remoteUserId);
  }
}

/// Storage boundary used by session startup.
///
/// Keeping this smaller than the historical `User` model prevents a remote
/// identity, presentation preference, or budget value from selecting a ledger.
abstract interface class LocalOwnerRepository {
  Future<LocalOwner?> get(String id);
  Future<List<LocalOwner>> getAll();
  Future<void> create(LocalOwner owner);
  Future<void> setRemoteUserId(String ownerId, String? remoteUserId);
  Future<void> delete(String id);
}
