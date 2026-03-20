# LinkVault — Technical Architecture

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Architecture:** Clean Architecture + Feature-First (Curate Foundation)  
**Status:** Reference Document — Implement as Written

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Clean Architecture Layers](#2-clean-architecture-layers)
3. [Folder Structure](#3-folder-structure)
4. [State Management](#4-state-management)
5. [Database Architecture](#5-database-architecture)
6. [Dependency Injection](#6-dependency-injection)
7. [Navigation](#7-navigation)
8. [Error Handling](#8-error-handling)
9. [Code Conventions](#9-code-conventions)

---

## 1. Architecture Overview

### 1.1 Pattern

**Clean Architecture + Feature-First Organization**

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│          (Screens, Widgets, Riverpod Providers)      │
├─────────────────────────────────────────────────────┤
│                  Application Layer                   │
│            (Use Cases, Business Logic)               │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│         (Entities, Repository Interfaces)            │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│      (Repository Impl, Models, Mappers, Sources)     │
├─────────────────────────────────────────────────────┤
│                   Infrastructure                     │
│        (ObjectBox, Supabase, AdMob, RevenueCat)      │
└─────────────────────────────────────────────────────┘
```

### 1.2 Key Principles

1. **Dependency Inversion** — inner layers never depend on outer layers
2. **Single state manager** — Riverpod only (no BLoC, no setState)
3. **Single backend** — Supabase only (no Firebase data, no Firestore)
4. **Offline-first** — ObjectBox is the primary data source; Supabase is synced on demand for premium users
5. **Feature isolation** — each feature is a self-contained folder

### 1.3 Dual-Repository Pattern (Core of LinkVault)

LinkVault's defining architectural decision. Every data operation goes through a repository interface. The **concrete implementation is injected at runtime based on the user's tier**:

```
Guest / Free users  →  LocalCollectionRepository  (ObjectBox)
Premium users       →  SupabaseCollectionRepository (Supabase)
```

```dart
// Domain Interface (tier-agnostic)
abstract class CollectionRepository {
  Stream<List<CollectionEntity>> watchRootCollections();
  Stream<List<CollectionEntity>> watchChildCollections(String parentId);
  Future<Either<Failure, CollectionEntity>> getCollection(String id);
  Future<Either<Failure, Unit>> createCollection(CollectionEntity collection);
  Future<Either<Failure, Unit>> updateCollection(CollectionEntity collection);
  Future<Either<Failure, Unit>> deleteCollection(String id);
}

// Injected by Riverpod based on UserTier
final collectionsRepositoryProvider = Provider<CollectionRepository>((ref) {
  final tier = ref.watch(userTierProvider);
  return switch (tier) {
    UserTier.premium => ref.read(supabaseCollectionsRepoProvider),
    _               => ref.read(localCollectionsRepoProvider),
  };
});
```

---

## 2. Clean Architecture Layers

### 2.1 Domain Layer (Pure Dart)

**No Flutter imports. No external dependencies. The core of the app.**

Contains:
- **Entities** — immutable data classes (Equatable)
- **Repository interfaces** — abstract classes defining data contract
- **Failures** — domain-specific error types

```dart
// lib/features/collections/domain/entities/collection_entity.dart
class CollectionEntity extends Equatable {
  final String id;
  final String ownerId;
  final String? parentId;     // null = root collection
  final String title;
  final String iconName;
  final String colorHex;
  final String category;
  final bool isPinned;
  final bool isArchived;
  final double position;      // fractional index for ordering
  final int urlCount;         // denormalized for fast display
  final DateTime createdAt;
  final DateTime updatedAt;
  // ...
}

// lib/features/urls/domain/entities/url_entity.dart
class UrlEntity extends Equatable {
  final String id;
  final String ownerId;
  final String collectionId;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? dominantColor;
  final String? tags;           // comma-separated "flutter,dart,riverpod"
  final String? annotation;     // personal notes
  final UrlStatus status;       // unread / read / archived
  final bool isPinned;
  final int clickCount;
  final double position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  // ...
}

enum UrlStatus { unread, read, archived }
```

**Rules:**
- ✅ Pure Dart only
- ❌ No flutter imports
- ❌ No external package imports (except `equatable`, `fpdart`)

---

### 2.2 Application Layer (Use Cases)

One class per business operation. Calls repository, returns `Either<Failure, T>`.

```dart
// lib/features/collections/application/usecases/create_collection_usecase.dart
class CreateCollectionUsecase {
  final CollectionRepository _repo;
  CreateCollectionUsecase(this._repo);

  Future<Either<Failure, Unit>> call({
    required String title,
    required String iconName,
    required String colorHex,
    required String category,
    String? parentId,
  }) async {
    if (title.trim().isEmpty) {
      return Left(ValidationFailure('Title cannot be empty'));
    }
    final entity = CollectionEntity(
      id: const Uuid().v4(),
      ownerId: '', // filled by repository from auth
      parentId: parentId,
      title: title.trim(),
      iconName: iconName,
      colorHex: colorHex,
      category: category,
      isPinned: false,
      isArchived: false,
      position: await _repo.getNextPosition(parentId),
      urlCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _repo.createCollection(entity);
  }
}
```

**Rules:**
- ✅ One use case = one business action
- ✅ Returns `Either<Failure, T>` (using `fpdart`)
- ✅ Contains all validation logic
- ❌ No UI imports

---

### 2.3 Data Layer

**Repository Implementations + Models + Mappers + Data Sources**

```dart
// lib/features/collections/data/repositories/local_collection_repository.dart
class LocalCollectionRepository implements CollectionRepository {
  final ObjectBox _db;
  LocalCollectionRepository(this._db);

  @override
  Stream<List<CollectionEntity>> watchRootCollections() {
    return _db.collectionBox
      .query(CollectionModel_.parentId.isNull()
        .and(CollectionModel_.isArchived.equals(false)))
      .order(CollectionModel_.isPinned, flags: Order.descending)
      .order(CollectionModel_.position)
      .watch(triggerImmediately: true)
      .map((q) => q.find().map(CollectionMapper.toEntity).toList());
  }

  @override
  Future<Either<Failure, Unit>> createCollection(CollectionEntity entity) async {
    try {
      _db.collectionBox.put(CollectionMapper.toModel(entity));
      return Right(unit);
    } catch (e, st) {
      return Left(DatabaseFailure('Failed to create collection', error: e, stackTrace: st));
    }
  }
}
```

**Mappers are separate classes:**
```dart
// lib/features/collections/data/mappers/collection_mapper.dart
class CollectionMapper {
  static CollectionEntity toEntity(CollectionModel model) => CollectionEntity(
    id: model.id,
    parentId: model.parentId,
    title: model.title,
    // ...
  );

  static CollectionModel toModel(CollectionEntity entity) => CollectionModel(
    id: entity.id,
    parentId: entity.parentId,
    title: entity.title,
    // ...
  );

  static Map<String, dynamic> toSupabaseJson(CollectionEntity entity) => {
    'id': entity.id,
    'parent_id': entity.parentId,
    'title': entity.title,
    // ...
  };

  static CollectionEntity fromSupabaseJson(Map<String, dynamic> json) => CollectionEntity(
    id: json['id'] as String,
    parentId: json['parent_id'] as String?,
    title: json['title'] as String,
    // ...
  );
}
```

---

### 2.4 Presentation Layer

**Riverpod providers + ConsumerWidgets. No business logic.**

```dart
// lib/features/collections/presentation/providers/collections_providers.dart
final rootCollectionsProvider = StreamProvider<List<CollectionEntity>>((ref) {
  return ref.watch(collectionsRepositoryProvider).watchRootCollections();
});

final childCollectionsProvider = StreamProvider.family<List<CollectionEntity>, String>((ref, parentId) {
  return ref.watch(collectionsRepositoryProvider).watchChildCollections(parentId);
});

// lib/features/collections/presentation/screens/collections_screen.dart
class CollectionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCollections = ref.watch(rootCollectionsProvider);
    return asyncCollections.when(
      data: (collections) => CollectionsGrid(collections: collections),
      loading: () => const CollectionsShimmer(),
      error: (err, _) => ErrorView(message: err.toString()),
    );
  }
}
```

---

## 3. Folder Structure

```
lib/
├── main.dart
├── main_dev.dart
├── main_production.dart
├── bootstrap.dart                   # App initialization
│
├── core/                            # Shared infrastructure
│   ├── config/
│   │   ├── app_config.dart          # Env-driven config (Supabase URL, RC keys)
│   │   └── flavor_config.dart       # dev / production flavor
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── asset_paths.dart
│   ├── errors/
│   │   ├── failures.dart            # Failure hierarchy
│   │   └── exceptions.dart
│   ├── infrastructure/
│   │   ├── objectbox/
│   │   │   ├── objectbox_store.dart # ObjectBox initialization
│   │   │   └── objectbox.g.dart     # Generated
│   │   └── supabase/
│   │       └── supabase_client.dart
│   ├── providers/
│   │   └── core_providers.dart      # DB, Supabase, auth state, user tier
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   └── utils/
│       ├── url_metadata_fetcher.dart  # Auto-fetch title/thumbnail/favicon
│       ├── url_validator.dart
│       ├── date_formatter.dart
│       └── extensions.dart
│
├── features/
│   ├── auth/                          # Authentication
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── collections/                   # Nested folder CRUD
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── collection_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── collection_repository.dart
│   │   │   └── failures/
│   │   │       └── collection_failures.dart
│   │   ├── application/
│   │   │   └── usecases/
│   │   │       ├── create_collection_usecase.dart
│   │   │       ├── update_collection_usecase.dart
│   │   │       ├── delete_collection_usecase.dart
│   │   │       ├── reorder_collection_usecase.dart
│   │   │       └── get_collection_usecase.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── collection_model.dart    # ObjectBox @Entity
│   │   │   ├── mappers/
│   │   │   │   └── collection_mapper.dart   # entity ↔ model ↔ supabase JSON
│   │   │   └── repositories/
│   │   │       ├── local_collection_repository.dart
│   │   │       └── supabase_collection_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── collections_providers.dart
│   │       ├── screens/
│   │       │   ├── collections_screen.dart
│   │       │   └── collection_form_screen.dart
│   │       └── widgets/
│   │           ├── collection_card.dart
│   │           ├── collection_grid.dart
│   │           └── collections_breadcrumb.dart
│   │
│   ├── urls/                          # URL / Link management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── url_entity.dart
│   │   │   └── repositories/
│   │   │       └── url_repository.dart
│   │   ├── application/
│   │   │   └── usecases/
│   │   │       ├── add_url_usecase.dart
│   │   │       ├── update_url_usecase.dart
│   │   │       ├── delete_url_usecase.dart
│   │   │       ├── fetch_url_metadata_usecase.dart
│   │   │       └── open_url_usecase.dart        # tracks click count
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── url_model.dart
│   │   │   ├── mappers/
│   │   │   │   └── url_mapper.dart
│   │   │   └── repositories/
│   │   │       ├── local_url_repository.dart
│   │   │       └── supabase_url_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       │   ├── url_list_screen.dart
│   │       │   ├── url_detail_screen.dart
│   │       │   ├── add_url_screen.dart
│   │       │   └── receive_intent_screen.dart
│   │       └── widgets/
│   │
│   ├── search/                        # Global search
│   ├── rss_feeds/                     # RSS reader
│   ├── monetization/                  # AdMob + RevenueCat
│   ├── profile/                       # User profile
│   ├── settings/                      # App settings
│   ├── onboarding/                    # First-run flow
│   ├── splash/                        # Splash screen
│   └── debug/                         # Debug tools (dev flavor only)
│
└── shared/
    ├── widgets/
    │   ├── lv_button.dart
    │   ├── lv_text_field.dart
    │   ├── loading_shimmer.dart
    │   ├── error_view.dart
    │   └── empty_state_view.dart
    └── constants/
        ├── collection_icons.dart      # Preset icon names
        └── collection_colors.dart     # Preset color palette
```

---

## 4. State Management

### 4.1 Riverpod Provider Types

| Provider | Use Case | Example |
|---|---|---|
| `Provider` | Immutable services / repos | `collectionsRepositoryProvider` |
| `StateProvider` | Simple mutable UI state | `currentFilterProvider` |
| `AsyncNotifierProvider` | Complex async state with methods | `urlListNotifierProvider` |
| `StreamProvider` | Reactive ObjectBox / Supabase streams | `rootCollectionsProvider` |
| `FutureProvider` | One-off async fetches | `userProfileProvider` |
| `StreamProvider.family` | Stream with a parameter | `childCollectionsProvider(parentId)` |

### 4.2 Rules

- ✅ `ref.watch` in `build()` methods only
- ✅ `ref.read` in callbacks and event handlers
- ✅ Use `invalidate()` to force refresh
- ❌ Never call `ref.watch` inside a loop
- ❌ No `setState` anywhere

---

## 5. Database Architecture

### 5.1 ObjectBox (Local)

ObjectBox is the **primary data source** for all users. It's fast, type-safe, and works fully offline.

**ObjectBox Entities:**

```dart
// lib/features/collections/data/models/collection_model.dart
@Entity()
class CollectionModel {
  @Id()
  int dbId = 0;           // ObjectBox internal ID
  
  @Unique()
  String id = '';         // UUID — used as business key
  
  String ownerId = '';
  String? parentId;       // null = root
  String title = '';
  String iconName = '';
  String colorHex = '';
  String category = '';
  bool isPinned = false;
  bool isArchived = false;
  double position = 0.0;
  int urlCount = 0;
  int createdAt = 0;      // epoch millis
  int updatedAt = 0;
  
  // Soft delete flag (for sync diffing)
  bool isDeleted = false;
  int? deletedAt;
}

// lib/features/urls/data/models/url_model.dart
@Entity()
class UrlModel {
  @Id()
  int dbId = 0;
  
  @Unique()
  String id = '';
  
  String ownerId = '';
  
  @Index()
  String collectionId = '';   // indexed for fast filtering
  
  String url = '';
  String? title;
  String? description;
  String? thumbnailUrl;
  String? faviconUrl;
  String? dominantColor;
  String? tags;               // "flutter,dart,mobile"
  String? annotation;
  String status = 'unread';   // 'unread' | 'read' | 'archived'
  bool isPinned = false;
  int clickCount = 0;
  double position = 0.0;
  int createdAt = 0;
  int updatedAt = 0;
  int? lastAccessedAt;
  bool isDeleted = false;
  int? deletedAt;
}
```

**Reactive Queries (Stream-based):**
```dart
Stream<List<CollectionEntity>> watchRootCollections() {
  return _store.box<CollectionModel>()
    .query(CollectionModel_.parentId.isNull()
      .and(CollectionModel_.isDeleted.equals(false))
      .and(CollectionModel_.isArchived.equals(false)))
    .order(CollectionModel_.isPinned, flags: Order.descending)
    .order(CollectionModel_.position)
    .watch(triggerImmediately: true)
    .map((q) => q.find().map(CollectionMapper.toEntity).toList());
}
```

### 5.2 Supabase (Remote — Premium Only)

See: `docs/03_ARCHITECTURE/Supabase_Schema_Design.md` for full SQL.

**Tables:**
- `lv_user_profiles` — user account data
- `lv_collections` — collections with `parent_id` for nesting
- `lv_urls` — URLs with all metadata fields

**Sync Strategy:**
- On premium activation → push all local ObjectBox data to Supabase
- On launch (premium) → pull latest Supabase data, merge into ObjectBox
- Conflict resolution: `updated_at` timestamp wins (last-write)
- Soft delete: `is_deleted: true` + `deleted_at` timestamp

---

## 6. Dependency Injection

All DI via Riverpod. Providers are in `core/providers/` and feature-level `providers/` files.

```dart
// lib/core/providers/core_providers.dart

// ObjectBox store
final objectBoxProvider = Provider<ObjectBoxStore>((ref) {
  throw UnimplementedError(); // overridden in main bootstrap
});

// Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Current auth user
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange
    .map((event) => event.session?.user);
});

// User tier — drives repository selection
final userTierProvider = Provider<UserTier>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final isPremium = ref.watch(premiumStatusProvider).valueOrNull ?? false;
  if (user == null) return UserTier.guest;
  if (isPremium) return UserTier.premium;
  return UserTier.free;
});

// Collection repository — switches between local and Supabase
final collectionsRepositoryProvider = Provider<CollectionRepository>((ref) {
  final tier = ref.watch(userTierProvider);
  if (tier == UserTier.premium) {
    return SupabaseCollectionRepository(ref.read(supabaseClientProvider));
  }
  return LocalCollectionRepository(ref.read(objectBoxProvider));
});
```

---

## 7. Navigation

**GoRouter** with nested navigation for collection drilling.

```dart
// lib/core/router/app_router.dart
final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthWelcomeScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const CollectionsScreen(),
          routes: [
            // Nested collection drilling
            GoRoute(
              path: 'collection/:id',
              builder: (_, state) => CollectionDetailScreen(
                collectionId: state.pathParameters['id']!,
              ),
              routes: [
                GoRoute(
                  path: 'url/:urlId',
                  builder: (_, state) => UrlDetailScreen(
                    urlId: state.pathParameters['urlId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/feeds', builder: (_, __) => const RssFeedsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/ad-gate', builder: (_, __) => const AdGateScreen()),
  ],
));
```

**Breadcrumb state** is maintained via a `List<CollectionEntity>` stack in a `StateNotifierProvider`.

---

## 8. Error Handling

### 8.1 Failure Hierarchy

```dart
// lib/core/errors/failures.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class DatabaseFailure extends Failure {
  final Object? error;
  final StackTrace? stackTrace;
  const DatabaseFailure(super.message, {this.error, this.stackTrace});
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class MetadataFetchFailure extends Failure {
  const MetadataFetchFailure(super.message);
}

final class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  final Object? error;
  final StackTrace? stackTrace;
  const UnexpectedFailure(super.message, {this.error, this.stackTrace});
}
```

### 8.2 Use Case Returns

```dart
// Always Either<Failure, T>
Future<Either<Failure, Unit>> call(...) async {
  try {
    // ...
    return Right(unit);
  } on SomeException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e, st) {
    return Left(UnexpectedFailure('Unexpected error', error: e, stackTrace: st));
  }
}
```

### 8.3 In UI

```dart
final result = await ref.read(addUrlUsecaseProvider).call(url: url, collectionId: id);
result.fold(
  (failure) => _showError(context, failure.message),
  (_) => context.pop(),
);
```

---

## 9. Code Conventions

### Naming

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `collection_repository.dart` |
| Classes | `PascalCase` | `CollectionRepository` |
| Variables / functions | `camelCase` | `urlCount` |
| Constants | `lowerCamelCase` (Dart style) | `maxCollectionDepth` |
| Provider names | end in `Provider` | `collectionsRepositoryProvider` |
| Use case names | end in `Usecase` | `CreateCollectionUsecase` |
| Entity names | end in `Entity` | `CollectionEntity` |
| ObjectBox model names | end in `Model` | `CollectionModel` |
| Screen names | end in `Screen` | `CollectionsScreen` |
| Widget names | descriptive `PascalCase` | `CollectionCard` |

### Imports Order
```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// 4. Internal - core
import 'package:link_vault/core/errors/failures.dart';

// 5. Internal - features
import 'package:link_vault/features/collections/domain/entities/collection_entity.dart';
```

### Flutter Riverpod Annotations (Generator)

Use `@riverpod` annotation style where appropriate for code generation:
```dart
@riverpod
Stream<List<CollectionEntity>> rootCollections(Ref ref) {
  return ref.watch(collectionsRepositoryProvider).watchRootCollections();
}
```

---

## Schema Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | March 20, 2026 | Initial architecture — full reboot from Curate foundation |
