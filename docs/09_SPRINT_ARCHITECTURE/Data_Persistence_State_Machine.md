# LinkVault — Data Persistence State Machine

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Purpose:** Define exactly which data repository is active under every combination of user state

---

## Overview

LinkVault uses **two data backends**:
- **ObjectBox** (local, always available) — primary for free/guest users
- **Supabase PostgreSQL** (remote, requires internet + premium) — primary for premium users

The repository implementation injected by Riverpod depends on three variables:

| Variable | Source | Type |
|---|---|---|
| `isAuthenticated` | Supabase Auth session | `bool` |
| `isPremium` | RevenueCat entitlement `premium` | `bool` |
| `hasMigrated` | SharedPreferences flag `lv_has_migrated_to_cloud` | `bool` |

---

## State Decision Table

| State | `isAuthenticated` | `isPremium` | `hasMigrated` | Collection Repo | URL Repo | Description |
|---|---|---|---|---|---|---|
| **1** | ❌ | — | — | Local | Local | Guest mode — full local access |
| **2** | ✅ | ❌ | ❌ | Local | Local | Free tier — local only, Ad Day Pass required |
| **3** | ✅ | ❌ | ✅ | ReadOnly(Local) | ReadOnly(Local) | Downgraded premium — reads cloud data, writes blocked |
| **4** | ✅ | ✅ | ❌ | Local | Local | Premium just purchased — migration pending |
| **5** | ✅ | ✅ | ✅ | Supabase | Supabase | Full premium — cloud sync active |
| **6** | ✅ | ✅ | ✅ (offline) | Local cache | Local cache | Premium but offline — reads from ObjectBox cache |
| **7** | ❌→✅ | — | — | Local→migrate | Local→migrate | Account just created — trigger migration prompt |
| **8** | ✅ | ✅→❌ | ✅ | ReadOnly | ReadOnly | Subscription expired — data preserved, writes locked |

---

## State Transitions

```
[Guest] ──────────────────────────────────────> [State 1: Guest / Local]
                                                         │
                                                  Sign Up / Sign In
                                                         │
                                                         ▼
                                              [State 2: Free / Local]
                                                    │         │
                                           Purchase │         │ No purchase
                                           Premium  │         │ (stays free)
                                                    ▼         │
                                        [State 4: Premium New]│
                                                    │         │
                                         Run migration         │
                                                    │         │
                                                    ▼         │
                                        [State 5: Premium Full]│
                                                    │         │
                                     Subscription   │         │
                                     expires        │         │
                                                    ▼         │
                                        [State 8: Expired]    │
                                          │                   │
                              Re-subscribe│                   │
                                          ▼                   ▼
                                    [State 5]         [State 2: Free]
```

---

## Riverpod Provider Logic

```dart
// lib/core/providers/core_providers.dart

final userTierProvider = FutureProvider<UserTier>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return UserTier.guest;

  final isPremium = ref.watch(premiumStatusProvider).valueOrNull ?? false;
  if (!isPremium) return UserTier.free;
  
  return UserTier.premium;
});

final collectionsRepositoryProvider = Provider<CollectionRepository>((ref) {
  final tier = ref.watch(userTierProvider).valueOrNull ?? UserTier.guest;
  final hasMigrated = ref.watch(hasMigratedProvider);
  final isOnline = ref.watch(connectivityProvider).valueOrNull ?? false;

  return switch (tier) {
    // State 5: Premium + migrated + online -> Supabase
    UserTier.premium when hasMigrated && isOnline => 
      ref.read(supabaseCollectionsRepoProvider),
    
    // State 6: Premium + migrated + offline -> Local cache (ObjectBox)
    UserTier.premium when hasMigrated && !isOnline =>
      ref.read(localCollectionsRepoProvider),
    
    // State 4: Premium + not yet migrated -> Local (migration pending)
    UserTier.premium when !hasMigrated =>
      ref.read(localCollectionsRepoProvider),

    // States 1, 2: Guest or free -> Local
    _ => ref.read(localCollectionsRepoProvider),
  };
});
```

---

## Migration Flow (State 4 → State 5)

Triggered when a free/guest user purchases premium.

### Step 1 — Trigger Migration Screen

