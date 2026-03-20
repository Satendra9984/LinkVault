# LinkVault — Cloud Sync & Scalability Strategy

**Version:** 1.0  
**Last Updated:** March 20, 2026

---

## Overview

LinkVault is **offline-first by design**. The local ObjectBox database is the primary data store for all users. Supabase (PostgreSQL) is the cloud sync layer, active only for premium users.

---

## Architecture

```
[User Device]                    [Cloud — Supabase]
┌──────────────┐                ┌──────────────────────┐
│   ObjectBox  │ ←── always ──> │ lv_collections       │
│  (local DB)  │                │ lv_urls              │
│              │ ←── sync ─────>│ lv_user_profiles     │
│ All users    │  (premium only) │                      │
└──────────────┘                └──────────────────────┘
        │
        ↓
  Flutter App (Riverpod)
  Repository selected by UserTier
```

---

## Sync Strategy

### Trigger Points (Premium Users)

| Event | Action |
|---|---|
| App launch (premium, online) | Pull delta changes since `last_synced_at` |
| Create/edit/delete operation | Push change immediately to Supabase |
| App background → foreground | Pull delta changes |
| Manual sync (settings screen) | Full push + pull |
| First premium activation | Full migration (all local → Supabase) |

### Delta Sync Algorithm

```dart
Future<void> deltaSync(String userId, DateTime lastSyncedAt) async {
  // 1. Pull remote changes newer than lastSyncedAt
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
  
  // 2. Merge into ObjectBox (last-write-wins by updated_at)
  for (final json in remoteCollections) {
    final remote = CollectionMapper.fromSupabaseJson(json);
    final local = _store.collectionBox.query(
      CollectionModel_.id.equals(remote.id)
    ).build().findFirst();
    
    if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
      _store.collectionBox.put(CollectionMapper.toModel(remote));
    }
  }
  
  // 3. Push local changes not yet in remote
  final localNew = _store.collectionBox
    .query(CollectionModel_.updatedAt.greaterThan(
      lastSyncedAt.millisecondsSinceEpoch
    ))
    .build().find();
  
  if (localNew.isNotEmpty) {
    await supabase.from('lv_collections').upsert(
      localNew.map(CollectionMapper.toSupabaseJson).toList(),
    );
  }
  
  // 4. Update last_synced_at
  await supabase.from('lv_user_profiles').update({
    'last_synced_at': DateTime.now().toIso8601String()
  }).eq('id', userId);
}
```

### Conflict Resolution

**Strategy: Last-write-wins by `updated_at`**

- The record with the newer `updated_at` timestamp wins
- This is simple and correct for a single-user app (no collaboration in v1)
- If two devices edit the same record simultaneously:
  - Whichever syncs last wins (within seconds on typical usage)
  - No data is permanently lost — delete conflicts use soft delete

### Soft Delete Pattern

All records use `is_deleted: bool + deleted_at: TIMESTAMPTZ` instead of hard deletes. This allows:
1. Sync diffing (remote can see what was deleted since last sync)
2. Undo functionality within app session
3. Recovery from accidental deletes

Hard purge runs after 30 days via a Supabase scheduled function.

---

## First-Time Migration (Local → Cloud)

When a free/guest user purchases premium, all local data must be migrated to Supabase.

### Flow

```
Purchase confirmed (RevenueCat)
        │
        ▼
Show migration screen: "Syncing your data to the cloud..."
        │
        ▼
1. Fetch all ObjectBox collections (non-deleted)
2. Batch upsert to lv_collections (owner_id = auth.uid())
3. Fetch all ObjectBox URLs (non-deleted)
4. Batch upsert to lv_urls
5. Upload any cached thumbnails to lv-thumbnails bucket
6. Set SharedPreferences: lv_has_migrated_to_cloud = true
7. Update lv_user_profiles: last_synced_at = now()
        │
        ▼
Switch repository provider to Supabase (Riverpod invalidation)
        │
        ▼
Show success: "All your links are backed up!"
```

### Batch Size

- Collections: upload all at once (users rarely have >500 collections)
- URLs: batch in groups of 100 to avoid Supabase payload limits

---

## Scalability Planning

### Current Target (v1)
- 50,000 MAU
- Average 200 URLs per user, 20 collections
- Total rows: ~10M URLs, ~1M collections
- Supabase free tier: 500MB database → upgrade to Pro ($25/month) at ~50K premium users

### Indexes (Already in Schema)

All critical query paths are indexed:
- `idx_lv_collections_owner_parent` — root + child collection queries
- `idx_lv_urls_collection_pos` — URL list within a collection
- `idx_lv_urls_owner_updated` — delta sync query
- `idx_lv_urls_search` — GIN full-text search

### Scaling Milestones

| Users | Action |
|---|---|
| 10K premium | Monitor Supabase DB size, enable connection pooling (PgBouncer) |
| 50K premium | Upgrade Supabase to Pro plan |
| 100K premium | Add Supabase read replicas if query latency increases |
| 500K premium | Evaluate moving to dedicated Postgres (RDS/Neon) with Supabase auth |

### `activities` Table (Phase 2)

If social/activity features are added in Phase 2, partition the `lv_activities` table by `created_at` month to prevent unbounded growth. Archive entries older than 90 days.

---

## Offline Behavior

| User Action (Offline) | Behavior |
|---|---|
| Add URL | Saved to ObjectBox immediately; queued for sync |
| Edit URL | Updated in ObjectBox; sync on reconnect |
| Delete URL | Soft-deleted in ObjectBox; sync on reconnect |
| Open URL | Opens from ObjectBox cache; click count updated locally |
| Search | Full-text on ObjectBox (no network needed) |
| View collections | From ObjectBox stream |
| Cloud sync status | Show "Offline — sync pending" indicator |

### Sync Queue

Premium users who edit while offline get their changes queued:

```dart
// ShProvider persists across app restarts
@riverpod
class SyncQueueNotifier extends _$SyncQueueNotifier {
  // Tracks entity IDs modified offline
  // On reconnect: flush queue → Supabase upsert
}
```

---

## Security

- All Supabase tables: RLS enabled, `owner_id = auth.uid()` enforced
- Thumbnails in `lv-thumbnails` bucket: read-public, write-scoped to `userId` folder
- No user data leaves device unless premium is active and user is authenticated
- Export files contain no auth tokens
