import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/collection_sibling_order.dart';
import '../../domain/entities/collection.dart';
import '../providers/collections_providers.dart';
import '../providers/collections_hub_notifier.dart';
import '../providers/collections_list_ui_notifier.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_list_tile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/presentation/widgets/content_state_widgets.dart';
import '../../../../core/presentation/widgets/empty_state_view.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/presentation/providers/items_providers.dart';
import '../../../items/presentation/widgets/url_preview_tile.dart';

/// **Rollback artifact — not routed.** `/collections` uses [CollectionsBranchRootScreen]
/// → [ItemsListScreen] under the persisted library root (`LibraryRootCollection`).
/// Kept temporarily so router can be reverted without reintroducing dead code.
class CollectionsListScreen extends ConsumerStatefulWidget {
  const CollectionsListScreen({super.key});

  @override
  ConsumerState<CollectionsListScreen> createState() =>
      _CollectionsListScreenState();
}

class _CollectionsListScreenState
    extends ConsumerState<CollectionsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification) {
      final goingDown = (n.scrollDelta ?? 0) > 0;
      if (goingDown != !_fabVisible) {
        setState(() => _fabVisible = !goingDown);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsListProvider);
    final rootItemsAsync = ref.watch(_rootLinksProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _buildFab(context, collectionsAsync),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              floating: true,
              snap: true,
              scrolledUnderElevation: innerBoxIsScrolled ? 2 : 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.scaffoldBackgroundColor,
              expandedHeight: 112,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 52),
                      child: Text(
                        'Collections',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: primary),
                  tooltip: 'New folder',
                  onPressed: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    context.push('/collections/create');
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  labelColor: primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurfaceVariant,
                  indicatorColor: primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 2,
                  tabs: [
                    Tab(
                      text: collectionsAsync.whenData((list) {
                        final rootCount = list
                            .where((c) =>
                                c.parentId == null &&
                                !c.isDeleted &&
                                !c.isArchived)
                            .length;
                        return 'Folders ($rootCount)';
                      }).valueOrNull ??
                          'Folders',
                    ),
                    Tab(
                      text: rootItemsAsync.whenData((items) {
                        return 'Links (${items.length})';
                      }).valueOrNull ??
                          'Links',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _FoldersTab(
              collectionsAsync: collectionsAsync,
              onScroll: _onScroll,
            ),
            _RootLinksTab(
              itemsAsync: rootItemsAsync,
              onScroll: _onScroll,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFab(
      BuildContext context, AsyncValue<List<Collection>> collectionsAsync) {
    if (!_fabVisible) return null;
    final isFolders = _tabController.index == 0;

    if (isFolders) {
      return FloatingActionButton.extended(
        heroTag: 'root_hub_fab_folder',
        onPressed: () async {
          final ok = await DayPassGate.check(context, ref);
          if (!ok || !context.mounted) return;
          context.push('/collections/create');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New folder'),
      );
    }

    return FloatingActionButton.extended(
      heroTag: 'root_hub_fab_link',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Save links to a collection first using + New folder')),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_link_rounded),
      label: const Text('Add link'),
    );
  }
}

// ── Folders tab ──────────────────────────────────────────────────────────────

class _FoldersTab extends ConsumerStatefulWidget {
  const _FoldersTab({
    required this.collectionsAsync,
    required this.onScroll,
  });

  final AsyncValue<List<Collection>> collectionsAsync;
  final Function(ScrollNotification) onScroll;

  @override
  ConsumerState<_FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends ConsumerState<_FoldersTab> {
  List<Collection> _filter(List<Collection> all) {
    final roots = all
        .where((c) => c.parentId == null && !c.isDeleted && !c.isArchived)
        .toList();
    final q = ref
        .watch(collectionsListUiNotifierProvider)
        .folderSearchQuery
        .trim()
        .toLowerCase();
    if (q.isEmpty) return roots;
    return roots
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final uiState = ref.watch(collectionsListUiNotifierProvider);
    final uiNotifier = ref.read(collectionsListUiNotifierProvider.notifier);

    return widget.collectionsAsync.when(
      data: (all) {
        final roots = _filter(all);

      return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            widget.onScroll(n);
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search + layout toggle toolbar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: uiNotifier.updateFolderSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Search folders…',
                            prefixIcon: Icon(Icons.search_rounded,
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                                size: 20),
                            isDense: true,
                            filled: true,
                            fillColor: theme.colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          uiState.isGrid ? Icons.view_list : Icons.grid_view,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: uiNotifier.toggleGrid,
                      ),
                    ],
                  ),
                ),
              ),

              // Empty state
              if (all.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateView(
                    imageAsset: AppAssets.emptyCollections,
                    title: 'No folders here yet',
                    message:
                        'Create a folder to start organizing your links.',
                    buttonText: '+ New folder',
                    // Gated: create folder (Curate-style parent action).
                    onButtonPressed: () async {
                      final ok = await DayPassGate.check(context, ref);
                      if (!ok || !context.mounted) return;
                      context.push('/collections/create');
                    },
                  ),
                )
              else if (roots.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateView(
                    imageAsset: AppAssets.emptyCollections,
                    title: 'No folders here yet',
                    message:
                        'Create a folder to start organizing your links.',
                    buttonText: '+ New folder',
                    onButtonPressed: () async {
                      final ok = await DayPassGate.check(context, ref);
                      if (!ok || !context.mounted) return;
                      context.push('/collections/create');
                    },
                  ),
                )
              else if (uiState.isGrid)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final c = roots[i];
                        return CollectionCard(
                          collection: c,
                          onTap: () async {
                            final ok = await DayPassGate.check(
                                context, ref);
                            if (!ok || !context.mounted) return;
                            context.push(
                                '/collections/${c.id}',
                                extra: c.title);
                          },
                          onLongPress: () => _showOptions(
                              context, ref, c, isPremium),
                        );
                      },
                      childCount: roots.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  sliver: _ReorderableList(
                    collections: roots,
                    isPremium: isPremium,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const CollectionGridSkeleton(),
      error: (err, _) => EmptyStateView(
        imageAsset: AppAssets.errorNetwork,
        title: 'Oops! Something went wrong',
        message: 'Check your internet connection and try again.',
        buttonText: 'Retry',
        onButtonPressed: () => ref.invalidate(collectionsListProvider),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Collection c,
      bool isPremium) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _CollectionOptionsSheet(
          collection: c, ref: ref, isPremium: isPremium),
    );
  }
}

class _ReorderableList extends ConsumerWidget {
  const _ReorderableList(
      {required this.collections, required this.isPremium});

  final List<Collection> collections;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordered = List<Collection>.from(collections)
      ..sort(compareCollectionsSiblings);

    return SliverReorderableList(
      onReorder: (oldIndex, newIndex) async {
        var to = newIndex;
        if (to > oldIndex) to--;
        if (oldIndex == to) return;
        await ref.read(collectionsHubNotifierProvider.notifier).reorderSiblings(
              siblings: ordered,
              oldIndex: oldIndex,
              newIndex: to,
            );
      },
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final c = ordered[index];
        return ReorderableDragStartListener(
          key: ValueKey(c.id),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CollectionListTile(
              collection: c,
              onTap: () async {
                final ok = await DayPassGate.check(context, ref);
                if (!ok || !context.mounted) return;
                context.push('/collections/${c.id}', extra: c.title);
              },
              onLongPress: () => showModalBottomSheet(
                context: context,
                builder: (ctx) => _CollectionOptionsSheet(
                    collection: c, ref: ref, isPremium: isPremium),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Links tab placeholder ─────────────────────────────────────────────────────

final _rootLinksProvider = FutureProvider<List<Item>>((ref) async {
  final itemsResult = await ref.read(getAllItemsUseCaseProvider).call();
  final allCollections = ref.watch(collectionsListProvider).valueOrNull ?? const [];
  final existingCollectionIds = allCollections.map((c) => c.id).toSet();

  return itemsResult.fold(
    (_) => <Item>[],
    (items) {
      final filtered = items.where((item) {
        final rawId = item.collectionId.trim();
        if (rawId.isEmpty) return true;
        if (rawId == 'root' || rawId == 'ROOT') return true;
        return !existingCollectionIds.contains(rawId);
      }).toList();
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    },
  );
});

class _RootLinksTab extends ConsumerStatefulWidget {
  const _RootLinksTab({
    required this.itemsAsync,
    required this.onScroll,
  });

  final AsyncValue<List<Item>> itemsAsync;
  final Function(ScrollNotification) onScroll;

  @override
  ConsumerState<_RootLinksTab> createState() => _RootLinksTabState();
}

class _RootLinksTabState extends ConsumerState<_RootLinksTab> {
  List<Item> _filtered(List<Item> items) {
    final ui = ref.read(collectionsListUiNotifierProvider);
    final q = ui.rootLinksSearchQuery.trim().toLowerCase();
    return items.where((item) {
      if (ui.rootLinksStatusFilter != null &&
          item.status != ui.rootLinksStatusFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final title = item.title.toLowerCase();
      final link = (item.link ?? '').toLowerCase();
      return title.contains(q) || link.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(collectionsListUiNotifierProvider);
    final uiNotifier = ref.read(collectionsListUiNotifierProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        widget.onScroll(n);
        return false;
      },
      child: widget.itemsAsync.when(
        data: (items) {
          final filtered = _filtered(items);
          if (items.isEmpty) {
            return const EmptyStateView(
              imageAsset: AppAssets.emptySearch,
              title: 'No root links yet',
              message: 'Links not assigned to a folder will appear here.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    onChanged: uiNotifier.updateRootLinksSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search links…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: uiState.rootLinksSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: uiNotifier.clearRootLinksSearchQuery,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: uiState.rootLinksStatusFilter == null,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksStatusFilter(null),
                      ),
                      FilterChip(
                        label: const Text('Unread'),
                        selected: uiState.rootLinksStatusFilter == ItemStatus.unread,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksStatusFilter(ItemStatus.unread),
                      ),
                      FilterChip(
                        label: const Text('Read'),
                        selected: uiState.rootLinksStatusFilter == ItemStatus.read,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksStatusFilter(ItemStatus.read),
                      ),
                      ChoiceChip(
                        label: const Text('List'),
                        selected: uiState.rootLinksViewMode == UrlViewMode.list,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksViewMode(UrlViewMode.list),
                      ),
                      ChoiceChip(
                        label: const Text('Cards'),
                        selected: uiState.rootLinksViewMode == UrlViewMode.cards,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksViewMode(UrlViewMode.cards),
                      ),
                      ChoiceChip(
                        label: const Text('Icons'),
                        selected: uiState.rootLinksViewMode == UrlViewMode.icons,
                        onSelected: (_) =>
                            uiNotifier.setRootLinksViewMode(UrlViewMode.icons),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    imageAsset: AppAssets.emptySearch,
                    title: 'No links match current filters',
                    message: 'Try a different query or clear status filters.',
                    buttonText: 'Clear filters',
                    onButtonPressed: () {
                      uiNotifier.clearRootLinksSearchQuery();
                      uiNotifier.setRootLinksStatusFilter(null);
                    },
                  ),
                )
              else if (uiState.rootLinksViewMode == UrlViewMode.list)
                SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: UrlPreviewTile(
                      item: filtered[index],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Assign this link to a folder to open detail.'),
                          ),
                        );
                      },
                      onLongPress: () {},
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => UrlPreviewTile(
                        item: filtered[index],
                        compact: uiState.rootLinksViewMode == UrlViewMode.icons,
                        onTap: () {},
                        onLongPress: () {},
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: uiState.rootLinksViewMode == UrlViewMode.icons ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          uiState.rootLinksViewMode == UrlViewMode.icons
                              ? 1.1
                              : 0.78,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const ItemsListSkeleton(),
        error: (err, _) => AppErrorState(
          error: err,
          title: 'Could not load root links',
          onRetry: () => ref.invalidate(_rootLinksProvider),
        ),
      ),
    );
  }
}
// ── Collection options bottom sheet ──────────────────────────────────────────

class _CollectionOptionsSheet extends ConsumerWidget {
  const _CollectionOptionsSheet({
    required this.collection,
    required this.ref,
    required this.isPremium,
  });

  final Collection collection;
  final WidgetRef ref;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit'),
          onTap: () async {
            context.pop();
            final ok = await DayPassGate.check(context, widgetRef);
            if (!ok || !context.mounted) return;
            context.push('/collections/${collection.id}/edit');
          },
        ),
        ListTile(
          leading: Icon(collection.isPinned
              ? Icons.push_pin
              : Icons.push_pin_outlined),
          title: Text(collection.isPinned ? 'Unpin' : 'Pin to top'),
          onTap: () async {
            context.pop();
            await widgetRef
                .read(collectionsHubNotifierProvider.notifier)
                .togglePin(collection);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Delete',
              style: TextStyle(color: Colors.red)),
          onTap: () {
            context.pop();
            _confirmDelete(context, widgetRef, collection.id);
          },
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef widgetRef, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: const Text(
            'This will delete the collection and all its items.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widgetRef
                  .read(collectionsHubNotifierProvider.notifier)
                  .deleteCollection(id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
