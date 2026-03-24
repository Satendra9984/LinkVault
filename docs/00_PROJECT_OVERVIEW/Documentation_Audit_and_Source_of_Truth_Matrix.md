# LinkVault Documentation Audit and Source-of-Truth Matrix

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active (Canonical Audit)

---

## Purpose

This audit defines which documents in `docs/` are authoritative, which require rewrites, and which external references from `curate/docs/` can be used as supporting material only.

The primary objective is to ensure one active source of truth per topic before implementation begins.

---

## Scoring Method

Each document is scored 1-5 (higher is better):

- Correctness: technical and product accuracy against current project direction
- Completeness: coverage depth for implementation
- Consistency: alignment with other active docs
- Production usefulness: practical value for real delivery
- Overlap risk: risk of conflicting guidance (5 = low overlap risk, 1 = severe overlap/conflict)

Decision classes:

- Keep: retain with minor edits only
- Rewrite: replace with new canonical version
- Merge: merge into another canonical doc; then mark as reference-only
- Archive: keep historical record only, not active guidance

---

## Audit of Existing `docs/` Files


| Path                                                             | Correctness | Completeness | Consistency | Production usefulness | Overlap risk | Decision      | Notes                                                                                                         |
| ---------------------------------------------------------------- | ----------- | ------------ | ----------- | --------------------- | ------------ | ------------- | ------------------------------------------------------------------------------------------------------------- |
| `docs/README.md`                                                 | 3           | 2            | 3           | 3                     | 3            | Rewrite       | Good index intent, but too small for full governance and does not reflect expanded doc set.                   |
| `docs/00_PROJECT_OVERVIEW/Master_Project_Plan.md`                | 4           | 4            | 3           | 4                     | 3            | Keep + Update | Strong roadmap baseline; update sequencing, remove stale references, and align with rebase/migration reality. |
| `docs/01_PRODUCT/Product_Requirements_Document.md`               | 4           | 5            | 4           | 5                     | 4            | Keep + Update | Strong PRD foundation; keep as canonical product document.                                                    |
| `docs/01_PRODUCT/Premium_Feature_Gating_Matrix.md`               | 4           | 4            | 4           | 5                     | 4            | Keep + Update | Good gate model; ensure parity with updated state machine and monetization docs.                              |
| `docs/03_ARCHITECTURE/Technical_Architecture.md`                 | 3           | 4            | 3           | 4                     | 2            | Rewrite       | Needs stronger canonical boundaries, migration states, and implementation constraints.                        |
| `docs/03_ARCHITECTURE/Developer_Bible.md`                        | 4           | 4            | 3           | 5                     | 3            | Rewrite       | Strong rules, but missing governance metadata and conflicts around analytics/telemetry stack.                 |
| `docs/03_ARCHITECTURE/Supabase_Schema_Design.md`                 | 4           | 5            | 4           | 5                     | 4            | Rewrite       | High quality; rewrite into migration-safe schema pack and explicit SQL delivery order.                        |
| `docs/03_ARCHITECTURE/Cloud_Sync_Scalability_Strategy.md`        | 3           | 4            | 3           | 4                     | 3            | Rewrite       | Good direction; needs deterministic migration workflows and failure handling details.                         |
| `docs/05_MONETIZATION/Monetization_Strategy_RevenueCat_Guide.md` | 4           | 5            | 4           | 5                     | 4            | Keep + Update | Keep as RevenueCat/AdMob ops reference; pair with `Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md`. |
| `docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md` | 4 | 5 | 4 | 5 | 4 | Keep | Canonical tier + quota + unit economics (guest local / free cloud / premium). |
| `docs/09_SPRINT_ARCHITECTURE/Data_Persistence_State_Machine.md`  | 4           | 4            | 4           | 5                     | 4            | Rewrite       | Strong baseline, but needs explicit technical contracts and transition edge-case handling.                    |


---

## Curate Reference Set (`curate/docs/`) Classification

These are not canonical for LinkVault execution. They are reference inputs only.


