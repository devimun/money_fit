# ADR-006: v6 ledger schema rollout gate

- Status: Accepted for the PR 7.2 migration preparation release
- Date: 2026-07-27

## Context

`SqliteV6Migration` has a transaction-safe conversion from the v5 tables to
the owner-scoped, minor-unit v6 ledger schema.  The current application
composition still supplies the legacy `UserRepository`, `CategoryRepository`,
and `ExpenseRepository`; they read v5 columns such as `users.budget`,
`categories.user_id`, and `expenses.amount/date/type`.

Changing only `openDatabase(version: 6)` would successfully drop those
columns, then fail on the next repository read.  A remote feature flag is not
a safe substitute: an older binary cannot open a database once it has moved to
v6.

## Decision

The runtime remains at schema v5 until the v6 repository set is composed in
the same release.  `DatabaseSchemaRollout` is the single release gate:

- `runtimeVersion` supplies the version passed to `openDatabase`.
- `v6RepositoriesAreActive` must be changed together with that version and
  the new repository composition.
- `shouldApplyV6Migration` is the only `onUpgrade` path that calls
  `SqliteV6Migration`.
- SQLite foreign keys are enabled at connection configuration time, so the
  v6 release has the required connection behavior before its transaction
  begins.

The transaction, fixture audits, and v6 constraint tests are therefore
production-ready migration machinery, while the destructive switch is
explicitly blocked until its consumers are ready.

## Consequences and release checklist

The v6 activation commit must atomically include all of the following:

1. Set `runtimeVersion` to 6 and `v6RepositoriesAreActive` to true.
2. Replace every v5 repository in `appDatabaseProvider` composition.
3. Run v1–v5 fixture upgrades, restart/idempotency checks, and owner/category
   aggregate reconciliation.
4. Test a fresh v6 database as well as upgraded copies.
5. Use staged rollout and a forward-fix build; never roll a v6 database back
   to an older binary.

Until then, v5 remains the deliberately supported runtime schema rather than
an implicit partial v6 rollout.
