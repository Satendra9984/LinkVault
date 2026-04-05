# Guest → Cloud Sync: Architecture, Bugs, and Fixes — Case Study

**Scope:** This document covers the full lifecycle of the guest-to-cloud feature from architecture design through two production bugs discovered during manual QA and how each was diagnosed and fixed. It is written as a learning reference and engineering case study.

---

## 1. Product Goal

LinkVault supports two first-run personas:

1. **Guest (offline-first):** The user taps "Continue as Guest." The app writes all data to local **ObjectBox** on the device. No Supabase session. Subject to the 3-day DayPass trial.
2. **Signed-in (free or premium):** The user authenticates with OTP. Data lives in Supabase (`lv_collections` / `lv_urls`). Premium users additionally enable delta sync for offline durability.

A critical UX requirement is: if a guest later creates an account or signs in, **all their local data must be carried over to Supabase seamlessly**, so nothing is lost.

---

## 2. Architecture Overview

### 2.1 Data Backend Routing (ADR-0002)

```
lib/core/providers/data_backend_selection_provider.dart
```

```dart
final useCloud = isAuthenticated && isOnline && (!isPremium || hasMigratedToCloud);
```

| State | Repository Used |
|---|---|
| Guest (no session) | `CollectionsRepositoryImpl` (ObjectBox) |
| Authenticated + online, free or migrated | `SupabaseCollectionRepository` |
| Authenticated + online, premium + not migrated | `CollectionsRepositoryImpl` (stay local until bulk migration) |
| Authenticated + offline | `CollectionsRepositoryImpl` (cache) |
| Premium lapsed, online | `ReadOnlyCollectionsRepository` (cloud, read-only) |

### 2.2 Library Root Invariant

Postgres enforces:

```sql
-- supabase/migrations/014_uq_library_root_per_user.sql
CREATE UNIQUE INDEX uq_lv_collections_one_root_per_user
  ON public.lv_collections (owner_id)
  WHERE parent_id IS NULL AND is_deleted = false;
```

**Exactly one non-deleted, non-parented (root-level) row per user is allowed.** This "Library" folder is the anchor of the whole tree. Every other collection is nested under it.

On the server, `ensure_library_root(p_owner_id)` (migration 015) atomically gets-or-creates this row:

```sql
-- supabase/migrations/015_ensure_library_root_rpc.sql
SELECT … FOR UPDATE;   -- finds existing root
IF NOT FOUND THEN INSERT …;  -- creates exactly one
RETURN root_id;
```

On the client, `CollectionsRepositoryImpl.ensureLibraryRootCollection()` does the same for ObjectBox, reparenting any extra top-level rows under a new root when multiple exist.

### 2.3 Guest → Cloud Migration Flow

When a guest signs in, `auth_verify_screen.dart` detects `_wasGuestBeforeVerify = true` and navigates to `/migration`:

```
auth_verify_screen.dart  →  context.go('/migration')  →  MigrationScreen
                                                           ↓
                                              CloudMigrationService.migrateToCloud()
```

The migration steps are:

```
1. ensureLibraryRootCollection()       // repair local ObjectBox: 1 root guaranteed
2. _repairExtraLocalTopLevelFolders()  // belt-and-suspenders: reparent extras
3. getAllCollections()                  // read clean local state
4. ensure_library_root RPC → S         // get/create server root id S
5. collectionsWithRemappedRootIds(L→S) // remap local root L to server root S
6. assertValidRootRows(payload)        // safety check: exactly 1 root in batch
7. upsert lv_collections               // push remapped collections
8. upsert lv_urls                      // push items (collection_id L→S)
9. hasMigratedToCloud = true           // flag: subsequent runs use cloud repo
```

### 2.4 Delta Sync Flow

After migration, the `SyncCoordinator` (premium) or the normal cloud repo (free) keeps data in sync. The delta sync service (`cloud_delta_sync_service.dart`) runs a pull-then-push cycle:

