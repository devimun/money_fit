import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/models/user_model.dart';

/// UserRepository의 인터페이스입니다.
/// 향후 Supabase 연동 시, 이 인터페이스를 따르는 새로운 리포지토리를 만들 수 있습니다.
abstract class IUserRepository {
  Future<User?> getUser(String id);
  Future<List<User>> getAllUsers();
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}

class UserRepository implements IUserRepository {
  final AppDatabase _database;

  UserRepository({required AppDatabase database}) : _database = database;

  @override
  Future<void> createUser(User user) async {
    final db = await _database.executor;
    await db.insert('users', user.toJson());
  }

  @override
  Future<User?> getUser(String id) async {
    final db = await _database.executor;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    final db = await _database.executor;
    final maps = await db.query('users', orderBy: 'created_at ASC, id ASC');
    return maps.map(User.fromJson).toList(growable: false);
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await _database.executor;
    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _database.executor;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
