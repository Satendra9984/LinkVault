# LinkVault Legacy Firebase Import Runbook

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering  
Depends On: `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`, `docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md`

---

## Purpose

Specify the optional migration path for Firebase-era LinkVault users. This runbook is designed to preserve data where feasible without blocking greenfield production rollout.

---

## Policy

- Migration path is optional for end users.
- New users and users who skip migration proceed normally on Supabase/ObjectBox architecture.
- Import flow is feature-flag controlled.

---

## Supported Migration Paths

1. In-app authenticated import (preferred where old data is still accessible to user session).
2. Support-assisted JSON import (fallback).
3. No-import path (user starts fresh).

---

## Data Mapping

| Legacy Source | Target | Notes |
|---|---|---|
| Firebase collection doc ID | `lv_collections.id` | preserve ID if UUID-compatible, otherwise map and record |
| Firebase folder hierarchy field | `lv_collections.parent_id` | normalize null/root semantics |
| Firebase link item ID | `lv_urls.id` | preserve if safe; otherwise deterministic remap |
| Legacy URL status | `lv_urls.status` | map to `unread/read/archived` |
| legacy tags array | `lv_urls.tags` | serialize or normalize based on parser contract |
| created/updated timestamps | `created_at/updated_at` | backfill in UTC |

---

## Import Execution Flow

1. User chooses "Import old LinkVault data" in settings or onboarding recovery prompt.
2. Eligibility check:
   - authenticated Supabase user
   - feature flag enabled
3. Dry-run analysis:
   - count records
   - detect malformed URLs
   - detect duplicate IDs
4. User confirmation with migration estimate.
5. Import execution:
   - collections first
   - URLs second
   - chunk writes
   - idempotent upsert
6. Verification:
   - row counts and parent-child integrity checks
   - invalid records report
7. Commit migration marker and show summary to user.

---

## Idempotency and Safety Requirements

- Each imported row includes source fingerprint in migration metadata table or local import log.
- Re-running import should not duplicate rows.
- Failed batch must be retryable independently.
- Import can be resumed from checkpoint.

---

## Duplicate and Conflict Handling

Priority order:

1. exact ID match -> update existing row if imported `updated_at` is newer
2. same normalized URL + collection + title -> treat as duplicate candidate and skip or merge
3. otherwise create new row

All duplicate decisions should be included in final import summary.

---

## Validation Rules

- URL must be syntactically valid
- collection parent references must resolve (or be remapped to root with warning)
- status must map to allowed enum
- timestamps must be parseable or defaulted with warning

Rows failing hard validation are skipped and included in report.

---

## Observability

Track:

- import_started
- import_row_processed
- import_row_failed
- import_completed

Capture:

- import run ID
- total rows attempted/imported/skipped/failed
- duration
- top error categories

---

## User Experience Requirements

- Show explicit optionality: "Start fresh" and "Import existing data."
- Show progress percentage and resumable behavior.
- Do not block app usage permanently on import failures.
- Provide downloadable/importable failure report for support.

---

## Rollback Strategy

Rollback scope:

- per-import-run rollback where possible (delete rows created by specific run ID)
- no full-account destructive rollback without explicit user confirmation

If rollback is unavailable for mixed updates:

- run compensating migration (re-apply canonical latest data)
- keep audit logs for support reconciliation

---

## Support Playbook

When user reports import issue:

1. collect run ID from in-app diagnostics
2. inspect failure categories
3. attempt resume if recoverable
4. if unrecoverable, provide support-assisted JSON import fallback

---

## Exit Criteria for Enabling by Default

- 95%+ success rate on internal migration test dataset
- no critical data loss defects in beta cohort
- support tooling available for manual reconciliation

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | First canonical optional legacy migration runbook. |
