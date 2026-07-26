import 'package:money_fit/core/foundation/budget_type.dart';

/// The currently active budget. A missing value means the setup flow has not
/// been completed yet; zero is never a valid configured budget.
class CurrentBudget {
  const CurrentBudget({required this.amount, required this.type})
    : assert(amount > 0);

  final double amount;
  final BudgetType type;
}
