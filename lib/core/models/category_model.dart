import 'package:flutter/foundation.dart';
import 'package:money_fit/core/models/expense_model.dart';

// 지출/카테고리 타입을 나타내는 enum

@immutable
class Category {
  final String id;
  final String? userId; // NULL이면 기본 카테고리
  final String name;
  final ExpenseType type;
  final bool isDeletable;

  const Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.isDeletable,
  });

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    ExpenseType? type,
    bool? isDeletable,
  }) {
    return Category(
      id: id ?? this.id,
      // userId는 null일 수 있으므로, 명시적으로 null로 변경하는 경우를 고려해야 함
      // 여기서는 간단하게 null이 아니면 기존 값을 사용하도록 처리
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      type: ExpenseType.values.firstWhere((e) => e.name == json['type'], orElse: () => ExpenseType.n),
      isDeletable: json['is_deletable'] is bool
          ? json['is_deletable']
          : json['is_deletable'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
      // 로컬 DB는 INTEGER 타입을 사용하므로 1 또는 0으로 변환
      'is_deletable': isDeletable ? 1 : 0,
    };
  }
}
