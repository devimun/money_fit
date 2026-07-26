/// Controls when an on-device database can move to the v6 ledger schema.
///
/// A schema-version bump is coupled to the v6 repository composition. Keeping
/// that decision in a single, testable gate prevents a version-only rollout
/// that would expose v6 columns to v5 adapters.
abstract final class DatabaseSchemaRollout {
  static const legacyVersion = 5;
  static const v6Version = 6;

  /// The version opened by the shipped v6 composition root.
  static const runtimeVersion = v6Version;

  /// True only when this binary also wires v6 ledger repositories.
  ///
  /// This is intentionally a compile-time release gate rather than a remote
  /// flag: SQLite schema versions cannot be safely rolled back by an older
  /// binary after a remote flag changes.
  static const v6RepositoriesAreActive = true;

  static bool shouldApplyV6Migration({
    required int oldVersion,
    required int newVersion,
  }) {
    return v6RepositoriesAreActive &&
        oldVersion < v6Version &&
        newVersion >= v6Version;
  }
}
