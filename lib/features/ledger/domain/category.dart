enum SpendingKind { essential, discretionary }

class LedgerCategory {
  const LedgerCategory({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.kind,
    required this.isBuiltIn,
  });

  final String id;
  final String ownerId;
  final String name;
  final SpendingKind kind;
  final bool isBuiltIn;
}
