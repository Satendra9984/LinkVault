import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/infrastructure/providers.dart';
import '../../../../core/providers/data_backend_selection_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/i_collections_repository.dart';
import '../../data/repositories/collections_repository_impl.dart';
import '../../data/repositories/supabase_collection_repository.dart';
import '../../data/repositories/read_only_collections_repository.dart';
import '../../domain/usecases/watch_collections_usecase.dart';
import '../../domain/usecases/create_collection_usecase.dart';
import '../../domain/usecases/update_collection_usecase.dart';
import '../../domain/usecases/delete_collection_usecase.dart';
import '../../domain/usecases/get_all_collections_usecase.dart';
import '../../domain/usecases/get_collection_by_id_usecase.dart';
import '../../domain/usecases/record_collection_access_usecase.dart';
import '../../domain/usecases/update_collection_position_usecase.dart';

// Repository selector — ADR-0002 aligned:
// - Guest: local ObjectBox only.
// - Authenticated + online: Supabase when free, or premium after migration.
// - Premium + online + not migrated: stay on local until bulk migration completes.
// - Authenticated + offline: local cache.
// - Premium lapsed (RC inactive): read-only cloud when online.
final collectionsRepositoryProvider = Provider<ICollectionsRepository>((ref) {
  final backend = ref.watch(dataBackendSelectionProvider);
  final supabaseUserId = backend.supabaseUserId;
  if (backend.useCloud && supabaseUserId != null) {
    final cloudRepo = SupabaseCollectionRepository(
      Supabase.instance.client,
      userId: supabaseUserId,
    );
    if (backend.isReadOnlyCloud) {
      return ReadOnlyCollectionsRepository(cloudRepo);
    }
    return cloudRepo;
  }

  final appDatabase = ref.watch(appDatabaseProvider);
  return CollectionsRepositoryImpl(appDatabase.store);
});

// Use Case Providers
final watchCollectionsUseCaseProvider =
    Provider<WatchCollectionsUseCase>((ref) {
  return WatchCollectionsUseCase(ref.watch(collectionsRepositoryProvider));
});

final createCollectionUseCaseProvider =
    Provider<CreateCollectionUseCase>((ref) {
  return CreateCollectionUseCase(ref.watch(collectionsRepositoryProvider));
});

final updateCollectionUseCaseProvider =
    Provider<UpdateCollectionUseCase>((ref) {
  return UpdateCollectionUseCase(ref.watch(collectionsRepositoryProvider));
});

final deleteCollectionUseCaseProvider =
    Provider<DeleteCollectionUseCase>((ref) {
  return DeleteCollectionUseCase(ref.watch(collectionsRepositoryProvider));
});

final getCollectionByIdUseCaseProvider =
    Provider<GetCollectionByIdUseCase>((ref) {
  return GetCollectionByIdUseCase(ref.watch(collectionsRepositoryProvider));
});

final getAllCollectionsUseCaseProvider =
    Provider<GetAllCollectionsUseCase>((ref) {
  return GetAllCollectionsUseCase(ref.watch(collectionsRepositoryProvider));
});

final recordCollectionAccessUseCaseProvider =
    Provider<RecordCollectionAccessUseCase>((ref) {
  return RecordCollectionAccessUseCase(ref.watch(collectionsRepositoryProvider));
});

final updateCollectionPositionUseCaseProvider =
    Provider<UpdateCollectionPositionUseCase>((ref) {
  return UpdateCollectionPositionUseCase(ref.watch(collectionsRepositoryProvider));
});

// Stream of Collections
final collectionsListProvider = StreamProvider<List<Collection>>((ref) {
  final useCase = ref.watch(watchCollectionsUseCaseProvider);
  return useCase();
});

/// Quick lookup for one collection by id from current stream snapshot.
final collectionByIdProvider =
    Provider.family<Collection?, String>((ref, collectionId) {
  final all = ref.watch(collectionsListProvider).valueOrNull;
  if (all == null) return null;
  for (final c in all) {
    if (c.id == collectionId) return c;
  }
  return null;
});

/// Persists / migrates the single library root, then exposes it for routing.
final libraryRootCollectionProvider = FutureProvider<Collection>((ref) async {
  ref.watch(currentUserProvider);
  final repo = ref.read(collectionsRepositoryProvider);
  final result = await repo.ensureLibraryRootCollection();
  return result.fold(
    (f) => throw Exception(f.message),
    (c) => c,
  );
});

// View Mode Provider (true = grid, false = list)
final collectionsViewModeProvider = StateProvider<bool>((ref) => true);
