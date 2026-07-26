class ExpenseRow {
  const ExpenseRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseRow.fromMap(Map<String, Object?> row) => ExpenseRow(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    name: row['name'] as String,
    amount: (row['amount'] as num).toDouble(),
    date: row['date'] as String,
    categoryId: row['category_id'] as String,
    type: row['type'] as String,
    createdAt: row['created_at'] as String,
    updatedAt: row['updated_at'] as String,
  );

  final String id;
  final String userId;
  final String name;
  final double amount;
  final String date;
  final String categoryId;
  final String type;
  final String createdAt;
  final String updatedAt;
}
