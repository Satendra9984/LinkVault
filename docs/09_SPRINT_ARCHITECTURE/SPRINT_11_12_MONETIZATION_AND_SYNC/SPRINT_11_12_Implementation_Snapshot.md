# Sprint 11–12 Implementation Snapshot

Baseline matrix (post-implementation): requirement → status → primary files.


| Requirement                                    | Status       | Files                                                                                                                                                        |
| ---------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Ad Day Pass (trial, 24h pass, grace)           | Done         | `check_ad_access_usecase.dart`, `day_pass_gate.dart` → `/daypass` screen contract, `day_pass_screen.dart`, `ad_gate_screen.dart`, `ad_gate_provider.dart`    |
| RevenueCat purchase / identity                 | Done         | `bootstrap.dart`, `revenuecat_premium_repository.dart`, `auth_notifier.dart` (logOut), `premium_provider.dart` + `subscription_status_provider.dart` (alias) |
| AdMob dev/prod                                 | Partial→Done | `app_config.dart` (test ID fallback), `admob_service.dart`, `bootstrap.dart` (diagnostics)                                                                   |
| Free-tier quota (client)                       | Done         | `tier_quota_guard.dart`                                                                                                                                      |
| Guest → account migration (ObjectBox → `lv_*`) | Done         | `local_*_repository_provider`, `migration_screen.dart`, `cloud_migration_service.dart` (`lv_urls`)                                                           |
| Downgrade import/delete                        | Done         | `cloud_downgrade_service.dart` (`lv_collections` / `lv_urls`)                                                                                                |
| Delta sync + LWW conflicts                     | Done         | `cloud_delta_sync_service.dart`, `conflict_policy.dart`                                                                                                      |
| Offline durability + reconnect flush           | Done         | Local-first ObjectBox + `sync_coordinator_provider.dart` (online/resume/lifecycle)                                                                           |
| Sync status UI + manual sync                   | Done         | `profile_screen.dart`, `sync_coordinator_provider.dart`                                                                                                      |
| Sign-out migration flag reset                  | Done         | `app_settings_repository.dart`                                                                                                                               |


## Risks (remaining)

- Server-side `lv_user_profiles.is_premium` vs RevenueCat requires shared webhook (Curate/Supabase); not changed in-app.
- Full E2E AdMob / IAP remains manual sandbox QA.

## Manual QA

See checklist in `Master_Project_Plan.md` Sprint 11–12 Verification block.

## Week 11 Test Matrix (Monetization & Cloud Sync)

### Automated tests (must pass in CI/local)


| Area                      | Test file                                                      | Focus                                                       |
| ------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------- |
| DayPass status            | `test/features/monetization/check_ad_access_usecase_test.dart` | Trial boundary, active pass, legacy fallback, grace/expired |
| Premium state merge       | `test/features/monetization/is_premium_provider_test.dart`     | `isPremiumProvider = dbPremium OR rcPremium`                |
| Quota guard               | `test/core/monetization/tier_quota_guard_test.dart`            | Free-tier caps and premium bypass                           |
| Sync conflict policy      | `test/features/sync/conflict_policy_test.dart`                 | Last-write-wins timestamp rules                             |
| Sync metadata persistence | `test/features/sync/sync_metadata_store_test.dart`             | per-user sync anchor set/get/clear                          |
| Sync error classification | `test/features/sync/delta_sync_error_kind_test.dart`           | network / auth / quota mapping for `PostgrestException`     |
| Sync transient retry      | `test/features/sync/sync_transient_retry_test.dart`            | bounded retry on `SocketException`, no retry on fatal       |


### Manual QA checklist (Week 11)


| ID          | Scenario                              | Expected                                                           |
| ----------- | ------------------------------------- | ------------------------------------------------------------------ |
| W11-MON-01  | Fresh install in dev, within 3 days   | `DayPassStatus.freeTrial`, no ad-gate block                        |
| W11-MON-02  | Post-trial user with no pass          | Gated actions push `/daypass`; grant requires ad or premium        |
| W11-MON-03  | Test Store monthly purchase           | `premium` entitlement active, app unlocks premium immediately      |
| W11-MON-04  | Restore purchases after reinstall     | Premium restored for same app user                                 |
| W11-MON-05  | Shared entitlement smoke test         | Buy in LinkVault dev, Curate dev reflects premium (and vice versa) |
| W11-SYNC-01 | Offline edits then reconnect          | Pending sync count drops after reconnect + flush                   |
| W11-SYNC-02 | Guest → account migration             | Local collections/URLs appear in `lv_collections`/`lv_urls`        |
| W11-SYNC-03 | Sign out then sign in another account | No leaked sync cursor / migration flags                            |


