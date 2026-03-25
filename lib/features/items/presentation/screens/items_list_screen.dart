import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../domain/entities/item.dart';
import '../providers/items_providers.dart';
import '../widgets/url_favicon_tile.dart';
import '../widgets/url_preview_tile.dart';
import '../../../../core/config/app_config.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/collection_display_defaults.dart';

class ItemsListScreen extends ConsumerStatefulWidget {
  final String collectionId;
  final String? collectionName;

  const ItemsListScreen({
    super.key,
    required this.collectionId,
    this.collectionName,
  });

  @override
  ConsumerState<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends ConsumerState<ItemsListScreen> {
  bool _isReorderMode = false;
  bool _hasAppliedCollectionDefaults = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(collectionsRepositoryProvider)
            .recordCollectionAccess(widget.collectionId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(itemsNotifierProvider(widget.collectionId).notifier)
          .fetchNextPage();
    }
  }

  void _showCollectionOptionsBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white30 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Collection Actions
                    ListTile(
                      leading: Icon(Icons.edit_outlined, color: textColor),
                      title: Text('Edit Collection',
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        context.pop();
                        context
                            .push('/collections/${widget.collectionId}/edit');
                      },
                    ),
                    // Share Collection — hidden until Sprint 10 social features ship
                    if (AppConfig.instance.isDev)
                      ListTile(
                        leading: Icon(Icons.share_outlined, color: textColor),
                        title: Text('Share Collection',
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500)),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sharing coming soon!',
                              ),
                            ),
                          );
                        },
                      ),
                    Divider(
                        height: 32,
                        color: isDark ? Colors.white24 : Colors.grey[300]),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsNotifierProvider(widget.collectionId));
    final collectionsAsync = ref.watch(collectionsListProvider);

    final titleText = widget.collectionName ?? 'Collection Items';
    final primary = Theme.of(context).colorScheme.primary;

    final itemsState = itemsAsync.valueOrNull;
    final initialTabIndex = itemsState?.activeTab == UnifiedTab.childCollections ? 0 : 1;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Builder(
        builder: (tabContext) {
          // Important: `tabContext` is under `DefaultTabController`, so
          // `DefaultTabController.of(...)` cannot crash.
          final tabController = DefaultTabController.of(tabContext);
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: primary),
              title: collectionsAsync.maybeWhen(
                data: (collections) =>
                    _buildBreadcrumbTitle(collections, primary),
                orElse: () => Text(
                  titleText,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              bottom: TabBar(
                onTap: (index) {
                  final tab = index == 0
                      ? UnifiedTab.childCollections
                      : UnifiedTab.urls;
                  ref
                      .read(itemsNotifierProvider(widget.collectionId).notifier)
                      .setActiveTab(tab);
                },
                tabs: const [
                  Tab(text: 'Child Collections'),
                  Tab(text: 'URLs'),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.create_new_folder_outlined, color: primary),
                  onPressed: () {
                    Collection? parent;
                    final list = collectionsAsync.valueOrNull;
                    if (list != null) {
                      for (final c in list) {
                        if (c.id == widget.collectionId) {
                          parent = c;
                          break;
                        }
                      }
                    }
                    context.push(
                      '/collections/create?parent=${widget.collectionId}',
                      extra: parent,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: primary),
                  onPressed: _showCollectionOptionsBottomSheet,
                ),
                IconButton(
                  icon: Icon(
                    _isReorderMode
                        ? Icons.check_circle_outline
                        : Icons.reorder,
                    color: primary,
                  ),
                  onPressed: () {
                    final isUrlsTab = tabController.index == 1;
                    if (!isUrlsTab) {
                      tabController.animateTo(1);
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setActiveTab(UnifiedTab.urls);
                      return;
                    }

                    setState(() => _isReorderMode = !_isReorderMode);
                    if (!_isReorderMode) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .refresh();
                    }
                  },
                ),
              ],
            ),
            bottomNavigationBar: (itemsState?.activeTab ?? UnifiedTab.urls) ==
                    UnifiedTab.urls
                ? _buildBottomAddButton()
                : null,
            body: itemsAsync.when(
              data: (state) {
                Collection? currentCollection;
                final list = collectionsAsync.valueOrNull;
                final childCollections = list
                        ?.where((collection) =>
                            collection.parentId == widget.collectionId &&
                            !collection.isDeleted &&
                            !collection.isArchived)
                        .toList() ??
                    const <Collection>[];

                if (list != null) {
                  for (final c in list) {
                    if (c.id == widget.collectionId) {
                      currentCollection = c;
                      break;
                    }
                  }
                }

                if (!_hasAppliedCollectionDefaults && currentCollection != null) {
                  _hasAppliedCollectionDefaults = true;
                  final mappedViewMode = _viewModeFromCollection(
                      currentCollection.itemsLayout);
                  final mappedSortOption = _sortOptionFromCollection(
                      currentCollection.itemsSortDefault);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(itemsNotifierProvider(widget.collectionId).notifier)
                        .setViewMode(mappedViewMode);
                    ref
                        .read(itemsNotifierProvider(widget.collectionId).notifier)
                        .setSortOption(mappedSortOption);
                  });
                }

                final urlsTab = RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(collectionsListProvider);
                    await ref
                        .read(itemsNotifierProvider(widget.collectionId).notifier)
                        .refresh();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildTopControlsSliver(state, currentCollection),
                      ..._buildItemSlivers(state),
                      if (state.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child:
                                Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 12),
                      ),
                    ],
                  ),
                );

                final childrenTab = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildChildTopControlsSliver(currentCollection),
                    _buildChildCollectionsContentSliver(
                      childCollections,
                      currentCollection,
                    ),
                  ],
                );

                return TabBarView(
                  children: [
                    childrenTab,
                    urlsTab,
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbTitle(List<Collection> collections, Color primary) {
    final byId = {for (final collection in collections) collection.id: collection};
    final trail = <Collection>[];
    var cursor = byId[widget.collectionId];
    while (cursor != null) {
      trail.insert(0, cursor);
      cursor = cursor.parentId == null ? null : byId[cursor.parentId!];
    }
    if (trail.isEmpty) {
      return Text(
        widget.collectionName ?? 'Collection Items',
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < trail.length; i++) ...[
            InkWell(
              onTap: () {
                final target = trail[i];
                if (target.id == widget.collectionId) return;
                context.push('/collections/${target.id}', extra: target.title);
              },
              child: Text(
                i == 0 ? 'Home/${trail[i].title}' : trail[i].title,
                style: TextStyle(
                  color: primary,
                  fontWeight: i == trail.length - 1
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (i < trail.length - 1)
              Text(' > ', style: TextStyle(color: primary, fontSize: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildChildCollectionsStrip(List<Collection> childCollections) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: childCollections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final child = childCollections[index];
          return InkWell(
            onTap: () => context.push('/collections/${child.id}', extra: child.title),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.iconName, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    child.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${child.itemCount} links',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
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

  Widget _buildChildTopControlsSliver(Collection? currentCollection) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.black54;
    final surfaceColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    final childLayoutMode = currentCollection == null
        ? UrlViewMode.list
        : _childViewModeFromCollection(currentCollection.childCollectionsLayout);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layout',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<UrlViewMode>(
              style: SegmentedButton.styleFrom(
                backgroundColor: surfaceColor,
                foregroundColor: secondaryTextColor,
                selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.2),
                selectedForegroundColor: AppColors.primary,
                side: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey[300]!,
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: UrlViewMode.list,
                  icon: Icon(Icons.view_list),
                  label: Text('List'),
                ),
                ButtonSegment(
                  value: UrlViewMode.cards,
                  icon: Icon(Icons.grid_view),
                  label: Text('Cards'),
                ),
                ButtonSegment(
                  value: UrlViewMode.icons,
                  icon: Icon(Icons.apps),
                  label: Text('Icons'),
                ),
              ],
              selected: {childLayoutMode},
              onSelectionChanged: (Set<UrlViewMode> newSelection) async {
                if (currentCollection == null) return;
                await _persistChildCollectionsLayout(
                  collection: currentCollection,
                  viewMode: newSelection.first,
                );
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCollectionTile(
    Collection child, {
    required bool compact,
  }) {
    final iconSize = compact ? 16.0 : 18.0;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: compact ? 13.0 : 14.0,
    );
    final countStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: compact ? 10.0 : 12.0,
    );

    return InkWell(
      onTap: () => context.push('/collections/${child.id}', extra: child.title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(compact ? 10 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(child.iconName, style: TextStyle(fontSize: iconSize)),
            const SizedBox(height: 6),
            Text(
              child.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            const SizedBox(height: 4),
            Text('${child.itemCount} links', style: countStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCollectionsEmptySliver() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text('No child collections'),
      ),
    );
  }

  Widget _buildChildCollectionsContentSliver(
    List<Collection> childCollections,
    Collection? currentCollection,
  ) {
    final childLayoutMode = currentCollection == null
        ? UrlViewMode.list
        : _childViewModeFromCollection(currentCollection.childCollectionsLayout);

    if (childCollections.isEmpty) {
      return _buildChildCollectionsEmptySliver();
    }

    if (childLayoutMode == UrlViewMode.list) {
      return SliverToBoxAdapter(child: _buildChildCollectionsStrip(childCollections));
    }

    final crossAxisCount = childLayoutMode == UrlViewMode.cards ? 2 : 3;
    final compact = childLayoutMode == UrlViewMode.icons;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final child = childCollections[index];
            return _buildChildCollectionTile(child, compact: compact);
          },
          childCount: childCollections.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: compact ? 0.9 : 0.85,
        ),
      ),
    );
  }

  Future<void> _persistChildCollectionsLayout({
    required Collection collection,
    required UrlViewMode viewMode,
  }) async {
    final layout = switch (viewMode) {
      UrlViewMode.list => CollectionLayoutMode.list,
      UrlViewMode.cards => CollectionLayoutMode.grid,
      UrlViewMode.icons => CollectionLayoutMode.compactGrid,
    };

    final updated = Collection(
      id: collection.id,
      ownerId: collection.ownerId,
      parentId: collection.parentId,
      isShared: collection.isShared,
      title: collection.title,
      description: collection.description,
      category: collection.category,
      colorHex: collection.colorHex,
      iconName: collection.iconName,
      iconJson: collection.iconJson,
      position: collection.position,
      isPinned: collection.isPinned,
      isArchived: collection.isArchived,
      isDeleted: collection.isDeleted,
      childCount: collection.childCount,
      createdAt: collection.createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: collection.lastAccessedAt,
      itemsLayout: collection.itemsLayout,
      childCollectionsLayout: layout,
      itemsSortDefault: collection.itemsSortDefault,
      openLinksIn: collection.openLinksIn,
      showLinkPreviews: collection.showLinkPreviews,
      itemCount: collection.itemCount,
    );

    await ref.read(collectionsRepositoryProvider).updateCollection(updated);
    ref.invalidate(collectionsListProvider);
  }

  Widget _buildTopControlsSliver(ItemsState state, Collection? collection) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.black54;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<UrlViewMode>(
              style: SegmentedButton.styleFrom(
                backgroundColor: surfaceColor,
                foregroundColor: secondaryTextColor,
                selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.2),
                selectedForegroundColor: AppColors.primary,
                side: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey[300]!,
                ),
              ),
              segments: const [
                ButtonSegment(
                    value: UrlViewMode.list,
                    icon: Icon(Icons.view_list),
                    label: Text('List')),
                ButtonSegment(
                    value: UrlViewMode.cards,
                    icon: Icon(Icons.grid_view),
                    label: Text('Cards')),
                ButtonSegment(
                    value: UrlViewMode.icons,
                    icon: Icon(Icons.apps),
                    label: Text('Icons')),
              ],
              selected: {state.viewMode},
              onSelectionChanged: (Set<UrlViewMode> newSelection) {
                final viewMode = newSelection.first;
                ref
                    .read(itemsNotifierProvider(widget.collectionId).notifier)
                    .setViewMode(viewMode);
                _persistCollectionDisplayDefaults(
                  collection: collection,
                  viewMode: viewMode,
                  sortOption: state.sortOption,
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: state.statusFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setStatusFilter(null);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Unread'),
                  selected: state.statusFilter == ItemStatus.unread,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setStatusFilter(ItemStatus.unread);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Read'),
                  selected: state.statusFilter == ItemStatus.read,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setStatusFilter(ItemStatus.read);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Position'),
                  selected: state.sortOption == UrlSortOption.position,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setSortOption(UrlSortOption.position);
                      _persistCollectionDisplayDefaults(
                        collection: collection,
                        viewMode: state.viewMode,
                        sortOption: UrlSortOption.position,
                      );
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Recently added'),
                  selected: state.sortOption == UrlSortOption.dateAdded,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setSortOption(UrlSortOption.dateAdded);
                      _persistCollectionDisplayDefaults(
                        collection: collection,
                        viewMode: state.viewMode,
                        sortOption: UrlSortOption.dateAdded,
                      );
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Recently edited'),
                  selected: state.sortOption == UrlSortOption.dateEdited,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(itemsNotifierProvider(widget.collectionId).notifier)
                          .setSortOption(UrlSortOption.dateEdited);
                      _persistCollectionDisplayDefaults(
                        collection: collection,
                        viewMode: state.viewMode,
                        sortOption: UrlSortOption.dateEdited,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _persistCollectionDisplayDefaults({
    required Collection? collection,
    required UrlViewMode viewMode,
    required UrlSortOption sortOption,
  }) async {
    if (collection == null) return;

    final layout = switch (viewMode) {
      UrlViewMode.list => CollectionLayoutMode.list,
      UrlViewMode.cards => CollectionLayoutMode.grid,
      UrlViewMode.icons => CollectionLayoutMode.compactGrid,
    };

    final sort = switch (sortOption) {
      UrlSortOption.position => CollectionItemsSortDefault.manual,
      UrlSortOption.dateAdded => CollectionItemsSortDefault.addedDesc,
      UrlSortOption.dateEdited => CollectionItemsSortDefault.lastOpenedDesc,
    };

    final updated = Collection(
      id: collection.id,
      ownerId: collection.ownerId,
      parentId: collection.parentId,
      isShared: collection.isShared,
      title: collection.title,
      description: collection.description,
      category: collection.category,
      colorHex: collection.colorHex,
      iconName: collection.iconName,
      iconJson: collection.iconJson,
      position: collection.position,
      isPinned: collection.isPinned,
      isArchived: collection.isArchived,
      isDeleted: collection.isDeleted,
      childCount: collection.childCount,
      createdAt: collection.createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: collection.lastAccessedAt,
      itemsLayout: layout,
      childCollectionsLayout: collection.childCollectionsLayout,
      itemsSortDefault: sort,
      openLinksIn: collection.openLinksIn,
      showLinkPreviews: collection.showLinkPreviews,
      itemCount: collection.itemCount,
    );

    await ref.read(collectionsRepositoryProvider).updateCollection(updated);
    ref.invalidate(collectionsListProvider);
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
    if (items.isEmpty) {
      return [_buildEmptyItemsSliver()];
    }

    if (_isReorderMode && state.viewMode == UrlViewMode.list) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverReorderableList(
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                key: ValueKey(item.id),
                leading: UrlFaviconTile(item: item, size: 26),
                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
              final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
              reordered.insert(adjustedNewIndex, moved);
              final orderedIds = reordered.map((e) => e.id).toList();

              ref
                  .read(reorderItemsUseCaseProvider)
                  .call(collectionId: widget.collectionId, orderedIds: orderedIds)
                  .then((_) {
                ref
                    .read(itemsNotifierProvider(widget.collectionId).notifier)
                    .refresh();
              });
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
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return _buildIconItem(item);
            }, childCount: items.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return _buildCardItem(item);
          }, childCount: items.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomAddButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              router.push(
                '/collections/${widget.collectionId}/items/create',
                extra: widget.collectionName,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            child: const Text('Add item'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyItemsSliver() {
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
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No links yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your first URL to start building this collection.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Item item) {
    return InkWell(
      onTap: () => _openItemAndTrack(item),
      onLongPress: () => _showItemOptions(context, item),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UrlFaviconTile(item: item, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(item.status),
                        size: 13,
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
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    )
                  else
                    Text(
                      _extractDomain(item.link ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
              onPressed: () => _showItemOptions(context, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(Item item) {
    return UrlPreviewTile(
      item: item,
      compact: true,
      onTap: () => _openItemAndTrack(item),
      onLongPress: () => _showItemOptions(context, item),
    );
  }

  Widget _buildCardItem(Item item) {
    return UrlPreviewTile(
      item: item,
      onTap: () => _openItemAndTrack(item),
      onLongPress: () => _showItemOptions(context, item),
    );
  }

  Future<void> _openItemAndTrack(Item item) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;

    if (item.status == ItemStatus.unread) {
      await ref.read(markItemReadAndTrackUseCaseProvider).call(item.id);
      final updatedItem = item.copyWith(
        status: ItemStatus.read,
        updatedAt: DateTime.now(),
      );
      ref
          .read(itemsNotifierProvider(widget.collectionId).notifier)
          .updateItemInState(updatedItem);
    }

    if (!mounted) return;
    context.push('/collections/${widget.collectionId}/items/${item.id}');
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

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.push_pin_outlined, color: textColor),
              title: Text(
                'Toggle Pin',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                context.pop();
                await ref
                    .read(toggleItemPinUseCaseProvider)
                    .call(item.id);
                // Refresh keeps the list consistent after the mutation.
                ref
                    .read(itemsNotifierProvider(widget.collectionId).notifier)
                    .refresh();
              },
            ),
            ListTile(
              leading: Icon(
                item.status == ItemStatus.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                color: textColor,
              ),
              title: Text(
                item.status == ItemStatus.archived ? 'Unarchive' : 'Archive',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                context.pop();
                await ref
                    .read(toggleItemArchiveUseCaseProvider)
                    .call(item.id);

                final newStatus = item.status == ItemStatus.archived
                    ? ItemStatus.unread
                    : ItemStatus.archived;
                final updatedItem = item.copyWith(
                  status: newStatus,
                  updatedAt: DateTime.now(),
                );
                ref
                    .read(itemsNotifierProvider(widget.collectionId).notifier)
                    .updateItemInState(updatedItem);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: textColor),
              title: Text('Edit',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w500)),
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
              title: const Text('Delete',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () {
                context.pop();
                _confirmDelete(context, item.id);
              },
            ),
          ],
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
              await ref.read(deleteItemUseCaseProvider).call(itemId);
              ref
                  .read(itemsNotifierProvider(widget.collectionId).notifier)
                  .removeItemFromState(itemId);
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
}