```
_runDeltaBody():
  PULL:  SELECT lv_collections WHERE owner_id=? [AND updated_at > anchor]
         SELECT lv_urls         WHERE owner_id=? [AND updated_at > anchor]
         → _mergeCollection() / _mergeItem() → LWW merge into ObjectBox

  PUSH:  allOwnedCollections ← ObjectBox (all with owner match)
         collectionsToPush   ← filter by updatedAt > anchor
         localRootId ← canonicalTopLevelRootId(allOwnedCollections)
         serverRootId ← ensure_library_root RPC (if push non-empty)
         canonicalCollections ← collectionsWithRemappedRootIds(L→S)
         assertValidRootRows(payload)   // ← safety guard
         upsert lv_collections
         upsert lv_urls
         advance anchor to syncStarted
```

**Last-write-wins (LWW):** `ConflictPolicy.remoteIsNewer(local.updatedAt, remote.updatedAt)` — the side with the newer `updated_at` wins during merge.

---

## 3. Bug 1 — Migration: 23505 Duplicate Root Constraint

### 3.1 Symptom

```
PostgrestException(message: duplicate key value violates unique constraint
  "uq_lv_collections_one_root_per_user", code: 23505)
⛔ Cloud Migration Failed
```

**Reproduction:** Install → Continue as Guest → create a collection → Sign in (account with existing Supabase data).

### 3.2 Root Cause

Before the fix, `migrateToCloud()` was:

```dart
// OLD code (simplified)
final collections = await _localCollectionsRepo.getAllCollections();
final collectionData = collections.map((c) => toJson(c, userId)).toList();
upsert(lv_collections, collectionData);  // ← 23505 here
```

Two cases caused the collision:

**Case A — Local drift (multiple local roots):**
`getAllCollections()` returned every row in ObjectBox without normalizing the tree. If a user created a folder before `ensureLibraryRootCollection()` was triggered (race condition, legacy install, etc.), ObjectBox could have 2+ rows with `parentId == null`. The batch then tried to insert 2 root rows for the same `owner_id` → constraint violation.

**Case B — Server already has a root (the real QA failure):**
The account had existing data in Supabase: a Library row with id **S** and `parent_id IS NULL`. The device had local root id **L** (a different UUID). The batch pushed **L** as a new `parent_id IS NULL` row for the same user, colliding with **S**.

```
Supabase:  S (parent_id=null, owner=userId)   ← exists
Payload:   L (parent_id=null, owner=userId)   ← conflict → 23505
```

### 3.3 The Fix

**Step 1 — Normalize local before reading:**
Call `ensureLibraryRootCollection()` at the start of migration to guarantee exactly one root in ObjectBox, then run `_repairExtraLocalTopLevelFolders()` as belt-and-suspenders.

**Step 2 — Reconcile with server root:**
Call `ensure_library_root` RPC → get `S`. If `S != L`, remap the entire payload:
- Collection with `id == L` → rewrite to `id = S`
- Any collection with `parentId == L` → rewrite to `parentId = S`
- Items with `collectionId == L` → rewrite to `collectionId = S`

This is done in `CloudMigrationRootAlignment.collectionsWithRemappedRootIds()`.

**Step 3 — Assert before upsert:**
`assertValidRootRows(payload)` throws if the payload would still violate the constraint. Migration returns a user-facing error instead of letting Postgres reject it.

```
New flow:
  ensureLibraryRootCollection()    → ObjectBox: 1 root L
  _repairExtraLocalTopLevelFolders() → ObjectBox: still 1 root
  getAllCollections()
  ensure_library_root RPC → S
  collectionsWithRemappedRootIds(L→S) → payload: {id:S, parent:null}, {id:child, parent:S}
  assertValidRootRows(payload)     → count=1, OK
  upsert lv_collections            → no conflict
```

**New files:**
- `lib/features/monetization/application/cloud_migration_root_alignment.dart` — pure remap helpers, fully unit-tested.
- Updated `lib/features/monetization/application/cloud_migration_service.dart`.
- Tests: `test/features/monetization/cloud_migration_root_alignment_test.dart`.

---

