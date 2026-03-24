import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/infrastructure/providers.dart';
import '../../../../core/providers/network_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../monetization/presentation/providers/subscription_status_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/i_collections_repository.dart';
import '../../data/repositories/collections_repository_impl.dart';
import '../../data/repositories/supabase_collection_repository.dart';
import '../../data/repositories/read_only_collections_repository.dart';
import '../../domain/usecases/watch_collections_usecase.dart';
import '../../domain/usecases/create_collection_usecase.dart';
import '../../domain/usecases/update_collection_usecase.dart';
import '../../domain/usecases/delete_collection_usecase.dart';

// Repository selector — ADR-0002 aligned:
// - Guest: local ObjectBox only.
// - Authenticated + online: Supabase when free, or premium after migration.
// - Premium + online + not migrated: stay on local until bulk migration completes.
// - Authenticated + offline: local cache.
// - Premium lapsed (RC inactive): read-only cloud when online.
final collectionsRepositoryProvider = Provider<ICollectionsRepository>((ref) {
  final hasMigratedToCloud = ref.watch(hasMigratedToCloudProvider);
  final currentUser = ref.watch(currentUserProvider);
  final isOnline = ref.watch(isOnlineProvider);
  final isAuthenticated = currentUser != null;
  final isPremium = ref.watch(isPremiumProvider);
  final isActive =
      ref.watch(isSubscriptionActiveProvider).valueOrNull ?? false;

  final useCloud = isAuthenticated &&
      isOnline &&
      (!isPremium || hasMigratedToCloud);

  final supabaseUserId = currentUser?.supabaseId;
  if (useCloud && supabaseUserId != null) {
    final cloudRepo = SupabaseCollectionRepository(
      Supabase.instance.client,
      userId: supabaseUserId,
    );
    if (isPremium && !isActive) {
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

// Stream of Collections
final collectionsListProvider = StreamProvider<List<Collection>>((ref) {
  final useCase = ref.watch(watchCollectionsUseCaseProvider);
  return useCase();
});

// View Mode Provider (true = grid, false = list)
final collectionsViewModeProvider = StateProvider<bool>((ref) => true);
