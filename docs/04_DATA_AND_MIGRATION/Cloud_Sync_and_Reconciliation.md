# LinkVault Cloud Sync and Reconciliation

Version: 1.1  
Last Updated: 2026-03-24  
Status: Active  
Owner: Engineering  
Depends On: `docs/04_DATA_AND_MIGRATION/Supabase_Schema_and_Migrations.md`, `docs/04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md`, `docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md`

---

## Purpose

Define deterministic sync behavior between ObjectBox and Supabase, including trigger points, conflict policy, retry behavior, and recovery strategies.

---

## Sync Model

LinkVault sync uses:

- **local-first / cache-first** writes for offline resilience
- **cloud propagation for all authenticated users** (guest remains local-only)
- **Free account:** same delta sync patterns as premium but **writes must respect quotas**
- **Premium:** no quota wall (or much higher limits)
- idempotent upserts
- soft-delete aware reconciliation

Sync does not rely on uncontrolled full realtime streams for large URL lists.

---

## Trigger Points

| Trigger | Action |
|---|---|
| App launch (authenticated + online, not guest) | delta pull then queued push flush |
| Foreground resume | quick delta pull |
| Local mutation while online (free or premium) | write-through or queue per implementation; **quota check** on free tier creates |
| Manual sync action | full verification pass + drift report |
| Guest → account | start **upload migration** workflow |
| Premium upgrade (not migrated / legacy) | start migration workflow if applicable |

---

## Conflict Resolution Policy

Primary policy: last-write-wins by `updated_at`.

Secondary safeguards:

- compare `is_deleted` to prevent resurrecting intentionally deleted rows
- prefer non-null metadata fields if timestamps are equal and records differ
- log each resolved conflict for diagnostics

Decision table:

| Local | Remote | Decision |
|---|---|---|
| newer `updated_at` | older `updated_at` | push local |
| older `updated_at` | newer `updated_at` | pull remote |
| both deleted | either order | keep deleted |
| equal timestamps, different data | tie-break by deterministic field precedence and log warning |

---

## Delta Sync Algorithm (Reference)

```dart
Future<void> runDeltaSync({
  required String userId,
  required DateTime lastSyncedAt,
}) async {
  // Pull recent remote changes
  final remoteCollections = await supabase
      .from('lv_collections')
      .select()
      .eq('owner_id', userId)
      .gt('updated_at', lastSyncedAt.toIso8601String());

  final remoteUrls = await supabase
      .from('lv_urls')
      .select()
      .eq('owner_id', userId)
      .gt('updated_at', lastSyncedAt.toIso8601String());

  mergeRemoteIntoLocal(remoteCollections, remoteUrls);

  // Push local pending changes
  final localPendingCollections = getLocalPendingCollections(lastSyncedAt);
  final localPendingUrls = getLocalPendingUrls(lastSyncedAt);

  await supabase.from('lv_collections').upsert(localPendingCollections);
  await supabase.from('lv_urls').upsert(localPendingUrls);

  await updateLastSyncedAt(userId, DateTime.now());
}
```

---

## Retry and Backoff Strategy

- Retry classes:
  - transient network errors
  - Supabase rate/timeout errors
- No-retry classes:
  - validation/constraint failures
  - authorization failures

Backoff:

- 1st retry: 2s
- 2nd retry: 5s
- 3rd retry: 15s
- then mark queue item as failed and surface diagnostic status

---

## Sync Queue Contract

Queue stores:

- entity type (`collection`, `url`)
- operation (`upsert`, `delete`)
- entity ID
- payload hash
- attempts count
- last error code/message

Queue behavior:

1. persist queue locally
2. dedupe by entity ID + latest payload hash
3. flush on connectivity regain or explicit sync trigger
4. keep dead-letter entries for manual recovery review

---

## Reconciliation Windows

Run periodic reconciliation to detect drift:

- lightweight at startup (last 24h changes)
- full verification on manual sync
- post-migration verification after first premium cloud push

Checks:

- local/cloud row count parity per collection
- deleted-state parity
- collection URL counters match actual rows

---

## Failure Modes and Handling

| Failure Mode | Impact | Handling |
|---|---|---|
| network offline | no cloud update | queue and continue local operations |
| partial batch write | inconsistent cloud state | chunked retries with idempotent upsert |
| stale entitlement state | wrong repo selection | re-evaluate entitlement before sync run |
| constraint violation | sync blocked for row | isolate row, log, continue remaining queue |
| schema drift | mapper failures | fail fast, disable sync, surface high-priority alert |

---

## Observability Requirements

Emit events for:

- sync_started
- sync_completed
- sync_failed
- queue_flush_started/completed
- conflict_resolved
- migration_sync_completed

Minimum log attributes:

- user hash ID
- run ID
- affected entity counts
- duration
- error class

---

## Exit Criteria for Production Readiness

- sync queue survives app restarts
- migration followed by delta sync yields no drift in test dataset
- conflict policy validated with simulated multi-device edits
- failure modes produce actionable error messages and telemetry

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.1 | 2026-03-24 | Authenticated free tier uses cloud + quotas; guest upload migration; trigger table updated. |
| 1.0 | 2026-03-23 | New canonical sync/reconciliation specification. |
