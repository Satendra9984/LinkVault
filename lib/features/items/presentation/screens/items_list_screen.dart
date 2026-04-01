import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/presentation/widgets/content_state_widgets.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../domain/entities/item.dart';
import '../../domain/link_open_behavior.dart';
import '../providers/items_providers.dart';
import '../providers/items_hub_notifier.dart';
import '../providers/items_hub_ui_notifier.dart';
import '../providers/items_hub_ui_state.dart';
import '../widgets/url_favicon_tile.dart';
import '../widgets/url_icon_link_tile.dart';
import '../widgets/url_preview_tile.dart';
import '../widgets/unified_collection_sheets.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/presentation/providers/collections_hub_notifier.dart';
import '../../../collections/presentation/widgets/collection_card.dart';
import '../../../collections/presentation/widgets/collection_list_tile.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/collection_display_defaults.dart';

enum _EmptyLinksMode { noLinks, noFilterMatches, noSearchMatches }

enum _LinksQuickDate { all, last7Days, last30Days, thisYear }

/// Responsive grid for links / nested folders (min tile width + aspect targets).
class _HubGridMetrics {
  const _HubGridMetrics({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final int crossAxisCount;
  final double childAspectRatio;
}

_HubGridMetrics _linksCardsGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 148.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(1, 4);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  final imageH = cellW * 9 / 16;
  // Budget for footer: padding + domain row + gaps + 2-line title (+ optional desc).
  const textBlockH = 112.0;
  var ratio = cellW / (imageH + textBlockH);
  ratio = ratio.clamp(0.46, 0.82);
  return _HubGridMetrics(
    crossAxisCount: count,
    childAspectRatio: ratio,
  );
}

_HubGridMetrics _linksIconsGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 92.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(2, 6);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  // ~56 icon container + padding + 2-line title + domain
  final targetH = 118.0;
  var ratio = cellW / targetH;
  ratio = ratio.clamp(0.72, 1.05);
  return _HubGridMetrics(
    crossAxisCount: count,
    childAspectRatio: ratio,
  );
}

_HubGridMetrics _childFoldersGridMetrics(double innerWidth,
    {required bool compact}) {
  const spacing = 16.0;
  // Compact: smaller min cell + shorter row height so tiles read clearly smaller than grid.
  final minCell = compact ? 88.0 : 152.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = compact ? count.clamp(2, 6) : count.clamp(1, 3);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  final targetH = compact ? (cellW * 0.48 + 58) : (cellW * 0.48 + 96);
  var ratio = cellW / targetH;
  ratio = compact ? ratio.clamp(0.82, 1.08) : ratio.clamp(0.72, 0.92);
  return _HubGridMetrics(
    crossAxisCount: count,
    childAspectRatio: ratio,
  );
}

class ItemsListScreen extends ConsumerStatefulWidget {
  final String collectionId;
  final String? collectionName;
  final bool isRoot;

  const ItemsListScreen({
    super.key,
    required this.collectionId,
    this.collectionName,
    this.isRoot = false,
  });

