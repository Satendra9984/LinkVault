# LinkVault Risk Register

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering Leadership + Product  
Depends On: `docs/10_DECISIONS_AND_RISKS/ADR_0001_Canonical_Architecture_and_Data_Model.md`

---

## Purpose

Track the highest-impact delivery and production risks with clear ownership and mitigation strategy.

---

## Risk Scoring

- Probability: Low / Medium / High
- Impact: Low / Medium / High / Critical
- Priority is derived by impact first, then probability

---

## Active Risks

| ID | Risk | Probability | Impact | Priority | Owner | Mitigation | Contingency | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | Mixed runtime paths after rebase cause regressions | High | Critical | P0 | Engineering | enforce canonical entrypoint and remove dead-path dependencies | freeze features and run stabilization sprint | Open |
| R2 | Schema/RLS misconfiguration leaks cross-user data | Medium | Critical | P0 | Engineering | policy tests for all `lv_*` tables and staged validation | disable affected endpoints and hotfix policy | Open |
| R3 | Migration workflow causes duplicate or missing URL records | Medium | High | P0 | Engineering | idempotent import, checkpoints, post-import verification | pause migration feature flag and revert to local-only mode | Open |
| R4 | Premium entitlement drift causes wrong repository selection | Medium | High | P1 | Engineering | entitlement refresh on startup/foreground and migration gate checks | force local mode until entitlement revalidation | Open |
| R5 | Legacy import complexity delays core release | Medium | Medium | P1 | Product + Engineering | keep legacy import optional and feature-flagged | defer legacy import default enablement | Open |
| R6 | Observability gaps prevent root-cause during sync failures | Medium | High | P1 | Engineering + Ops | require sync/migration telemetry before rollout | increase rollout hold and collect logs manually | Open |
| R7 | Performance degradation for large collections/URLs | Medium | Medium | P2 | Engineering | pagination, indexing, benchmark gates | disable heavy views/filters temporarily | Open |
| R8 | Inconsistent docs lead to implementation drift | High | Medium | P1 | Engineering Leadership | canonical docs ownership and archive stale docs | weekly doc review checkpoints | Open |

---

## Risk Review Cadence

- Weekly review during active development
- Additional review before each release gate decision

---

## Escalation Triggers

Escalate to P0 incident planning when:

- any Critical-impact risk changes to High probability
- data integrity issues are observed in migration/sync workflows
- security policy tests fail in pre-release environments

---

## Closed Risks Log

| ID | Resolution Date | Resolution Notes |
|---|---|---|
| None | - | - |

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | Initial project risk register for execution readiness. |
