/// The cadence used when a user enters a budget amount.
///
/// This deliberately lives in foundation while the v5 `users` row and the
/// budget feature coexist. It keeps old serialized values stable without
/// making budget domain code depend on the legacy user model.
enum BudgetType { daily, monthly }