## 4. Bug 2 — Delta Sync: "2 active root rows" After First Pull

### 4.1 Symptom

```
Bad state: Invalid collections payload: 2 active root rows (expected <= 1)
[DeltaSync] failed reason=resume user=...
```

**Reproduction:** Continue as Guest → create mock data → Sign in → Migration succeeds → Sync runs → assertion fires.

### 4.2 Why Migration Succeeded but Sync Failed

Migration fixed the Supabase state correctly:

```
After migration:
  Supabase: S (parent_id=null) + children (parent_id=S)
  ObjectBox: L (parentId=null) + children (parentId=L)    ← L stays locally
```

Migration does NOT update ObjectBox's root id to S. It only pushes a remapped payload to Supabase. ObjectBox retains the old local root L.

Then the sync coordinator runs `_runDeltaBody` with `anchor = null` (first sync, no checkpoint):

**Pull phase:**
```
SELECT lv_collections WHERE owner_id=? → [S, children with parentId=S]

_mergeCollection(S):
  box.query(uid = S).findFirst() → NOT FOUND (ObjectBox has L, not S)
  → INSERT S into ObjectBox     ← This is the trigger
```

After the pull, ObjectBox has:
```
L  (parentId=null, ownerId=null, createdAt=earlier)   ← old local root
S  (parentId=null, ownerId=userId, createdAt=later)   ← just inserted from server
children…
```

**Push phase:**
```
allOwnedCollections = [L, S, children]   // _ownedByUser(null, userId)=true catches L

localRootId = canonicalTopLevelRootId([L, S, …])
            = L  (Library title, older createdAt → picks L as canonical)

ensure_library_root RPC → S

canonicalizeCollectionsForSync([L, S, children], localRootId=L, serverRootId=S):
  L: id==localRootId → remap id to S, parentId stays null → {id:S, parent:null}
  S: id≠L, parentRefsLocal(null)=false → unchanged → {id:S, parent:null}
  children: parentId=S≠L → unchanged → {id:child, parent:S}

collectionPayloads = [
  {id:S, parent_id:null},   ← from L, remapped
  {id:S, parent_id:null},   ← from S, unchanged
  …
]

countActiveRootRowsInJson = 2   ← two rows with id=S and parent_id=null
assertValidRootRows → throws!
```

The assertion correctly detects the duplicates. The issue is that the remap of `L→S` produces a row with `id=S`, but the original `S` (pulled from Supabase) was already in the push list with `id=S`. Both have `parent_id=null` → counted as 2 roots.

### 4.3 The Fix

**Filter out collections whose `id == serverRootId && id != localRootId` before mapping.**

These are server-side roots that were pulled from Supabase into ObjectBox. When `localRootId` gets remapped to `serverRootId`, it already covers the server root's slot in the upsert. Including the original-S row creates a duplicate `id=S` in the payload.

```dart
// In collectionsWithRemappedRootIds, BEFORE the map:
final deduped = (localRootId == serverRootId)
    ? collections
    : collections
        .where((c) => !(c.id == serverRootId && c.id != localRootId))
        .toList();
return deduped.map((c) { … }).toList();
```

After this filter:
```
Input:  [L, S, children]
Filter: drop S (id==serverRootId && id!=localRootId)
Remaining: [L, children]

Remap L→S:
  L → {id:S, parent:null}
  children → unchanged {id:child, parent:S}

Payload: [{id:S, parent:null}, {id:child, parent:S}]
count=1 → OK
```

**Why this is safe:**
- The server already has S in the correct state (migration pushed it).
- The remapped L provides a fresh upsert of S's metadata (title, color, etc.) if it changed locally.
- Pulling S from the server (during sync) might have updated S's metadata via LWW — but for the Library root, this metadata is rarely changed.
- On subsequent syncs `anchor` advances. L's `updatedAt` is before anchor, so L is excluded from `collectionsToPush`. The issue is self-healing after the first successful sync.

---

## 5. Architecture Diagram (Complete Data Flow)

