import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/core/foundation/spending_kind.dart';
import 'package:money_fit/features/ledger/data/legacy/category_model.dart';
import 'package:money_fit/features/ledger/data/legacy/category_repository.dart';
import 'package:sqflite/sqflite.dart';

/// Compatibility adapter for presentation still expressed in [Category].
///
/// It keeps legacy widgets off v6 column names while all data remains in the
/// owner-scoped v6 `categories` table.
class SqliteV6LegacyCategoryRepository implements ICategoryRepository {
  const SqliteV6LegacyCategoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Category>> getAllCategories(String? userId) async {
    if (userId == null) return const [];
    final db = await _database.executor;
    final rows = await db.query(
      'categories',
      where: 'owner_id = ? AND archived_at IS NULL',
      whereArgs: [userId],
      orderBy: 'spending_kind, is_built_in DESC, stable_code, display_name',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> createCategory(Category category) async {
    if (!category.isDeletable || category.userId == null) {
      throw ArgumentError(
        'User-created categories must be owned and deletable.',
      );
    }
    final db = await _database.executor;
    await db.insert('categories', {
      'id': category.id,
      'owner_id': category.userId,
      'stable_code': null,
      'display_name': category.name,
      'spending_kind': _kind(category.type),
      'is_built_in': 0,
      'archived_at': null,
    });
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (category.userId == null || !category.isDeletable) {
      throw const ConstraintFailure(
        constraint: 'Built-in categories cannot be changed.',
      );
    }
    final db = await _database.executor;
    final changed = await db.update(
      'categories',
      {'display_name': category.name, 'spending_kind': _kind(category.type)},
      where: 'id = ? AND owner_id = ? AND is_built_in = 0',
      whereArgs: [category.id, category.userId],
    );
    if (changed == 0) {
      throw NotFoundFailure(resource: 'Category', identifier: category.id);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _database.executor;
    final rows = await db.query(
      'categories',
      columns: const ['id', 'owner_id', 'is_built_in'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      throw NotFoundFailure(resource: 'Category', identifier: id);
    }
    if (rows.single['is_built_in'] == 1) {
      throw const ConstraintFailure(
        constraint: 'Built-in categories cannot be deleted.',
      );
    }
    final usage = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM expenses WHERE category_id = ?', [
        id,
      ]),
    );
    if ((usage ?? 0) > 0) {
      throw const ConstraintFailure(
        constraint: 'Categories in use cannot be deleted.',
      );
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Category _fromRow(Map<String, Object?> row) {
    final builtIn = row['is_built_in'] == 1;
    final name = builtIn ? row['stable_code'] : row['display_name'];
    final kind = row['spending_kind'];
    if (name is! String || kind is! String) {
      throw const FormatException('Invalid v6 category row.');
    }
    return Category(
      id: row['id'] as String,
      userId: row['owner_id'] as String,
      name: name,
      type: kind == 'essential'
          ? SpendingKind.essential
          : SpendingKind.discretionary,
      isDeletable: !builtIn,
    );
  }

  String _kind(SpendingKind kind) => switch (kind) {
    SpendingKind.essential => 'essential',
    SpendingKind.discretionary => 'discretionary',
    SpendingKind.unknown => throw ArgumentError.value(kind, 'type'),
  };
}
