import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/presentation/widgets/content_state_widgets.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../../core/presentation/widgets/empty_state_view.dart';
import '../../domain/entities/collection.dart';
import '../../data/models/search_history_model.dart';
import '../providers/collections_providers.dart';
import '../providers/search/global_search_links_notifier.dart';
import '../providers/search/global_search_notifier.dart';
import '../providers/search/global_search_query_providers.dart';
import '../providers/search/global_search_state.dart';
import '../providers/search/search_notifier.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_list_tile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/presentation/providers/items_list_models.dart';
import '../../../items/presentation/widgets/url_icon_link_tile.dart';
import '../../../items/presentation/widgets/url_list_row_tile.dart';
import '../../../items/presentation/widgets/url_preview_tile.dart';

// Grid metrics (matches hub helpers in items_list_screen.dart).
_GridMetrics _collectionsGridMetrics(double innerWidth,
    {required bool compact}) {
  const spacing = 16.0;
  final minCell = compact ? 88.0 : 152.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = compact ? count.clamp(2, 6) : count.clamp(1, 3);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  final targetH = compact ? (cellW * 0.48 + 58) : (cellW * 0.48 + 96);
  var ratio = cellW / targetH;
  ratio = compact ? ratio.clamp(0.82, 1.08) : ratio.clamp(0.72, 0.92);
  return _GridMetrics(crossAxisCount: count, childAspectRatio: ratio);
}

_GridMetrics _linksCardsGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 148.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(1, 4);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  final imageH = cellW * 9 / 16;
  const textBlockH = 112.0;
  var ratio = cellW / (imageH + textBlockH);
  ratio = ratio.clamp(0.46, 0.82);
  return _GridMetrics(crossAxisCount: count, childAspectRatio: ratio);
}

_GridMetrics _linksIconsGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 92.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(2, 6);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  const targetH = 118.0;
  var ratio = cellW / targetH;
  ratio = ratio.clamp(0.72, 1.05);
  return _GridMetrics(crossAxisCount: count, childAspectRatio: ratio);
}

