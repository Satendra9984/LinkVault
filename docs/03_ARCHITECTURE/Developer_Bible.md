# LinkVault — Developer Bible

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Read this before writing a single line of code.**

---

## 1. Project Philosophy

LinkVault is an **offline-first, mobile-first URL organizer** rebuilt from scratch on the Curate architecture foundation. The original app suffered from:
- Dual state management (BLoC + Riverpod)
- Dual backends (Firebase + Supabase)
- No use-case layer
- Isar v3 (outdated, buggy on iOS)
- No environment separation

This reboot corrects all of these. **The rules below are absolute**.

---

## 2. The Six Non-Negotiable Rules

### Rule 1: One State Manager — Riverpod Only

- ✅ `flutter_riverpod` (Riverpod 2.x)
- ❌ `flutter_bloc`
- ❌ `provider` package
- ❌ `setState` (except for trivial animation controllers)
- ❌ `ChangeNotifier`

> **Why:** Two competing state managers create unpredictable behavior, race conditions, and double-rebuilds. Riverpod's compile-time safety is superior.

### Rule 2: One Backend — Supabase Only

- ✅ Supabase Auth (OTP + Email passwordless)
- ✅ Supabase PostgreSQL (premium cloud data)
- ✅ Supabase Storage (thumbnails)
- ❌ Firebase Auth
- ❌ Firestore / Firebase Realtime DB
- ❌ Any other backend service

> **Why:** Firebase + Supabase was the original app's primary architectural mistake. Mixed backends mean mixed auth states, mixed error handling, double initialization costs.

### Rule 3: Local-First ObjectBox

- ✅ ObjectBox v4 (`objectbox` package) for all local storage
- ❌ Isar
- ❌ Hive
- ❌ SQLite directly

> **Why:** ObjectBox is the fastest Flutter local database (benchmarks show 10x over Isar v3 for reactive queries). It has proper reactive streams via `Query.watch()`.

### Rule 4: Every Feature Has a Use Case Layer

Do NOT call repositories directly from providers. All business logic lives in use case classes.

```dart
// ✅ CORRECT
final result = await ref.read(addUrlUsecaseProvider).call(params);

// ❌ WRONG — never call repo directly from provider/screen
final result = await ref.read(urlRepositoryProvider).addUrl(params);
```

### Rule 5: Clean Architecture Dependency Direction

```
Presentation → Application → Domain ← Data
```

- Presentation depends on Application (use cases)
- Application depends on Domain (entities, repo interfaces)
- Domain has ZERO dependencies (pure Dart)
- Data depends on Domain (implements repo interfaces)
- Data does NOT depend on Presentation

Violations are immediately refactored. No exceptions.

### Rule 6: Environments Must Be Separate

- `.env.dev` — dev Supabase project, RevenueCat test keys, AdMob test IDs
- `.env.production` — prod Supabase project, real RevenueCat keys, real AdMob IDs
- Never hardcode API keys, URLs, or secrets in Dart code
- Run dev: `flutter run --flavor dev --dart-define-from-file=.env.dev`
- Run prod: `flutter run --flavor production --dart-define-from-file=.env.production`

---

## 3. Folder Structure Rules

Every feature folder must follow this exact structure:

```
features/
└── feature_name/
    ├── domain/
    │   ├── entities/          # Immutable, Equatable, pure Dart
    │   ├── repositories/      # Abstract interfaces only
    │   └── failures/          # Feature-specific failure types (optional)
    ├── application/
    │   └── usecases/          # One file = one use case
    ├── data/
    │   ├── models/            # ObjectBox @Entity classes
    │   ├── mappers/           # entity ↔ model ↔ Supabase JSON
    │   └── repositories/      # local_*.dart + supabase_*.dart implementations
    └── presentation/
        ├── providers/         # Riverpod providers
        ├── screens/           # Full-screen views (*_screen.dart)
        └── widgets/           # Reusable pieces (*_card.dart, *_list.dart)
```