### Week 11 Manual QA Run Order (30–45 mins)

Use this run order to close Week 11 verification quickly with minimal context switching.

#### Prep (5 mins)

1. Use a physical Android device with internet + one secondary test account.
2. Confirm LinkVault dev build uses `.env.dev` (`test_` RC key).
3. Confirm RevenueCat sandbox access is enabled (`Anybody`) and Test Store products are attached to `premium`.
4. Keep RevenueCat dashboard open on **Customers** for entitlement checks.

#### Pass 1 — DayPass behavior (8–10 mins)

1. Fresh install LinkVault dev.
2. Navigate to a gated action (e.g., create flow).
3. Expected (day 0–3): no hard block, app remains usable under free trial.
4. Simulate post-trial state (clock/date or debug state) and retry gated action.
5. Expected (day 4+): redirected to `/daypass` gate.
6. Watch ad from gate.
7. Expected: access granted and subsequent gated actions pass for ~24h.

#### Pass 2 — Premium purchase + restore (8–10 mins)

1. Open paywall in LinkVault dev.
2. Buy monthly Test Store product (`lv_premium_monthly`).
3. Expected: RC customer shows `premium` entitlement active; app unlocks premium immediately.
4. Uninstall/reinstall app, sign in with same account, tap **Restore Purchases**.
5. Expected: premium restored with no extra purchase.

#### Pass 3 — Shared entitlement smoke test (6–8 mins)

1. Keep same account signed in.
2. Purchase in LinkVault dev (or reuse active premium from Pass 2).
3. Open Curate dev.
4. Expected: Curate also sees premium (same project entitlement).
5. Optional reverse check: buy in Curate dev and verify LinkVault premium.

#### Pass 4 — Sync + migration + isolation (10–12 mins)

1. As guest, create 1 collection + 1 URL locally.
2. Sign up/sign in (guest → account migration path).
3. Expected: data appears in cloud (`lv_collections`/`lv_urls`) and in-app after sync.
4. Toggle airplane mode, edit/add item locally, return online.
5. Expected: pending sync decreases and server reflects changes after flush/manual sync.
6. Sign out; sign in with different account.
7. Expected: no leaked migration flag/sync cursor/data from previous user.

#### Week 11 Exit Criteria (2 mins)

- Mark these as done in `Master_Project_Plan.md` verification block when all pass:
  - Day 0–3 no ad gate
  - Day 4+ ad gate + rewarded access
  - RC sandbox purchase works
  - Premium bypass and free-tier behavior validated
  - Downgrade/migration/sync isolation validated

If any fail, log with ID `W11-MON-*` or `W11-SYNC-*` from the matrix above.


### Suggested device matrix

1. **Day Pass:** Fresh install → days 0–3 no gate; after clock skew / day 4+ → parent actions push `/daypass` only when `expired` (**not** when `grace`). Profile “Daily Access Pass” tile opens `/daypass` (status + countdown).
2. **AdMob dev:** Empty `.env` test IDs → rewarded still loads (Google sample unit).
3. **Guest → account:** Create local collection + URL → sign up → migration → rows visible in Supabase `lv_collections` + `lv_urls`.
4. **Sync:** Toggle airplane mode → edit local → online → Profile pending count drops after sync; pull-to-refresh manual **Sync now**.
5. **Sign out / sign in:** Different account → no leaked `hasMigratedToCloud` / sync cursor (`SyncMetadataStore` cleared).
6. **Downgrade:** Import from cloud → local ObjectBox populated; delete remote → `lv_`* empty for user.

## Changelog (2026-03-30)

- Added `lib/features/sync/` (delta sync + coordinator + prefs metadata).
- Monetization/auth/bootstrap/profile/migration/downgrade/quota fixes as in table above.
- Tests: `tier_quota_guard_test`, `check_ad_access_usecase_test`, `conflict_policy_test`.
- **Curate-style gating parity:** `DayPassGate` uses `/daypass` + `pop(bool)`; `/collections/create` route order + safe `extra`; parent-action sweep (home empty create, collections empty, items hub sheet, search open/edit); `CreateEditItemScreen` belt-and-suspenders guard; Profile Day Pass tile → `/daypass` with status-first copy. Tests: `test/core/go_router_collections_create_route_order_test.dart`.

## Week 12 — Cloud Sync Architecture

