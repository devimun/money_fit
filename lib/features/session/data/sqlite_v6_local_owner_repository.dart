import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';

/// v6 implementation backed only by `local_users`.
class SqliteV6LocalOwnerRepository implements LocalOwnerRepository {
  const SqliteV6LocalOwnerRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> create(LocalOwner owner) async {
    if (owner.id.trim().isEmpty) {
      throw ArgumentError.value(owner.id, 'owner.id', 'must not be blank');
    }
    final db = await _database.executor;
    final batch = db.batch();
    batch.insert('local_users', {
      'id': owner.id,
      'remote_user_id': _normalizeRemoteUserId(owner.remoteUserId),
      'created_at': owner.createdAt.toUtc().toIso8601String(),
    });
    // A fresh local owner must be immediately usable by the ledger and budget
    // repositories. The migration has one settings row for every v5 owner, so
    // new v6 owners follow the same invariant.
    batch.insert('ledger_settings', {
      'owner_id': owner.id,
      'currency_code': 'USD',
    });
    for (final category in _builtInCategories) {
      batch.insert('categories', {
        'id': 'builtin:${owner.id}:${category.code}',
        'owner_id': owner.id,
        'stable_code': category.code,
        'display_name': null,
        'spending_kind': category.spendingKind,
        'is_built_in': 1,
        'archived_at': null,
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _database.executor;
    await db.delete('local_users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<LocalOwner?> get(String id) async {
    final db = await _database.executor;
    final rows = await db.query(
      'local_users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.single);
  }

  @override
  Future<List<LocalOwner>> getAll() async {
    final db = await _database.executor;
    final rows = await db.query(
      'local_users',
      orderBy: 'created_at ASC, id ASC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> setRemoteUserId(String ownerId, String? remoteUserId) async {
    final db = await _database.executor;
    final changed = await db.update(
      'local_users',
      {'remote_user_id': _normalizeRemoteUserId(remoteUserId)},
      where: 'id = ?',
      whereArgs: [ownerId],
    );
    if (changed != 1) {
      throw StateError('Cannot link a missing local owner: $ownerId');
    }
  }

  LocalOwner _fromRow(Map<String, Object?> row) {
    final id = row['id'];
    final createdAt = row['created_at'];
    if (id is! String || id.isEmpty || createdAt is! String) {
      throw FormatException('Invalid v6 local_users row');
    }
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      throw FormatException('Invalid local user creation time');
    }
    final remoteUserId = row['remote_user_id'];
    if (remoteUserId != null && remoteUserId is! String) {
      throw FormatException('Invalid remote user id');
    }
    return LocalOwner(
      id: id,
      createdAt: parsed.toUtc(),
      remoteUserId: remoteUserId as String?,
    );
  }

  String? _normalizeRemoteUserId(String? remoteUserId) {
    final normalized = remoteUserId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _BuiltInCategory {
  const _BuiltInCategory(this.code, this.spendingKind);

  final String code;
  final String spendingKind;
}

const _builtInCategories = <_BuiltInCategory>[
  _BuiltInCategory('food', 'essential'),
  _BuiltInCategory('traffic', 'essential'),
  _BuiltInCategory('communication', 'essential'),
  _BuiltInCategory('housing', 'essential'),
  _BuiltInCategory('medical', 'essential'),
  _BuiltInCategory('insurance', 'essential'),
  _BuiltInCategory('necessities', 'essential'),
  _BuiltInCategory('finance', 'essential'),
  _BuiltInCategory('eating-out', 'discretionary'),
  _BuiltInCategory('cafe', 'discretionary'),
  _BuiltInCategory('shopping', 'discretionary'),
  _BuiltInCategory('hobby', 'discretionary'),
  _BuiltInCategory('travel', 'discretionary'),
  _BuiltInCategory('subscribe', 'discretionary'),
  _BuiltInCategory('beauty', 'discretionary'),
];
