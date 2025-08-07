import 'package:flutter/foundation.dart';

// "필수", "변동" 타입을 나타내는 enum
enum ExpenseType { essential, discretionary, n }

@immutable
class Expense {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final String categoryId;
  final ExpenseType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
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

  Expense copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    DateTime? date,
    String? categoryId,
    ExpenseType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      // 날짜만 저장되므로, 자정(UTC)으로 파싱
      date: DateTime.parse(json['date'] as String),
      categoryId: json['category_id'] as String,
      type: ExpenseType.values.firstWhere((e) => e.name == json['type'], orElse: () => ExpenseType.n),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String().substring(0, 10),
      'category_id': categoryId,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
