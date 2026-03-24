# LinkVault Developer Bible

Version: 2.1  
Last Updated: 2026-03-24  
Status: Active  
Owner: Engineering  
Depends On: `docs/03_ARCHITECTURE/Technical_Architecture.md`, `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`, `docs/05_MONETIZATION/Monetization_Strategy_RevenueCat_Guide.md`, `docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md`, `docs/10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md`

---

## Purpose

This is the non-negotiable engineering rulebook for LinkVault implementation.  
When another document conflicts with this one, raise an ADR before coding.

---

## Absolute Rules

### 1) Riverpod Is the Only App-State Framework

Allowed:

- `flutter_riverpod`
- Riverpod codegen annotations where useful

Not allowed:

- `flutter_bloc`
- `provider`
- feature state in `setState` (except local animation-only concerns)

### 2) Supabase Is the Only Product Data Backend

Allowed:

- Supabase Auth
- Supabase PostgreSQL (`lv_*` tables)
- Supabase Storage

Not allowed:

- Firebase Auth/Firestore/Realtime DB for product data paths
- parallel backend stacks for the same business flow

### 3) ObjectBox Is Mandatory for Local Persistence

Not allowed:

- Isar/Hive/SQLite for primary product persistence in new implementation

### 4) Every Mutation Must Flow Through a Use Case

Screens/providers cannot write through repositories directly.

### 5) Environment and Secrets Discipline

- no hardcoded keys in Dart
- use flavor-specific env files
- fail startup if required keys are missing

### 6) Type-Safe Error Handling

- use `Either<Failure, T>`
- no silent catch blocks
- map external exceptions into project failures

---

## Dependency Direction

```text
Presentation -> Application -> Domain <- Data <- Infrastructure
```

Violations must be corrected before merge.

---

## Runtime Contracts

### Repository Selection

Repository injection must be decided by:

- auth state
- premium entitlement
- migration completion flag
- connectivity state

No feature is allowed to bypass the selector.

### Collections and URLs Contract

- Collections use LinkVault schema semantics (`parentId`, `position`, `isDeleted`).
- URLs use LinkVault schema semantics (`collectionId`, `status`, `clickCount`, metadata fields).
- All cloud models map to `lv_collections` and `lv_urls`.

### Migration Contract

- premium enablement can trigger local-to-cloud migration
- migration must be idempotent and resumable
- legacy Firebase import remains optional and non-blocking

---

## Code Organization Rules

### Feature Layout

Every feature follows:

```text
feature/
├── domain/
├── application/usecases/
├── data/{models,mappers,repositories}/
└── presentation/{providers,screens,widgets}/
```

### Naming Rules

- `*Entity` for domain entities
- `*Model` for persistence models
- `Local*Repository` and `Supabase*Repository` for data implementations
- `*Usecase` for use case classes
- providers end with `Provider`

---

## Data and Schema Rules

- business IDs are UUID strings and remain stable across local/cloud stores
- local store keeps sync metadata (`updatedAt`, `isDeleted`, `deletedAt`)
- all cloud writes include owner identity fields and obey RLS model
- soft delete is preferred to hard delete for sync-safe behavior

---

## Security Rules

- RLS is required on every `lv_*` table before feature release
- user-scoped ownership checks are mandatory in insert/update/delete policies
- service-role operations are isolated to explicit administrative flows only
- export/import features must never include auth tokens

---

## Monetization Rules

- entitlement key: `premium`
- RevenueCat user identity must use Supabase `auth.uid()`
- use return values from purchase/restore calls directly
- premium checks gate cloud sync and ad bypass behavior

---

## Performance Rules

- list features with pagination must avoid full-table load in UI
- metadata fetch must be timeout-bound and non-blocking for save action
- reorder uses fractional indexing and rebalance logic when precision saturates

---

## Test Expectations

- each use case has unit tests
- repository mapping and failure paths are tested
- critical flows (auth, save URL, collection CRUD, premium migration) have integration coverage
- migration paths include success, retry, resume, and rollback-adjacent tests

---

## Pull Request Gate Checklist

Before merge:

- architecture boundaries respected
- no disallowed dependencies introduced
- no secrets added
- migration/sync behavior covered by tests where changed
- docs updated for behavior changes

---

## Violation Handling

If a rule is violated:

1. block merge
2. open remediation task
3. if rule must change, create ADR first

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 2.1 | 2026-03-24 | Depends on monetization model + ADR-0002 (free account Supabase + quotas). |
| 2.0 | 2026-03-23 | Rewritten as canonical engineering contract for execution phase. |
| 1.0 | 2026-03-20 | Initial reboot rules draft. |
