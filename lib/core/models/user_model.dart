import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String? email;
  final String? displayName;
  final double dailyBudget;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.email,
    this.displayName,
    required this.dailyBudget,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    double? dailyBudget,
    bool? isDarkMode,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      dailyBudget: (json['daily_budget'] as num).toDouble(),
      // 로컬 DB에서는 INTEGER, Supabase에서는 BOOLEAN일 수 있으므로 유연하게 처리
      isDarkMode: json['is_dark_mode'] is bool
          ? json['is_dark_mode']
          : json['is_dark_mode'] == 1,
      notificationsEnabled: json['notifications_enabled'] is bool
          ? json['notifications_enabled']
          : json['notifications_enabled'] == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'daily_budget': dailyBudget,
      'is_dark_mode': isDarkMode,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
