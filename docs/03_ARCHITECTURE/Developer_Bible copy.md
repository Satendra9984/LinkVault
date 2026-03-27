# Curate — Developer Bible

## The Complete Guide to Building, Extending & Maintaining the App

**Version:** 1.0  
**Date:** February 18, 2026  
**Audience:** Any developer (including future-you) working on this codebase  
**Status:** Living Document — update when conventions change

---

## Table of Contents

1. [Philosophy & Principles](#1-philosophy--principles)
2. [Project Structure](#2-project-structure)
3. [Architecture: Clean Architecture + MVVM](#3-architecture-clean-architecture--mvvm)
   - [Forms Architecture Guide](Form_Handling_Architecture.md)
4. [State Management: Riverpod](#4-state-management-riverpod)
5. [Error Handling: fpdart Either](#5-error-handling-fpdart-either)
6. [Navigation: GoRouter](#6-navigation-gorouter)
7. [Environment & Flavors](#7-environment--flavors)
8. [Database: objectbox (Local) + Supabase (Cloud)](#8-database-objectbox-local--supabase-cloud)
9. [Design System](#9-design-system)
10. [Asset Management](#10-asset-management)
11. [Adding a New Feature — Step-by-Step](#11-adding-a-new-feature--step-by-step)
12. [Naming Conventions](#12-naming-conventions)
13. [Git Workflow & Branching](#13-git-workflow--branching)
14. [Code Review Checklist](#14-code-review-checklist)
15. [What NOT to Do](#15-what-not-to-do)

---

## 1. Philosophy & Principles

### The Core Belief

> **Every decision in this codebase should make the next developer's job easier, not harder.**

We follow these principles, in order of priority:

### 1.1 Separation of Concerns (SoC)

Every file, class, and function has **one job**. A screen doesn't talk to the database. A repository doesn't know about Flutter widgets. A use case doesn't know about objectbox.

### 1.2 Dependency Rule

Dependencies only point **inward**. The outer layers (UI, Database) depend on the inner layers (Domain). The inner layers never depend on the outer layers.

```
UI → Domain ← Data
     ↑
  (Core of the app — no dependencies on anything)
```

### 1.3 Explicit Over Implicit

- Errors are returned as values (`Either<Failure, T>`), not thrown as exceptions
- State is explicit (`OnboardingState` class), not scattered across widget fields
- Config is typed (`AppConfig.instance.supabaseUrl`), not raw strings

### 1.4 The Boy Scout Rule

> Leave the code cleaner than you found it.

If you touch a file, fix any obvious issues you see. Don't leave TODOs without a ticket.

---

## 2. Project Structure

```
curate/
├── lib/
│   ├── main.dart                    # Redirect to main_dev.dart
│   ├── main_dev.dart                # Dev flavor entry point
│   ├── main_production.dart         # Production flavor entry point
│   ├── bootstrap.dart               # Shared init logic + CurateApp widget
│   │
│   ├── core/                        # Shared infrastructure (no feature logic)
│   │   ├── architecture/            # Base classes (UseCase, etc.)
│   │   ├── config/
│   │   │   └── app_config.dart      # Environment config singleton
│   │   ├── constants/
│   │   │   ├── app_assets.dart      # All asset paths
│   │   │   └── app_strings.dart     # Non-localized constants
│   │   ├── data/                    # Core data layer (user prefs, etc.)
│   │   ├── domain/                  # Core domain (UserRepository interface)
│   │   ├── errors/
│   │   │   └── failures.dart        # Failure hierarchy
│   │   ├── infrastructure/
│   │   │   ├── database/
│   │   │   │   └── app_database.dart  # objectbox initialization
│   │   │   └── providers.dart         # Core Riverpod providers
│   │   ├── providers/
│   │   │   └── core_providers.dart    # UserRepository provider
│   │   ├── router/
│   │   │   └── app_router.dart        # GoRouter configuration
│   │   ├── theme/
│   │   │   ├── app_theme.dart         # ThemeData (light + dark)
│   │   │   ├── color_palette.dart     # AppColors
│   │   │   ├── type_system.dart       # AppTypography
│   │   │   └── theme_provider.dart    # Theme state (light/dark toggle)
│   │   └── utils/                     # Pure utility functions
│   │
│   ├── features/                    # One folder per feature
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── collections/
│   │   ├── items/
│   │   └── settings/
│   │
│   └── shared/                      # Reusable widgets used across features
│       └── widgets/
│           ├── curate_button.dart
│           ├── curate_card.dart
│           └── curate_text_field.dart
│
├── assets/
│   └── images/                      # All image assets
│
├── docs/                            # All project documentation
│   ├── 00_PROJECT_OVERVIEW/
│   ├── 01_PRODUCT/
│   ├── 02_DESIGN/
│   ├── 03_ARCHITECTURE/             # ← You are here
│   └── ...
│
├── .env.dev                         # Dev secrets (gitignored)
├── .env.production                  # Production secrets (gitignored)
└── pubspec.yaml
```

### Rule: Where Does New Code Go?

| Code Type                     | Location                                   |
| ----------------------------- | ------------------------------------------ |
| Feature-specific UI           | `lib/features/<feature>/presentation/`     |
| Feature business logic        | `lib/features/<feature>/domain/usecases/`  |
| Feature data access           | `lib/features/<feature>/data/`             |
| Reusable widget (2+ features) | `lib/shared/widgets/`                      |
| App-wide config/constants     | `lib/core/`                                |
| New asset                     | `assets/images/` + register in `AppAssets` |

---

## 3. Architecture: Clean Architecture + MVVM

### The Three Layers

```
┌─────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                  │
│  Screens (View) + Providers/Notifiers (ViewModel)   │
│  → Knows about: State, UI events                    │
│  → Does NOT know about: objectbox, Supabase, HTTP        │
├─────────────────────────────────────────────────────┤
│  DOMAIN LAYER                                        │
│  Entities + Use Cases + Repository Interfaces       │
│  → Pure Dart. Zero Flutter/objectbox/Supabase imports    │
│  → The "what" of the app, not the "how"             │
├─────────────────────────────────────────────────────┤
│  DATA LAYER                                          │
│  Repository Implementations + Models + Mappers      │
│  → Knows about: objectbox, Supabase, SharedPreferences   │
│  → Does NOT know about: Flutter widgets             │
└─────────────────────────────────────────────────────┘
```

### 3.1 Domain Layer — The Rules

**Entities** — Pure Dart business objects:

```dart
// ✅ CORRECT
class Collection extends Equatable {
  final String id;       // UUID string
  final String name;
  final String color;
  final int itemCount;
  final DateTime createdAt;

  const Collection({...});

  @override
  List<Object?> get props => [id, name, color];
}

// ❌ WRONG — Entities must NOT import objectbox, Flutter, or Supabase
import 'package:objectbox/objectbox.dart'; // FORBIDDEN in domain/
```

**Repository Interfaces** — Define the contract:

```dart
// Always use Either<Failure, T> — never throw exceptions
abstract class ICollectionsRepository {
  Future<Either<Failure, List<Collection>>> getAllCollections();
  Future<Either<Failure, Collection>> getCollectionById(String id);
  Future<Either<Failure, void>> createCollection(Collection collection);
  Future<Either<Failure, void>> updateCollection(Collection collection);
  Future<Either<Failure, void>> deleteCollection(String id);
}
```

**Use Cases** — One class, one action:

```dart
// ✅ CORRECT — Single responsibility
class GetAllCollectionsUseCase {
  final ICollectionsRepository _repository;
  GetAllCollectionsUseCase(this._repository);

  Future<Either<Failure, List<Collection>>> call() =>
      _repository.getAllCollections();
}

// ❌ WRONG — Use cases should not contain multiple operations
class CollectionsUseCase {
  Future<void> getAll() {...}
  Future<void> create() {...}  // Split into separate use cases!
  Future<void> delete() {...}
}
```

### 3.2 Data Layer — The Implementation

**Models** — Database-specific classes:

```dart
// objectbox model — only in data/models/
@collection
class CollectionModel {
  Id get objectboxId => fastHash(id);  // String UUID → objectbox int ID
  late String id;                  // UUID
  late String name;
  late String color;
  late int itemCount;
  late DateTime createdAt;
}
```

**Mappers** — Bridge between Model and Entity:

```dart
// Static conversion — no state, no dependencies
class CollectionMapper {
  static Collection toEntity(CollectionModel model) => Collection(
    id: model.id,
    name: model.name,
    color: model.color,
    itemCount: model.itemCount,
    createdAt: model.createdAt,
  );

  static CollectionModel toModel(Collection entity) => CollectionModel()
    ..id = entity.id
    ..name = entity.name
    ..color = entity.color
    ..itemCount = entity.itemCount
    ..createdAt = entity.createdAt;
}
```

**Repository Implementations** — Catch exceptions, return Either:

```dart
class objectboxCollectionsRepository implements ICollectionsRepository {
  final objectbox _objectbox;
  objectboxCollectionsRepository(this._objectbox);

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      final models = await _objectbox.collectionModels.where().findAll();
      return Right(models.map(CollectionMapper.toEntity).toList());
    } catch (e, st) {
      return Left(DatabaseFailure('Failed to fetch collections', error: e, stackTrace: st));
    }
  }
}
```

### 3.3 Presentation Layer — MVVM

**ViewModel (Notifier)** — Manages state, calls use cases:

```dart
// State class — immutable, copyWith pattern
class CollectionsState extends Equatable {
  final List<Collection> collections;
  final bool isLoading;
  final String? errorMessage;

  const CollectionsState({
    this.collections = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CollectionsState copyWith({...}) => CollectionsState(...);

  @override
  List<Object?> get props => [collections, isLoading, errorMessage];
}

// Notifier — the ViewModel
class CollectionsNotifier extends AsyncNotifier<CollectionsState> {
  late GetAllCollectionsUseCase _getAllCollections;

  @override
  Future<CollectionsState> build() async {
    _getAllCollections = GetAllCollectionsUseCase(
      ref.watch(collectionsRepositoryProvider),
    );
    return _loadCollections();
  }

  Future<CollectionsState> _loadCollections() async {
    final result = await _getAllCollections();
    return result.fold(
      (failure) => CollectionsState(errorMessage: failure.message),
      (collections) => CollectionsState(collections: collections),
    );
  }
}
```

**View (Screen)** — Dumb widget, reads state, delegates actions:

```dart
// ✅ CORRECT — Screen is a "dumb" view
class CollectionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionsProvider);
    final notifier = ref.read(collectionsProvider.notifier);

    return state.when(
      loading: () => const LoadingIndicator(),
      error: (e, st) => ErrorView(message: e.toString()),
      data: (collectionsState) => CollectionsListView(
        collections: collectionsState.collections,
        onDelete: notifier.deleteCollection,
        onTap: (id) => context.push('/collections/$id'),
      ),
    );
  }
}

// ❌ WRONG — Screen should NOT contain business logic
class CollectionsScreen extends ConsumerWidget {
  Future<void> _deleteCollection(String id) async {
    final objectbox = ref.read(objectboxProvider);  // FORBIDDEN — direct DB access in UI
    await objectbox.writeTxn(() => objectbox.collectionModels.delete(...));
}
```

> **Note on Forms:** For complex data entry screens (like creating a Collection or Item), standard `AsyncNotifier` is not ideal since the state updates synchronously as the user types. Instead, we use `AutoDisposeNotifier` managing a dedicated `FormState` class. See the [Form Handling Architecture](Form_Handling_Architecture.md) guide for full details.

---

## 4. State Management: Riverpod

### Provider Types — When to Use Which

| Provider                | Use When                       | Example                  |
| ----------------------- | ------------------------------ | ------------------------ |
| `Provider`              | Simple, synchronous, no state  | `userRepositoryProvider` |
| `StateProvider`         | Simple mutable value           | `selectedTabProvider`    |
| `AsyncNotifierProvider` | Async state with loading/error | `collectionsProvider`    |
| `NotifierProvider`      | Sync state with complex logic  | `onboardingProvider`     |
| `StreamProvider`        | Realtime data streams          | `notificationsProvider`  |

### Provider File Convention

Every feature has a `providers/` folder:

```
features/collections/presentation/providers/
├── collections_provider.dart        # Main feature provider
└── collection_detail_provider.dart  # Detail-specific provider
```

### Provider Naming Convention

```dart
// ✅ CORRECT naming
final collectionsProvider = AsyncNotifierProvider<CollectionsNotifier, CollectionsState>(
  CollectionsNotifier.new,
);

// Repository providers go in core or feature data layer
final collectionsRepositoryProvider = Provider<ICollectionsRepository>((ref) {
  return objectboxCollectionsRepository(ref.watch(objectboxProvider));
});
```

### Watching vs Reading

```dart
// ref.watch() — rebuilds widget when value changes (use in build())
final state = ref.watch(collectionsProvider);

// ref.read() — one-time read, no rebuild (use in callbacks/methods)
final notifier = ref.read(collectionsProvider.notifier);
onPressed: () => ref.read(collectionsProvider.notifier).deleteCollection(id),

// ❌ WRONG — never ref.watch() inside callbacks
onPressed: () => ref.watch(collectionsProvider.notifier).deleteCollection(id),
```

---

## 5. Error Handling: fpdart Either

### The Failure Hierarchy

All failures extend the base `Failure` class in `lib/core/errors/failures.dart`:

```dart
abstract class Failure extends Equatable {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
}

// Existing failures:
class DatabaseFailure extends Failure { ... }    // objectbox errors
class CacheFailure extends Failure { ... }       // SharedPreferences errors
class NotFoundFailure extends Failure { ... }    // Entity not found
class UnexpectedFailure extends Failure { ... }  // Catch-all

// Add new failures as needed:
class NetworkFailure extends Failure { ... }     // HTTP/Supabase errors
class ValidationFailure extends Failure { ... }  // Input validation errors
class AuthFailure extends Failure { ... }        // Auth errors
```

### The Golden Rule: Always fold()

```dart
// ✅ CORRECT — always handle both cases
final result = await createCollectionUseCase(collection);
result.fold(
  (failure) => state = state.copyWith(errorMessage: failure.message),
  (success) => state = state.copyWith(collections: [...state.collections, success]),
);

// ❌ WRONG — never ignore the Left case
final result = await createCollectionUseCase(collection);
result.getRight(); // Silently ignores errors
```

### Adding a New Failure Type

When you encounter a new category of error, add it to `failures.dart`:

```dart
// For Supabase/network errors
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {dynamic error, StackTrace? stackTrace})
      : super(message, error: error, stackTrace: stackTrace);
}

// For auth-specific errors
class AuthFailure extends Failure {
  final String code; // e.g., 'invalid_credentials', 'email_taken'
  const AuthFailure(String message, {required this.code, dynamic error})
      : super(message, error: error);

  @override
  List<Object?> get props => [...super.props, code];
}
```

---

## 6. Navigation: GoRouter

### Route Definitions

All routes are defined in `lib/core/router/app_router.dart`. **Never** use `Navigator.push()` directly.

```dart
// ✅ CORRECT — use GoRouter
context.push('/collections/create');
context.go('/collections');          // Replace entire stack
context.pop();                       // Go back

// ❌ WRONG — never use Navigator directly
Navigator.push(context, MaterialPageRoute(builder: (_) => SomeScreen()));
```

### Adding a New Route

1. Add the route to `app_router.dart`:

```dart
GoRoute(
  path: '/auth/signin',
  builder: (context, state) => const SignInScreen(),
),
```

2. Add a route constant to prevent typos:

```dart
// lib/core/router/app_routes.dart (create if doesn't exist)
class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const collections = '/collections';
  static const signIn = '/auth/signin';
}
```

3. Use the constant:

```dart
context.go(AppRoutes.signIn);
```

### Passing Data Between Routes

```dart
// Simple data — use path/query parameters
context.push('/collections/${collection.id}');

// Complex data — use GoRouter's extra parameter
context.push('/collections/edit', extra: collection);

// In the route:
GoRoute(
  path: '/collections/edit',
  builder: (context, state) {
    final collection = state.extra as Collection;
    return EditCollectionScreen(collection: collection);
  },
),
```

---

## 7. Environment & Flavors

### The Two Environments

|                  | Dev                          | Production                 |
| ---------------- | ---------------------------- | -------------------------- |
| **App ID**       | `com.vicharshala.curate.dev` | `com.vicharshala.curate`   |
| **App Name**     | Curate Dev                   | Curate                     |
| **Supabase**     | Dev project                  | Production project         |
| **Debug Banner** | ✅ Visible                   | ❌ Hidden                  |
| **Entry Point**  | `lib/main_dev.dart`          | `lib/main_production.dart` |

### Run Commands

```bash
# Development (daily use)
flutter run --flavor dev -t lib/main_dev.dart

# Production (before release)
flutter run --flavor production -t lib/main_production.dart

# Build APK for testing
flutter build apk --flavor dev -t lib/main_dev.dart --debug

# Build release APK
flutter build apk --flavor production -t lib/main_production.dart --release

# Build App Bundle for Play Store
flutter build appbundle --flavor production -t lib/main_production.dart --release
```

### Accessing Config in Code

```dart
import 'package:curate/core/config/app_config.dart';

// Check environment
if (AppConfig.instance.isDev) {
  debugPrint('Running in dev mode');
}

// Access Supabase URL (already initialized — just for reference)
final url = AppConfig.instance.supabaseUrl;

// Access Supabase client
final supabase = Supabase.instance.client;
```

### Rules for Secrets

- ✅ Store secrets in `.env.dev` and `.env.production`
- ✅ Both files are in `.gitignore`
- ✅ Share secrets via secure channel (1Password, Bitwarden)
- ❌ Never hardcode secrets in Dart files
- ❌ Never commit `.env.*` files to git
- ❌ Never use the Supabase `service_role` key in Flutter

---

## 8. Database: objectbox (Local) + Supabase (Cloud)

### Dual-Tier Architecture

```
Free User:  Flutter App → objectbox (local only)
Premium:    Flutter App → objectbox (cache) + Supabase (cloud sync)
```

The **Repository Pattern** abstracts this — the UI never knows which database is being used.

### objectbox Rules

```dart
// ✅ Always use transactions for writes
await objectbox.writeTxn(() async {
  await objectbox.collectionModels.put(model);
});

// ✅ Use String UUIDs for IDs (consistent with Supabase)
import 'package:uuid/uuid.dart';
final id = const Uuid().v4();

// ✅ Hash UUID to objectbox int ID
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < string.length; i++) {
    hash ^= string.codeUnitAt(i);
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash;
}

// ❌ Never access objectbox directly from a screen or notifier
// Always go through the repository
```

### Supabase Rules

```dart
// ✅ Always use the client from Supabase.instance
final supabase = Supabase.instance.client;

// ✅ Always handle errors
final response = await supabase
    .from('collections')
    .select()
    .eq('owner_id', supabase.auth.currentUser!.id);

// ✅ Use RLS — never bypass it from the Flutter app
// ❌ Never use service_role key in Flutter
```

### Adding a New objectbox Collection

1. Create model in `features/<feature>/data/models/`
2. Add `@collection` annotation
3. Register schema in `AppDatabase.init()`:

```dart
objectbox = await objectbox.open(
  [CollectionModelSchema, ItemModelSchema, YourNewModelSchema], // ← Add here
  directory: dir.path,
);
```

4. Run code generation: `dart run build_runner build`

---

## 9. Design System

### Colors — `AppColors`

```dart
import 'package:curate/core/theme/color_palette.dart';

// ✅ Always use AppColors
Container(color: AppColors.primary)       // Orange #FF6B4A
Container(color: AppColors.background)    // Warm White #F8F9FA
Container(color: AppColors.surface)       // Pure White

// Collection color picker
final color = AppColors.collectionColors[index]; // 9 pastel options

// ❌ Never hardcode colors
Container(color: Color(0xFFFF6B4A))  // WRONG — use AppColors.primary
Container(color: Colors.orange)      // WRONG
```

### Typography — `AppTypography`

```dart
// ✅ Use theme text styles
Text('Heading', style: Theme.of(context).textTheme.displayLarge)   // Outfit 32px Bold
Text('Subheading', style: Theme.of(context).textTheme.displayMedium) // Outfit 24px SemiBold
Text('Body', style: Theme.of(context).textTheme.bodyLarge)          // Inter 16px
Text('Caption', style: Theme.of(context).textTheme.bodySmall)       // Inter 12px 70% opacity

// ❌ Never hardcode font sizes or families
Text('Hello', style: TextStyle(fontSize: 24, fontFamily: 'Outfit')) // WRONG
```

### Spacing — Use multiples of 4

```dart
// ✅ Consistent spacing
const SizedBox(height: 8)   // Small gap
const SizedBox(height: 16)  // Standard gap
const SizedBox(height: 24)  // Section gap
const SizedBox(height: 32)  // Large gap

// Padding
const EdgeInsets.all(16)                          // Standard card padding
const EdgeInsets.symmetric(horizontal: 20, vertical: 16) // Input padding
```

### Border Radius

```dart
// ✅ Standard radius
BorderRadius.circular(16)  // Cards, inputs (from theme)
BorderRadius.circular(12)  // Buttons
BorderRadius.circular(8)   // Small chips/tags
BorderRadius.circular(100) // Fully rounded (avatars, pills)
```

### Shared Widgets

Always use shared widgets instead of raw Flutter widgets:

```dart
// ✅ Use shared widgets
CurateButton(label: 'Save', onPressed: _save)
CurateCard(child: content)
CurateTextField(label: 'Name', controller: _controller)

// ❌ Don't reinvent the wheel
ElevatedButton(onPressed: _save, child: Text('Save')) // Use CurateButton instead
```

---

## 10. Asset Management

### `AppAssets` Class

All asset paths are defined as constants in `lib/core/constants/app_assets.dart`.

```dart
// ✅ Always use AppAssets
Image.asset(AppAssets.onboardingWelcome)
Image.asset(AppAssets.appLogoReference)

// ❌ Never hardcode asset paths
Image.asset('assets/images/onboarding_welcome.png') // WRONG
```

### Adding a New Asset

1. Place the file in `assets/images/` (or `assets/images/misc/` for uncategorized)
2. Add a constant to `AppAssets`:

```dart
class AppAssets {
  static const String _imagesPath = 'assets/images';

  // Add your new asset here
  static const String authIllustration = '$_imagesPath/auth_illustration.png';
}
```

3. Use it: `Image.asset(AppAssets.authIllustration)`

---

## 11. Adding a New Feature — Step-by-Step

This is the exact process to follow every time you add a new feature (e.g., "Authentication").

### Step 1: Create the folder structure

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── i_auth_repository.dart
│   └── usecases/
│       ├── sign_in_usecase.dart
│       ├── sign_up_usecase.dart
│       └── sign_out_usecase.dart
├── data/
│   ├── models/
│   │   └── user_model.dart          # (if local storage needed)
│   ├── repositories/
│   │   └── supabase_auth_repository.dart
│   └── mappers/
│       └── user_mapper.dart
└── presentation/
    ├── screens/
    │   ├── sign_in_screen.dart
    │   └── sign_up_screen.dart
    ├── widgets/
    │   └── auth_form.dart
    └── providers/
        └── auth_provider.dart
```

### Step 2: Define the Entity (Domain)

```dart
// lib/features/auth/domain/entities/user.dart
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final bool isPremium;

  const AppUser({required this.id, required this.email, ...});

  @override
  List<Object?> get props => [id, email];
}
```

### Step 3: Define the Repository Interface (Domain)

```dart
// lib/features/auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<Either<Failure, AppUser>> signIn({required String email, required String password});
  Future<Either<Failure, AppUser>> signUp({required String email, required String password});
  Future<Either<Failure, void>> signOut();
  Stream<AppUser?> get authStateChanges;
}
```

### Step 4: Create Use Cases (Domain)

```dart
// lib/features/auth/domain/usecases/sign_in_usecase.dart
class SignInUseCase {
  final IAuthRepository _repository;
  SignInUseCase(this._repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) {
    // Validation before hitting the repository
    if (email.isEmpty || !email.contains('@')) {
      return Future.value(Left(ValidationFailure('Invalid email')));
    }
    if (password.length < 6) {
      return Future.value(Left(ValidationFailure('Password too short')));
    }
    return _repository.signIn(email: email, password: password);
  }
}
```

### Step 5: Implement the Repository (Data)

```dart
// lib/features/auth/data/repositories/supabase_auth_repository.dart
class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _client;
  SupabaseAuthRepository(this._client);

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return Left(AuthFailure('Sign in failed', code: 'no_user'));
      return Right(UserMapper.toEntity(response.user!));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.statusCode ?? 'unknown'));
    } catch (e, st) {
      return Left(UnexpectedFailure('Unexpected error', error: e, stackTrace: st));
    }
  }
}
```

### Step 6: Create the Provider (Presentation)

```dart
// lib/features/auth/presentation/providers/auth_provider.dart

// Repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

// State
class AuthState extends Equatable {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;
  ...
}

// Notifier
class AuthNotifier extends AsyncNotifier<AuthState> {
  late SignInUseCase _signIn;

  @override
  Future<AuthState> build() async {
    _signIn = SignInUseCase(ref.watch(authRepositoryProvider));
    return const AuthState();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result = await _signIn(email: email, password: password);
    state = result.fold(
      (failure) => AsyncData(AuthState(errorMessage: failure.message)),
      (user) => AsyncData(AuthState(user: user)),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

### Step 7: Build the Screen (Presentation)

```dart
// lib/features/auth/presentation/screens/sign_in_screen.dart
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for navigation side-effects
    ref.listen(authProvider, (_, next) {
      next.whenData((state) {
        if (state.user != null) context.go('/collections');
      });
    });

    return Scaffold(
      body: authState.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text(e.toString()),
        data: (state) => Column(
          children: [
            if (state.errorMessage != null) ErrorBanner(state.errorMessage!),
            CurateTextField(label: 'Email', controller: _emailController),
            CurateTextField(label: 'Password', controller: _passwordController, obscure: true),
            CurateButton(
              label: 'Sign In',
              onPressed: () => ref.read(authProvider.notifier).signIn(
                _emailController.text,
                _passwordController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 8: Add Route

```dart
// In app_router.dart
GoRoute(path: '/auth/signin', builder: (_, __) => const SignInScreen()),
GoRoute(path: '/auth/signup', builder: (_, __) => const SignUpScreen()),
```

### Step 9: Test the flow

Run with dev flavor and verify:

- [ ] Happy path works
- [ ] Error states display correctly
- [ ] Navigation works
- [ ] No direct database access in UI layer

---

## 12. Naming Conventions

### Files

| Type                 | Convention                          | Example                                 |
| -------------------- | ----------------------------------- | --------------------------------------- |
| Dart files           | `snake_case.dart`                   | `sign_in_screen.dart`                   |
| Entity               | `<noun>.dart`                       | `collection.dart`                       |
| Use Case             | `<verb>_<noun>_usecase.dart`        | `create_collection_usecase.dart`        |
| Repository Interface | `i_<noun>_repository.dart`          | `i_collections_repository.dart`         |
| Repository Impl      | `<source>_<noun>_repository.dart`   | `objectbox_collections_repository.dart` |
| Model                | `<noun>_model.dart`                 | `collection_model.dart`                 |
| Mapper               | `<noun>_mapper.dart`                | `collection_mapper.dart`                |
| Screen               | `<noun>_screen.dart`                | `collections_list_screen.dart`          |
| Widget               | `<noun>_widget.dart` or descriptive | `collection_card.dart`                  |
| Provider             | `<noun>_provider.dart`              | `collections_provider.dart`             |
| Notifier             | `<noun>_notifier.dart`              | `collections_notifier.dart`             |
| State                | `<noun>_state.dart`                 | `collections_state.dart`                |

### Classes

```dart
// Entities — PascalCase noun
class Collection {}
class AppUser {}

// Use Cases — PascalCase verb+noun
class CreateCollectionUseCase {}
class GetAllCollectionsUseCase {}

// Repository interfaces — I prefix
abstract class ICollectionsRepository {}

// Repository implementations — source prefix
class objectboxCollectionsRepository {}
class SupabaseCollectionsRepository {}

// Providers — camelCase + Provider suffix
final collectionsProvider = ...
final authRepositoryProvider = ...

// Notifiers — PascalCase + Notifier suffix
class CollectionsNotifier extends AsyncNotifier<CollectionsState> {}

// State — PascalCase + State suffix
class CollectionsState extends Equatable {}
```

### Variables & Methods

```dart
// Variables — camelCase
final collectionId = '...';
bool isLoading = false;

// Private — underscore prefix
final _repository = ...;
void _loadData() {}

// Constants — camelCase (in classes) or SCREAMING_SNAKE (top-level)
static const String appName = 'Curate';
const double kDefaultPadding = 16.0;

// Booleans — is/has/can prefix
bool isLoading;
bool hasError;
bool canDelete;
```

---

## 13. Git Workflow & Branching

### Branch Strategy

```
main                    ← Production-ready code only
├── develop             ← Integration branch
│   ├── feature/auth-signin
│   ├── feature/collections-search
│   ├── fix/splash-navigation-bug
│   └── chore/update-dependencies
```

### Branch Naming

```bash
feature/<short-description>    # New feature
fix/<short-description>        # Bug fix
chore/<short-description>      # Maintenance (deps, config)
refactor/<short-description>   # Code restructuring
docs/<short-description>       # Documentation only
```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]
[optional footer]
```

**Types:**

- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `style` — Formatting, missing semicolons, etc.
- `docs` — Documentation only
- `chore` — Build process, dependency updates
- `test` — Adding/updating tests

**Examples:**

```bash
feat(auth): add sign in screen with email/password
fix(collections): prevent duplicate collection names
refactor(onboarding): extract page indicator to separate widget
chore(deps): upgrade supabase_flutter to 2.12.0
docs(architecture): update developer bible with auth patterns
```

### Pull Request Rules

1. **Never push directly to `main`**
2. PR must pass all checks before merge
3. PR description must include: what changed, why, how to test
4. Self-review your diff before requesting review

---

## 14. Code Review Checklist

Before submitting any PR, verify:

### Architecture

- [ ] No direct database access in screens or notifiers
- [ ] All repository methods return `Either<Failure, T>`
- [ ] Use cases have single responsibility
- [ ] Domain layer has zero Flutter/objectbox/Supabase imports

### State Management

- [ ] `ref.watch()` only in `build()` methods
- [ ] `ref.read()` only in callbacks/methods
- [ ] State is immutable (uses `copyWith`)
- [ ] Loading and error states are handled

### Error Handling

- [ ] All `Either` results are `fold()`-ed
- [ ] No bare `try/catch` without returning a `Failure`
- [ ] No `!` (null assertion) without a comment explaining why it's safe

### Design System

- [ ] No hardcoded colors (use `AppColors`)
- [ ] No hardcoded font sizes (use `Theme.of(context).textTheme`)
- [ ] No hardcoded asset paths (use `AppAssets`)
- [ ] Spacing uses multiples of 4

### Security

- [ ] No secrets in Dart files
- [ ] No `service_role` key usage
- [ ] `.env.*` files not committed

### Code Quality

- [ ] No `print()` statements (use `debugPrint()` in dev only)
- [ ] No commented-out code
- [ ] Public APIs have doc comments (`///`)
- [ ] File follows naming conventions

---

## 15. What NOT to Do

These are the most common mistakes. Avoid them at all costs.

### ❌ Direct Database Access in UI

```dart
// WRONG
class CollectionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectbox = ref.read(objectboxProvider);
    final collections = objectbox.collectionModels.where().findAllSync(); // FORBIDDEN
    ...
  }
}
```

### ❌ Business Logic in Screens

```dart
// WRONG — validation belongs in UseCase
class CreateCollectionScreen extends ConsumerWidget {
  void _save() {
    if (_nameController.text.isEmpty) { // This belongs in UseCase
      showError('Name required');
      return;
    }
    // ...
  }
}
```

### ❌ Throwing Exceptions Instead of Returning Failures

```dart
// WRONG
Future<List<Collection>> getAllCollections() async {
  try {
    return await objectbox.collectionModels.where().findAll();
  } catch (e) {
    throw DatabaseException('Failed'); // WRONG — return Left(DatabaseFailure(...))
  }
}
```

### ❌ Hardcoded Strings in UI

```dart
// WRONG
Text('Welcome to Curate')  // Use AppLocalizations or at least a constant
Text('assets/images/logo.png')  // Use AppAssets
Color(0xFFFF6B4A)  // Use AppColors.primary
```

### ❌ God Classes

```dart
// WRONG — one class doing everything
class AppManager {
  void loadCollections() {}
  void saveUser() {}
  void navigateToHome() {}
  void showError() {}
  void initDatabase() {}
}
```

### ❌ ref.watch() in Callbacks

```dart
// WRONG
ElevatedButton(
  onPressed: () {
    final notifier = ref.watch(collectionsProvider.notifier); // WRONG — use ref.read()
    notifier.deleteCollection(id);
  },
)
```

### ❌ Committing Secrets

```bash
# WRONG — never do this
git add .env.production
git commit -m "add env file"
```

---

## Quick Reference Card

```
New Feature?     → Follow Section 11 (Step-by-Step)
New Color?       → Add to AppColors, use AppColors.xxx
New Asset?       → Add to assets/, register in AppAssets
New Route?       → Add to app_router.dart + AppRoutes constants
New Error Type?  → Add to failures.dart
New Provider?    → AsyncNotifierProvider for async, NotifierProvider for sync
Run Dev?         → flutter run --flavor dev -t lib/main_dev.dart
Build Release?   → flutter build appbundle --flavor production -t lib/main_production.dart --release
```

---

_This document is the source of truth for how we build Curate. When in doubt, refer here first._  
_Last updated: February 18, 2026_
