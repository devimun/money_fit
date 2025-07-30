import 'package:money_fit/core/database/database_helper.dart';
import 'package:money_fit/core/models/category_model.dart';

/// CategoryRepository의 인터페이스입니다.
abstract class ICategoryRepository {
  Future<List<Category>> getAllCategories(String? userId);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

class CategoryRepository implements ICategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  /// 기본 카테고리(userId가 null)와 특정 사용자가 생성한 카테고리를 모두 가져옵니다.
  @override
  Future<List<Category>> getAllCategories(String? userId) async {
    final db = await _dbHelper.database;
    // userId가 null인 경우, 기본 카테고리만 조회합니다.
    // userId가 제공된 경우, 기본 카테고리와 해당 사용자의 카테고리를 모두 조회합니다.
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: userId == null
          ? 'user_id IS NULL'
          : 'user_id IS NULL OR user_id = ?',
      whereArgs: userId == null ? null : [userId],
      orderBy: 'type',
    );

    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  @override
  Future<void> createCategory(Category category) async {
    // 사용자가 직접 추가하는 카테고리는 isDeletable이 항상 true여야 합니다.
    if (!category.isDeletable) {
      throw ArgumentError('User-created categories must be deletable.');
    }
    // 사용자가 직접 추가하는 카테고리는 userId가 반드시 있어야 합니다.
    if (category.userId == null) {
      throw ArgumentError('User-created categories must have a userId.');
    }

    final db = await _dbHelper.database;
    await db.insert('categories', category.toJson());
  }

  @override
  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toJson(),
      // 기본 카테고리는 수정할 수 없도록 id와 userId를 함께 확인합니다.
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, category.userId],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      // 기본 카테고리는 삭제할 수 없도록 is_deletable 플래그를 확인합니다.
      where: 'id = ? AND is_deletable = 1',
      whereArgs: [id],
    );
  }
}
