import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../../core/providers/network_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../monetization/presentation/providers/subscription_status_provider.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/i_items_repository.dart';
import '../../data/repositories/items_repository_impl.dart';
import '../../data/repositories/supabase_items_repository.dart';
import '../../data/repositories/read_only_items_repository.dart';
import '../../domain/usecases/get_paginated_items_usecase.dart';
import '../../domain/usecases/create_item_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/toggle_item_status_usecase.dart';

// Same routing rules as [collectionsRepositoryProvider] (ADR-0002).
final itemsRepositoryProvider = Provider<IItemsRepository>((ref) {
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
    final cloudRepo = SupabaseItemsRepository(
      Supabase.instance.client,
      userId: supabaseUserId,
    );
    if (isPremium && !isActive) {
      return ReadOnlyItemsRepository(cloudRepo);
    }
    return cloudRepo;
  }

  final appDatabase = ref.watch(appDatabaseProvider);
  return ItemsRepositoryImpl(appDatabase.store);
});

// Use Case Providers
final getPaginatedItemsUseCaseProvider =
    Provider<GetPaginatedItemsUseCase>((ref) {
  return GetPaginatedItemsUseCase(ref.watch(itemsRepositoryProvider));
});

final createItemUseCaseProvider = Provider<CreateItemUseCase>((ref) {
  return CreateItemUseCase(ref.watch(itemsRepositoryProvider));
});

final updateItemUseCaseProvider = Provider<UpdateItemUseCase>((ref) {
  return UpdateItemUseCase(ref.watch(itemsRepositoryProvider));
});

final deleteItemUseCaseProvider = Provider<DeleteItemUseCase>((ref) {
  return DeleteItemUseCase(ref.watch(itemsRepositoryProvider));
});

final toggleItemStatusUseCaseProvider =
    Provider<ToggleItemStatusUseCase>((ref) {
  return ToggleItemStatusUseCase(ref.watch(itemsRepositoryProvider));
});

class ItemsState {
  final List<Item> items;
  final bool hasMore;
  final bool isLoadingMore;

  ItemsState({
    required this.items,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ItemsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ItemsNotifier extends FamilyAsyncNotifier<ItemsState, String> {
  static const int _pageSize = 20;
  String get _collectionId => arg;

  @override
  Future<ItemsState> build(String arg) async {
    return _fetchPage(0, []);
  }

  Future<ItemsState> _fetchPage(int offset, List<Item> currentItems) async {
    final useCase = ref.read(getPaginatedItemsUseCaseProvider);
    final result = await useCase.call(_collectionId, _pageSize, offset);

    return result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (newItems) {
        return ItemsState(
          items: [...currentItems, ...newItems],
          hasMore: newItems.length == _pageSize,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final offset = currentState.items.length;
      final newState = await _fetchPage(offset, currentState.items);
      state = AsyncData(newState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final newState = await _fetchPage(0, []);
      state = AsyncData(newState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void addItemToState(Item newItem) {
    if (state.value == null) return;

    final currentItems = state.value!.items;
    final newItems = [newItem, ...currentItems];
    state = AsyncData(state.value!.copyWith(items: newItems));
  }

  void updateItemInState(Item updatedItem) {
    if (state.value == null) return;

    final currentItems = state.value!.items;
    final index = currentItems.indexWhere((i) => i.id == updatedItem.id);

    if (index != -1) {
      final newItems = List<Item>.from(currentItems);
      newItems[index] = updatedItem;
      state = AsyncData(state.value!.copyWith(items: newItems));
    }
  }

  void removeItemFromState(String itemId) {
    if (state.value == null) return;

    final currentItems = state.value!.items;
    final newItems = currentItems.where((i) => i.id != itemId).toList();
    state = AsyncData(state.value!.copyWith(items: newItems));
  }
}

final itemsNotifierProvider =
    AsyncNotifierProviderFamily<ItemsNotifier, ItemsState, String>(() {
  return ItemsNotifier();
});
