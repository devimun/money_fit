import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/data/category_row.dart';
import 'package:money_fit/features/ledger/data/expense_row.dart';
import 'package:money_fit/features/ledger/domain/category.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';

class LedgerMapper {
  const LedgerMapper(this.currency);

  final LedgerCurrency currency;

  ExpenseEntry expenseFromRow(ExpenseRow row) => ExpenseEntry(
    id: row.id,
    ownerId: row.userId,
    name: row.name,
    amount: Money.parse(row.amount.toString(), currency),
    occurredOn: LocalDate.parse(row.date),
    categoryId: row.categoryId,
    createdAt: DateTime.parse(row.createdAt),
    updatedAt: DateTime.parse(row.updatedAt),
  );

  LedgerCategory categoryFromRow(CategoryRow row, String ownerId) {
    final kind = switch (row.type) {
      'essential' => SpendingKind.essential,
      'discretionary' => SpendingKind.discretionary,
      _ => throw FormatException('Unknown category type.', row.type),
    };
    return LedgerCategory(
      id: row.id,
      ownerId: row.userId ?? ownerId,
      name: row.name,
      kind: kind,
      isBuiltIn: !row.isDeletable,
    );
  }
}
