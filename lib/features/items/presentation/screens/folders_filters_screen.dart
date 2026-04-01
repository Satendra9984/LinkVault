import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../collections/domain/collection_display_defaults.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_hub_notifier.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../providers/items_hub_ui_notifier.dart';
import '../providers/items_list_models.dart';
import '../widgets/filter_section_widgets.dart';
import '../widgets/folder_filter_category_sheet.dart';

/// Full-screen Folders tab filters (replaces [ChildFoldersFilterSortSheet] modal).
class FoldersFiltersScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const FoldersFiltersScreen({
    super.key,
    required this.collectionId,
  });

  @override
  ConsumerState<FoldersFiltersScreen> createState() =>
      _FoldersFiltersScreenState();
}

class _FoldersFiltersScreenState extends ConsumerState<FoldersFiltersScreen> {
  late UrlViewMode _layout;
  late ChildFolderSort _sort;
  late bool _includeArchived;
  late Set<String> _categories;
  DateTime? _updatedAfter;
  DateTime? _updatedBefore;

  @override
  void initState() {
    super.initState();
    final ui = ref.read(itemsHubUiNotifierProvider(widget.collectionId));
    final collection = ref.read(collectionByIdProvider(widget.collectionId));
    _layout = _childViewModeFromCollection(
      collection?.childCollectionsLayout ?? CollectionLayoutMode.list,
    );
    _sort = ui.childFolderSort;
    _includeArchived = ui.childIncludeArchived;
    _categories = {...ui.childSelectedCategories};
    _updatedAfter = ui.childUpdatedAfter;
    _updatedBefore = ui.childUpdatedBefore;
  }

  UrlViewMode _childViewModeFromCollection(String childLayout) {
    return switch (childLayout) {
      CollectionLayoutMode.grid => UrlViewMode.cards,
      CollectionLayoutMode.compactGrid => UrlViewMode.icons,
      _ => UrlViewMode.list,
    };
  }

  Future<void> _openCategoryPicker() async {
    await showFolderFilterCategoryPicker(
      context: context,
      initialSelection: Set<String>.from(_categories),
      onDone: (next) {
        setState(() {
          _categories
            ..clear()
            ..addAll(next);
        });
      },
    );
  }

  void _reset() {
    setState(() {
      _layout = UrlViewMode.list;
      _sort = ChildFolderSort.titleAsc;
      _includeArchived = false;
      _categories.clear();
      _updatedAfter = null;
      _updatedBefore = null;
    });
  }

  Future<void> _pickDate({required bool isAfter}) async {
    final now = DateTime.now();
    final initial =
        isAfter ? (_updatedAfter ?? now) : (_updatedBefore ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isAfter) {
        _updatedAfter = picked;
      } else {
        _updatedBefore = picked;
      }
    });
  }

  Future<void> _apply() async {
    final uiNotifier =
        ref.read(itemsHubUiNotifierProvider(widget.collectionId).notifier);
    uiNotifier.setChildFolderSort(_sort);
    uiNotifier.setChildIncludeArchived(_includeArchived);
    uiNotifier.setChildSelectedCategories(_categories);
    uiNotifier.setChildUpdatedAfter(_updatedAfter);
    uiNotifier.setChildUpdatedBefore(_updatedBefore);

    final collection = ref.read(collectionByIdProvider(widget.collectionId));
    if (collection != null) {
      await _persistChildCollectionsLayout(
        collection: collection,
        viewMode: _layout,
      );
    }

    if (mounted) context.pop();
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

    await ref
        .read(collectionsHubNotifierProvider.notifier)
        .saveCollection(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          TextButton(
            onPressed: _reset,
            style: TextButton.styleFrom(foregroundColor: subtle),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Layout, sort order, and which folders to show.',
              style: theme.textTheme.bodySmall?.copyWith(color: subtle),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('folders_filters_scroll'),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                16 + keyboardInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilterSectionCard(
                    title: 'CATEGORY',
                    subtitle:
                        'Choose categories in the sheet. Empty selection shows all categories.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _openCategoryPicker,
                          icon: const Icon(Icons.category_outlined),
                          label: Text(
                            _categories.isEmpty
                                ? 'Choose categories'
                                : '${_categories.length} categor${_categories.length == 1 ? 'y' : 'ies'} selected',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SELECTED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: subtle,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_categories.isEmpty)
                          Text(
                            'No category filter — all folders shown',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: subtle,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories
                                .map(
                                  (c) => InputChip(
                                    label: Text(c),
                                    onDeleted: () => setState(
                                      () => _categories.remove(c),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'LAYOUT',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final child = SegmentedButton<UrlViewMode>(
                          segments: const [
                            ButtonSegment(
                              value: UrlViewMode.list,
                              icon: Icon(Icons.view_list_rounded, size: 20),
                              label: Text('List'),
                            ),
                            ButtonSegment(
                              value: UrlViewMode.cards,
                              icon: Icon(Icons.grid_view_rounded, size: 20),
                              label: Text('Grid'),
                            ),
                            ButtonSegment(
                              value: UrlViewMode.icons,
                              icon: Icon(Icons.apps_rounded, size: 20),
                              label: Text('Compact'),
                            ),
                          ],
                          selected: {_layout},
                          onSelectionChanged: (s) {
                            if (s.isEmpty) return;
                            setState(() => _layout = s.first);
                          },
                        );
                        if (constraints.maxWidth < 400) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: child,
                          );
                        }
                        return child;
                      },
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'SORT BY',
                    child: DropdownButtonFormField<ChildFolderSort>(
                      key: ValueKey(_sort),
                      initialValue: _sort,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ChildFolderSort.titleAsc,
                          child: Text('Title (A–Z)'),
                        ),
                        DropdownMenuItem(
                          value: ChildFolderSort.titleDesc,
                          child: Text('Title (Z–A)'),
                        ),
                        DropdownMenuItem(
                          value: ChildFolderSort.itemCountDesc,
                          child: Text('Most links'),
                        ),
                        DropdownMenuItem(
                          value: ChildFolderSort.createdDesc,
                          child: Text('Recently added'),
                        ),
                        DropdownMenuItem(
                          value: ChildFolderSort.updatedDesc,
                          child: Text('Recently updated'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _sort = v);
                      },
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'VISIBILITY',
                    subtitle: 'Control whether archived folders appear in this list.',
                    child: FilterArchiveRow(
                      value: _includeArchived,
                      onChanged: (v) =>
                          setState(() => _includeArchived = v),
                      title: 'Include archived folders',
                      subtitle: 'When off, archived folders are hidden.',
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'DATE RANGE',
                    subtitle:
                        'Optional. Filters child folders by last updated date.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilterDateRow(
                          label: 'Updated after',
                          value: _updatedAfter,
                          onPickDate: () => _pickDate(isAfter: true),
                          trailingIsClear: _updatedAfter != null,
                          onTrailingPressed: () {
                            if (_updatedAfter == null) {
                              _pickDate(isAfter: true);
                            } else {
                              setState(() => _updatedAfter = null);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        FilterDateRow(
                          label: 'Updated before',
                          value: _updatedBefore,
                          onPickDate: () => _pickDate(isAfter: false),
                          trailingIsClear: _updatedBefore != null,
                          onTrailingPressed: () {
                            if (_updatedBefore == null) {
                              _pickDate(isAfter: false);
                            } else {
                              setState(() => _updatedBefore = null);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 6,
            shadowColor: Colors.black26,
            color: theme.colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
