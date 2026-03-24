import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/collection_fractional_reorder.dart';
import '../../domain/collection_sibling_order.dart';
import '../../domain/entities/collection.dart';
import '../providers/collections_providers.dart';
import '../providers/home_tab_providers.dart';
import '../widgets/collection_card.dart';
import '../widgets/collection_list_tile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/presentation/widgets/empty_state_view.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/config/app_config.dart';

class CollectionsListScreen extends ConsumerWidget {
  const CollectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the fully computed/sorted list instead of the raw firehose
    final collectionsAsync = ref.watch(homeCollectionsProvider);
    final rawCollectionsAsync =
        ref.watch(collectionsListProvider); // For FAB visibility logic
    final currentTab = ref.watch(homeTabNotifierProvider);

    final isPremium = ref.watch(isPremiumProvider);
    final isGrid = ref.watch(collectionsViewModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: theme
                  .scaffoldBackgroundColor, // Prevents transparent mode overlay color
              elevation: innerBoxIsScrolled ? 2 : 0,
              centerTitle: true,
              title: Text(
                'Home',
                style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold) ??
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
              ),
              leading: GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person_outline,
                        color: theme.colorScheme.primary, size: 20),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: theme.colorScheme.primary),
                  onPressed: () => context.push('/search_collections'),
                ),
                // Notifications — hidden until Sprint 10 social features ship
                if (AppConfig.instance.isDev)
                  IconButton(
                    icon: Icon(Icons.notifications_none,
                        color: theme.colorScheme.primary),
                    onPressed: () => context.push('/activity'),
                  ),
              ],
              // Tabs (Recent / Private / Shared) — hidden until Sprint 10
              bottom: AppConfig.instance.isDev
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 8.0),
                        child: _buildCustomTabs(theme, ref, currentTab),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: collectionsAsync.when(
            data: (filteredCollections) {
              // 1. If global list is completely empty, show full empty state
              return rawCollectionsAsync.maybeWhen(
                data: (raw) {
                  if (raw.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // 2. We have collections, display the filtered view
                  final rootCollections = filteredCollections
                      .where((collection) =>
                          collection.parentId == null &&
                          !collection.isDeleted &&
                          !collection.isArchived)
                      .toList();
                  return _buildCollectionsView(
                    context,
                    ref,
                    rootCollections,
                    isGrid,
                    isPremium,
                    isSharedTab: currentTab == HomeTab.shared,
                  );
                },
                orElse: () => const Center(child: CircularProgressIndicator()),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => EmptyStateView(
              imageAsset: AppAssets.errorNetwork,
              title: 'Oops! Something went wrong',
              message: 'Check your internet connection and try again.',
              buttonText: 'Retry',
              onButtonPressed: () {
                // Refresh the list provider
                ref.invalidate(collectionsListProvider);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: rawCollectionsAsync.maybeWhen(
        data: (collections) => collections.isEmpty
            ? null
            : FloatingActionButton(
                heroTag: 'collections_fab',
                onPressed: () async {
                  final ok = await DayPassGate.check(context, ref);
                  if (!ok || !context.mounted) return;
                  context.push('/collections/create');
                },
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildCustomTabs(ThemeData theme, WidgetRef ref, HomeTab currentTab) {
    final isGrid = ref.watch(collectionsViewModeProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTabButton(theme, ref, HomeTab.recent, currentTab, 'Recent'),
            const SizedBox(width: 8),
            _buildTabButton(theme, ref, HomeTab.private, currentTab, 'Private'),
            const SizedBox(width: 8),
            _buildTabButton(theme, ref, HomeTab.shared, currentTab, 'Shared'),
          ],
        ),
        IconButton(
          onPressed: () {
            ref.read(collectionsViewModeProvider.notifier).state = !isGrid;
          },
          icon: Icon(
            isGrid ? Icons.view_list : Icons.grid_view,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: isGrid ? 'List View' : 'Grid View',
        ),
      ],
    );
  }

  Widget _buildTabButton(ThemeData theme, WidgetRef ref, HomeTab tab,
      HomeTab currentTab, String title) {
    final isSelected = currentTab == tab;
    return GestureDetector(
      onTap: () {
        ref.read(homeTabNotifierProvider.notifier).setTab(tab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateView(
      imageAsset: AppAssets.emptyCollections,
      title: 'Start curating your life',
      message: 'Create your first collection to organize your items.',
      buttonText: 'Create Collection',
      onButtonPressed: () => context.push('/collections/create'),
    );
  }

  Widget _buildCollectionsView(BuildContext context, WidgetRef ref,
      List<Collection> collections, bool isGrid, bool isPremium,
      {bool isSharedTab = false}) {
    if (isSharedTab && !isPremium) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Premium Feature',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Upgrade to share collections with friends.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/paywall'),
              child: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      );
    }

    if (collections.isEmpty) {
      if (isSharedTab) {
        return EmptyStateView(
          imageAsset:
              AppAssets.emptyCollections, // Reusing existing illustration
          title: 'No Shared Collections',
          message: 'Collections shared with you will appear here.',
        );
      }
      return EmptyStateView(
        imageAsset: AppAssets.emptyCollections,
        title: 'Start curating your life',
        message: 'Create your first collection to organize your items.',
      );
    }

    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.only(
            top: 8, bottom: 80), // Added bottom padding for FAB
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              1.15, // Made cards less tall for better data density
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return CollectionCard(
            collection: collection,
            onTap: () async {
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              context.push('/collections/${collection.id}',
                  extra: collection.title);
            },
            onLongPress: () {
              // Show edit/delete options
              _showCollectionOptions(context, ref, collection, isPremium);
            },
          );
        },
      );
    } else {
      final orderedForList = List<Collection>.from(collections)
        ..sort(compareCollectionsSiblings);
      return ReorderableListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: orderedForList.length,
        onReorder: (oldIndex, newIndex) async {
          var to = newIndex;
          if (to > oldIndex) to--;
          if (oldIndex == to) return;
          final repo = ref.read(collectionsRepositoryProvider);
          final result = computeSiblingReorderPositions(
            siblings: orderedForList,
            oldIndex: oldIndex,
            newIndex: to,
          );
          if (result.rebalanceAll != null) {
            for (final e in result.rebalanceAll!.entries) {
              await repo.updateCollectionPosition(e.key, e.value);
            }
          } else {
            await repo.updateCollectionPosition(
                result.primaryId, result.primaryPosition);
          }
        },
        itemBuilder: (context, index) {
          final collection = orderedForList[index];
          return Padding(
            key: ValueKey(collection.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: CollectionListTile(
              collection: collection,
              onTap: () async {
                final ok = await DayPassGate.check(context, ref);
                if (!ok || !context.mounted) return;
                context.push('/collections/${collection.id}',
                    extra: collection.title);
              },
              onLongPress: () {
                _showCollectionOptions(context, ref, collection, isPremium);
              },
            ),
          );
        },
      );
    }
  }

  void _showCollectionOptions(BuildContext context, WidgetRef ref,
      Collection collection, bool isPremium) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () async {
              context.pop();
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              context.push('/collections/${collection.id}/edit');
            },
          ),
          ListTile(
            leading:
                Icon(collection.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            title: Text(collection.isPinned ? 'Unpin' : 'Pin to top'),
            onTap: () async {
              context.pop();
              final updated = Collection(
                id: collection.id,
                ownerId: collection.ownerId,
                parentId: collection.parentId,
                isShared: collection.isShared,
                title: collection.title,
                category: collection.category,
                colorHex: collection.colorHex,
                iconName: collection.iconName,
                position: collection.position,
                isPinned: !collection.isPinned,
                isArchived: collection.isArchived,
                isDeleted: collection.isDeleted,
                childCount: collection.childCount,
                createdAt: collection.createdAt,
                updatedAt: DateTime.now(),
                itemCount: collection.itemCount,
              );
              await ref.read(updateCollectionUseCaseProvider).call(updated);
            },
          ),
          ListTile(
            leading: Icon(collection.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            title: Text(collection.isArchived ? 'Unarchive' : 'Archive'),
            onTap: () async {
              context.pop();
              final updated = Collection(
                id: collection.id,
                ownerId: collection.ownerId,
                parentId: collection.parentId,
                isShared: collection.isShared,
                title: collection.title,
                category: collection.category,
                colorHex: collection.colorHex,
                iconName: collection.iconName,
                position: collection.position,
                isPinned: collection.isPinned,
                isArchived: !collection.isArchived,
                isDeleted: collection.isDeleted,
                childCount: collection.childCount,
                createdAt: collection.createdAt,
                updatedAt: DateTime.now(),
                itemCount: collection.itemCount,
              );
              await ref.read(updateCollectionUseCaseProvider).call(updated);
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
                        'Advanced sharing coming in Sprint 10. Toggle isShared inside Edit for now.')));
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.pop();
              _confirmDelete(context, ref, collection.id);
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
