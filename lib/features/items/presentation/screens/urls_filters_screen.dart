import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../collections/domain/collection_display_defaults.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_hub_notifier.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../domain/entities/item.dart';
import '../providers/items_hub_ui_notifier.dart';
import '../providers/items_providers.dart';
import '../widgets/filter_section_widgets.dart';

/// Full-screen Links tab filters (replaces [UrlsFilterSortSheet] modal).
class UrlsFiltersScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const UrlsFiltersScreen({
    super.key,
    required this.collectionId,
  });

  @override
  ConsumerState<UrlsFiltersScreen> createState() => _UrlsFiltersScreenState();
}

class _UrlsFiltersScreenState extends ConsumerState<UrlsFiltersScreen> {
  late UrlViewMode _view;
  late UrlSortOption _sort;
  late ItemStatus? _status;
  late bool _pinnedOnly;
  late bool _withDescriptionOnly;
  late bool _withImageOnly;
  late final TextEditingController _domainController;
  DateTime? _savedAfter;
  DateTime? _savedBefore;

  @override
  void initState() {
    super.initState();
    final itemsAsync = ref.read(itemsNotifierProvider(widget.collectionId));
    final state = itemsAsync.valueOrNull;
    final ui = ref.read(itemsHubUiNotifierProvider(widget.collectionId));
    _view = state?.viewMode ?? UrlViewMode.icons;
    _sort = state?.sortOption ?? UrlSortOption.dateAdded;
    _status = state?.statusFilter;
    _pinnedOnly = ui.urlPinnedOnly;
    _withDescriptionOnly = ui.urlWithDescriptionOnly;
    _withImageOnly = ui.urlWithImageOnly;
    _domainController = TextEditingController(text: ui.urlDomainQuery);
    _savedAfter = ui.urlSavedAfter;
    _savedBefore = ui.urlSavedBefore;
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _view = UrlViewMode.icons;
      _sort = UrlSortOption.dateAdded;
      _status = null;
      _pinnedOnly = false;
      _withDescriptionOnly = false;
      _withImageOnly = false;
      _domainController.clear();
      _savedAfter = null;
      _savedBefore = null;
    });
  }

  Future<void> _pickDate({required bool isAfter}) async {
    final now = DateTime.now();
    final initial = isAfter ? (_savedAfter ?? now) : (_savedBefore ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isAfter) {
        _savedAfter = picked;
      } else {
        _savedBefore = picked;
      }
    });
  }

  Future<void> _apply() async {
    final uiNotifier =
        ref.read(itemsHubUiNotifierProvider(widget.collectionId).notifier);
    uiNotifier.setUrlPinnedOnly(_pinnedOnly);
    uiNotifier.setUrlWithDescriptionOnly(_withDescriptionOnly);
    uiNotifier.setUrlWithImageOnly(_withImageOnly);
    uiNotifier.updateUrlDomainQuery(_domainController.text.trim());
    uiNotifier.setUrlSavedAfter(_savedAfter);
    uiNotifier.setUrlSavedBefore(_savedBefore);

    final notifier =
        ref.read(itemsNotifierProvider(widget.collectionId).notifier);
    await notifier.setViewMode(_view);
    await notifier.applySortAndStatusFromFilterSheet(
      sortOption: _sort,
      statusFilter: _status,
    );

    final collection = ref.read(collectionByIdProvider(widget.collectionId));
    if (collection != null) {
      await _persistCollectionDisplayDefaults(collection: collection);
    }

    if (mounted) context.pop();
  }

  Future<void> _persistCollectionDisplayDefaults({
    required Collection collection,
  }) async {
    final layout = switch (_view) {
      UrlViewMode.list => CollectionLayoutMode.list,
      UrlViewMode.cards => CollectionLayoutMode.grid,
      UrlViewMode.icons => CollectionLayoutMode.compactGrid,
    };

    final sort = switch (_sort) {
      UrlSortOption.position => CollectionItemsSortDefault.manual,
      UrlSortOption.dateAdded => CollectionItemsSortDefault.addedDesc,
      UrlSortOption.dateEdited => CollectionItemsSortDefault.lastOpenedDesc,
      UrlSortOption.mostVisited => CollectionItemsSortDefault.manual,
      UrlSortOption.alphabeticalAsc => CollectionItemsSortDefault.manual,
      UrlSortOption.alphabeticalDesc => CollectionItemsSortDefault.manual,
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
        title: const Text('Filter & sort'),
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
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('urls_filters_scroll'),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                8,
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
                              icon:
                                  Icon(Icons.view_list_rounded, size: 20),
                              label: Text('List'),
                            ),
                            ButtonSegment(
                              value: UrlViewMode.cards,
                              icon:
                                  Icon(Icons.grid_view_rounded, size: 20),
                              label: Text('Cards'),
                            ),
                            ButtonSegment(
                              value: UrlViewMode.icons,
                              icon: Icon(Icons.apps_rounded, size: 20),
                              label: Text('Icons'),
                            ),
                          ],
                          selected: {_view},
                          onSelectionChanged: (s) {
                            if (s.isEmpty) return;
                            setState(() => _view = s.first);
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
                    child: DropdownButtonFormField<UrlSortOption>(
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
                          value: UrlSortOption.position,
                          child: Text('Manual order'),
                        ),
                        DropdownMenuItem(
                          value: UrlSortOption.dateAdded,
                          child: Text('Recently added'),
                        ),
                        DropdownMenuItem(
                          value: UrlSortOption.dateEdited,
                          child: Text('Recently edited'),
                        ),
                        DropdownMenuItem(
                          value: UrlSortOption.mostVisited,
                          child: Text('Most visited'),
                        ),
                        DropdownMenuItem(
                          value: UrlSortOption.alphabeticalAsc,
                          child: Text('Alphabetical A-Z'),
                        ),
                        DropdownMenuItem(
                          value: UrlSortOption.alphabeticalDesc,
                          child: Text('Alphabetical Z-A'),
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
                    title: 'STATUS',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _status == null,
                          onSelected: (_) => setState(() => _status = null),
                        ),
                        FilterChip(
                          label: const Text('Unread'),
                          selected: _status == ItemStatus.unread,
                          onSelected: (_) => setState(
                              () => _status = ItemStatus.unread),
                        ),
                        FilterChip(
                          label: const Text('Read'),
                          selected: _status == ItemStatus.read,
                          onSelected: (_) =>
                              setState(() => _status = ItemStatus.read),
                        ),
                        FilterChip(
                          label: const Text('Archived'),
                          selected: _status == ItemStatus.archived,
                          onSelected: (_) => setState(
                              () => _status = ItemStatus.archived),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'MORE',
                    subtitle: 'Narrow links by extras and metadata.',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Pinned only'),
                          selected: _pinnedOnly,
                          onSelected: (v) =>
                              setState(() => _pinnedOnly = v),
                        ),
                        FilterChip(
                          label: const Text('Has description'),
                          selected: _withDescriptionOnly,
                          onSelected: (v) =>
                              setState(() => _withDescriptionOnly = v),
                        ),
                        FilterChip(
                          label: const Text('Has image'),
                          selected: _withImageOnly,
                          onSelected: (v) =>
                              setState(() => _withImageOnly = v),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'DOMAIN',
                    subtitle: 'Match links whose host contains this text.',
                    child: TextField(
                      controller: _domainController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Domain contains',
                        hintText: 'e.g. github.com',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  SizedBox(height: FilterSectionTokens.sectionGap),
                  FilterSectionCard(
                    title: 'DATE RANGE',
                    subtitle:
                        'Optional. Filters links by saved date (created).',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilterDateRow(
                          label: 'Saved after',
                          value: _savedAfter,
                          onPickDate: () => _pickDate(isAfter: true),
                          trailingIsClear: _savedAfter != null,
                          onTrailingPressed: () {
                            if (_savedAfter == null) {
                              _pickDate(isAfter: true);
                            } else {
                              setState(() => _savedAfter = null);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        FilterDateRow(
                          label: 'Saved before',
                          value: _savedBefore,
                          onPickDate: () => _pickDate(isAfter: false),
                          trailingIsClear: _savedBefore != null,
                          onTrailingPressed: () {
                            if (_savedBefore == null) {
                              _pickDate(isAfter: false);
                            } else {
                              setState(() => _savedBefore = null);
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
