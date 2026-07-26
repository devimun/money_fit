class CategoryRow {
  const CategoryRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.isDeletable,
  });

  factory CategoryRow.fromMap(Map<String, Object?> row) => CategoryRow(
    id: row['id'] as String,
    userId: row['user_id'] as String?,
    name: row['name'] as String,
    type: row['type'] as String,
    isDeletable: row['is_deletable'] == 1,
  );

  final String id;
  final String? userId;
  final String name;
  final String type;
  final bool isDeletable;
}
