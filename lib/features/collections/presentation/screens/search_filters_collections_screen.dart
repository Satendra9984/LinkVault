import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../items/presentation/providers/items_list_models.dart';
import '../../../items/presentation/widgets/filter_section_widgets.dart';
import '../../../items/presentation/widgets/folder_filter_category_sheet.dart';
import '../providers/search/global_search_notifier.dart';

/// Global search — Collections tab filters (parity with hub folder filters).
class SearchFiltersCollectionsScreen extends ConsumerStatefulWidget {
  const SearchFiltersCollectionsScreen({super.key});

  @override
  ConsumerState<SearchFiltersCollectionsScreen> createState() =>
      _SearchFiltersCollectionsScreenState();
}

class _SearchFiltersCollectionsScreenState
    extends ConsumerState<SearchFiltersCollectionsScreen> {
  late UrlViewMode _layout;
  late ChildFolderSort _sort;
  late bool _includeArchived;
  late bool _showOnlyPrivate;
  late Set<String> _categories;
  DateTime? _updatedAfter;
  DateTime? _updatedBefore;

  @override
  void initState() {
    super.initState();
    final gs = ref.read(globalSearchNotifierProvider);
    _layout = gs.collectionsViewMode;
    _sort = gs.collectionsFolderSort;
    _includeArchived = gs.collectionsIncludeArchived;
    _showOnlyPrivate = gs.collectionsShowOnlyPrivate;
    _categories = {...gs.collectionsSelectedCategories};
    _updatedAfter = gs.collectionsUpdatedAfter;
    _updatedBefore = gs.collectionsUpdatedBefore;
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
      _layout = UrlViewMode.icons;
      _sort = ChildFolderSort.titleAsc;
      _includeArchived = false;
      _showOnlyPrivate = false;
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

  void _apply() {
    final n = ref.read(globalSearchNotifierProvider.notifier);
    n.setCollectionsViewMode(_layout);
    n.setCollectionsFolderSort(_sort);
    n.setCollectionsIncludeArchived(_includeArchived);
    n.setCollectionsShowOnlyPrivate(_showOnlyPrivate);
    n.setCollectionsSelectedCategories(_categories);
    n.setCollectionsUpdatedAfter(_updatedAfter);
    n.setCollectionsUpdatedBefore(_updatedBefore);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Collections'),
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
              'Sort, visibility, and which collections match global search.',
              style: theme.textTheme.bodySmall?.copyWith(color: subtle),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('global_search_collections_filters'),
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
                    title: 'VIEW',
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
                              label: Text('Icons'),
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
                            'No category filter — all collections shown',
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
                    subtitle:
                        'Control archived and shared collections in search results.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilterArchiveRow(
                          value: _includeArchived,
                          onChanged: (v) =>
                              setState(() => _includeArchived = v),
                          title: 'Include archived collections',
                          subtitle: 'When off, archived collections are hidden.',
                        ),
                        const SizedBox(height: 12),
                        FilterArchiveRow(
                          value: _showOnlyPrivate,
                          onChanged: (v) =>
                              setState(() => _showOnlyPrivate = v),
                          title: 'Private collections only',
                          subtitle: 'When on, shared collections are hidden.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'DATE RANGE',
                    subtitle:
                        'Optional. Filters collections by last updated date.',
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