**Naming must match:**
- Entity: `CollectionEntity`
- ObjectBox model: `CollectionModel`
- Mapper: `CollectionMapper`
- Local repo: `LocalCollectionRepository`
- Supabase repo: `SupabaseCollectionRepository`
- Use case: `CreateCollectionUsecase`
- Provider: `collectionsRepositoryProvider`

---

## 4. Data Flow Example (End-to-End)

**User adds a URL via Share Intent:**

```
1. receive_sharing_intent → ReceiveIntentScreen
2. Screen calls: ref.read(addUrlUsecaseProvider).call(url: sharedUrl, collectionId: selectedId)
3. AddUrlUsecase:
   a. Validate URL format
   b. Call FetchUrlMetadataUsecase → returns title, thumbnail, favicon, dominantColor
   c. Build UrlEntity (UUID, timestamps, status: unread)
   d. Call urlRepository.addUrl(entity)
4. Repository (based on tier):
   - Free/Guest: LocalUrlRepository → ObjectBox put()
   - Premium: SupabaseUrlRepository → supabase.from('lv_urls').insert(json)
5. StreamProvider watching the collection auto-updates → UI rebuilds
6. ReceiveIntentScreen pops on Right(unit) result
```

---

## 5. Error Handling Contract

**Every use case returns `Either<Failure, T>`** using `fpdart`.

```dart
Future<Either<Failure, T>> call(...) async {
  try {
    // happy path
    return Right(result);
  } on SpecificException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e, st) {
    // Always log unexpected errors
    _logger.e('Unexpected error', error: e, stackTrace: st);
    return Left(UnexpectedFailure('Something went wrong', error: e, stackTrace: st));
  }
}
```

**In UI, always handle both sides:**

```dart
final result = await ref.read(someUsecaseProvider).call(...);
result.fold(
  (failure) {
    if (failure is ValidationFailure) {
      // Show inline field error
    } else {
      // Show generic snackbar
      _showErrorSnackbar(context, failure.message);
    }
  },
  (success) {
    // Navigate or show success
  },
);
```

**Never swallow errors silently.** If you catch and don't at minimum log, you introduce invisible bugs.

---

## 6. Supabase RLS Policy Contract

Every Supabase table used by LinkVault must have:
1. `ENABLE ROW LEVEL SECURITY`
2. A SELECT policy that checks `auth.uid() = owner_id`
3. An INSERT policy with `WITH CHECK (auth.uid() = owner_id)`
4. An UPDATE policy with `USING (auth.uid() = owner_id)`
5. A DELETE policy with `USING (auth.uid() = owner_id)`

**No table ships without RLS.** Test by querying as a different user and confirming zero results.

---

## 7. ObjectBox Rules

- All ObjectBox entities are in `data/models/`
- All entities have a `String id` field (UUID) that is the **business key**
- The `@Id() int dbId` is the ObjectBox internal key — never expose it
- Always use `Query.watch(triggerImmediately: true)` for reactive streams
- Use transactions for batch writes: `store.runInTransaction(TxMode.write, () { ... })`
- Never store `DateTime` directly — use epoch milliseconds (`int`) for portability

---

## 8. RevenueCat Integration Rules

- Use the `CustomerInfo` returned **directly** from `Purchases.purchase()` — do NOT call `Purchases.getCustomerInfo()` separately (stale data race condition)
- Same rule for `Purchases.restorePurchases()` — use its return value directly
- Entitlement identifier in RevenueCat: `premium` (shared across both LinkVault and Curate)
- App User ID passed to RevenueCat: **the Supabase `auth.uid()`** (ensures cross-app sharing)
- Dev flavor uses `test_` API key (Test Store)
- Prod Android uses `goog_` API key
- Prod iOS uses `appl_` API key — must NOT use `goog_` for iOS

---

## 9. Metadata Fetch Rules

URL metadata is fetched by `UrlMetadataFetcher` utility:

