import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/money.dart';

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.amount,
    required this.occurredOn,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final Money amount;
  final LocalDate occurredOn;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
