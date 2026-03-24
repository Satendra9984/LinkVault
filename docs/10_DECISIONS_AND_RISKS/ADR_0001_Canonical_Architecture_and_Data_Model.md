# ADR-0001: Canonical Architecture and Data Model

Version: 1.0  
Last Updated: 2026-03-23  
Status: Approved  
Owner: Engineering Leadership  
Depends On: `docs/03_ARCHITECTURE/Technical_Architecture.md`, `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`

---

## Status

Approved

## Date

2026-03-23

## Context

The repository and docs currently show mixed implementation eras:

- legacy Firebase + mixed state-management paths
- partial Supabase paths
- dual entrypoint ambiguity
- conflicting documentation sources between LinkVault and Curate references

The project requires one production-ready architecture baseline before implementation proceeds.

## Decision

1. Curate-inspired clean architecture becomes the code-structure baseline.
2. LinkVault-specific domain model is canonical for product data:
   - `lv_collections`
   - `lv_urls`
3. Supabase is the only cloud backend for product data and authentication.
4. ObjectBox is the canonical local persistence layer.
5. Tier and migration state determine repository selection.
6. Legacy Firebase import remains optional and non-blocking.

## Alternatives Considered

### A) Reuse Curate unprefixed `collections/items` tables directly

Pros:

- less schema duplication

Cons:

- tighter coupling to Curate domain assumptions
- higher cross-app blast radius for schema changes

Decision:

- rejected for LinkVault v1 execution phase

### B) Keep legacy LinkVault architecture and selectively patch

Pros:

- less immediate refactor effort

Cons:

- retains mixed-stack technical debt
- prolongs operational instability and ambiguity

Decision:

- rejected

### C) Canonical LinkVault `lv_*` model with Curate-style architecture

Pros:

- preserves LinkVault domain specificity
- maintains shared Supabase project coexistence
- lowers cross-app coupling risk

Cons:

- requires up-front migration documentation and stronger governance

Decision:

- accepted

## Consequences

Positive:

- clean architecture boundaries for implementation
- clear ownership of LinkVault data model
- safer rollout strategy with optional legacy migration

Negative:

- additional documentation and migration tooling needed
- temporary cost of deprecating old guidance and code paths

## Implementation Notes

- enforce canonical docs in `docs/`
- build from migration suite and state machine contracts
- phase rollout through milestone gates

## Verification

- schema and RLS validations pass in staging
- repository selector behaves correctly across all defined persistence states
- sync and migration test suites pass agreed thresholds

## Rollback Strategy

- if migration defects threaten data safety, disable migration flag and run local-only fallback for affected cohorts
- use staged rollout to limit blast radius

## Related Documents

- `docs/03_ARCHITECTURE/Technical_Architecture.md`
- `docs/03_ARCHITECTURE/Developer_Bible.md`
- `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`
- `docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md`
- `docs/10_DECISIONS_AND_RISKS/Milestones_Dependencies_and_Readiness_Gates.md`
- `docs/10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md` (free **account** = Supabase + quotas; guest local-only)
