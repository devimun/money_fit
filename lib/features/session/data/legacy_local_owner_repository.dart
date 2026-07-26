import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';

/// v5 adapter retained until the schema rollout composes local_users directly.
class LegacyLocalOwnerRepository implements LocalOwnerRepository {
  const LegacyLocalOwnerRepository(this._users);

  final IUserRepository _users;

  @override
  Future<void> create(LocalOwner owner) {
    return _users.createUser(
      User(
        id: owner.id,
        budget: 0,
        budgetType: BudgetType.daily,
        isDarkMode: false,
        notificationsEnabled: false,
        createdAt: owner.createdAt,
        updatedAt: owner.createdAt,
      ),
    );
  }

  @override
  Future<void> delete(String id) => _users.deleteUser(id);

  @override
  Future<LocalOwner?> get(String id) async {
    final user = await _users.getUser(id);
    return user == null
        ? null
        : LocalOwner(id: user.id, createdAt: user.createdAt);
  }

  @override
  Future<List<LocalOwner>> getAll() async {
    final users = await _users.getAllUsers();
    return users
        .map((user) => LocalOwner(id: user.id, createdAt: user.createdAt))
        .toList(growable: false);
  }

  @override
  Future<void> setRemoteUserId(String ownerId, String? remoteUserId) async {
    // v5 has no durable local/remote identity column. SessionContext keeps the
    // mapping in its compatibility document until the v6 repository is active.
  }
}
