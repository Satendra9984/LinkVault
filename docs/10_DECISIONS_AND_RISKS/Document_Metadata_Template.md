# Document Metadata Template

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering Leadership  
Depends On: `docs/README.md`, `docs/00_PROJECT_OVERVIEW/Documentation_Information_Architecture.md`

---

Use this header in every canonical document:

```md
# <Document Title>

Version: <major.minor>
Last Updated: <YYYY-MM-DD>
Status: <Draft | Active | Approved | Deprecated | Archived>
Owner: <Team or Role>
Depends On: <doc paths, comma-separated>
Blocks: <optional doc paths or milestones>

---

## Purpose
<what this doc defines and who should use it>
```

---

## Metadata Field Guidance

| Field | Required | Notes |
|---|---|---|
| Version | yes | bump major for behavior changes, minor for clarifications |
| Last Updated | yes | use ISO date |
| Status | yes | lifecycle control for implementation safety |
| Owner | yes | accountable reviewer/maintainer |
| Depends On | yes | lists upstream docs required for interpretation |
| Blocks | optional | use only if this doc gates delivery |

---

## Status Usage Rules

- Draft: incomplete and not implementation-safe
- Active: implementation guidance in current iteration
- Approved: validated and baseline-locked
- Deprecated: superseded by another active/approved doc
- Archived: historical context only

---

## Template Example

```md
# Data Persistence State Machine

Version: 2.1
Last Updated: 2026-03-23
Status: Approved
Owner: Engineering
Depends On: docs/03_ARCHITECTURE/Technical_Architecture.md, docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md
Blocks: docs/09_RELEASE_AND_OPERATIONS/Release_Operations_Runbook.md
```
