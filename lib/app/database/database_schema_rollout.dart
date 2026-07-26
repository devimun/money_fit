/// Controls when an on-device database can move to the v6 ledger schema.
///
/// The application still composes repositories that read the v5
/// `users`/`categories`/`expenses` columns.  A schema-version bump must stay
/// coupled to replacing those repositories; otherwise an upgrade succeeds and
/// the next read fails with missing-column errors.  Keeping that decision in a
/// single, testable gate prevents an accidental version-only rollout.
abstract final class DatabaseSchemaRollout {
  static const legacyVersion = 5;
  static const v6Version = 6;

  /// The version opened by the currently shipped composition root.
  static const runtimeVersion = legacyVersion;

  /// Becomes true only in the release that also wires v6 ledger repositories.
  ///
  /// This is intentionally a compile-time release gate rather than a remote
  /// flag: SQLite schema versions cannot be safely rolled back by an older
  /// binary after a remote flag changes.
  static const v6RepositoriesAreActive = false;

  static bool shouldApplyV6Migration({
    required int oldVersion,
    required int newVersion,
  }) {
    return v6RepositoriesAreActive &&
        oldVersion < v6Version &&
        newVersion >= v6Version;
  }
}
