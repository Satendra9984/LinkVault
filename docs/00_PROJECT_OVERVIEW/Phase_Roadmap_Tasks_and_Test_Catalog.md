# LinkVault — Phase Roadmap, Tasks, Evaluation Gates, and Test Catalog

Version: 1.1  
Last Updated: 2026-03-24  
Status: Active  
Owner: Product + Engineering  
Depends On: [Master_Project_Plan.md](./Master_Project_Plan.md), [../08_TESTING_AND_QUALITY/Testing_Strategy_and_Quality_Gates.md](../08_TESTING_AND_QUALITY/Testing_Strategy_and_Quality_Gates.md), [../10_DECISIONS_AND_RISKS/Milestones_Dependencies_and_Readiness_Gates.md](../10_DECISIONS_AND_RISKS/Milestones_Dependencies_and_Readiness_Gates.md)

---

## Purpose

Single execution companion to the [Master Project Plan](./Master_Project_Plan.md): phased task lists (Curate-style checkboxes + verification), **phase evaluation gates**, and **traceable test cases**. Update checkboxes as sprints complete.

**Cursor mode for maintaining this doc:** use **Auto** for checkbox updates and small edits; use **Premium** when revising gates after a major architecture or migration change.

---

## How Phases Map to the 14-Week Plan

| Phase | Weeks / Sprints | Master Plan alignment |
|-------|-----------------|------------------------|
| P0 Rebase & lock | Sprint 0 | Pre–Sprint 1 stabilization |
| P1 Foundation | Sprints 1–2 | Weeks 1–2 |
| P2 Auth & profile | Sprints 3–4 | Weeks 3–4 |
| P3 Collections & URLs | Sprints 5–8 | Weeks 5–8 |
| P4 Search, RSS, share | Sprints 9–10 | Weeks 9–10 |
| P5 Monetization & cloud | Sprints 11–12 | Weeks 11–12 |
| P6 Polish, QA, launch | Sprints 13–14 | Weeks 13–14 |

---

## Task ID Convention