```dart
// After RevenueCat confirms purchase
ref.read(premiumStatusProvider.notifier).setPremium(true);

// Check if migration needed
final hasMigrated = prefs.getBool('lv_has_migrated_to_cloud') ?? false;
if (!hasMigrated) {
  context.push('/migrate-to-cloud');
}
```

### Step 2 — Migration Service

```dart
class CloudMigrationService {
  final ObjectBoxStore _localDb;
  final SupabaseClient _supabase;
  final String _userId;

  Future<Either<Failure, MigrationResult>> migrateToCloud() async {
    try {
      // 1. Fetch all local collections
      final localCollections = _localDb.collectionBox
        .query(CollectionModel_.isDeleted.equals(false))
        .build().find();
      
      // 2. Fetch all local URLs
      final localUrls = _localDb.urlBox
        .query(UrlModel_.isDeleted.equals(false))
        .build().find();
      
      // 3. Upsert to Supabase (batch)
      await _supabase
        .from('lv_collections')
        .upsert(localCollections.map(CollectionMapper.toSupabaseJson).toList());
      
      await _supabase
        .from('lv_urls')
        .upsert(localUrls.map(UrlMapper.toSupabaseJson).toList());
      
      // 4. Mark migration complete
      await SharedPreferences.getInstance()
        .then((p) => p.setBool('lv_has_migrated_to_cloud', true));
      
      return Right(MigrationResult(
        collectionsCount: localCollections.length,
        urlsCount: localUrls.length,
      ));
    } catch (e, st) {
      return Left(UnexpectedFailure('Migration failed', error: e, stackTrace: st));
    }
  }
}
```

---

## Downgrade Flow (State 5 → State 8)

When a premium subscription expires:

1. RevenueCat `CustomerInfo` listener detects `premium` entitlement is no longer active
2. `isPremium` set to `false` in app
3. State transitions to **State 8** (ReadOnly)
4. User sees a banner: *"Your LinkVault Premium has expired. Your data is safe. Renew to sync again."*
5. Writes are blocked — `ReadOnlyCollectionRepository` wraps the Supabase repo and throws `DowngradeFailure` on any mutation

### ReadOnly Repository Wrapper

```dart
class ReadOnlyCollectionRepository implements CollectionRepository {
  final CollectionRepository _delegate;
  ReadOnlyCollectionRepository(this._delegate);

  // Allow reads
  @override
  Stream<List<CollectionEntity>> watchRootCollections() =>
    _delegate.watchRootCollections();

  // Block all writes
  @override
  Future<Either<Failure, Unit>> createCollection(CollectionEntity e) async =>
    Left(DowngradeFailure('Renew your subscription to save changes'));

  @override
  Future<Either<Failure, Unit>> updateCollection(CollectionEntity e) async =>
    Left(DowngradeFailure('Renew your subscription to save changes'));

  @override
  Future<Either<Failure, Unit>> deleteCollection(String id) async =>
    Left(DowngradeFailure('Renew your subscription to delete'));
}
```

---

## Ad Day Pass State Machine

Separate from the premium state machine. Applies only to **free authenticated users (State 2)**.

```
App Launch
    │
    ▼
Is premium?  ──YES──> Skip (no gate)
    │
    NO
    ▼
Are we in 3-day trial period?  ──YES──> Grant access (no ad)
    │
    NO
    ▼
Time since last ad watch < 24hrs?  ──YES──> Grant access (pass active)
    │
    NO
    ▼
Is network available AND ad loaded?  ──YES──> Show ad gate → watch ad → grant 24hr pass
    │
    NO
    ▼
Apply grace period (24hr) → Grant access, log grace_period_used=true
```

### Persistence (SharedPreferences)

| Key | Type | Description |
|---|---|---|
| `lv_first_install_at` | `int` (epoch ms) | App install timestamp |
| `lv_last_ad_watched_at` | `int` (epoch ms) | Timestamp of last rewarded ad |
| `lv_grace_period_active` | `bool` | Currently in grace period |
| `lv_grace_period_expires_at` | `int` (epoch ms) | When grace expires |
| `lv_total_ads_watched` | `int` | Lifetime ad watch count |

---

## Schema Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | March 20, 2026 | Initial state machine document |