```
GUEST SESSION                   SIGN-IN                   AUTHENTICATED SESSION
─────────────────               ──────────────────        ─────────────────────────────────
User taps "Guest"               OTP verified              Delta sync (SyncCoordinator)
  → isGuestMode=true               ↓                         ↓
  → useCloud=false              _wasGuestBeforeVerify?    _runDeltaBody():
  → ObjectBox repo                 ↓ (true)                 PULL lv_collections WHERE owner=?
                                context.go('/migration')        → _mergeCollection (LWW)
User creates collections           ↓                       PULL lv_urls WHERE owner=?
  → ObjectBox: L(root),        migrateToCloud():              → _mergeItem (LWW)
    children(parentId=L)          ↓                       BUILD push list (updatedAt > anchor)
                              ensureLocal 1 root (L)         localRootId = canonicalRoot(all)
                                  ↓                          ensure_library_root RPC → S
                              RPC ensure_library_root → S    dedup server root from push list ← FIX 2
                                  ↓ (S != L)               remap L→S in payload
                              remap payload L→S              assertValidRootRows → 1 root
                                  ↓                          upsert lv_collections
                              assertValidRootRows ← FIX 1   upsert lv_urls
                                  ↓                          advance anchor
                              upsert lv_collections
                              upsert lv_urls
                                  ↓
                              hasMigratedToCloud=true
                                  ↓
                              useCloud=true (ADR-0002)
```

---

## 6. ObjectBox State After Migration (The Ghost Root Problem)

This is the key architectural subtlety that caused Bug 2:

**Migration is one-way and does not update ObjectBox.**

```
Before migration:  ObjectBox: [L(parent=null)]
After migration:   ObjectBox: [L(parent=null)]  ← unchanged
                   Supabase:  [S(parent=null)]   ← S is a new/different UUID
```

The fix to Bug 1 remaps the PAYLOAD (Supabase upload). It does NOT rename L to S in ObjectBox. ObjectBox keeps L as a "ghost" with the old UUID.

**Why this is acceptable:**
1. For free/signed-in users: `useCloud=true` → `collectionsRepositoryProvider` returns `SupabaseCollectionRepository`. CRUD operations go directly to Supabase. ObjectBox is only used as a write-back cache by delta sync.
2. On the first successful delta sync: the PULL phase downloads S from Supabase and inserts it into ObjectBox. Now ObjectBox has both L and S. The PUSH phase (with Bug 2 fixed) correctly deduplicates and pushes only S. Anchor advances.
3. On subsequent syncs: L's `updatedAt` is before anchor → excluded from push. Only new/changed data is pushed. L is never pushed again. It becomes an inert orphan.
4. Future improvement: After migration, explicitly soft-delete L in ObjectBox (set `isDeleted=true`) or update L's id to S so ObjectBox and Supabase are in perfect alignment.

---

## 7. Key Files Reference

| File | Role |
|---|---|
| `lib/core/providers/data_backend_selection_provider.dart` | ADR-0002 backend routing |
| `lib/features/monetization/application/cloud_migration_service.dart` | Guest→cloud bulk upload |
| `lib/features/monetization/application/cloud_migration_root_alignment.dart` | Root remap + dedup helpers |
| `lib/features/sync/application/cloud_delta_sync_service.dart` | Pull-merge-push delta sync |
| `lib/features/sync/application/sync_transient_retry.dart` | Bounded retry with exponential backoff |
| `lib/features/sync/domain/conflict_policy.dart` | Last-write-wins timestamp comparator |
| `lib/features/collections/data/repositories/collections_repository_impl.dart` | Local ObjectBox repo |
| `lib/features/collections/data/repositories/supabase_collection_repository.dart` | Cloud Supabase repo |
| `supabase/migrations/014_uq_library_root_per_user.sql` | DB constraint: 1 root per user |
| `supabase/migrations/015_ensure_library_root_rpc.sql` | Atomic get-or-create server root RPC |
| `test/features/monetization/cloud_migration_root_alignment_test.dart` | Pure unit tests for remap logic |

---

## 8. Lessons Learned

### L1 — A migration that fixes the upload payload is not the same as fixing local state.