- `P{n}-T{nn}` — task within phase (e.g. `P2-T03`)
- `TC-XXX` — test case ID (see [Test catalog by phase](#test-catalog-by-phase))

---

## Phase 0 — Rebase stabilization and architecture lock

**Goal:** One canonical app entrypoint, build green, architecture/docs aligned before feature migration.

**Dependencies:** None.

### Task backlog

- [ ] **P0-T01** Lock single `main` / flavor entrypoint; document in ADR or bootstrap doc
- [ ] **P0-T02** Remove or quarantine dead dual-stack paths (document what remains temporarily)
- [ ] **P0-T03** CI: `flutter analyze` + tests on default branch
- [ ] **P0-T04** Confirm canonical docs index: [README.md](../README.md), [Technical_Architecture.md](../03_ARCHITECTURE/Technical_Architecture.md)
- [ ] **P0-T05** Risk review: update [Risk_Register.md](../10_DECISIONS_AND_RISKS/Risk_Register.md) for rebase-specific items

### Evaluation gate (Phase 0 exit)

| Criterion | Target |
|-----------|--------|
| Build | Release/debug flavor builds succeed on iOS + Android |
| Entrypoint | Single documented entry; no ambiguous `main` for prod |
| Docs | No conflicting *active* guidance for backend/state (see deprecation register) |
| Quality | Analyzer clean for touched packages (or waived list documented) |
| Security hygiene | Secret scan for repo and CI logs shows no production keys in source |
| Rollback baseline | Last-known-good pre-rebase tag/branch and restore steps documented |
| Dependency safety | Lockfile updated and reviewed for auth/sync package changes |

### Verification (Curate-style checklist)

- [ ] App installs and cold-starts without crash on dev flavor
- [ ] Documented entrypoint matches CI / store build config
- [ ] Team can trace “where auth / DB init happens” from one doc

### Test cases (minimum)

| ID | Summary | Priority | Auto? |
|----|---------|----------|-------|
| TC-P0-001 | Cold start: no crash, splash or home reachable | P0 | Manual / integration |
| TC-P0-002 | Dev flavor uses dev env keys only (spot-check) | P0 | Manual |

---

## Phase 1 — Foundation (Sprints 1–2)

**Goal:** Curate-style scaffold, flavors, env, ObjectBox + Supabase client bootstrap, splash, onboarding, welcome.

**User journey:** Install → Splash → Onboarding (first run) → Welcome (Sign up / Sign in / Guest).

**Dependencies:** Phase 0 complete.

### Task backlog

**Week 1 — Scaffold**

- [ ] **P1-T01** Feature-first `lib/` layout per [Technical_Architecture.md](../03_ARCHITECTURE/Technical_Architecture.md)
- [ ] **P1-T02** `flutter_flavorizr` (or equivalent): dev / production
- [ ] **P1-T03** `.env.dev` / `.env.production`; no secrets in source
- [ ] **P1-T04** ObjectBox store bootstrap + schema placeholders for collections/URLs
- [ ] **P1-T05** Supabase client init from env
- [ ] **P1-T06** GoRouter shell + splash route
- [ ] **P1-T07** Design tokens (colors, typography, spacing)
- [ ] **P1-T08** Apply `lv_*` schema migrations in dev Supabase ([Supabase_Schema_and_Migrations.md](../04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md))

**Week 2 — Onboarding**

- [ ] **P1-T09** 3-page onboarding + skip + completion flag (SharedPreferences)
- [ ] **P1-T10** Welcome: Sign up / Sign in / Continue as Guest
- [ ] **P1-T11** Riverpod app container + core providers stub

### Evaluation gate (Phase 1 exit)

| Criterion | Target |
|-----------|--------|
| UX | First-run → onboarding → welcome without dead ends |
| Config | Flavors load correct env; prod build has no dev keys |
| Data | ObjectBox opens; Supabase client connects in dev |
| Schema | `lv_*` tables + RLS smoke-tested in dev project |
| Security | User B cannot read User A `lv_*` rows in smoke SQL tests |
| Rollback | Dev migration rollback or snapshot restore path documented and tested |
| Integrity | ObjectBox schema upgrade path documented for next app version |

### Verification

- [ ] Splash → onboarding (first launch) → welcome
- [ ] Second launch skips onboarding if completed
- [ ] Guest path does not require network for core local navigation stub

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P1-001 | First install: onboarding shows | P0 | Widget / manual |
| TC-P1-002 | Onboarding complete: next launch skips onboarding | P0 | Widget / integration |
| TC-P1-003 | Dev flavor: Supabase URL from env, app does not crash | P0 | Integration |
| TC-P1-004 | ObjectBox directory created; store opens | P1 | Unit / integration |

---

## Phase 2 — Authentication & profile (Sprints 3–4)

**Goal:** Supabase OTP (and/or magic link per PRD), guest mode, profile, settings, delete account, legal screens.

**User journey:** Welcome → Auth → Home shell; Profile → edit / settings / delete.

**Dependencies:** Phase 1.

### Task backlog

**Week 3 — Auth**

- [ ] **P2-T01** `AuthRepository` + use cases (sign in, sign out, session refresh)
- [ ] **P2-T02** OTP / passwordless flow per PRD
- [ ] **P2-T03** Guest mode: local-only; no cloud writes for product data (authenticated users use `lv_*` per ADR-0002 — implemented in later phases if not yet in code)
- [ ] **P2-T04** `lv_user_profiles` row on signup (trigger verified)
- [ ] **P2-T05** Auth state Riverpod; `Purchases.logIn(uid)` when session exists (RevenueCat)

**Week 4 — Profile & settings**

- [ ] **P2-T06** Profile screen: avatar, display name, email
- [ ] **P2-T07** Edit profile → Supabase + local mirror if applicable
- [ ] **P2-T08** Settings: theme, export/import entry, about, legal
- [ ] **P2-T09** Delete account: SECURITY DEFINER RPC + cascade `lv_*` (per schema doc)
- [ ] **P2-T10** Privacy / Terms (bundled markdown or web view per decision)
- [ ] **P2-T11** Guest-to-account continuity: preserve local collections/URLs after sign-up and bind ownership safely
- [ ] **P2-T12** Export/import implementation plan finalized (schema versioning, validation, merge/replace behavior)

### Evaluation gate (Phase 2 exit)

| Criterion | Target |
|-----------|--------|
| Auth | Sign up / sign in / sign out / session restore |
| Guest | Guest cannot write to `lv_*` via app paths; **signed-in free** may write within quotas (per ADR-0002) |
| Profile | CRUD profile; delete removes user data per runbook |
| Security | RLS: user A cannot read user B `lv_*` rows |
| Session safety | Revoked/expired session cannot perform cloud mutations |
| Data integrity | Account delete leaves zero `lv_*` rows for deleted user |
| Rollback | Delete-account failure path does not create partial/orphaned cloud state |

### Verification

- [ ] OTP (or magic link) end-to-end on physical device
- [ ] Guest mode: no Supabase writes for collections/URLs; **signed-in user:** smoke test `lv_*` insert within quota
- [ ] Delete account: confirmation UX + data gone for that uid in dev

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P2-001 | Sign in: session persists after kill app | P0 | Integration |
| TC-P2-002 | Sign out: no access to protected routes | P0 | Integration |
| TC-P2-003 | Guest: create local collection allowed; no cloud insert; signed-in: cloud insert allowed within quota | P0 | Integration |
| TC-P2-004 | Delete account: cannot sign in again with same expectation (or new user) | P0 | Manual + API check |
| TC-P2-005 | RLS: second user sees zero rows for first user’s collections | P0 | Manual / SQL |

---

## Phase 3 — Collections & URLs (Sprints 5–8)

**Goal:** Nested collections CRUD, breadcrumbs, reorder (fractional index); URLs CRUD, metadata fetch, status, pin, click count, share receive.

**Dependencies:** Phase 2; repository selector per [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md) and [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md).

### Task backlog — Collections (5–6)

- [ ] **P3-T01** `CollectionEntity` + `CollectionRepository` + use cases
- [ ] **P3-T02** `LocalCollectionRepository` (ObjectBox, watch queries)
- [ ] **P3-T03** `SupabaseCollectionRepository` (`lv_collections`)
- [ ] **P3-T04** Repository provider: tier + `hasMigrated` + online (per state machine)
- [ ] **P3-T05** UI: root grid, nested drill-down, breadcrumbs
- [ ] **P3-T06** Create/edit/delete collection; cascade rules documented
- [ ] **P3-T07** Drag reorder + fractional `position` + rebalance on precision exhaustion
- [ ] **P3-T08** Pin / archive collections

### Task backlog — URLs (7–8)

- [ ] **P3-T09** `UrlEntity` + `UrlRepository` + use cases
- [ ] **P3-T10** Local URL repo; list pagination (avoid loading 10k rows at once)
- [ ] **P3-T11** Supabase URL repo: `.range()` pagination for cloud
- [ ] **P3-T12** Metadata fetcher: timeout, non-blocking save, partial metadata OK
- [ ] **P3-T13** Status unread/read/archived; pin; click count + last accessed
- [ ] **P3-T14** `receive_sharing_intent`: validate URL → pick collection → save
- [ ] **P3-T15** Open URL (custom tabs) increments click count
- [ ] **P3-T16** Share-target platform setup: Android intent filters + iOS share extension wiring
- [ ] **P3-T17** Receive-intent cold-start handling and foreground stream handling with safe URL validation

### Evaluation gate (Phase 3 exit)

| Criterion | Target |
|-----------|--------|
| Collections | Unlimited nesting; reorder persists; delete cascade correct |
| URLs | CRUD + metadata; share intent saves to chosen collection |
| Performance | URL list scrollable with large local dataset (target per PRD) |
| Correctness | **Guest:** local-only; **free account:** Supabase paths + quota enforcement; no cross-owner writes |
| Security | Invalid/non-http share payloads rejected without crash or unsafe writes |
| Rollback | Share-intent feature flag/off-switch documented without blocking app startup |

### Verification

- [ ] Create 3-level nested collections; breadcrumb correct
- [ ] Reorder survives restart
- [ ] Add URL from share sheet; appears in collection
- [ ] Metadata failure still saves URL

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P3-001 | Create root + child collection; navigate both ways | P0 | Integration |
| TC-P3-002 | Delete parent: children URLs removed per product rules | P0 | Integration |
| TC-P3-003 | Reorder: order persists after app restart | P1 | Integration |
| TC-P3-004 | Add URL: invalid URL shows validation failure | P0 | Unit / widget |
| TC-P3-005 | Metadata timeout: URL row exists with empty optional fields | P0 | Unit / integration |
| TC-P3-006 | Share intent: one saved URL in correct collection | P0 | Integration / manual |
| TC-P3-007 | Open link: click_count increments | P1 | Integration |

---

## Phase 4 — Search, tags, RSS (Sprints 9–10)

**Goal:** Global search, filters/sort, tags; RSS feeds + save article as URL.

**Dependencies:** Phase 3.

### Task backlog

- [ ] **P4-T01** Local search (debounce 300ms) across collections + URLs
- [ ] **P4-T02** Optional: server search RPC `lv_search_urls` for premium
- [ ] **P4-T03** Filter chips: status, pinned, tags
- [ ] **P4-T04** Sort: date added / modified / visits / alpha
- [ ] **P4-T05** RSS: add feed, parse RSS 2.0 + Atom, cache locally
- [ ] **P4-T06** Save RSS item as `UrlEntity` in chosen collection
- [ ] **P4-T07** Export/import implementation: JSON schema versioning, validation report, merge/replace flows

### Evaluation gate (Phase 4 exit)

| Criterion | Target |
|-----------|--------|
| Search | Finds by title, URL, tags within performance budget |
| RSS | Feed refresh; save-to-vault works offline-friendly where defined |
| Security | Search/RSS input sanitation prevents malformed input crashes and unsafe query behavior |
| Data integrity | Import validation rejects malformed rows and reports skipped entries |
| Rollback | RSS and import features can be disabled by feature flag without route failures |

### Verification

- [ ] Search finds string in deep collection
- [ ] Tag filter narrows list correctly
- [ ] RSS article saves with correct link field

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P4-001 | Search debounce: no query storm on fast typing | P1 | Unit / widget |
| TC-P4-002 | Search returns hits across two collections | P0 | Integration |
| TC-P4-003 | RSS parse sample fixture: N items | P0 | Unit |
| TC-P4-004 | Save RSS item: URL appears in target collection | P0 | Integration |

---

## Phase 5 — Monetization & cloud sync (Sprints 11–12)

**Goal:** Ad Day Pass, RevenueCat, paywall; **free-account cloud + quotas**; guest→`lv_*` upload; premium delta sync + queue; thumbnails bucket.

**Dependencies:** Phase 3–4; schema; [Cloud_Sync_and_Reconciliation.md](../04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md); [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md).

### Task backlog

**Monetization**

- [ ] **P5-T01** AdMob rewarded: test IDs in dev
- [ ] **P5-T02** Ad Day Pass: trial, 24h pass, grace offline / load fail
- [ ] **P5-T03** RevenueCat: `premium` entitlement; use purchase/restore return values
- [ ] **P5-T04** Paywall UI; restore; sandbox checklist per [Monetization doc](../05_MONETIZATION/Monetization_Strategy_RevenueCat_Guide.md)

**Cloud**

- [ ] **P5-T05** Migration service: **guest → account** batch upsert collections then URLs; idempotent
- [ ] **P5-T05b** **Free-account quota** enforcement in Postgres (RPC or policies); configurable limits
- [ ] **P5-T06** Set `lv_has_migrated_to_cloud` (or equivalent) when needed for **premium legacy** or explicit backfill only after verification
- [ ] **P5-T07** Delta sync: pull/push by `updated_at`; LWW policy
- [ ] **P5-T08** Offline queue for premium: flush on reconnect
- [ ] **P5-T09** Thumbnails → `lv-thumbnails` per storage policy
- [ ] **P5-T10** Downgrade path: read-only or policy from PRD + state machine
- [ ] **P5-T11** Manual sync action in settings: full verification pass and user-visible outcome
- [ ] **P5-T12** Sync status indicator with queue depth / last sync timestamp / failed state hint
- [ ] **P5-T13** Post-migration reconciliation checks: row-count parity, delete-state parity, counter parity
- [ ] **P5-T14** Sync observability events wired: `sync_started`, `sync_failed`, `migration_sync_completed`, `conflict_resolved`
- [ ] **P5-T15** Optional legacy Firebase import path behind feature flag (non-blocking rollout)

### Evaluation gate (Phase 5 exit)

| Criterion | Target |
|-----------|--------|
| Ads | Day 1–3 no gate; day 4+ gate; grace paths verified |
| IAP | Purchase + restore; entitlement drives UI and repo selection |
| Migration | No duplicate rows; resumable; verification pass after migration |
| Sync | Conflict policy documented; queue drains after offline edits |
| Security | Entitlement + **quota** recheck before cloud writes; guest never receives cloud write path |
| Data integrity | Post-migration checksum (counts + id uniqueness + parity checks) passes |
| Rollback | Failed migration keeps `hasMigrated = false` and provides safe retry path |

### Verification

- [ ] Sandbox purchase → premium → migration → second device sees data
- [ ] Airplane mode: local edits queue; online: sync completes
- [ ] Expire subscription (sandbox): app matches downgrade spec

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P5-001 | Ad gate: day 4 simulated → gate shown | P0 | Integration |
| TC-P5-002 | Watch ad → 24h access; timestamp stored | P0 | Integration |
| TC-P5-003 | Premium purchase → ad gate bypass | P0 | Integration |
| TC-P5-004 | Restore purchases → entitlement restored | P0 | Integration |
| TC-P5-005 | Guest migration: local N collections / M URLs → cloud counts match | P0 | Integration |
| TC-P5-009 | Free tier at quota → insert rejected; premium insert succeeds | P0 | Integration |
| TC-P5-006 | Migration idempotency: run twice → no duplicate UUID rows | P0 | Integration |
| TC-P5-007 | Offline edit while premium: queue flush on reconnect | P0 | Integration |
| TC-P5-008 | LWW: older `updated_at` loses on merge (fixture) | P1 | Unit |
| TC-P5-101 | Concurrent update conflict: two devices edit same URL; deterministic winner by policy | P0 | Integration |
| TC-P5-102 | Large dataset migration + pagination safety with 500+ URLs in one collection | P0 | Integration |
| TC-P5-103 | Soft-delete propagation: deleted URL never resurrects after sync | P0 | Integration |
| TC-P5-104 | Queue durability: offline edits survive app kill and flush on reconnect | P0 | Integration |
| TC-P5-105 | Downgrade behavior: writes blocked or allowed exactly per selected policy | P0 | Integration |

---

## Phase 6 — Polish, QA, launch (Sprints 13–14)

**Goal:** A11y, performance, test coverage, beta, store submission, analytics/crash.

**Dependencies:** Phase 5.

### Task backlog

- [ ] **P6-T01** Shimmer / transitions / empty states
- [ ] **P6-T02** VoiceOver / TalkBack pass on P0 flows
- [ ] **P6-T03** Performance: cold start, search, list scroll (targets per PRD)
- [ ] **P6-T04** Unit coverage for all use cases (per Developer Bible)
- [ ] **P6-T05** Widget + integration tests for auth, save URL, migration smoke
- [ ] **P6-T06** Crash reporting + analytics events (per product decision; align with security doc)
- [ ] **P6-T07** TestFlight + Play internal; beta feedback loop
- [ ] **P6-T08** Store listings, screenshots, privacy labels
- [ ] **P6-T09** [Release_Operations_Runbook.md](../09_RELEASE_AND_OPERATIONS/Release_Operations_Runbook.md) executed for v1.0

### Evaluation gate (Phase 6 exit — launch)

| Criterion | Target |
|-----------|--------|
| Quality | No open Sev-0 / Sev-1; agreed waiver process for Sev-2 |
| Testing | Gates in [Testing_Strategy_and_Quality_Gates.md](../08_TESTING_AND_QUALITY/Testing_Strategy_and_Quality_Gates.md) met |
| Security | [Security_Compliance_Runbook.md](../07_SECURITY_AND_COMPLIANCE/Security_Compliance_Runbook.md) pre-release checklist |
| Ops | Rollback path documented; monitoring baseline live |
| Privacy | Analytics/crash logs contain no raw PII or auth tokens |
| Rollback drill | One staging rollback drill completed and documented |
| Stability | Beta soak for 7 days with sync/migration failure rates under threshold |

### Verification

- [ ] Beta cohort sign-off or tracked issues triaged
- [ ] Store review assets complete
- [ ] Rollback tested on staging (app and/or feature flags)

### Test cases

| ID | Summary | Priority | Type |
|----|---------|----------|------|
| TC-P6-001 | Full P0 journey: guest → save → sign up → premium → migrate | P0 | Integration |
| TC-P6-002 | Performance: cold start under target (device class documented) | P1 | Manual / tooling |
| TC-P6-003 | Accessibility: focus order on login + home | P1 | Manual |
| TC-P6-004 | Store build: no debug flags; correct applicationId/bundle | P0 | Manual |

---

## Test catalog by phase (rollup)

Use this table for traceability to QA suites; expand rows in phase sections above.

| Phase | P0 test count (min) | Focus |
|-------|---------------------|--------|
| P0 | 2 | Startup, env |
| P1 | 4 | Onboarding, DB, Supabase |
| P2 | 5 | Auth, guest, RLS, delete |
| P3 | 7 | Collections, URLs, share |
| P4 | 4 | Search, RSS |
| P5 | 13 | Ads, IAP, migration, sync, downgrade |
| P6 | 4 | E2E smoke, perf, a11y, release |

**Extended catalog:** add rows to each phase as features land; keep IDs unique (`TC-P3-008`, etc.).

---

## Cross-phase regression suite (every release candidate)

Run before tagging a release:

1. TC-P2-001, TC-P2-003, TC-P3-001, TC-P3-006, TC-P5-005, TC-P5-007, TC-P6-001  
2. RLS spot-check (TC-P2-005)  
3. Purchase restore smoke (TC-P5-004) on sandbox

---

## Revision history

| Version | Date | Notes |
|---------|------|-------|
| 1.1 | 2026-03-24 | Added missing tasks, measurable gate checks, and 5 additional P0 integration tests for migration/sync/downgrade; corrected P3 gate ordering. |
| 1.0 | 2026-03-24 | Initial phase roadmap + gates + test catalog |

---

## Premium follow-up prompt (use after Auto drafts)

Copy-paste when you want a **second pass** on risk, gaps, or gate tightening (use **Premium** model in Cursor):

```text
You are reviewing LinkVault execution docs only (no code changes).

Inputs:
- docs/00_PROJECT_OVERVIEW/Phase_Roadmap_Tasks_and_Test_Catalog.md
- docs/04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md
- docs/04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md
- docs/01_PRODUCT/Product_Requirements_Document.md

Tasks:
1) List any missing tasks or wrong phase ordering for: rebase → auth → collections/URLs → search/RSS → monetization/sync → launch.
2) For each phase exit gate, add 2–3 measurable checks we forgot (security, data integrity, or rollback).
3) Propose 5 additional P0 integration tests for migration + sync + downgrade only, with preconditions and expected results.
4) Flag contradictions with the PRD and say which doc should win (or suggest ADR).

Output: concise bullet list + updated gate table snippets in markdown only.
```

**When to run this Premium pass:** after you fill half the checkboxes in Phase 3–5, or before first beta.
