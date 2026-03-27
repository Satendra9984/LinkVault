import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/collection.dart';
import '../providers/collections_providers.dart';
import '../providers/search/search_state.dart';
import '../providers/search/search_notifier.dart';
import '../providers/search/filtered_search_collections_provider.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_list_tile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/presentation/widgets/empty_state_view.dart';
import '../../../../core/constants/app_assets.dart';
import '../../data/models/search_history_model.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/presentation/providers/items_providers.dart';
import '../../../items/presentation/widgets/url_preview_tile.dart';

final _allItemsForSearchProvider = FutureProvider<List<Item>>((ref) async {
  final result = await ref.read(itemsRepositoryProvider).getAllItems();
  return result.fold((_) => <Item>[], (items) => items);
});

class SearchCollectionsScreen extends ConsumerStatefulWidget {
  const SearchCollectionsScreen({super.key});

  @override
  ConsumerState<SearchCollectionsScreen> createState() =>
      _SearchCollectionsScreenState();
}

class _SearchCollectionsScreenState
    extends ConsumerState<SearchCollectionsScreen> {
  static const _radiusPill = 24.0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final searchNotifier = ref.read(searchNotifierProvider.notifier);
    final filteredCollectionsAsync =
        ref.watch(filteredSearchCollectionsProvider);
    final allItemsAsync = ref.watch(_allItemsForSearchProvider);
    final historyAsync = ref.watch(searchHistoryProvider);

    final isPremium = ref.watch(isPremiumProvider);
    final isGrid = ref.watch(collectionsViewModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context, theme, ref),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(theme, searchNotifier),
              const SizedBox(height: 16),

              // Filter Chips
              _buildFilterChips(theme, searchState, searchNotifier),
              const SizedBox(height: 12),

              // Content: History (when empty) or Results (when typing)
              Expanded(
                child: searchState.query.isEmpty
                    ? historyAsync.when(
                        data: (history) => _buildHistoryView(
                            context, theme, searchNotifier, history),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      )
                    : _buildUnifiedResults(
                        context,
                        ref,
                        filteredCollectionsAsync,
                        allItemsAsync,
                        searchState.query,
                        isGrid,
                        isPremium,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedResults(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Collection>> collectionsAsync,
    AsyncValue<List<Item>> itemsAsync,
    String query,
    bool isGrid,
    bool isPremium,
  ) {
    return collectionsAsync.when(
      data: (collections) => itemsAsync.when(
        data: (items) {
          final q = query.trim().toLowerCase();
          final matchedItems = items.where((item) {
            final title = item.title.toLowerCase();
            final link = (item.link ?? '').toLowerCase();
            final description = (item.description ?? '').toLowerCase();
            final tags = (item.tags ?? '').toLowerCase();
            return title.contains(q) ||
                link.contains(q) ||
                description.contains(q) ||
                tags.contains(q);
          }).toList();

          if (collections.isEmpty && matchedItems.isEmpty) {
            return EmptyStateView(
              imageAsset: AppAssets.emptySearch,
              title: 'No results found',
              message: 'Try adjusting your search or filters.',
              buttonText: 'Clear Search',
              onButtonPressed: () {
                ref.read(searchNotifierProvider.notifier).updateQuery('');
                _controller.clear();
              },
            );
          }

          return ListView(
            children: [
              if (collections.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Collections (${collections.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                SizedBox(
                  height: isGrid ? 320 : 280,
                  child: _buildSearchResults(
                    context,
                    ref,
                    collections,
                    isGrid,
                    isPremium,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (matchedItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Links (${matchedItems.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                ...matchedItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: UrlPreviewTile(
                      item: item,
                      onTap: () {
                        context.push('/collections/${item.collectionId}/items/${item.id}');
                      },
                      onLongPress: () {},
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => EmptyStateView(
        imageAsset: AppAssets.errorNetwork,
        title: 'Oops! Something went wrong',
        message: 'Check your internet connection and try again.',
        buttonText: 'Retry',
        onButtonPressed: () {
          ref.invalidate(filteredSearchCollectionsProvider);
          ref.invalidate(_allItemsForSearchProvider);
        },
      ),
    );
  }

  // ── History View ──────────────────────────────────────────────────────────

  Widget _buildHistoryView(BuildContext context, ThemeData theme,
      SearchNotifier notifier, List<SearchHistoryModel> history) {
    if (history.isEmpty) {
      return EmptyStateView(
        imageAsset: AppAssets.emptyCollections,
        title: 'No collections yet',
        message: 'Start curating to see your items here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
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
                    color: theme.colorScheme.error, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // History chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: history
              .take(10)
              .map((item) => _buildHistoryChip(theme, notifier, item))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHistoryChip(
      ThemeData theme, SearchNotifier notifier, SearchHistoryModel item) {
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
      onPressed: () {
        _controller.text = item.query;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: item.query.length),
        );
        notifier.updateQuery(item.query);
      },
      backgroundColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Search',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            final isGrid = ref.read(collectionsViewModeProvider);
            ref.read(collectionsViewModeProvider.notifier).state = !isGrid;
          },
          icon: Icon(
            ref.watch(collectionsViewModeProvider)
                ? Icons.view_list
                : Icons.grid_view,
            color: theme.colorScheme.primary,
          ),
          tooltip: ref.watch(collectionsViewModeProvider)
              ? 'List View'
              : 'Grid View',
        ),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(
      ThemeData theme, SearchState state, SearchNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Recent'),
            selected: state.sortOption == 'date_edited',
            onSelected: (_) => notifier.updateSortOption('date_edited'),
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Oldest first'),
            selected: state.sortOption == 'date_added',
            onSelected: (_) => notifier.updateSortOption('date_added'),
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Private only'),
            selected: state.showOnlyPrivate,
            onSelected: notifier.togglePrivateFilter,
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(ThemeData theme, SearchNotifier notifier) {
    return TextFormField(
      controller: _controller,
      autofocus: true,
      style: TextStyle(color: theme.colorScheme.onSurface),
      onChanged: (val) => notifier.updateQuery(val),
      onFieldSubmitted: (val) => notifier.submitQuery(val),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search your lists...',
        hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
        prefixIcon:
            Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  notifier.updateQuery('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // ── Search Results ────────────────────────────────────────────────────────

  Widget _buildSearchResults(BuildContext context, WidgetRef ref,
      List<Collection> collections, bool isGrid, bool isPremium) {
    if (isGrid) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return CollectionCard(
            collection: collection,
            onTap: () {
              ref
                  .read(searchNotifierProvider.notifier)
                  .submitQuery(ref.read(searchNotifierProvider).query);
              context.push('/collections/${collection.id}');
            },
            onLongPress: () =>
                _showCollectionOptions(context, ref, collection.id, isPremium),
          );
        },
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: collections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final collection = collections[index];
          return CollectionListTile(
            collection: collection,
            onTap: () {
              ref
                  .read(searchNotifierProvider.notifier)
                  .submitQuery(ref.read(searchNotifierProvider).query);
              context.push('/collections/${collection.id}');
            },
            onLongPress: () =>
                _showCollectionOptions(context, ref, collection.id, isPremium),
          );
        },
      );
    }
  }

  // ── Options / Delete ──────────────────────────────────────────────────────

  void _showCollectionOptions(BuildContext context, WidgetRef ref,
      String collectionId, bool isPremium) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              context.pop();
              context.push('/collections/$collectionId/edit');
            },
          ),
          if (isPremium)
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Options'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Advanced sharing coming in Sprint 10.')));
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.pop();
              _confirmDelete(context, ref, collectionId);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String collectionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection?'),
        content:
            const Text('This will delete the collection and all its items.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(deleteCollectionUseCaseProvider).call(collectionId);
              context.pop();
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