```dart
// lib/core/utils/url_metadata_fetcher.dart
class UrlMetadataFetcher {
  static Future<UrlMetadata> fetch(String url) async {
    // 1. HTTP GET with timeout: 5 seconds
    // 2. Parse HTML for: <title>, og:title, og:description, og:image, <link rel="icon">
    // 3. Fallback gracefully — if any field fails, return null for that field
    // 4. Never throw — always return partial metadata
  }
}
```

**Rules:**
- Timeout: 5 seconds hard cutoff
- Never block the URL save on metadata failure — save with empty metadata first, enrich async
- Cache fetched metadata in ObjectBox to avoid re-fetching
- Respect `robots.txt` and fetch failures gracefully

---

## 10. RSS Feed Rules

- RSS feeds are parsed using the `xml` package — no external RSS parsing library needed
- Support: RSS 2.0, Atom 1.0
- Local ObjectBox cache for feed items (evict items older than 7 days)
- Manual refresh only in v1 — no background push
- "Save to LinkVault" creates a `UrlEntity` from the article's `<link>` field

---

## 11. Share Intent Rules

- Platform: `receive_sharing_intent` package (forked master branch for bug fixes)
- On shared URL received → navigate to `ReceiveIntentScreen`
- If app is in background: handle via `getInitialMedia()` on startup
- If app is in foreground: handle via `getMediaStream()`
- Always validate the received URL before showing collection picker

---

## 12. Fractional Position Indexing

Collections and URLs are ordered using `position: FLOAT8`. Do NOT use integer sequence (0, 1, 2, ...) as it requires mass re-numbering.

**Algorithm: Midpoint positioning**
```dart
// Insert between items A (position=1.0) and B (position=2.0)
double newPosition = (A.position + B.position) / 2; // = 1.5

// Insert at start (before first item at position=1.0)
double newPosition = firstItem.position / 2; // = 0.5

// Insert at end (after last item at position=5.0)
double newPosition = lastItem.position + 1.0; // = 6.0
```

When `newPosition - math.min(a, b) < 0.0001` (precision exhausted), **rebalance** by querying all items in the collection and assigning `position = index * 1.0`.

---

## 13. Testing Philosophy

Every use case must have a unit test. No exceptions.

```
test/
├── features/
│   ├── collections/
│   │   └── application/
│   │       └── create_collection_usecase_test.dart
│   └── urls/
│       └── application/
│           └── add_url_usecase_test.dart
└── core/
    └── utils/
        └── url_metadata_fetcher_test.dart
```

**Minimum coverage target: 80% of use case logic**

---

## 14. Debug Feature Flag

```dart
// lib/core/config/flavor_config.dart
enum Flavor { dev, production }

class FlavorConfig {
  static Flavor current = Flavor.production;
  static bool get isDev => current == Flavor.dev;
  static bool get isProduction => current == Flavor.production;
}

// In UI — show debug tools only in dev
if (FlavorConfig.isDev) ...[
  const DebugMenuTile(),
]
```

The `debug` feature module is only visible in the `dev` flavor. It must never appear in the production build.

---

## 15. Localization (Future-Ready)

- All user-facing strings must go via `l10n` from day 1
- No hardcoded English strings in widget files
- Use `AppLocalizations.of(context)!.someKey`
- v1 ships English-only; the scaffolding must support adding Hindi, Telugu, Tamil, Spanish later

---

## Quick Reference

| Question | Answer |
|---|---|
| Where do I put business logic? | `features/X/application/usecases/` |
| Where do I define data contracts? | `features/X/domain/repositories/` |
| Where do I put ObjectBox entities? | `features/X/data/models/` |
| Where do I convert between model and entity? | `features/X/data/mappers/` |
| How do I inject the right repository? | Riverpod `Provider` in `core/providers/core_providers.dart` |
| Can I call a repository from a screen? | No. Call a use case. |
| Can I use setState? | Only for animation controllers. Never for app state. |
| Where are API keys? | `.env.dev` / `.env.production` — never in Dart files |
| What happens if metadata fetch fails? | Save URL with empty metadata. Log warning. Never block save. |
