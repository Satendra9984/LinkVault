import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../../core/providers/data_backend_selection_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/i_items_repository.dart';
import '../../data/repositories/items_repository_impl.dart';
import '../../data/repositories/supabase_items_repository.dart';
import '../../data/repositories/read_only_items_repository.dart';
import '../../domain/usecases/get_paginated_items_usecase.dart';
import '../../domain/usecases/get_all_items_usecase.dart';
import '../../domain/usecases/get_item_usecase.dart';
import '../../domain/usecases/create_item_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/mark_item_read_and_track_usecase.dart';
import '../../domain/usecases/toggle_item_status_usecase.dart';
import '../../domain/usecases/toggle_item_archive_usecase.dart';
import '../../domain/usecases/toggle_item_pin_usecase.dart';
import '../../domain/usecases/reorder_items_usecase.dart';
import '../../domain/usecases/query_url_items_usecase.dart';
import '../../domain/models/url_items_query.dart';
import '../../domain/url_sort_option.dart';

export '../../domain/url_sort_option.dart';

import 'items_hub_ui_notifier.dart';
import 'items_list_models.dart';

export 'items_list_models.dart';

/// Always **local ObjectBox** — pair with [localCollectionsRepositoryProvider]
/// for migration uploads.
final localItemsRepositoryProvider = Provider<IItemsRepository>((ref) {
  return ItemsRepositoryImpl(ref.watch(appDatabaseProvider).store);
});