class _GridMetrics {
  const _GridMetrics({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
  final int crossAxisCount;
  final double childAspectRatio;
}

/// Global search: two tabs (Collections + Links) with exact hub-style layout.
class SearchCollectionsScreen extends ConsumerStatefulWidget {
  const SearchCollectionsScreen({super.key});

  @override
  ConsumerState<SearchCollectionsScreen> createState() =>
      _SearchCollectionsScreenState();
}

class _SearchCollectionsScreenState
    extends ConsumerState<SearchCollectionsScreen>
    with SingleTickerProviderStateMixin {
  static const _radiusLg = 16.0;

  late TabController _tabController;
  final TextEditingController _collectionsController = TextEditingController();
  final TextEditingController _linksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final gs = ref.read(globalSearchNotifierProvider);
    _collectionsController.text = gs.collectionsSearchDraft;
    _linksController.text = gs.linksSearchDraft;
    _collectionsController.addListener(() => setState(() {}));
    _linksController.addListener(() => setState(() {}));
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: gs.activeTab == GlobalSearchTab.collections ? 0 : 1,
    );
    _tabController.addListener(_onTabControllerTick);
  }

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    final tab = _tabController.index == 0
        ? GlobalSearchTab.collections
        : GlobalSearchTab.links;
    final current = ref.read(globalSearchNotifierProvider).activeTab;
    if (tab != current) {
      ref.read(globalSearchNotifierProvider.notifier).setActiveTab(tab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerTick);
    _tabController.dispose();
    _collectionsController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  Future<void> _openLinkDetail(Item item) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !mounted) return;
    context.push('/collections/${item.collectionId}/items/${item.id}');
  }

  bool _onScrollNotification(ScrollNotification n, bool isLinks) {
    if (!isLinks) return false;
    if (n is ScrollUpdateNotification && n.metrics.maxScrollExtent > 0) {
      if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.8) {
        ref.read(globalSearchLinksNotifierProvider.notifier).fetchNextPage();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(globalSearchNotifierProvider);
    final gn = ref.read(globalSearchNotifierProvider.notifier);
    final filteredCollectionsAsync =
        ref.watch(globalSearchFilteredCollectionsProvider);
    final linksState = ref.watch(globalSearchLinksNotifierProvider);
    final historyAsync = ref.watch(searchHistoryProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final linksLocalOnly = ref.watch(globalSearchLinksLocalOnlyProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final collectionsShowHistory =
        gs.collectionsCommittedQuery.trim().isEmpty &&
            gs.collectionsSearchDraft.trim().isEmpty;
    final linksShowHistory = gs.linksCommittedQuery.trim().isEmpty &&
        gs.linksSearchDraft.trim().isEmpty;

    return DefaultTabController(
      length: 2,
      initialIndex: gs.activeTab == GlobalSearchTab.collections ? 0 : 1,
      child: Builder(
        builder: (tabContext) {
          final tabController = DefaultTabController.of(tabContext);
          // Keep _tabController in sync (used for old listener).
          if (_tabController != tabController) {
            // Already handled via _tabController in initState.
          }
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: true,
                    floating: false,
                    snap: false,
                    automaticallyImplyLeading: false,
                    scrolledUnderElevation: innerBoxIsScrolled ? 2 : 0,
                    elevation: innerBoxIsScrolled ? 2 : 0,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    leading: context.canPop()
                        ? IconButton(
                            icon: Icon(Icons.arrow_back, color: primary),
                            onPressed: () => context.pop(),
                          )
                        : null,
                    title: Text(
                      'Search',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    // No actions — layout is controlled from filter screens.
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Semantics(
                        container: true,
                        label: 'Search tabs',
                        child: TabBar(
                          controller: _tabController,
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
                                ? GlobalSearchTab.collections
                                : GlobalSearchTab.links;
                            gn.setActiveTab(tab);
                          },
                          tabs: const [
                            Tab(text: 'Collections'),
                            Tab(text: 'Links'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // ── Collections tab ──────────────────────────────────────
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) => _onScrollNotification(n, false),
                    child: Builder(
                      builder: (nestedCtx) => CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                              nestedCtx,
                            ),
                          ),
                          // Search toolbar
                          SliverToBoxAdapter(
                            child: _buildCollectionsToolbar(theme, gs, gn),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 8),
                          ),
                          // Content
                          if (collectionsShowHistory)
                            SliverFillRemaining(
                              hasScrollBody: true,
                              child: historyAsync.when(
                                data: (h) => _buildHistoryView(
                                  theme,
                                  gn,
                                  h,
                                  GlobalSearchTab.collections,
                                ),
                                loading: () => const CollectionGridSkeleton(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            )
                          else
                            ..._buildCollectionsSlivers(
                              filteredCollectionsAsync,
                              gs,
                              isPremium,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Links tab ────────────────────────────────────────────
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) => _onScrollNotification(n, true),
                    child: Builder(
                      builder: (nestedCtx) => CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                              nestedCtx,
                            ),
                          ),
                          // Search toolbar
                          SliverToBoxAdapter(
                            child: _buildLinksToolbar(theme, gs, gn),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          // Offline / DayPass banner
                          if (linksLocalOnly)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Material(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cloud_off_outlined,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Showing offline links only. Use Day Pass to access your full library.',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Content
                          if (linksShowHistory)
                            SliverFillRemaining(
                              hasScrollBody: true,
                              child: historyAsync.when(
                                data: (h) => _buildHistoryView(
                                  theme,
                                  gn,
                                  h,
                                  GlobalSearchTab.links,
                                ),
                                loading: () => const ItemsListSkeleton(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            )
                          else
                            ..._buildLinksSlivers(linksState, gs),
                        ],
                      ),
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

  // ── Toolbars ──────────────────────────────────────────────────────────────

  Widget _buildCollectionsToolbar(
    ThemeData theme,
    GlobalSearchState gs,
    GlobalSearchNotifier gn,
  ) {
    final surface = theme.colorScheme.surfaceContainerHighest;
    final filterBadge = gs.collectionsFiltersActive;
    final showHint = gs.collectionsSearchDraft.trim().isNotEmpty &&
        gs.collectionsCommittedQuery.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Material(
            color: surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(_radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _collectionsController,
                      onChanged: gn.updateCollectionsSearchDraft,
                      onFieldSubmitted: (v) async {
                        await gn.submitCollectionsSearchToHistory(v);
                        setState(() {});
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: 'Search folders',
                        hintText: 'Search folders…',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                        suffixIcon: gs.collectionsSearchDraft.trim().isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Search',
                                    icon: const Icon(Icons.search_rounded),
                                    onPressed: () async {
                                      await gn.submitCollectionsSearchToHistory(
                                        _collectionsController.text,
                                      );
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _collectionsController.clear();
                                      gn.clearCollectionsSearchQuery();
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Folder filters',
                    onPressed: () =>
                        context.push('/search/filters/collections'),
                    icon: Badge(
                      isLabelVisible: filterBadge,
                      smallSize: 8,
                      child: Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showHint)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4),
            child: Text(
              'Press the search icon or Enter to search & save',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLinksToolbar(
    ThemeData theme,
    GlobalSearchState gs,
    GlobalSearchNotifier gn,
  ) {
    final surface = theme.colorScheme.surfaceContainerHighest;
    final filterBadge = gs.linksFiltersActive;
    final showHint = gs.linksSearchDraft.trim().isNotEmpty &&
        gs.linksCommittedQuery.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Material(
            color: surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(_radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _linksController,
                      onChanged: gn.updateLinksSearchDraft,
                      onFieldSubmitted: (v) async {
                        await gn.submitLinksSearch(v);
                        await ref
                            .read(globalSearchLinksNotifierProvider.notifier)
                            .searchAndReset();
                        setState(() {});
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: 'Search links',
                        hintText: 'Search links…',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                        suffixIcon: gs.linksSearchDraft.trim().isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Search',
                                    icon: const Icon(Icons.search_rounded),
                                    onPressed: () async {
                                      await gn.submitLinksSearch(
                                          _linksController.text);
                                      await ref
                                          .read(
                                              globalSearchLinksNotifierProvider
                                                  .notifier)
                                          .searchAndReset();
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _linksController.clear();
                                      gn.clearLinksSearch();
                                      ref
                                          .read(
                                              globalSearchLinksNotifierProvider
                                                  .notifier)
                                          .reset();
                                      setState(() {});
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter & sort',
                    onPressed: () => context.push('/search/filters/links'),
                    icon: Badge(
                      isLabelVisible: filterBadge,
                      smallSize: 8,
                      child: Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showHint)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4),
            child: Text(
              'Press the search icon or Enter to search & save',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // ── Collections slivers ───────────────────────────────────────────────────

  List<Widget> _buildCollectionsSlivers(
    AsyncValue<List<Collection>> collectionsAsync,
    GlobalSearchState gs,
    bool isPremium,
  ) {
    return collectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                imageAsset: AppAssets.emptySearch,
                title: 'No results found',
                message: 'Try adjusting your search or filters.',
                buttonText: 'Clear search',
                onButtonPressed: () {
                  _collectionsController.clear();
                  ref
                      .read(globalSearchNotifierProvider.notifier)
                      .clearCollectionsSearchQuery();
                },
              ),
            ),
          ];
        }

        switch (gs.collectionsViewMode) {
          case UrlViewMode.list:
            return [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final collection = collections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CollectionListTile(
                          collection: collection,
                          onTap: () async {
                            final ok = await DayPassGate.check(context, ref);
                            if (!ok || !context.mounted) return;
                            context.push('/collections/${collection.id}');
                          },
                          onLongPress: () => _showCollectionOptions(
                            collection,
                            isPremium,
                          ),
                        ),
                      );
                    },
                    childCount: collections.length,
                  ),
                ),
              ),
            ];

          case UrlViewMode.cards:
            return [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final m = _collectionsGridMetrics(
                      constraints.crossAxisExtent,
                      compact: false,
                    );
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final collection = collections[index];
                          return CollectionCard(
                            collection: collection,
                            onTap: () async {
                              final ok = await DayPassGate.check(context, ref);
                              if (!ok || !context.mounted) return;
                              context.push('/collections/${collection.id}');
                            },
                            onLongPress: () => _showCollectionOptions(
                              collection,
                              isPremium,
                            ),
                          );
                        },
                        childCount: collections.length,
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
              ),
            ];

          case UrlViewMode.icons:
            return [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final m = _collectionsGridMetrics(
                      constraints.crossAxisExtent,
                      compact: true,
                    );
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final collection = collections[index];
                          return CollectionCard(
                            collection: collection,
                            compact: true,
                            onTap: () async {
                              final ok = await DayPassGate.check(context, ref);
                              if (!ok || !context.mounted) return;
                              context.push('/collections/${collection.id}');
                            },
                            onLongPress: () => _showCollectionOptions(
                              collection,
                              isPremium,
                            ),
                          );
                        },
                        childCount: collections.length,
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
              ),
            ];
        }
      },
      loading: () => [
        const SliverFillRemaining(
          hasScrollBody: true,
          child: CollectionGridSkeleton(),
        ),
      ],
      error: (error, _) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(
            error: error,
            title: 'Could not load collections',
            onRetry: () => ref.invalidate(collectionsListProvider),
          ),
        ),
      ],
    );
  }

  // ── Links slivers ─────────────────────────────────────────────────────────

  List<Widget> _buildLinksSlivers(
    GlobalSearchLinksState linksState,
    GlobalSearchState gs,
  ) {
    final notifier = ref.read(globalSearchLinksNotifierProvider.notifier);

    switch (linksState.phase) {
      case GlobalSearchLinksPhase.idle:
        return [const SliverToBoxAdapter(child: SizedBox.shrink())];

      case GlobalSearchLinksPhase.loading:
        return [
          const SliverFillRemaining(
            hasScrollBody: true,
            child: ItemsListSkeleton(),
          ),
        ];

      case GlobalSearchLinksPhase.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              imageAsset: AppAssets.errorNetwork,
              title: 'Oops! Something went wrong',
              message: linksState.errorMessage ??
                  'Check your connection and try again.',
              buttonText: 'Retry',
              onButtonPressed: notifier.searchAndReset,
            ),
          ),
        ];

      case GlobalSearchLinksPhase.loaded:
        final items = linksState.items;
        if (items.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                imageAsset: AppAssets.emptyLinks,
                title: 'No results found',
                message: 'Try a different search or adjust filters.',
                buttonText: 'Clear search',
                onButtonPressed: () {
                  _linksController.clear();
                  ref
                      .read(globalSearchNotifierProvider.notifier)
                      .clearLinksSearch();
                  notifier.reset();
                  setState(() {});
                },
              ),
            ),
          ];
        }

        final loadingFooter = linksState.isLoadingMore
            ? [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ]
            : <Widget>[];

        switch (gs.linksViewMode) {
          case UrlViewMode.list:
            return [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return UrlListRowTile(
                        item: item,
                        onTap: () => _openLinkDetail(item),
                        onLongPress: () async {
                          final ok = await DayPassGate.check(context, ref);
                          if (!ok || !context.mounted) return;
                          context.push(
                            '/collections/${item.collectionId}/items/${item.id}/edit',
                          );
                        },
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
              ...loadingFooter,
            ];

          case UrlViewMode.icons:
            return [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final m =
                        _linksIconsGridMetrics(constraints.crossAxisExtent);
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          return UrlIconLinkTile(
                            item: item,
                            onTap: () => _openLinkDetail(item),
                            onLongPress: () async {
                              final ok = await DayPassGate.check(context, ref);
                              if (!ok || !context.mounted) return;
                              context.push(
                                '/collections/${item.collectionId}/items/${item.id}/edit',
                              );
                            },
                          );
                        },
                        childCount: items.length,
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
              ),
              ...loadingFooter,
            ];

          case UrlViewMode.cards:
            return [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final m =
                        _linksCardsGridMetrics(constraints.crossAxisExtent);
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          return UrlPreviewTile(
                            item: item,
                            onTap: () => _openLinkDetail(item),
                            onLongPress: () async {
                              final ok = await DayPassGate.check(context, ref);
                              if (!ok || !context.mounted) return;
                              context.push(
                                '/collections/${item.collectionId}/items/${item.id}/edit',
                              );
                            },
                          );
                        },
                        childCount: items.length,
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
              ),
              ...loadingFooter,
            ];
        }
    }
  }

  // ── History view ──────────────────────────────────────────────────────────

  Widget _buildHistoryView(
    ThemeData theme,
    GlobalSearchNotifier notifier,
    List<SearchHistoryModel> history,
    GlobalSearchTab activeTab,
  ) {
    if (history.isEmpty) {
      return EmptyStateView(
        imageAsset: activeTab == GlobalSearchTab.collections
            ? AppAssets.emptyCollections
            : AppAssets.emptyLinks,
        title: 'No recent searches',
        message: activeTab == GlobalSearchTab.collections
            ? 'Search collections above.'
            : 'Search links above.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => notifier.clearHistory(),
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: history
                    .take(20)
                    .map(
                      (item) => _buildHistoryChip(
                        theme,
                        notifier,
                        item,
                        activeTab,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(
    ThemeData theme,
    GlobalSearchNotifier notifier,
    SearchHistoryModel item,
    GlobalSearchTab activeTab,
  ) {
    return InputChip(
      label: Text(item.query),
      avatar: Icon(
        Icons.history_rounded,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      deleteIcon: Icon(
        Icons.close_rounded,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onDeleted: () => notifier.removeHistoryEntry(item.id),
      onPressed: () async {
        if (activeTab == GlobalSearchTab.collections) {
          _collectionsController.text = item.query;
          _collectionsController.selection = TextSelection.fromPosition(
            TextPosition(offset: item.query.length),
          );
          await notifier.submitCollectionsSearchToHistory(item.query);
        } else {
          _linksController.text = item.query;
          _linksController.selection = TextSelection.fromPosition(
            TextPosition(offset: item.query.length),
          );
          await notifier.submitLinksSearch(item.query);
          await ref
              .read(globalSearchLinksNotifierProvider.notifier)
              .searchAndReset();
        }
        setState(() {});
      },
      backgroundColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ── Collection options ────────────────────────────────────────────────────

  void _showCollectionOptions(Collection collection, bool isPremium) {
    final isRoot =
        collection.parentId == null || collection.parentId!.trim().isEmpty;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !mounted) return;
              if (!context.mounted) return;
              context.push('/collections/${collection.id}/edit');
            },
          ),
          if (isPremium)
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share options'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Advanced sharing coming in a later sprint.'),
                  ),
                );
              },
            ),
          if (!isRoot)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDelete(collection.id);
              },
            ),
        ],
      ),
    );
  }

  void _confirmDelete(String collectionId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete collection?'),
        content: const Text(
          'This will delete the collection and all its items.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(deleteCollectionUseCaseProvider).call(collectionId);
              ctx.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