  @override
  ConsumerState<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends ConsumerState<ItemsListScreen> {
  static const _radiusMd = 12.0;
  static const _radiusLg = 16.0;
  static const _animMs = Duration(milliseconds: 250);
  bool _hasAppliedCollectionDefaults = false;

  /// Nudges rebuild while collection is missing from cache so defaults+prefetch can run.
  int _urlsCollectionCacheWaitFrames = 0;
  static const _maxUrlsCollectionCacheWaits = 12;
  bool _urlsEmergencyPrefetchWithoutCollection = false;
  bool _fabVisible = true;
  bool _fabExtended = true;
  Timer? _urlSearchDebounce;

  /// Null = use per-link override + folder default ([effectiveOpenLinksIn]).
  String? _linkTapOpenOverride;
  TabController? _hubTabController;

  void _onHubTabControllerChanged() {
    final c = _hubTabController;
    if (c == null || c.indexIsChanging) return;
    final tab = c.index == 0 ? UnifiedTab.childCollections : UnifiedTab.urls;
    ref
        .read(itemsNotifierProvider(widget.collectionId).notifier)
        .setActiveTab(tab);
  }

  void _syncHubTabController(TabController c) {
    if (_hubTabController == c) return;
    _hubTabController?.removeListener(_onHubTabControllerChanged);
    _hubTabController = c;
    c.addListener(_onHubTabControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hubTabController != c) return;
      _onHubTabControllerChanged();
    });
  }

  void _onScrollUpdate(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.metrics.maxScrollExtent > 0) {
      final goingDown = (n.scrollDelta ?? 0) > 0;
      final nextExtended = !goingDown;
      if (nextExtended != _fabExtended) {
        setState(() => _fabExtended = nextExtended);
      }
      if (goingDown != !_fabVisible) {
        setState(() => _fabVisible = !goingDown);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(collectionsHubNotifierProvider.notifier)
            .recordAccess(widget.collectionId);
      }
    });
  }

  @override
  void dispose() {
    _hubTabController?.removeListener(_onHubTabControllerChanged);
    _hubTabController = null;
    _urlSearchDebounce?.cancel();
    super.dispose();
  }

  void _scheduleUrlQueryRefetch() {
    _urlSearchDebounce?.cancel();
    _urlSearchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref
          .read(itemsNotifierProvider(widget.collectionId).notifier)
          .refetchUrlsWithCurrentFilters();
    });
  }

  List<Collection> _filterChildCollectionsBySearch(
    List<Collection> children,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return children;
    return children.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  List<Collection> _sortChildCollections(
    List<Collection> list,
    ChildFolderSort childFolderSort,
  ) {
    final out = List<Collection>.from(list);
    switch (childFolderSort) {
      case ChildFolderSort.titleAsc:
        out.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case ChildFolderSort.titleDesc:
        out.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case ChildFolderSort.itemCountDesc:
        out.sort((a, b) => b.itemCount.compareTo(a.itemCount));
        break;
      case ChildFolderSort.createdDesc:
        out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ChildFolderSort.updatedDesc:
        out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    return out;
  }

  bool _urlsExtrasActive(ItemsHubUiState uiState) {
    return uiState.urlPinnedOnly ||
        uiState.urlWithDescriptionOnly ||
        uiState.urlWithImageOnly ||
        uiState.urlDomainQuery.trim().isNotEmpty ||
        uiState.urlSavedAfter != null ||
        uiState.urlSavedBefore != null;
  }

  bool _urlsFiltersDifferFromDefaults(
      ItemsState state, ItemsHubUiState uiState) {
    return state.statusFilter != null ||
        state.sortOption != UrlSortOption.dateAdded ||
        state.viewMode != UrlViewMode.list ||
        _urlsExtrasActive(uiState);
  }

  bool _childFiltersActive(ItemsHubUiState uiState) {
    return uiState.childFolderSort != ChildFolderSort.titleAsc ||
        uiState.childIncludeArchived ||
        uiState.childSelectedCategories.isNotEmpty ||
        uiState.childUpdatedAfter != null ||
        uiState.childUpdatedBefore != null;
  }

  void _openUrlsFiltersScreen() {
    context.push('/collections/${widget.collectionId}/filters/urls');
  }

  void _openFoldersFiltersScreen() {
    context.push('/collections/${widget.collectionId}/filters/folders');
  }

  void _showCollectionActionsBottomSheet({
    required TabController tabController,
  }) {
    final current = _currentCollectionFromCache();
    final metadata =
        '${current?.category ?? 'General'} · ${current?.childCount ?? 0} folders';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CollectionHubActionsSheet(
        title: current?.title ?? widget.collectionName ?? 'Collection',
        metadata: metadata,
        isRoot: widget.isRoot,
        isLinksTab: !widget.isRoot && tabController.index == 1,
        isReorderMode: ref
            .read(itemsHubUiNotifierProvider(widget.collectionId))
            .isReorderMode,
        // Gated: add subfolder / edit collection / settings (matrix).
        onAddSubfolder: () async {
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !mounted) return;
          final parent = _currentCollectionFromCache();
          if (!context.mounted) return;
          context.push(
            '/collections/create?parent=${widget.collectionId}',
            extra: parent,
          );
        },
        onAddLink: () async {
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !mounted) return;
          context.push(
            '/collections/${widget.collectionId}/items/create',
            extra: widget.collectionName,
          );
        },
        onEditCollection: () async {
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !mounted) return;
          if (!context.mounted) return;
          context.push('/collections/${widget.collectionId}/edit');
        },
        onTogglePinCollection: () {
          _toggleCollectionFlags(pin: true);
        },
        onToggleArchiveCollection: () {
          _toggleCollectionFlags(archive: true);
        },
        onDeleteCollection: () {
          _confirmDeleteCollection();
        },
        onToggleReorderLinks: () {
          final uiNotifier = ref
              .read(itemsHubUiNotifierProvider(widget.collectionId).notifier);
          final uiState =
              ref.read(itemsHubUiNotifierProvider(widget.collectionId));
          if (widget.isRoot) {
            return;
          }
          if (tabController.index != 1) {
            tabController.animateTo(1);
            ref
                .read(itemsNotifierProvider(widget.collectionId).notifier)
                .setActiveTab(UnifiedTab.urls);
            return;
          }
          uiNotifier.toggleReorderMode();
          if (uiState.isReorderMode) {
            ref
                .read(itemsNotifierProvider(widget.collectionId).notifier)
                .refresh();
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete collection?'),
        content: const Text(
          'This will permanently delete this collection and its links.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(collectionsHubNotifierProvider.notifier)
        .deleteCollection(widget.collectionId);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _toggleCollectionFlags({
    bool pin = false,
    bool archive = false,
  }) async {
    final current = _currentCollectionFromCache();
    if (current == null) return;
    final updated = Collection(
      id: current.id,
      ownerId: current.ownerId,
      parentId: current.parentId,
      isShared: current.isShared,
      title: current.title,
      description: current.description,
      category: current.category,
      colorHex: current.colorHex,
      iconName: current.iconName,
      iconJson: current.iconJson,
      position: current.position,
      isPinned: pin ? !current.isPinned : current.isPinned,
      isArchived: archive ? !current.isArchived : current.isArchived,
      isDeleted: current.isDeleted,
      childCount: current.childCount,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: current.lastAccessedAt,
      itemsLayout: current.itemsLayout,
      childCollectionsLayout: current.childCollectionsLayout,
      itemsSortDefault: current.itemsSortDefault,
      openLinksIn: current.openLinksIn,
      showLinkPreviews: current.showLinkPreviews,
      itemCount: current.itemCount,
    );
    await ref
        .read(collectionsHubNotifierProvider.notifier)
        .saveCollection(updated);
  }

  Collection? _currentCollectionFromCache() {
    return ref.read(collectionByIdProvider(widget.collectionId));
  }

  Widget _buildHubHeaderContent(
    List<Collection> collections,
    Collection? currentCollection,
    Color primary,
    int folderCountFromList,
  ) {
    final theme = Theme.of(context);
    final byId = {for (final c in collections) c.id: c};
    final trail = <Collection>[];
    var cursor = byId[widget.collectionId];
    while (cursor != null) {
      trail.insert(0, cursor);
      cursor = cursor.parentId == null ? null : byId[cursor.parentId!];
    }
    final current = trail.isNotEmpty ? trail.last : currentCollection;
    final title = current?.title ??
        currentCollection?.title ??
        widget.collectionName ??
        'Collection';
    final ancestors =
        trail.length > 1 ? trail.sublist(0, trail.length - 1) : <Collection>[];
    final shownAncestors = ancestors.length <= 3
        ? ancestors
        : <Collection>[
            ancestors.first,
            ancestors[ancestors.length - 2],
            ancestors.last
          ];
    final isTruncated = ancestors.length > 3;

    final folders = (current?.childCount ?? 0) > 0
        ? current!.childCount
        : folderCountFromList;

    if (widget.isRoot) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Collections',
            style: TextStyle(
              color: primary.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$folders folders',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Breadcrumb: "Collections" is always the root segment.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/collections'),
                child: Text(
                  'Collections',
                  style: TextStyle(
                    color: primary.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (var i = 0; i < shownAncestors.length; i++) ...[
                Text(
                  ' › ',
                  style: TextStyle(
                    color: primary.withValues(alpha: 0.45),
                    fontSize: 13,
                  ),
                ),
                InkWell(
                  onTap: () => context.push(
                    '/collections/${shownAncestors[i].id}',
                    extra: shownAncestors[i].title,
                  ),
                  child: Text(
                    shownAncestors[i].title,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isTruncated && i == 0) ...[
                  Text(
                    ' › ',
                    style: TextStyle(
                      color: primary.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '…',
                    style: TextStyle(
                      color: primary.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        // Row(
        //   children: [
        //     Icon(
        //       Icons.folder_outlined,
        //       size: 16,
        //       color: theme.colorScheme.onSurfaceVariant,
        //     ),
        //     const SizedBox(width: 6),
        //     Expanded(
        //       child: Text(
        //         '$folders folders · $links links',
        //         style: theme.textTheme.bodySmall?.copyWith(
        //           color: theme.colorScheme.onSurfaceVariant,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget? _buildTabFab(
    BuildContext context,
    TabController tabController,
    AsyncValue<ItemsState> itemsAsync,
  ) {
    if (!itemsAsync.hasValue) return null;
    final isFolders = widget.isRoot || tabController.index == 0;
    if (isFolders) {
      if (_fabExtended) {
        return FloatingActionButton.extended(
          heroTag: 'items_list_fab_subfolder',
          onPressed: () async {
            final ok = await DayPassGate.check(context, ref);
            if (!ok || !context.mounted) return;
            final parent = _currentCollectionFromCache();
            if (!context.mounted) return;
            context.push(
              '/collections/create?parent=${widget.collectionId}',
              extra: parent,
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('New folder'),
        );
      }
      return FloatingActionButton(
        heroTag: 'items_list_fab_subfolder',
        onPressed: () async {
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !context.mounted) return;
          final parent = _currentCollectionFromCache();
          if (!context.mounted) return;
          context.push(
            '/collections/create?parent=${widget.collectionId}',
            extra: parent,
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.create_new_folder_outlined),
      );
    }
    if (_fabExtended) {
      return FloatingActionButton.extended(
        heroTag: 'items_list_fab_add',
        onPressed: () async {
          final router = GoRouter.of(context);
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !context.mounted) return;
          router.push(
            '/collections/${widget.collectionId}/items/create',
            extra: widget.collectionName,
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add link'),
      );
    }
    return FloatingActionButton(
      heroTag: 'items_list_fab_add',
      onPressed: () async {
        final router = GoRouter.of(context);
        final ok = await DayPassGate.check(context, ref);
        if (!ok || !context.mounted) return;
        router.push(
          '/collections/${widget.collectionId}/items/create',
          extra: widget.collectionName,
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  List<Widget> _buildHubTabs(
      ItemsState state, int foldersCount, int linksCount) {
    return [
      Tab(text: 'Folders ($foldersCount)'),
      Tab(text: 'Links (${_linksTabCountLabel(state, linksCount)})'),
    ];
  }

  List<Widget> _buildHubTabViews({
    required Widget childrenTab,
    required Widget urlsTab,
  }) {
    if (widget.isRoot) {
      return [childrenTab];
    }
    return [childrenTab, urlsTab];
  }

  bool _shouldShowFab({
    required ItemsState state,
    required List<Collection> childCollections,
    required bool isFoldersTab,
  }) {
    if (isFoldersTab) {
      // Empty-state has its own primary CTA.
      return childCollections.isNotEmpty;
    }
    if (state.urlsDataPhase != UrlsDataPhase.loaded) {
      return true;
    }
    // "No links yet" shows the primary empty-state CTA.
    return state.items.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsNotifierProvider(widget.collectionId));
    final collectionsAsync = ref.watch(collectionsListProvider);
    final uiState = ref.watch(itemsHubUiNotifierProvider(widget.collectionId));

    final titleText = widget.collectionName ?? 'Collection Items';
    final primary = Theme.of(context).colorScheme.primary;

    final itemsState = itemsAsync.valueOrNull;
    // While items are still loading, default to Folders — null must not map to Links (index 1).
    final initialTabIndex = widget.isRoot
        ? 0
        : (itemsState == null
            ? 0
            : (itemsState.activeTab == UnifiedTab.childCollections ? 0 : 1));

    ref.listen<AsyncValue<ItemsState>>(
      itemsNotifierProvider(widget.collectionId),
      (previous, next) {
        next.whenOrNull(
          data: (st) {
            if (st.urlsDataPhase != UrlsDataPhase.notStarted) return;
            final c = _hubTabController;
            if (c == null || c.index != 1 || c.indexIsChanging) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _onHubTabControllerChanged();
            });
          },
        );
      },
    );

    return DefaultTabController(
      length: widget.isRoot ? 1 : 2,
      initialIndex: initialTabIndex,
      child: Builder(
        builder: (tabContext) {
          // Important: `tabContext` is under `DefaultTabController`, so
          // `DefaultTabController.of(...)` cannot crash.
          final tabController = DefaultTabController.of(tabContext);
          _syncHubTabController(tabController);
          final theme = Theme.of(tabContext);
          final stateForFab = itemsAsync.valueOrNull;
          final childCollectionsForFab = (collectionsAsync.valueOrNull
                  ?.where((collection) =>
                      collection.parentId == widget.collectionId &&
                      !collection.isDeleted &&
                      (uiState.childIncludeArchived || !collection.isArchived))
                  .toList() ??
              const <Collection>[]);
          final isFoldersTabForFab = widget.isRoot || tabController.index == 0;
          final allowFab = stateForFab != null &&
              _shouldShowFab(
                state: stateForFab,
                childCollections: childCollectionsForFab,
                isFoldersTab: isFoldersTabForFab,
              );
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            floatingActionButton: itemsAsync.hasValue && _fabVisible && allowFab
                ? AnimatedBuilder(
                    animation: tabController,
                    builder: (_, __) => AnimatedSwitcher(
                      duration: _animMs,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child:
                          _buildTabFab(tabContext, tabController, itemsAsync) ??
                              const SizedBox.shrink(),
                    ),
                  )
                : null,
            body: itemsAsync.when(
              data: (state) {
                Collection? currentCollection = _currentCollectionFromCache();
                final list = collectionsAsync.valueOrNull;
                final childCollections = list
                        ?.where((collection) =>
                            collection.parentId == widget.collectionId &&
                            !collection.isDeleted &&
                            (uiState.childIncludeArchived ||
                                !collection.isArchived) &&
                            (uiState.childSelectedCategories.isEmpty ||
                                uiState.childSelectedCategories.contains(
                                  collection.category,
                                )) &&
                            (uiState.childUpdatedAfter == null ||
                                !collection.updatedAt
                                    .isBefore(uiState.childUpdatedAfter!)) &&
                            (uiState.childUpdatedBefore == null ||
                                !collection.updatedAt
                                    .isAfter(uiState.childUpdatedBefore!)))
                        .toList() ??
                    const <Collection>[];

                if (!widget.isRoot &&
                    !_hasAppliedCollectionDefaults &&
                    currentCollection != null) {
                  _hasAppliedCollectionDefaults = true;
                  final mappedViewMode =
                      _viewModeFromCollection(currentCollection.itemsLayout);
                  final mappedSortOption = _sortOptionFromCollection(
                      currentCollection.itemsSortDefault);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final notifier = ref.read(
                        itemsNotifierProvider(widget.collectionId).notifier);
                    notifier.applyCollectionDisplayDefaults(
                      viewMode: mappedViewMode,
                      sortOption: mappedSortOption,
                    );
                    // Preload Links in the background (not only when user taps Links tab).
                    // Runs after defaults so the first query uses collection sort/layout prefs.
                    final phase = ref
                        .read(itemsNotifierProvider(widget.collectionId))
                        .valueOrNull
                        ?.urlsDataPhase;
                    if (phase == UrlsDataPhase.loaded) {
                      unawaited(notifier.refetchUrlsWithCurrentFilters());
                    } else {
                      unawaited(notifier.ensureUrlsLoaded());
                    }
                  });
                } else if (!widget.isRoot &&
                    !_hasAppliedCollectionDefaults &&
                    currentCollection == null &&
                    state.urlsDataPhase == UrlsDataPhase.notStarted &&
                    _urlsCollectionCacheWaitFrames <
                        _maxUrlsCollectionCacheWaits) {
                  _urlsCollectionCacheWaitFrames++;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {});
                  });
                } else if (!widget.isRoot &&
                    !_hasAppliedCollectionDefaults &&
                    currentCollection == null &&
                    state.urlsDataPhase == UrlsDataPhase.notStarted &&
                    _urlsCollectionCacheWaitFrames >=
                        _maxUrlsCollectionCacheWaits &&
                    !_urlsEmergencyPrefetchWithoutCollection) {
                  // Collection never resolved from cache in time; preload with notifier defaults.
                  // If collection appears later, [_hasAppliedCollectionDefaults] still false so
                  // collection sort/layout prefs are applied then.
                  _urlsEmergencyPrefetchWithoutCollection = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    unawaited(ref
                        .read(
                            itemsNotifierProvider(widget.collectionId).notifier)
                        .ensureUrlsLoaded());
                  });
                }

                final filteredChildCollections = _sortChildCollections(
                  _filterChildCollectionsBySearch(
                    childCollections,
                    uiState.childSearchQuery,
                  ),
                  uiState.childFolderSort,
                );

                final urlsTab = widget.isRoot
                    ? const SizedBox.shrink()
                    : _buildUrlsTab(
                        state: state,
                        currentCollection: currentCollection,
                        uiState: uiState,
                      );

                final childrenTab = NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    _onScrollUpdate(n);
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(collectionsListProvider);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        _buildChildFoldersToolbarSliver(
                          currentCollection,
                          uiState,
                        ),
                        _buildChildCollectionsContentSliver(
                          filteredChildCollections,
                          childCollections,
                          currentCollection,
                        ),
                      ],
                    ),
                  ), // RefreshIndicator
                ); // NotificationListener

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        pinned: false,
                        floating: true,
                        snap: true,
                        automaticallyImplyLeading: false,
                        scrolledUnderElevation: innerBoxIsScrolled ? 2 : 0,
                        elevation: innerBoxIsScrolled ? 2 : 0,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        surfaceTintColor: Colors.transparent,
                        leading: tabContext.canPop()
                            ? IconButton(
                                icon: Icon(Icons.arrow_back, color: primary),
                                onPressed: () => tabContext.pop(),
                              )
                            : null,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.more_vert, color: primary),
                            onPressed: () => _showCollectionActionsBottomSheet(
                              tabController: tabController,
                            ),
                          ),
                        ],
                        // stretch: true,
                        expandedHeight: 140,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: SafeArea(
                            bottom: false,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 56,
                                  right: 16,
                                  bottom: 52,
                                  // top: 8,
                                ),
                                child: collectionsAsync.maybeWhen(
                                  data: (cols) => _buildHubHeaderContent(
                                    cols,
                                    currentCollection,
                                    primary,
                                    childCollections.length,
                                  ),
                                  orElse: () => Text(
                                    titleText,
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottom: widget.isRoot
                            ? null
                            : PreferredSize(
                                preferredSize: const Size.fromHeight(48),
                                child: TabBar(
                                  controller: tabController,
                                  labelColor: primary,
                                  indicatorWeight: 2,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  unselectedLabelColor:
                                      theme.colorScheme.onSurfaceVariant,
                                  onTap: (index) {
                                    final tab = index == 0
                                        ? UnifiedTab.childCollections
                                        : UnifiedTab.urls;
                                    ref
                                        .read(itemsNotifierProvider(
                                                widget.collectionId)
                                            .notifier)
                                        .setActiveTab(tab);
                                  },
                                  tabs: _buildHubTabs(
                                    state,
                                    filteredChildCollections.length,
                                    state.items.length,
                                  ),
                                ),
                              ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: tabController,
                    children: _buildHubTabViews(
                      childrenTab: childrenTab,
                      urlsTab: urlsTab,
                    ),
                  ),
                );
              },
              loading: () => const ItemsListSkeleton(),
              error: (err, stack) => AppErrorState(
                error: err,
                title: 'Could not load links',
                onRetry: () => ref.invalidate(
                  itemsNotifierProvider(widget.collectionId),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  UrlViewMode _childViewModeFromCollection(String childLayout) {
    return _viewModeFromCollection(childLayout);
  }

  String _linksTabCountLabel(ItemsState state, int filteredCount) {
    switch (state.urlsDataPhase) {
      case UrlsDataPhase.notStarted:
        return '—';
      case UrlsDataPhase.loading:
        return '…';
      case UrlsDataPhase.loaded:
      case UrlsDataPhase.error:
        return '$filteredCount';
    }
  }

  Widget _buildUrlsTab({
    required ItemsState state,
    required Collection? currentCollection,
    required ItemsHubUiState uiState,
  }) {
    Future<void> onRefresh() async {
      ref.invalidate(collectionsListProvider);
      await ref
          .read(itemsNotifierProvider(widget.collectionId).notifier)
          .refresh();
    }

    switch (state.urlsDataPhase) {
      case UrlsDataPhase.notStarted:
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Saved links load when you open this tab.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case UrlsDataPhase.loading:
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildUrlsToolbarSliver(state, currentCollection, uiState),
              _buildUrlsLoadingSkeletonSliver(),
            ],
          ),
        );
      case UrlsDataPhase.error:
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildUrlsToolbarSliver(state, currentCollection, uiState),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.urlsErrorMessage ?? 'Could not load links',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            ref
                                .read(itemsNotifierProvider(widget.collectionId)
                                    .notifier)
                                .ensureUrlsLoaded(forceRefresh: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case UrlsDataPhase.loaded:
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            _onScrollUpdate(n);
            if (n is! ScrollUpdateNotification) return false;
            if (n.metrics.maxScrollExtent <= 0) return false;
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              ref
                  .read(itemsNotifierProvider(widget.collectionId).notifier)
                  .fetchNextPage();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (uiState.isReorderMode) _buildReorderBannerSliver(),
                _buildUrlsToolbarSliver(state, currentCollection, uiState),
                ..._buildItemSlivers(state),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 88),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildReorderBannerSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.primary.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.drag_handle_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Drag to reorder links. Use the menu to finish.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlsLoadingSkeletonSliver() {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      sliver: SliverList.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          height: 74,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlsToolbarSliver(
    ItemsState state,
    Collection? collection,
    ItemsHubUiState uiState,
  ) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    final filterBadge = _urlsFiltersDifferFromDefaults(state, uiState);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(_radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final uiNotifier = ref.read(
                    itemsHubUiNotifierProvider(widget.collectionId).notifier);
                final searchField = TextFormField(
                  initialValue: uiState.urlSearchQuery,
                  onChanged: (value) {
                    uiNotifier.updateUrlSearchQuery(value);
                    _scheduleUrlQueryRefetch();
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                    hintText: 'Search links…',
                    border: InputBorder.none,
                    // prefixIcon: Icon(
                    //   Icons.search_rounded,
                    //   color: theme.colorScheme.onSurfaceVariant,
                    // ),
                    suffixIcon: uiState.urlSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              uiNotifier.clearUrlSearchQuery();
                              ref
                                  .read(
                                      itemsNotifierProvider(widget.collectionId)
                                          .notifier)
                                  .refetchUrlsWithCurrentFilters();
                            },
                          )
                        : null,
                  ),
                );
                final filterButton = IconButton(
                  tooltip: 'Filter & sort',
                  onPressed: _openUrlsFiltersScreen,
                  icon: Badge(
                    isLabelVisible: filterBadge,
                    smallSize: 8,
                    child: Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
                final dateButton = PopupMenuButton<_LinksQuickDate>(
                  tooltip: 'Quick date',
                  onSelected: (date) {
                    final now = DateTime.now();
                    switch (date) {
                      case _LinksQuickDate.all:
                        uiNotifier.setUrlSavedAfter(null);
                        uiNotifier.setUrlSavedBefore(null);
                        break;
                      case _LinksQuickDate.last7Days:
                        uiNotifier.setUrlSavedAfter(
                          now.subtract(const Duration(days: 7)),
                        );
                        uiNotifier.setUrlSavedBefore(null);
                        break;
                      case _LinksQuickDate.last30Days:
                        uiNotifier.setUrlSavedAfter(
                          now.subtract(const Duration(days: 30)),
                        );
                        uiNotifier.setUrlSavedBefore(null);
                        break;
                      case _LinksQuickDate.thisYear:
                        uiNotifier.setUrlSavedAfter(DateTime(now.year, 1, 1));
                        uiNotifier.setUrlSavedBefore(null);
                        break;
                    }
                    ref
                        .read(
                            itemsNotifierProvider(widget.collectionId).notifier)
                        .refetchUrlsWithCurrentFilters();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _LinksQuickDate.all,
                      child: Text('All dates'),
                    ),
                    PopupMenuItem(
                      value: _LinksQuickDate.last7Days,
                      child: Text('Last 7 days'),
                    ),
                    PopupMenuItem(
                      value: _LinksQuickDate.last30Days,
                      child: Text('Last 30 days'),
                    ),
                    PopupMenuItem(
                      value: _LinksQuickDate.thisYear,
                      child: Text('This year'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Badge(
                      isLabelVisible: uiState.urlSavedAfter != null ||
                          uiState.urlSavedBefore != null,
                      smallSize: 8,
                      child: Icon(
                        Icons.date_range_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
                final sortButton = PopupMenuButton<UrlSortOption>(
                  tooltip: 'Quick sort',
                  onSelected: (sort) {
                    ref
                        .read(
                            itemsNotifierProvider(widget.collectionId).notifier)
                        .setSortOption(sort);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: UrlSortOption.position,
                      child: Text('Manual order'),
                    ),
                    PopupMenuItem(
                      value: UrlSortOption.dateAdded,
                      child: Text('Recently added'),
                    ),
                    PopupMenuItem(
                      value: UrlSortOption.dateEdited,
                      child: Text('Recently edited'),
                    ),
                    PopupMenuItem(
                      value: UrlSortOption.mostVisited,
                      child: Text('Most visited'),
                    ),
                    PopupMenuItem(
                      value: UrlSortOption.alphabeticalAsc,
                      child: Text('Alphabetical A-Z'),
                    ),
                    PopupMenuItem(
                      value: UrlSortOption.alphabeticalDesc,
                      child: Text('Alphabetical Z-A'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
                return Row(
                  children: [
                    Expanded(
                      child: searchField,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [filterButton, dateButton, sortButton],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildFoldersToolbarSliver(
    Collection? currentCollection,
    ItemsHubUiState uiState,
  ) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    final filterBadge = _childFiltersActive(uiState);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(_radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final uiNotifier = ref.read(
                    itemsHubUiNotifierProvider(widget.collectionId).notifier);
                final searchField = TextFormField(
                  initialValue: uiState.childSearchQuery,
                  onChanged: uiNotifier.updateChildSearchQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search folders…',
                    border: InputBorder.none,
                    // prefixIcon: Icon(
                    //   Icons.search_rounded,
                    //   color: theme.colorScheme.onSurfaceVariant,
                    // ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                    suffixIcon: uiState.childSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              uiNotifier.clearChildSearchQuery();
                            },
                          )
                        : null,
                  ),
                );
                final filterButton = IconButton(
                  tooltip: 'Folder filters & layout',
                  onPressed: _openFoldersFiltersScreen,
                  icon: Badge(
                    isLabelVisible: filterBadge,
                    smallSize: 8,
                    child: Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
                final sortButton = PopupMenuButton<ChildFolderSort>(
                  tooltip: 'Quick sort',
                  onSelected: (sort) {
                    uiNotifier.setChildFolderSort(sort);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: ChildFolderSort.titleAsc,
                      child: Text('Title A-Z'),
                    ),
                    PopupMenuItem(
                      value: ChildFolderSort.titleDesc,
                      child: Text('Title Z-A'),
                    ),
                    PopupMenuItem(
                      value: ChildFolderSort.itemCountDesc,
                      child: Text('Most links'),
                    ),
                    PopupMenuItem(
                      value: ChildFolderSort.createdDesc,
                      child: Text('Recently added'),
                    ),
                    PopupMenuItem(
                      value: ChildFolderSort.updatedDesc,
                      child: Text('Recently updated'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
                return Row(
                  children: [
                    Expanded(child: searchField),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [filterButton, sortButton],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildCollectionsEmptySliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'No subfolders yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a folder to organize links inside this list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  final parent = _currentCollectionFromCache();
                  context.push(
                    '/collections/create?parent=${widget.collectionId}',
                    extra: parent,
                  );
                },
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New subfolder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildCollectionsContentSliver(
    List<Collection> filtered,
    List<Collection> all,
    Collection? currentCollection,
  ) {
    final childLayoutMode = currentCollection == null
        ? UrlViewMode.list
        : _childViewModeFromCollection(
            currentCollection.childCollectionsLayout);

    if (all.isEmpty) {
      return _buildChildCollectionsEmptySliver();
    }

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No folders match your search',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref
                        .read(itemsHubUiNotifierProvider(widget.collectionId)
                            .notifier)
                        .clearChildSearchQuery();
                  },
                  child: const Text('Clear search'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (childLayoutMode == UrlViewMode.list) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final child = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CollectionListTile(
                  collection: child,
                  onTap: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push('/collections/${child.id}',
                        extra: child.title);
                  },
                  onLongPress: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push('/collections/${child.id}/edit');
                  },
                ),
              );
            },
            childCount: filtered.length,
          ),
        ),
      );
    }

    final compact = childLayoutMode == UrlViewMode.icons;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final m = _childFoldersGridMetrics(
            constraints.crossAxisExtent,
            compact: compact,
          );
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final child = filtered[index];
                return CollectionCard(
                  collection: child,
                  compact: compact,
                  onTap: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push('/collections/${child.id}',
                        extra: child.title);
                  },
                  onLongPress: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push('/collections/${child.id}/edit');
                  },
                );
              },
              childCount: filtered.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: m.crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: m.childAspectRatio,
            ),
          );
        },
      ),
    );
  }

  UrlViewMode _viewModeFromCollection(String itemsLayout) {
    return switch (itemsLayout) {
      CollectionLayoutMode.grid => UrlViewMode.cards,
      CollectionLayoutMode.compactGrid => UrlViewMode.icons,
      _ => UrlViewMode.list,
    };
  }

  UrlSortOption _sortOptionFromCollection(String sortDefault) {
    return switch (sortDefault) {
      CollectionItemsSortDefault.addedDesc => UrlSortOption.dateAdded,
      CollectionItemsSortDefault.lastOpenedDesc => UrlSortOption.dateEdited,
      _ => UrlSortOption.position,
    };
  }

  List<Widget> _buildItemSlivers(ItemsState state) {
    final items = state.items;
    final uiState = ref.read(itemsHubUiNotifierProvider(widget.collectionId));
    if (items.isEmpty) {
      if (uiState.urlSearchQuery.trim().isNotEmpty ||
          _urlsExtrasActive(uiState)) {
        return [_buildEmptyItemsSliver(mode: _EmptyLinksMode.noSearchMatches)];
      }
      if (state.statusFilter != null) {
        return [_buildEmptyItemsSliver(mode: _EmptyLinksMode.noFilterMatches)];
      }
      return [_buildEmptyItemsSliver(mode: _EmptyLinksMode.noLinks)];
    }

    if (uiState.isReorderMode && state.viewMode == UrlViewMode.list) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverReorderableList(
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                key: ValueKey(item.id),
                leading: UrlFaviconTile(item: item, size: 26),
                title: Text(item.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(item.status),
                      size: 12,
                      color: _getStatusColor(item.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(item.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(item.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle_rounded),
                ),
              );
            },
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              final reordered = List<Item>.from(items);
              final moved = reordered.removeAt(oldIndex);
              final adjustedNewIndex =
                  newIndex > oldIndex ? newIndex - 1 : newIndex;
              reordered.insert(adjustedNewIndex, moved);
              final orderedIds = reordered.map((e) => e.id).toList();

              ref.read(itemsHubNotifierProvider.notifier).reorderItems(
                    collectionId: widget.collectionId,
                    orderedIds: orderedIds,
                  );
            },
          ),
        ),
      ];
    }

    if (state.viewMode == UrlViewMode.list) {
      return [
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: _buildListItem(item),
            );
          },
        ),
      ];
    }

    if (state.viewMode == UrlViewMode.icons) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final m = _linksIconsGridMetrics(constraints.crossAxisExtent);
              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return _buildIconItem(item);
                }, childCount: items.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: m.crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: m.childAspectRatio,
                ),
              );
            },
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final m = _linksCardsGridMetrics(constraints.crossAxisExtent);
            return SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return _buildCardItem(item);
              }, childCount: items.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: m.crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: m.childAspectRatio,
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildEmptyItemsSliver({required _EmptyLinksMode mode}) {
    final theme = Theme.of(context);
    late final String title;
    late final String subtitle;
    late final IconData icon;
    switch (mode) {
      case _EmptyLinksMode.noLinks:
        title = 'No links yet';
        subtitle =
            'Add your first URL to start building this list, or tap + Add link.';
        icon = Icons.bookmark_border_rounded;
        break;
      case _EmptyLinksMode.noFilterMatches:
        title = 'Nothing matches these filters';
        subtitle =
            'Try changing status or sort in Filter & sort, or clear filters.';
        icon = Icons.filter_alt_off_outlined;
        break;
      case _EmptyLinksMode.noSearchMatches:
        title = 'No links match your search';
        subtitle = 'Try another keyword or clear the search box.';
        icon = Icons.search_off_rounded;
        break;
    }

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              if (mode == _EmptyLinksMode.noSearchMatches) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref
                        .read(itemsHubUiNotifierProvider(widget.collectionId)
                            .notifier)
                        .clearUrlSearchQuery();
                  },
                  child: const Text('Clear search'),
                ),
              ],
              if (mode == _EmptyLinksMode.noFilterMatches) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final notifier = ref.read(
                        itemsNotifierProvider(widget.collectionId).notifier);
                    await notifier.setStatusFilter(null);
                  },
                  child: const Text('Show all statuses'),
                ),
              ],
              if (mode == _EmptyLinksMode.noLinks) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    router.push(
                      '/collections/${widget.collectionId}/items/create',
                      extra: widget.collectionName,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add link'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Item item) {
    final domain = _extractDomain(item.link ?? '');
    final updatedAgo = _relativeAgo(item.updatedAt);
    final tags = (item.tags ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    return Dismissible(
      key: ValueKey('item_${item.id}'),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(_radiusMd),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child:
            const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(_radiusMd),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (item.status == ItemStatus.unread) {
            await ref.read(itemsHubNotifierProvider.notifier).markReadAndTrack(
                  collectionId: widget.collectionId,
                  itemId: item.id,
                );
          }
          return false;
        }
        _confirmDelete(context, item.id);
        return false;
      },
      child: InkWell(
        onTap: () => _openItemLink(item),
        onLongPress: () => _showItemOptions(context, item),
        borderRadius: BorderRadius.circular(_radiusMd),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusMd),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.45),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: tags.isNotEmpty ? 76 : 60,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                UrlFaviconTile(item: item, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$domain · $updatedAgo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...tags.take(3).map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(tag,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              ),
                          if (tags.length > 3)
                            Text('+${tags.length - 3}',
                                style: const TextStyle(fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item.status)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _getStatusText(item.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _getStatusColor(item.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (item.isPinned)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, right: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                IconButton(
                  icon:
                      Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
                  onPressed: () => _showItemOptions(context, item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeAgo(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  Widget _buildIconItem(Item item) {
    return UrlIconLinkTile(
      item: item,
      onTap: () => _openItemLink(item),
      onLongPress: () => _showItemOptions(context, item),
    );
  }

  Widget _buildCardItem(Item item) {
    return UrlPreviewTile(
      item: item,
      onTap: () => _openItemLink(item),
      onLongPress: () => _showItemOptions(context, item),
    );
  }

  Future<void> _markReadIfUnread(Item item) async {
    if (item.status != ItemStatus.unread) return;
    await ref.read(itemsHubNotifierProvider.notifier).markReadAndTrack(
          collectionId: widget.collectionId,
          itemId: item.id,
        );
    final updatedItem = item.copyWith(
      status: ItemStatus.read,
      updatedAt: DateTime.now(),
    );
    ref
        .read(itemsNotifierProvider(widget.collectionId).notifier)
        .updateItemInState(updatedItem);
  }

  /// Opens the in-app item detail screen (former default tap).
  Future<void> _openItemDetail(Item item) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;

    await _markReadIfUnread(item);

    if (!mounted) return;
    context.push('/collections/${widget.collectionId}/items/${item.id}');
  }

  Uri? _httpUriFromItem(Item item) {
    final raw = item.link?.trim();
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.host.isEmpty && uri.scheme != 'file')) {
      return null;
    }
    return uri;
  }

  Future<void> _launchUriForItem(Uri uri, Item item) async {
    final collection = _currentCollectionFromCache();
    final resolved = _linkTapOpenOverride ??
        effectiveOpenLinksIn(
          itemOpenLinksInOverride: item.openLinksInOverride,
          collectionOpenLinksIn: collection?.openLinksIn,
        );
    final launchMode = resolved == CollectionOpenLinksIn.externalBrowser
        ? LaunchMode.externalApplication
        : LaunchMode.inAppBrowserView;

    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: launchMode);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  /// Opens the URL using list tap preference, then per-link override, then folder default.
  Future<void> _openItemLink(Item item) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;

    await _markReadIfUnread(item);
    if (!mounted) return;

    final uri = _httpUriFromItem(item);
    if (uri == null) {
      final raw = item.link?.trim();
      if (raw == null || raw.isEmpty) {
        context.push('/collections/${widget.collectionId}/items/${item.id}');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }

    await _launchUriForItem(uri, item);
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return 'Unread';
      case ItemStatus.read:
        return 'Read';
      case ItemStatus.archived:
        return 'Archived';
    }
  }

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Icons.schedule_rounded;
      case ItemStatus.read:
        return Icons.check_circle_outline_rounded;
      case ItemStatus.archived:
        return Icons.star_border_rounded;
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Colors.orange;
      case ItemStatus.read:
        return Colors.green;
      case ItemStatus.archived:
        return AppColors.primary;
    }
  }

  String _extractDomain(String rawUrl) {
    if (rawUrl.trim().isEmpty) return '';
    final normalized =
        rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
            ? rawUrl
            : 'https://$rawUrl';
    try {
      final host = Uri.parse(normalized).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return rawUrl;
    }
  }

  void _showItemOptions(BuildContext context, Item item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final sheetMuted =
        Theme.of(context).colorScheme.onSurfaceVariant;
    final domain = _extractDomain(item.link ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: UrlFaviconTile(item: item, size: 24),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.article_outlined, color: textColor),
                  title: Text(
                    'View details',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    await _openItemDetail(item);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'When you tap a link',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sheetMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: _linkTapOpenOverride,
                            hint: Text(
                              'Smart (link + folder)',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Smart (link + folder)',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              DropdownMenuItem<String?>(
                                value: CollectionOpenLinksIn.inApp,
                                child: Text(
                                  'Always in app',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              DropdownMenuItem<String?>(
                                value: CollectionOpenLinksIn.externalBrowser,
                                child: Text(
                                  'Always in browser',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _linkTapOpenOverride = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.open_in_new_rounded, color: textColor),
                  title: Text(
                    'Open link now',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Uses the option above',
                    style: TextStyle(
                      fontSize: 12,
                      color: sheetMuted,
                    ),
                  ),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    nav.pop();
                    if (!mounted) return;
                    final ok = await DayPassGate.check(this.context, ref);
                    if (!ok || !mounted) return;
                    await _markReadIfUnread(item);
                    if (!mounted) return;
                    final uri = _httpUriFromItem(item);
                    if (uri == null) {
                      final raw = item.link?.trim();
                      if (raw == null || raw.isEmpty) {
                        if (!mounted) return;
                        this.context.push(
                            '/collections/${widget.collectionId}/items/${item.id}');
                        return;
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Invalid link')),
                      );
                      return;
                    }
                    await _launchUriForItem(uri, item);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.content_copy_rounded, color: textColor),
                  title: Text(
                    'Copy URL',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    context.pop();
                    final link = item.link ?? '';
                    if (link.isEmpty) return;
                    await Clipboard.setData(ClipboardData(text: link));
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('URL copied')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.push_pin_outlined, color: textColor),
                  title: Text(
                    item.isPinned ? 'Unpin from top' : 'Pin to top',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    context.pop();
                    await ref.read(itemsHubNotifierProvider.notifier).togglePin(
                          collectionId: widget.collectionId,
                          itemId: item.id,
                        );
                  },
                ),
                ListTile(
                  leading: Icon(
                    item.status == ItemStatus.read
                        ? Icons.mark_email_unread_outlined
                        : Icons.mark_email_read_outlined,
                    color: textColor,
                  ),
                  title: Text(
                    item.status == ItemStatus.read
                        ? 'Mark unread'
                        : 'Mark as read',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    context.pop();
                    if (item.status == ItemStatus.unread) {
                      await ref
                          .read(itemsHubNotifierProvider.notifier)
                          .markReadAndTrack(
                            collectionId: widget.collectionId,
                            itemId: item.id,
                          );
                    } else {
                      await ref
                          .read(itemsHubNotifierProvider.notifier)
                          .toggleReadStatus(
                            collectionId: widget.collectionId,
                            item: item,
                          );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder_open_rounded, color: textColor),
                  title: Text(
                    'Move to collection',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    context.pop();
                    await _showMoveToCollectionSheet(item);
                  },
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Icon(
                    item.status == ItemStatus.archived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: textColor,
                  ),
                  title: Text(
                    item.status == ItemStatus.archived
                        ? 'Unarchive'
                        : 'Archive',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    context.pop();
                    await ref
                        .read(itemsHubNotifierProvider.notifier)
                        .toggleArchive(
                          collectionId: widget.collectionId,
                          item: item,
                        );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit, color: textColor),
                  title: Text('Edit',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    context.pop();
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push(
                        '/collections/${widget.collectionId}/items/${item.id}/edit');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete link',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    context.pop();
                    _confirmDelete(context, item.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(itemsHubNotifierProvider.notifier).deleteItem(
                    collectionId: widget.collectionId,
                    itemId: itemId,
                  );
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoveToCollectionSheet(Item item) async {
    final collections =
        (ref.read(collectionsListProvider).valueOrNull ?? const <Collection>[])
            .where((c) => !c.isDeleted && c.id != widget.collectionId)
            .toList();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(collection.title),
                subtitle: Text(collection.category),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref.read(itemsHubNotifierProvider.notifier).moveItem(
                        sourceCollectionId: widget.collectionId,
                        item: item,
                        targetCollectionId: collection.id,
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Moved to ${collection.title}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