Migration remapped `L→S` in the Supabase payload but left ObjectBox unchanged. This is valid and intentional (ObjectBox is offline cache, not the source of truth for signed-in users). But it means the delta sync must also understand this remapping, not just the migration.

### L2 — A pull can make local state worse before the push.

The delta sync pull correctly inserted the server root S into ObjectBox. This increased the number of local roots from 1 to 2. A naive push then violated the invariant. The pull is not atomic with the push. State between them can be temporarily inconsistent.

### L3 — Deduplication must happen before payload validation, not after.

The assertion (`assertValidRootRows`) is a correct safety net. The mistake was that `collectionsWithRemappedRootIds` did not account for an input that already contained the target `serverRootId`. The remap produced two rows with the same id (one from the local root remapped, one from the server root unchanged). Deduplication before the map is the fix.

### L4 — `_ownedByUser(null, userId) == true` is a deliberate and necessary rule.

Guest collections stored in ObjectBox have `ownerId = null` (no Supabase user at the time of creation). The sync treats these as belonging to the current user after sign-in. This is correct: the migration step reassigns ownership by uploading with `owner_id = userId`. Without this rule, guest data would be invisible to the sync engine.

### L5 — Assertions in the push path are valuable, even when they expose bugs.

The `assertValidRootRows` guard existed specifically to catch scenarios like this. When it threw, it prevented a corrupt write to Supabase (two library roots for one user). The error message precisely identified the problem (count=2). This is the correct behavior: fail loudly before writing bad data, fix upstream.

### L6 — First sync (anchor=null) is the highest-risk sync run.

When anchor is null, every local collection and every server collection are candidates for push and pull respectively. Edge cases that only appear at first sync are easy to miss in testing. Always include a "sign-out → re-sign-in" test after migration QA.

---

## 9. Test Coverage Map

| Scenario | Test |
|---|---|
| Canonical root selection (Library title, createdAt tiebreak) | `cloud_migration_root_alignment_test.dart` |
| Remap: L→S on collection ids + parent_id refs | `cloud_migration_root_alignment_test.dart` |
| No-op when L==S | `cloud_migration_root_alignment_test.dart` |
| Item collection_id remap L→S | `cloud_migration_root_alignment_test.dart` |
| countActiveRootRowsInJson | `cloud_migration_root_alignment_test.dart` |
| Pulled server root S dedup with remapped L | `cloud_migration_root_alignment_test.dart` (Bug 2 fix) |
| Sync conflict LWW (remote newer wins) | `test/features/sync/conflict_policy_test.dart` |
| Transient retry (SocketException retried, fatal not retried) | `test/features/sync/sync_transient_retry_test.dart` |
| Sync anchor set/get/clear per user | `test/features/sync/sync_metadata_store_test.dart` |
| DeltaSyncErrorKind classification | `test/features/sync/delta_sync_error_kind_test.dart` |

---

## 10. Manual QA Checklist for This Feature

| ID | Scenario | Expected |
|---|---|---|
| QA-M-01 | Fresh install → guest → no collections → sign in | Migration runs, no error, home shows empty state |
| QA-M-02 | Fresh install → guest → create 1 folder → sign in (new account) | Migration runs, folder appears in cloud, sync OK |
| QA-M-03 | Guest → create folders+links → sign in → account had existing data | Migration succeeds, local data merged, no 23505 |
| QA-M-04 | Repeat QA-M-03 sign-out → sign-in | Second migration run, no 23505, anchor advances |
| QA-M-05 | Guest → mock data → sign in → sync fires | Sync assertion passes (no "2 root rows"), data visible |
| QA-M-06 | Sign in directly (no guest) | No migration, normal cloud session, sync works |
| QA-M-07 | Sign out → sign in same account | hasMigratedToCloud clears; migration re-runs cleanly |
| QA-M-08 | Network drops mid-migration | Retry screen shown; retry succeeds on reconnect |
| QA-M-09 | Offline → create collections → reconnect | Delta sync pushes pending rows, anchor advances |
