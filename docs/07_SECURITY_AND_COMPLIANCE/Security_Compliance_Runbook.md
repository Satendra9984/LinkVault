# LinkVault Security and Compliance Runbook

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering  
Depends On: `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`, `docs/09_RELEASE_AND_OPERATIONS/Release_Operations_Runbook.md`

---

## Purpose

Provide the minimum security and compliance controls required for LinkVault development, testing, release, and operation.

---

## Security Baseline

### Identity and Access

- Supabase Auth is the only authentication source for product data.
- RevenueCat user identity must be linked to Supabase UID.
- Admin/service-role credentials are restricted to trusted environments.

### Data Access

- RLS enabled for all `lv_*` tables before release.
- Table policy tests must validate tenant isolation.
- No privileged client-side bypass paths.

### Secrets Management

- use environment files or secret managers only
- do not commit production secrets
- rotate keys if leakage is suspected

---

## Data Protection Controls

| Data Type | Control |
|---|---|
| User profile and link metadata | RLS + user-scoped policies |
| URL thumbnails | bucket path ownership checks |
| Logs and telemetry | no raw auth tokens, avoid PII leakage |
| Export files | user data only, no credentials/session tokens |

---

## Compliance-Oriented Flows

### Account Deletion

Requirements:

- authenticated request
- irreversible confirmation UX
- deletion includes cloud rows in `lv_*` scope
- local device data cleanup where applicable
- completion response surfaced to user

### Data Export

Requirements:

- user-initiated export
- machine-readable format
- include collections and URLs
- include schema version for import compatibility

### Data Import

Requirements:

- validate format and version before write
- reject malformed records with clear report
- maintain idempotency where feasible

---

## Security Testing Checklist

1. user A cannot access user B rows through API queries.
2. write attempts with mismatched owner IDs are rejected.
3. storage write/delete denied outside user-owned folder path.
4. revoked/expired auth token cannot mutate data.
5. account deletion path removes data as documented.

---

## Incident Classification

| Class | Example | Response SLA |
|---|---|---|
| Critical | cross-user data exposure | immediate |
| High | auth/session compromise | same day |
| Medium | policy misconfiguration without exposure | next business day |
| Low | non-exploitable hardening issue | planned sprint |

---

## Security Incident Workflow

1. triage severity and scope
2. contain affected endpoints/features
3. preserve logs and evidence
4. remediate and patch
5. validate fix with focused tests
6. publish incident summary and preventive actions

---

## Release Security Gates

Release blocked unless:

- RLS tests pass
- no known critical/high unresolved vulnerabilities
- secret checks pass
- account deletion and export flows validated

---

## Policy for External Dependencies

- pin dependency versions through package manager lock state
- review changelogs for security-impacting updates
- avoid abandoned dependencies in auth/data paths

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | New canonical security/compliance runbook for LinkVault. |
