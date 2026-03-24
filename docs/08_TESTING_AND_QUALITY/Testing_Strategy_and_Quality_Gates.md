# LinkVault Testing Strategy and Quality Gates

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering + QA  
Depends On: `docs/03_ARCHITECTURE/Technical_Architecture.md`, `docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md`

---

## Purpose

Define how LinkVault validates correctness, resilience, and release quality across unit, widget, integration, migration, and production-readiness testing.

---

## Testing Pyramid Targets

| Layer | Target Share | Focus |
|---|---:|---|
| Unit tests | 60-70% | use cases, mappers, repositories, sync logic |
| Widget tests | 20-25% | state rendering and interaction behavior |
| Integration tests | 10-15% | end-to-end app flows and tier transitions |
| Manual exploratory | mandatory for release | edge-case UX and platform behavior |

---

## Coverage Priorities

P0 modules:

- auth and session lifecycle
- collections and URLs CRUD
- repository selector and persistence states
- premium migration and sync reconciliation

P1 modules:

- monetization surfaces
- search and filter/sort
- RSS integration

---

## Test Matrix

| Area | Unit | Widget | Integration | Manual |
|---|---|---|---|---|
| Auth (guest/free/premium) | yes | yes | yes | yes |
| Collections | yes | yes | yes | yes |
| URLs and metadata | yes | yes | yes | yes |
| Sync queue and reconciliation | yes | optional | yes | yes |
| Premium migration flow | yes | yes | yes | yes |
| Legacy import (optional) | yes | optional | yes | yes |
| Monetization | yes | yes | yes | yes |
| Settings/export/import | yes | yes | yes | yes |

---

## Required Automated Scenarios

### Unit

- use case validation and failure paths
- mapper symmetry (`entity <-> local model <-> supabase json`)
- repository conflict resolution behavior
- sync queue retry/backoff behavior

### Widget

- loading/data/error states for core screens
- collection and URL list interactions
- paywall and migration prompt states

### Integration

1. Guest -> save links locally -> sign in -> free tier continuity.
2. Free -> premium purchase -> migration -> cloud-mode operations.
3. Premium online/offline transitions with queued writes.
4. Premium expiry and re-subscribe behavior.
5. Optional legacy import end-to-end run.

---

## Migration and Sync Test Playbook

For each test dataset size (small, medium, large):

1. seed local data
2. run migration
3. verify cloud row counts and integrity
4. run delta sync after offline edits
5. verify no duplicate IDs and no missing records
6. inspect conflict logs

Pass criteria:

- zero data-loss defects
- deterministic conflict outcomes
- queue drains successfully after reconnect

---

## Quality Gates

### Gate Q1: Build and Static Health

- analyzer/lints clean for changed areas
- code generation and build steps succeed

### Gate Q2: Automated Test Health

- unit pass rate 100%
- widget/integration pass rate 100% on release branch
- no flaky test unresolved for critical flows

### Gate Q3: Data Integrity

- migration/sync test suite pass
- schema and RLS tests pass

### Gate Q4: Performance

- cold start and search latency meet defined targets
- list views stable for high-cardinality datasets

---

## Defect Severity Policy

| Severity | Definition | Release Impact |
|---|---|---|
| Sev-0 | data loss/security breach | release blocked |
| Sev-1 | critical user flow broken | release blocked |
| Sev-2 | feature degraded with workaround | needs explicit waiver |
| Sev-3 | cosmetic/non-critical | backlog allowed |

---

## Exit Criteria for Production Candidate

- all gates Q1-Q4 pass
- no unresolved Sev-0/Sev-1 defects
- rollback plan validated in staging
- docs and ADR updates merged for all changed contracts

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | New canonical testing and quality gate framework. |