> **Full architecture documentation lives here:**
> [`WEEK_12_CLOUD_SYNC_ARCHITECTURE_AND_DECISIONS.md`](./WEEK_12_CLOUD_SYNC_ARCHITECTURE_AND_DECISIONS.md)

### Week 12 at a glance

Week 12 completes the cloud-sync subsystem. The implementation snapshot entry is in the table above (rows: delta sync, migration, downgrade, offline durability, sync UI). The architecture doc above covers:

| Topic | What it answers |
|-------|----------------|
| Local-first rationale | Why writes go to ObjectBox first, not Supabase |
| Delta sync + anchor | How only changed rows are exchanged on each sync cycle |
| LWW conflict policy | Why last-write-wins is correct for personal link data |
| Migration lifecycle | One-time guest→cloud upload; safe to retry on failure |
| Downgrade lifecycle | Import cloud data locally; optional remote data delete |
| Failure handling | What happens when sync fails mid-cycle; recovery guarantees |
| Security (RLS) | How Supabase ensures each user only sees their own data |
| Scalability limits | Current capacity envelope; 5 concrete evolution paths |
| Decision log (D1–D6) | Alternatives considered for every major design choice |
| Validation evidence map | Which risks are automated, which require manual QA |
| Incident playbook | How to diagnose "data didn't sync" or "lost a link" reports |

### Week 12 Manual QA checklist

| ID | Scenario | Expected |
|----|----------|---------|
| W12-SYNC-01 | Guest creates data, migrates, verify on Supabase | Rows in `lv_collections` + `lv_urls` for user UUID |
| W12-SYNC-02 | Re-run migration on same account (idempotency) | No duplicate rows; same UUIDs |
| W12-SYNC-03 | Interrupt migration (airplane on), retry | `hasMigratedToCloud` stays false until success; data intact |
| W12-SYNC-04 | Airplane mode edits, reconnect | Pending count drops; server reflects changes |
| W12-SYNC-05 | Downgrade import then delete remote | Local data intact; `lv_*` tables empty for user |
| W12-SYNC-06 | Two devices edit same item offline, both sync | One edit wins (higher `updated_at`); no crash; no orphan row |
| W12-SYNC-07 | Cross-user data isolation (two test accounts) | User B cannot see User A's collections or URLs |

### Week 12 Exit Criteria

Architecture is complete when:

1. All automated tests pass (`flutter test`; 51 tests after Week 12 hardening additions).
2. Manual QA W12-SYNC-01 through W12-SYNC-05 verified.
3. RLS cross-user isolation verified in Supabase dashboard or with two test accounts.
4. No regression in Week 11 monetization test suite.

### Week 12 implementation baseline (hardening-first)

Scope is **stabilize before expanding** (see internal roadmap). Implementation acceptance is aligned with [`WEEK_12_CLOUD_SYNC_ARCHITECTURE_AND_DECISIONS.md`](./WEEK_12_CLOUD_SYNC_ARCHITECTURE_AND_DECISIONS.md) (anchor semantics, LWW, migration idempotency).

**Shipped in code (Week 12 track):**

| Area | Change |
|------|--------|
| Delta sync | Batched `upsert` push; bounded transient retry around full sync cycle; structured logs (`reason`, `durationMs`, counts) |
| Errors | `DeltaSyncErrorKind` + user-facing messages (network / auth / quota) |
| Coordinator | `CloudSyncTrigger` (manual / reconnect / resume / bootstrap); configurable throttle + batch/retry via `syncCoordinatorConfigProvider` |
| Migration | Collection upsert batched (100); transient retry on collection and URL upserts |
| Downgrade | Transient retry on fetch + delete RPC chains |
| Observability | `AppLogger` lines on sync success/failure from coordinator |

Optional expansion (Realtime, additive conflict fields) stays **after** this baseline is green in manual QA.

---

## Week 11 Automated Run Log (2026-03-31)


| Run                   | Command                                                                                                        | Result              |
| --------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------- |
| Sprint-focused suite  | `flutter test test/features/monetization test/features/sync test/core/monetization/tier_quota_guard_test.dart` | ✅ Passed (20 tests) |
| Full repository suite | `flutter test`                                                                                                 | ✅ Passed (44 tests) |


### Notes

- During first sprint-focused run, one test failed due to local-time vs UTC expectation in `sync_metadata_store_test`.
- Fixed by using `DateTime.utc(...)` in the test input.
- Re-ran sprint-focused suite: all tests passed.
- Then executed full repository test suite: all tests passed.

