# LinkVault Documentation Portal

Version: 2.4  
Last Updated: 2026-03-24  
Project Status: Documentation-First Execution Planning  
Canonical Docs Root: `docs/`

---

## Start Here

If you are new to the project, read in this order:

1. [Documentation Audit and Source-of-Truth Matrix](./00_PROJECT_OVERVIEW/Documentation_Audit_and_Source_of_Truth_Matrix.md)
2. [Phase Roadmap, Tasks, Evaluation Gates, and Test Catalog](./00_PROJECT_OVERVIEW/Phase_Roadmap_Tasks_and_Test_Catalog.md) *(v1.1 execution source for P0-P6 gates and test IDs)*
3. [Master Project Plan](./00_PROJECT_OVERVIEW/Master_Project_Plan.md) *(strategic and sprint narrative aligned to roadmap)*
4. [Product Requirements Document](./01_PRODUCT/Product_Requirements_Document.md) (v1.2+ Home & Library — [ADR-0003](./10_DECISIONS_AND_RISKS/ADR_0003_Home_Landing_and_Folder_Content_Model.md))
4b. [Monetization model — free cloud, quotas, unit economics](./05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md) · [ADR-0002](./10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md)
5. [Technical Architecture](./03_ARCHITECTURE/Technical_Architecture.md) · [Home and Collections UX](./03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md) · [ADR-0003](./10_DECISIONS_AND_RISKS/ADR_0003_Home_Landing_and_Folder_Content_Model.md) · [UI/UX flows & wireframes](./02_DESIGN/UI_UX_Flow_Document.md) · [Home visual contract](./02_DESIGN/Home_Collections_Visual_Contract.md)
6. [Supabase Schema and Migrations](./04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md)
7. [Data Persistence State Machine](./04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md)
8. [Execution Readiness Report](./10_DECISIONS_AND_RISKS/Execution_Readiness_Report.md)

**Execution order note:** when there is wording drift, phase gates and test IDs in the roadmap document are the release-control source of truth.

---

## Canonical Information Architecture

```text
docs/
├── README.md
├── 00_PROJECT_OVERVIEW/
├── 01_PRODUCT/
├── 02_DESIGN/
├── 03_ARCHITECTURE/
├── 04_DATA_AND_MIGRATION/
├── 05_MONETIZATION/
├── 06_ANALYTICS/
├── 07_SECURITY_AND_COMPLIANCE/
├── 08_TESTING_AND_QUALITY/
├── 09_RELEASE_AND_OPERATIONS/
└── 10_DECISIONS_AND_RISKS/
```

### Domain Ownership

| Section | Purpose | Primary Owner |
|---|---|---|
| `00_PROJECT_OVERVIEW` | Strategy, roadmap, governance context | Product + Engineering |
| `01_PRODUCT` | Functional/non-functional requirements | Product |
| `02_DESIGN` | UX flows, wireframes, contracts ([UI_UX_Flow_Document](./02_DESIGN/UI_UX_Flow_Document.md), [Home_Collections_Visual_Contract](./02_DESIGN/Home_Collections_Visual_Contract.md)) | Product + Design |
| `03_ARCHITECTURE` | Runtime architecture and coding contracts | Engineering |
| `04_DATA_AND_MIGRATION` | Schema, sync, migration, reconciliation | Engineering |
| `05_MONETIZATION` | Revenue and entitlement behavior | Product + Engineering |
| `06_ANALYTICS` | Metrics model and event definitions | Product + Engineering |
| `07_SECURITY_AND_COMPLIANCE` | Security controls and compliance posture | Engineering |
| `08_TESTING_AND_QUALITY` | Test strategy, quality gates | Engineering + QA |
| `09_RELEASE_AND_OPERATIONS` | Deployment, incidents, runbooks | Engineering + Ops |
| `10_DECISIONS_AND_RISKS` | ADRs, risk register, readiness | Engineering Leadership |

---

## Metadata Standard (Mandatory in All Docs)

Each active document must include this front section:

- Version
- Last Updated (YYYY-MM-DD)
- Status (`Draft`, `Active`, `Approved`, `Deprecated`, `Archived`)
- Owner (role/team)
- Depends On (linked docs)
- Blocks (optional, linked docs/tasks)

A full template is provided in:
[Document Metadata Template](./10_DECISIONS_AND_RISKS/Document_Metadata_Template.md)

---

## Source-of-Truth Rules

1. `docs/` is the only canonical documentation tree for LinkVault execution.
2. `curate/docs/` is reference-only and cannot be used as primary implementation authority.
3. One topic must map to one canonical owner document.
4. If two docs conflict, the doc listed in the source-of-truth matrix wins.
5. Deprecated guidance must be explicitly marked and linked to the replacement document.

---

## Core Engineering Baseline

| Decision Area | Canonical Choice |
|---|---|
| Architecture base | Curate-inspired clean architecture, adapted for LinkVault |
| Domain model for collections/items | LinkVault-specific `lv_collections` + `lv_urls` |
| Backend | Supabase-first (Auth + PostgreSQL + Storage) |
| Local persistence | ObjectBox local-first |
| Tier switching | Repository selection by auth/tier/migration state |
| Legacy migration | Optional Firebase-era import path (non-blocking for greenfield users) |

---

## Document Lifecycle

| Status | Meaning | Allowed Use |
|---|---|---|
| Draft | In progress and incomplete | Discussion only |
| Active | Current working guidance | Implementation allowed |
| Approved | Signed-off baseline | Implementation required to follow |
| Deprecated | Superseded by newer doc | Do not use for new work |
| Archived | Historical reference only | Read-only context |

---

## Maintenance Protocol

- Update `Last Updated` and version on every substantial change.
- Cross-link impacted docs whenever architecture or data behavior changes.
- Open a new ADR for decisions that alter boundaries, schema, migration logic, or release policy.
- Re-run readiness checks before implementation starts and before each major milestone.
- Keep `Master_Project_Plan.md` phase/sprint text synchronized with roadmap gates after any phase-level change.

---

## Critical Links

- [Execution Roadmap](./00_PROJECT_OVERVIEW/Phase_Roadmap_Tasks_and_Test_Catalog.md)
- [Master Plan](./00_PROJECT_OVERVIEW/Master_Project_Plan.md)
- [Cursor Usage SOP](./00_PROJECT_OVERVIEW/Cursor_Usage_SOP.md)
- [Architecture](./03_ARCHITECTURE/Technical_Architecture.md)
- [Home & Collections UX](./03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md)
- [UI/UX flows & wireframes](./02_DESIGN/UI_UX_Flow_Document.md)
- [Home visual contract](./02_DESIGN/Home_Collections_Visual_Contract.md)
- [Developer Bible](./03_ARCHITECTURE/Developer_Bible.md)
- [Data and Migration Suite](./04_DATA_AND_MIGRATION/)
- [Security and Compliance](./07_SECURITY_AND_COMPLIANCE/)
- [Testing and Quality](./08_TESTING_AND_QUALITY/)
- [Release and Operations](./09_RELEASE_AND_OPERATIONS/)
- [ADRs and Risks](./10_DECISIONS_AND_RISKS/) — [ADR-0003 Home & folder model](./10_DECISIONS_AND_RISKS/ADR_0003_Home_Landing_and_Folder_Content_Model.md)
