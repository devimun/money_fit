import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/money.dart';

class NewExpenseDraft {
  const NewExpenseDraft({
    required this.name,
    required this.amount,
    required this.occurredOn,
    required this.categoryId,
  });

  final String name;
  final Money amount;
  final LocalDate occurredOn;
  final String categoryId;
}

class ExpensePatch extends NewExpenseDraft {
  const ExpensePatch({
    required this.id,
    required super.name,
    required super.amount,
    required super.occurredOn,
    required super.categoryId,
  });

  final String id;
}
