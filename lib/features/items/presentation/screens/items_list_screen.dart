import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../domain/entities/item.dart';
import '../providers/items_providers.dart';
import '../widgets/item_card.dart';
import '../../../../core/config/app_config.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/domain/entities/collection.dart';

enum ViewMode { cards, list, icons }

enum SortOption { position, dateAdded, dateEdited }

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
  ViewMode _viewMode = ViewMode.list;
  ItemStatus? _filterStatus;
  final SortOption _sortBy = SortOption.dateAdded;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    final surfaceColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[300] : Colors.black54;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                    // Layout
                    Text('Layout',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 12),
                    SegmentedButton<ViewMode>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: secondaryTextColor,
                        selectedBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        selectedForegroundColor:
                            isDark ? AppColors.primary : AppColors.primary,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                        ),
                      ),
                      segments: const [
                        ButtonSegment(
                            value: ViewMode.list,
                            icon: Icon(Icons.view_list),
                            label: Text('List')),
                        ButtonSegment(
                            value: ViewMode.cards,
                            icon: Icon(Icons.grid_view),
                            label: Text('Cards')),
                        ButtonSegment(
                            value: ViewMode.icons,
                            icon: Icon(Icons.apps),
                            label: Text('Icons')),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (Set<ViewMode> newSelection) {
                        setState(() => _viewMode = newSelection.first);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 24),

                    // Filter
                    Text('Filter by Status',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _filterStatus == null,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundColor: surfaceColor,
                          checkmarkColor:
                              isDark ? AppColors.primary : AppColors.primary,
                          labelStyle: TextStyle(
                            color: _filterStatus == null
                                ? AppColors.primary
                                : secondaryTextColor,
                            fontWeight: _filterStatus == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: _filterStatus == null
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : (isDark ? Colors.white24 : Colors.grey[300]!),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _filterStatus = null);
                              setModalState(() {});
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Pending'),
                          selected: _filterStatus == ItemStatus.pending,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundColor: surfaceColor,
                          checkmarkColor:
                              isDark ? AppColors.primary : AppColors.primary,
                          labelStyle: TextStyle(
                            color: _filterStatus == ItemStatus.pending
                                ? AppColors.primary
                                : secondaryTextColor,
                            fontWeight: _filterStatus == ItemStatus.pending
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: _filterStatus == ItemStatus.pending
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : (isDark ? Colors.white24 : Colors.grey[300]!),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                  () => _filterStatus = ItemStatus.pending);
                              setModalState(() {});
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Visited'),
                          selected: _filterStatus == ItemStatus.visited,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundColor: surfaceColor,
                          checkmarkColor:
                              isDark ? AppColors.primary : AppColors.primary,
                          labelStyle: TextStyle(
                            color: _filterStatus == ItemStatus.visited
                                ? AppColors.primary
                                : secondaryTextColor,
                            fontWeight: _filterStatus == ItemStatus.visited
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: _filterStatus == ItemStatus.visited
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : (isDark ? Colors.white24 : Colors.grey[300]!),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                  () => _filterStatus = ItemStatus.visited);
                              setModalState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: primary),
        title: collectionsAsync.maybeWhen(
          data: (collections) => _buildBreadcrumbTitle(collections, primary),
          orElse: () => Text(
            titleText,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder_outlined, color: primary),
            onPressed: () {
              context.push('/collections/create?parent=${widget.collectionId}');
            },
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: primary),
            onPressed: _showCollectionOptionsBottomSheet,
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (state) {
          final items = state.items;
          var filteredItems = items;
          if (_filterStatus != null) {
            filteredItems =
                items.where((i) => i.status == _filterStatus).toList();
          }

          var sortedItems = List<Item>.from(filteredItems);
          switch (_sortBy) {
            case SortOption.dateAdded:
              sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case SortOption.dateEdited:
              sortedItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              break;
            case SortOption.position:
              sortedItems.sort((a, b) => a.position.compareTo(b.position));
              break;
          }

          if (sortedItems.isEmpty && items.isEmpty) {
            return _buildEmptyState();
          }

          final childCollections = collectionsAsync.valueOrNull
                  ?.where((collection) =>
                      collection.parentId == widget.collectionId &&
                      !collection.isDeleted &&
                      !collection.isArchived)
                  .toList() ??
              const <Collection>[];

          return Column(
            children: [
              if (childCollections.isNotEmpty)
                _buildChildCollectionsStrip(childCollections),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(collectionsListProvider);
                    await ref
                        .read(itemsNotifierProvider(widget.collectionId).notifier)
                        .refresh();
                  },
                  child: Column(
                    children: [
                      Expanded(child: _buildItemsView(sortedItems)),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                    ],
                  ),
                ),
              ),
              _buildBottomAddButton(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    'No items yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start building your list by adding the first item!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomAddButton(),
      ],
    );
  }

  Widget _buildItemsView(List<Item> items) {
    if (_viewMode == ViewMode.list) {
      return ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () async {
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              context
                  .push('/collections/${widget.collectionId}/items/${item.id}');
            },
            onLongPress: () => _showItemOptions(context, item.id),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: _getImageProvider(item) != null
                          ? Image(
                              image: _getImageProvider(item)!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image,
                              color: Colors.grey, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(_getStatusIcon(item.status),
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(item.status),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        if (item.description != null &&
                            item.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[400]),
                          ),
                        ]
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert,
                        size: 20, color: Colors.grey[400]),
                    onPressed: () => _showItemOptions(context, item.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (_viewMode == ViewMode.icons) {
      return GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () async {
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              context
                  .push('/collections/${widget.collectionId}/items/${item.id}');
            },
            onLongPress: () => _showItemOptions(context, item.id),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.grey[200],
                      child: _getImageProvider(item) != null
                          ? Image(
                              image: _getImageProvider(item)!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : const Center(
                              child: Icon(Icons.image, color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Cards View
      return GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemCard(
            item: item,
            onTap: () async {
              final ok = await DayPassGate.check(context, ref);
              if (!ok || !context.mounted) return;
              context
                  .push('/collections/${widget.collectionId}/items/${item.id}');
            },
            onLongPress: () => _showItemOptions(context, item.id),
            onToggleStatus: () async {
              await ref.read(toggleItemStatusUseCaseProvider).call(item);
              final newStatus = item.status == ItemStatus.completed
                  ? ItemStatus.pending
                  : ItemStatus.completed;
              final updatedItem =
                  item.copyWith(status: newStatus, updatedAt: DateTime.now());
              ref
                  .read(itemsNotifierProvider(widget.collectionId).notifier)
                  .updateItemInState(updatedItem);
            },
          );
        },
      );
    }
  }

  ImageProvider? _getImageProvider(Item item) {
    if (item.imageUrl != null) return NetworkImage(item.imageUrl!);
    if (item.imagePath != null) return FileImage(File(item.imagePath!));
    return null;
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return 'pending';
      case ItemStatus.visited:
        return 'visited';
      case ItemStatus.completed:
        return 'completed';
    }
  }

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Icons.schedule_rounded;
      case ItemStatus.visited:
        return Icons.check_circle_outline_rounded;
      case ItemStatus.completed:
        return Icons.star_border_rounded;
    }
  }

  void _showItemOptions(BuildContext context, String itemId) {
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
              leading: Icon(Icons.edit, color: textColor),
              title: Text('Edit',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              onTap: () async {
                context.pop();
                final ok = await DayPassGate.check(context, ref);
                if (!ok || !context.mounted) return;
                context.push(
                    '/collections/${widget.collectionId}/items/$itemId/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () {
                context.pop();
                _confirmDelete(context, itemId);
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
