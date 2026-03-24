# Archive and Deprecation Register

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering Leadership  
Depends On: `docs/00_PROJECT_OVERVIEW/Documentation_Audit_and_Source_of_Truth_Matrix.md`

---

## Purpose

Track documents that are no longer canonical and specify their active replacements.

---

## Deprecated in `docs/`

| Deprecated Path | Status | Replacement |
|---|---|---|
| `docs/03_ARCHITECTURE/Supabase_Schema_Design.md` | Deprecated | `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md` |
| `docs/03_ARCHITECTURE/Cloud_Sync_Scalability_Strategy.md` | Deprecated | `docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md` |
| `docs/09_SPRINT_ARCHITECTURE/Data_Persistence_State_Machine.md` | Deprecated | `docs/04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md` |

---

## Reference-Only External Docs

The following are reference-only and not LinkVault source-of-truth:

- `curate/docs/**`

Use case:

- architecture inspiration
- implementation pattern examples
- historical context

Not allowed:

- direct override of LinkVault canonical contracts

---

## Deprecation Policy

When deprecating a document:

1. mark status `Deprecated`
2. add replacement path
3. update this register
4. ensure `docs/README.md` links only canonical docs for critical topics

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | Initial deprecation and reference-only register. |
