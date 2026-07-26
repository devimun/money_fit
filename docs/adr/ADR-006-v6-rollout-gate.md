# ADR-006: v6 ledger schema runtime

- Status: Implemented
- Date: 2026-07-27

## Context

`SqliteV6Migration` converts v1–v5 data to the owner-scoped, minor-unit v6
ledger schema in one SQLite transaction. The running application now opens
schema version 6 and composes only v6-backed repositories. Historical UI
contracts for user, category, and expense data are retained as compatibility
projections; they do not read the removed v5 columns.

The v6 schema stores local owners, ledger currency, current budgets,
owner-scoped categories, and expenses separately. Foreign keys and checks are
enabled on every connection before migration or repository access.

## Decision

`DatabaseSchemaRollout` is the single, compile-time release decision:

- `runtimeVersion` is 6 and supplies the version passed to `openDatabase`.
- `v6RepositoriesAreActive` is true and is covered by a rollout composition
  test together with the version.
- `shouldApplyV6Migration` is the only `onUpgrade` path that calls
  `SqliteV6Migration`; new installs create the v6 tables directly.
- `SqliteV6UserRepository`, `SqliteV6LocalOwnerRepository`,
  `SqliteV6CurrentBudgetRepository`, and the v6-backed legacy ledger adapters
  are the composed persistence surface.

The migration audit, v1–v5 fixtures, rollback-on-error transaction test,
restart/idempotency test, and v6 constraint tests are release requirements for
future schema changes as well.

## Consequences and release checklist

The v6 activation was committed atomically with the following safeguards:

1. `runtimeVersion` is 6 and `v6RepositoriesAreActive` is true.
2. Every runtime repository is backed by v6 tables or a v6 compatibility
   projection.
3. v1–v5 fixture upgrades, restart/idempotency checks, and owner/category
   aggregate reconciliation.
4. A fresh v6 database and upgraded copies are tested.
5. Releases use staged rollout and a forward-fix build; never roll a v6 database back
   to an older binary.

SQLite versions cannot be lowered. A future incompatibility must be corrected
with a forward-fix build, not a binary rollback or remote feature flag.
