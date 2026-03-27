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

final getAllItemsUseCaseProvider = Provider<GetAllItemsUseCase>((ref) {
  return GetAllItemsUseCase(ref.watch(itemsRepositoryProvider));
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

enum UrlSortOption {
  position,
  dateAdded,
  dateEdited,
  mostVisited,
  alphabeticalAsc,
  alphabeticalDesc,
}
enum UnifiedTab { childCollections, urls }
enum UrlViewMode { list, cards, icons }

/// Links tab data: lazy-loaded when user switches to Links (or [ensureUrlsLoaded]).
enum UrlsDataPhase {
  notStarted,
  loading,
  loaded,
  error,
}

int compareBySortOption(UrlSortOption sort, Item a, Item b) {
  return switch (sort) {
    UrlSortOption.position => a.position.compareTo(b.position),
    UrlSortOption.dateAdded => b.createdAt.compareTo(a.createdAt),
    UrlSortOption.dateEdited => b.updatedAt.compareTo(a.updatedAt),
    UrlSortOption.mostVisited => b.clickCount.compareTo(a.clickCount),
    UrlSortOption.alphabeticalAsc =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    UrlSortOption.alphabeticalDesc =>
      b.title.toLowerCase().compareTo(a.title.toLowerCase()),
  };
}

class ItemsState {
  static const Object _kUnset = Object();

  final List<Item> items;
  final bool hasMore;
  final bool isLoadingMore;
  final ItemStatus? statusFilter;
  final UrlSortOption sortOption;
  final UrlViewMode viewMode;
  final UnifiedTab activeTab;
  final UrlsDataPhase urlsDataPhase;
  final String? urlsErrorMessage;
  /// How many raw rows we've fetched from the repository (used to keep
  /// pagination stable when client-side filtering is enabled).
  final int fetchedCount;

  ItemsState({
    required this.items,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statusFilter,
    this.sortOption = UrlSortOption.dateAdded,
    this.viewMode = UrlViewMode.list,
    this.activeTab = UnifiedTab.childCollections,
    this.urlsDataPhase = UrlsDataPhase.notStarted,
    this.urlsErrorMessage,
    this.fetchedCount = 0,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? hasMore,
    bool? isLoadingMore,
    ItemStatus? statusFilter,
    UrlSortOption? sortOption,
    UrlViewMode? viewMode,
    UnifiedTab? activeTab,
    UrlsDataPhase? urlsDataPhase,
    Object? urlsErrorMessage = _kUnset,
    int? fetchedCount,
  }) {
    return ItemsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter: statusFilter ?? this.statusFilter,
      sortOption: sortOption ?? this.sortOption,
      viewMode: viewMode ?? this.viewMode,
      activeTab: activeTab ?? this.activeTab,
      urlsDataPhase: urlsDataPhase ?? this.urlsDataPhase,
      urlsErrorMessage: urlsErrorMessage == _kUnset
          ? this.urlsErrorMessage
          : urlsErrorMessage as String?,
      fetchedCount: fetchedCount ?? this.fetchedCount,
    );
  }
}

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
    if (current == null) return;
    if (!forceRefresh &&
        current.urlsDataPhase == UrlsDataPhase.loaded) {
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

  Future<ItemsState> _fetchPage(int offset, List<Item> currentItems) async {
    final useCase = ref.read(getPaginatedItemsUseCaseProvider);
    final result = await useCase.call(_collectionId, _pageSize, offset);

    return result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (newItems) {
        final filteredPage = _statusFilter == null
            ? newItems
            : newItems.where((i) => i.status == _statusFilter).toList();

        final combined = <Item>[...currentItems, ...filteredPage];
        combined.sort((a, b) => compareBySortOption(_sortOption, a, b));

        return ItemsState(
          items: combined,
          hasMore: newItems.length == _pageSize,
          isLoadingMore: false,
          statusFilter: _statusFilter,
          sortOption: _sortOption,
          viewMode: _viewMode,
          activeTab: _activeTab,
          urlsDataPhase: UrlsDataPhase.loaded,
          urlsErrorMessage: null,
          fetchedCount: offset + newItems.length,
        );
      },
    );
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
    final base = state.value;
    if (base == null) return;
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

  Future<void> setSortOption(UrlSortOption sortOption) async {
    _sortOption = sortOption;
    final base = state.value;
    if (base == null) return;
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
    if (current == null) return;
    state = AsyncData(current.copyWith(activeTab: _activeTab));
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
    nextItems.sort((a, b) => compareBySortOption(_sortOption, a, b));
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
      newItems.sort((a, b) => compareBySortOption(_sortOption, a, b));
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