| Path                                                                         | Decision | Why                                                                                              |
| ---------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------ |
| `curate/docs/03_ARCHITECTURE/Clean_Architecture_Implementation_Guide.md`     | Merge    | Use structure and layer rigor patterns in LinkVault architecture docs.                           |
| `curate/docs/03_ARCHITECTURE/Technical_Architecture.md`                      | Merge    | Keep architectural examples that improve clarity; avoid direct table/model assumptions.          |
| `curate/docs/03_ARCHITECTURE/Supabase_Schema_Design.md`                      | Merge    | Reuse RLS and policy quality standards, not Curate's data model itself.                          |
| `curate/docs/09_SPRINT_ARCHITECTURE/Sprint_7_Items_Fetching_Architecture.md` | Merge    | Reuse pagination/performance rationale for large item lists.                                     |
| `curate/docs/09_SPRINT_ARCHITECTURE/Testing_Strategy.md`                     | Merge    | Reuse test pyramid and practical quality targets.                                                |
| `curate/docs/README.md`                                                      | Archive  | Informational only; status flags are inconsistent with actual files and not LinkVault-canonical. |
| Other Curate docs under product/design/ops                                   | Archive  | Historical/reference only for inspiration and optional implementation patterns.                  |


---

## Canonical Ownership Matrix (Active Source of Truth)


| Topic                                      | Canonical Document                                                  | Owner                  |
| ------------------------------------------ | ------------------------------------------------------------------- | ---------------------- |
| Product direction, goals, phasing          | `docs/00_PROJECT_OVERVIEW/Master_Project_Plan.md`                   | Product + Engineering  |
| Detailed feature requirements              | `docs/01_PRODUCT/Product_Requirements_Document.md`                  | Product                |
| Free/premium feature enforcement           | `docs/01_PRODUCT/Premium_Feature_Gating_Matrix.md`                  | Product + Engineering  |
| System architecture and boundaries         | `docs/03_ARCHITECTURE/Technical_Architecture.md`                    | Engineering            |
| Coding and architecture rules              | `docs/03_ARCHITECTURE/Developer_Bible.md`                           | Engineering            |
| Supabase schema and SQL migrations         | `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`      | Engineering            |
| Sync architecture and conflict policy      | `docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md`       | Engineering            |
| Runtime data persistence states            | `docs/04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md`      | Engineering            |
| Optional legacy migration path             | `docs/04_DATA_AND_MIGRATION/Legacy_Firebase_Import_Runbook.md`      | Engineering            |
| Monetization tiers, quotas, unit economics   | `docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md` + `ADR_0002` | Product + Engineering |
| Monetization and entitlement integration   | `docs/05_MONETIZATION/Monetization_Strategy_RevenueCat_Guide.md`    | Product + Engineering  |
| Security controls and compliance controls  | `docs/07_SECURITY_AND_COMPLIANCE/Security_Compliance_Runbook.md`    | Engineering            |
| Testing strategy and release quality gates | `docs/08_TESTING_AND_QUALITY/Testing_Strategy_and_Quality_Gates.md` | Engineering + QA       |
| Release, incidents, and operations         | `docs/09_RELEASE_AND_OPERATIONS/Release_Operations_Runbook.md`      | Engineering + Ops      |
| ADRs and risk governance                   | `docs/10_DECISIONS_AND_RISKS/` docs                                 | Engineering Leadership |


---

## Immediate Remediation Actions

1. Expand `docs/` taxonomy to include data/migration, security/compliance, QA, release/ops, and decisions/risk sections.
2. Rewrite architecture, schema, sync, and state-machine docs to eliminate contradiction and encode delivery-ready contracts.
3. Add governance docs (ADR template, initial ADRs, risk register, execution readiness criteria).
4. Mark Curate docs as reference-only from LinkVault docs index to prevent accidental source-of-truth confusion.

---

## Definition of Done for Documentation Readiness

- Every implementation-critical topic has one canonical owner doc in `docs/`.
- No active topic depends on a Curate file as primary authority.
- Data model (`lv_*`) and migration workflows are technically executable from docs alone.
- QA/security/release operations include explicit entry/exit criteria and rollback flows.
- Teams can start implementation with no unresolved architecture ambiguity.