// Same routing rules as [collectionsRepositoryProvider] (ADR-0002).
final itemsRepositoryProvider = Provider<IItemsRepository>((ref) {
  final backend = ref.watch(dataBackendSelectionProvider);
  final supabaseUserId = backend.supabaseUserId;
  if (backend.useCloud && supabaseUserId != null) {
    final cloudRepo = SupabaseItemsRepository(
      Supabase.instance.client,
      userId: supabaseUserId,
    );
    if (backend.isReadOnlyCloud) {
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

final queryUrlItemsUseCaseProvider = Provider<QueryUrlItemsUseCase>((ref) {
  return QueryUrlItemsUseCase(ref.watch(itemsRepositoryProvider));
});

final getAllItemsUseCaseProvider = Provider<GetAllItemsUseCase>((ref) {
  return GetAllItemsUseCase(ref.watch(itemsRepositoryProvider));
});

/// Pinned URLs across the library for Home (read-only aggregate).
///
/// Auto-dispose refetches when Home is opened again after dispose.
final homePinnedItemsProvider =
    FutureProvider.autoDispose<List<Item>>((ref) async {
  final result = await ref.watch(getAllItemsUseCaseProvider).call();
  return result.fold(
    (_) => <Item>[],
    (items) {
      final pinned = items
          .where(
            (i) =>
                i.isPinned &&
                !i.isDeleted &&
                i.status != ItemStatus.archived,
          )
          .toList()
        ..sort((a, b) {
          final byPos = a.position.compareTo(b.position);
          if (byPos != 0) return byPos;
          return b.updatedAt.compareTo(a.updatedAt);
        });
      const maxItems = 36;
      if (pinned.length <= maxItems) return pinned;
      return pinned.sublist(0, maxItems);
    },
  );
});

final createItemUseCaseProvider = Provider<CreateItemUseCase>((ref) {
  return CreateItemUseCase(ref.watch(itemsRepositoryProvider));
});

final getItemUseCaseProvider = Provider<GetItemUseCase>((ref) {
  return GetItemUseCase(ref.watch(itemsRepositoryProvider));
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

final markItemReadAndTrackUseCaseProvider =
    Provider<MarkItemReadAndTrackUseCase>((ref) {
  return MarkItemReadAndTrackUseCase(ref.watch(itemsRepositoryProvider));
});

final toggleItemPinUseCaseProvider = Provider<ToggleItemPinUseCase>((ref) {
  return ToggleItemPinUseCase(ref.watch(itemsRepositoryProvider));
});

final toggleItemArchiveUseCaseProvider =
    Provider<ToggleItemArchiveUseCase>((ref) {
  return ToggleItemArchiveUseCase(ref.watch(itemsRepositoryProvider));
});

final reorderItemsUseCaseProvider = Provider<ReorderItemsUseCase>((ref) {
  return ReorderItemsUseCase(ref.watch(itemsRepositoryProvider));
});

class ItemsNotifier extends FamilyAsyncNotifier<ItemsState, String> {
  static const int _pageSize = 20;
  String get _collectionId => arg;

  // MVVM: filtering/sorting state lives in the notifier, not the widget.
  ItemStatus? _statusFilter;
  UrlSortOption _sortOption = UrlSortOption.dateAdded;
  UrlViewMode _viewMode = UrlViewMode.list;
  UnifiedTab _activeTab = UnifiedTab.childCollections;

  @override
  Future<ItemsState> build(String arg) async {
    _statusFilter = null;
    _sortOption = UrlSortOption.dateAdded;
    _viewMode = UrlViewMode.list;
    _activeTab = UnifiedTab.childCollections;
    return ItemsState(
      items: const [],
      hasMore: false,
      isLoadingMore: false,
      statusFilter: _statusFilter,
      sortOption: _sortOption,
      viewMode: _viewMode,
      activeTab: _activeTab,
      urlsDataPhase: UrlsDataPhase.notStarted,
      urlsErrorMessage: null,
      fetchedCount: 0,
    );
  }

  /// Applies defaults from [Collection] without fetching URLs (lazy Links tab).
  void applyCollectionDisplayDefaults({
    required UrlViewMode viewMode,
    required UrlSortOption sortOption,
  }) {
    _viewMode = viewMode;
    _sortOption = sortOption;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        viewMode: _viewMode,
        sortOption: _sortOption,
      ),
    );
  }

  /// Loads URL rows for this collection (first open of Links tab, edit screen, etc.).
  Future<void> ensureUrlsLoaded({bool forceRefresh = false}) async {
    var current = state.value;
    // Tab sync can run before the first [build] completes; yield until [AsyncData] exists.
    if (current == null) {
      for (var i = 0; i < 50 && current == null; i++) {
        await Future<void>.delayed(Duration.zero);
        current = state.value;
      }
      if (current == null) return;
    }
    if (!forceRefresh && current.urlsDataPhase == UrlsDataPhase.loaded) {
      return;
    }
    if (!forceRefresh && current.urlsDataPhase == UrlsDataPhase.loading) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        urlsDataPhase: UrlsDataPhase.loading,
        urlsErrorMessage: null,
        isLoadingMore: false,
      ),
    );
    current = state.value;

    try {
      final newState = await _fetchPage(0, []);
      state = AsyncData(
        newState.copyWith(
          urlsDataPhase: UrlsDataPhase.loaded,
          urlsErrorMessage: null,
          activeTab: _activeTab,
        ),
      );
    } catch (e) {
      final failed = state.value;
      if (failed != null) {
        state = AsyncData(
          failed.copyWith(
            urlsDataPhase: UrlsDataPhase.error,
            urlsErrorMessage: e.toString(),
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  UrlItemsQuery _urlItemsQuery(int offset) {
    final ui = ref.read(itemsHubUiNotifierProvider(_collectionId));
    return UrlItemsQuery(
      collectionId: _collectionId,
      limit: _pageSize,
      offset: offset,
      status: _statusFilter,
      sort: _sortOption,
      searchQuery: ui.urlSearchQuery,
      pinnedOnly: ui.urlPinnedOnly,
      withDescriptionOnly: ui.urlWithDescriptionOnly,
      withImageOnly: ui.urlWithImageOnly,
      domainContains: ui.urlDomainQuery,
      savedAfter: ui.urlSavedAfter,
      savedBefore: ui.urlSavedBefore,
    );
  }

  Future<ItemsState> _fetchPage(int offset, List<Item> currentItems) async {
    final useCase = ref.read(queryUrlItemsUseCaseProvider);
    final result = await useCase(_urlItemsQuery(offset));

    return result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (page) {
        final combined =
            offset == 0 ? page.items : <Item>[...currentItems, ...page.items];

        return ItemsState(
          items: combined,
          hasMore: page.hasMore,
          isLoadingMore: false,
          statusFilter: _statusFilter,
          sortOption: _sortOption,
          viewMode: _viewMode,
          activeTab: _activeTab,
          urlsDataPhase: UrlsDataPhase.loaded,
          urlsErrorMessage: null,
          fetchedCount: offset + page.items.length,
        );
      },
    );
  }

  /// Re-runs the first page using current hub UI filters (search, dates, etc.).
  Future<void> refetchUrlsWithCurrentFilters() async {
    final base = state.value;
    if (base == null) return;
    if (base.urlsDataPhase == UrlsDataPhase.notStarted) return;

    state = AsyncData(
      base.copyWith(
        urlsDataPhase: UrlsDataPhase.loading,
        urlsErrorMessage: null,
        isLoadingMore: false,
      ),
    );
    try {
      final newState = await _fetchPage(0, []);
      state = AsyncData(
        newState.copyWith(urlsDataPhase: UrlsDataPhase.loaded),
      );
    } catch (e) {
      state = AsyncData(
        base.copyWith(
          urlsDataPhase: UrlsDataPhase.error,
          urlsErrorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.urlsDataPhase != UrlsDataPhase.loaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final offset = currentState.fetchedCount;
      final newState = await _fetchPage(offset, currentState.items);
      state = AsyncData(newState);
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(
          urlsDataPhase: UrlsDataPhase.error,
          urlsErrorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> setStatusFilter(ItemStatus? filter) async {
    _statusFilter = filter;
    await _refetchFirstPage();
  }

  Future<void> setSortOption(UrlSortOption sortOption) async {
    _sortOption = sortOption;
    await _refetchFirstPage();
  }

  /// Single refetch after filter sheet applies sort + status together.
  Future<void> applySortAndStatusFromFilterSheet({
    required UrlSortOption sortOption,
    required ItemStatus? statusFilter,
  }) async {
    _sortOption = sortOption;
    _statusFilter = statusFilter;
    await _refetchFirstPage();
  }

  Future<void> _refetchFirstPage() async {
    final base = state.value;
    if (base == null) return;
    if (base.urlsDataPhase == UrlsDataPhase.notStarted) return;
    state = AsyncData(
      base.copyWith(
        urlsDataPhase: UrlsDataPhase.loading,
        urlsErrorMessage: null,
      ),
    );
    try {
      final newState = await _fetchPage(0, []);
      state = AsyncData(
        newState.copyWith(urlsDataPhase: UrlsDataPhase.loaded),
      );
    } catch (e) {
      state = AsyncData(
        base.copyWith(
          urlsDataPhase: UrlsDataPhase.error,
          urlsErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> setViewMode(UrlViewMode viewMode) async {
    _viewMode = viewMode;
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(viewMode: _viewMode));
      return;
    }
  }

  Future<void> setActiveTab(UnifiedTab tab) async {
    _activeTab = tab;
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(activeTab: _activeTab));
    }
    if (tab == UnifiedTab.urls) {
      await ensureUrlsLoaded();
    }
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        urlsDataPhase: UrlsDataPhase.loading,
        urlsErrorMessage: null,
      ),
    );
    try {
      final newState = await _fetchPage(0, []);
      state = AsyncData(
        newState.copyWith(urlsDataPhase: UrlsDataPhase.loaded),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          urlsDataPhase: UrlsDataPhase.error,
          urlsErrorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  void addItemToState(Item newItem) {
    if (state.value == null) return;

    final currentItems = state.value!.items;
    final nextItems = <Item>[newItem, ...currentItems];
    nextItems.sort((a, b) => compareItemsByUrlSort(_sortOption, a, b));
    state = AsyncData(
      state.value!.copyWith(
        items: nextItems,
        fetchedCount: state.value!.fetchedCount + 1,
        urlsDataPhase: UrlsDataPhase.loaded,
      ),
    );
  }

  void updateItemInState(Item updatedItem) {
    if (state.value == null) return;

    final currentItems = state.value!.items;
    final index = currentItems.indexWhere((i) => i.id == updatedItem.id);

    if (index != -1) {
      final newItems = List<Item>.from(currentItems);
      newItems[index] = updatedItem;
      newItems.sort((a, b) => compareItemsByUrlSort(_sortOption, a, b));
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
