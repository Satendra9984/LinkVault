import 'package:flutter/material.dart';

import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/item.dart';
import '../providers/items_providers.dart';

/// Sort order for nested folder lists (client-side).
enum ChildFolderSort {
  titleAsc,
  titleDesc,
  itemCountDesc,
  createdDesc,
  updatedDesc,
}

/// Bottom sheet: view mode, sort, status, and extra client filters for URLs.
class UrlsFilterSortSheet extends StatefulWidget {
  final ItemsState state;
  final bool pinnedOnly;
  final bool withDescriptionOnly;
  final bool withImageOnly;
  final String domainFilter;
  final DateTime? savedAfter;
  final DateTime? savedBefore;
  final Future<void> Function({
    required UrlViewMode viewMode,
    required UrlSortOption sortOption,
    required ItemStatus? statusFilter,
    required bool pinnedOnly,
    required bool withDescriptionOnly,
    required bool withImageOnly,
    required String domainFilter,
    required DateTime? savedAfter,
    required DateTime? savedBefore,
  }) onApply;

  const UrlsFilterSortSheet({
    super.key,
    required this.state,
    required this.onApply,
    this.pinnedOnly = false,
    this.withDescriptionOnly = false,
    this.withImageOnly = false,
    this.domainFilter = '',
    this.savedAfter,
    this.savedBefore,
  });

  @override
  State<UrlsFilterSortSheet> createState() => _UrlsFilterSortSheetState();
}

class _UrlsFilterSortSheetState extends State<UrlsFilterSortSheet> {
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
    _view = widget.state.viewMode;
    _sort = widget.state.sortOption;
    _status = widget.state.statusFilter;
    _pinnedOnly = widget.pinnedOnly;
    _withDescriptionOnly = widget.withDescriptionOnly;
    _withImageOnly = widget.withImageOnly;
    _domainController = TextEditingController(text: widget.domainFilter);
    _savedAfter = widget.savedAfter;
    _savedBefore = widget.savedBefore;
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _view = UrlViewMode.list;
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

  Future<void> _pickDate({
    required bool isAfter,
  }) async {
    final now = DateTime.now();
    final initial = isAfter
        ? (_savedAfter ?? now)
        : (_savedBefore ?? now);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final maxSheetWidth = 520.0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final maxHeight = viewport.maxHeight * 0.85;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxSheetWidth,
                maxHeight: maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: subtle.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter & sort',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel(theme, 'VIEW'),
                  const SizedBox(height: 8),
                  LayoutBuilder(
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
                      if (constraints.maxWidth < 340) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: child,
                        );
                      }
                      return child;
                    },
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel(theme, 'SORT BY'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UrlSortOption>(
                    key: ValueKey(_sort),
                    initialValue: _sort,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
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
                  const SizedBox(height: 16),
                  _sectionLabel(theme, 'STATUS'),
                  const SizedBox(height: 8),
                  Wrap(
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
                        onSelected: (_) =>
                            setState(() => _status = ItemStatus.unread),
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
                        onSelected: (_) =>
                            setState(() => _status = ItemStatus.archived),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel(theme, 'MORE'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Pinned only'),
                        selected: _pinnedOnly,
                        onSelected: (v) => setState(() => _pinnedOnly = v),
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
                        onSelected: (v) => setState(() => _withImageOnly = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _domainController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Domain contains',
                      hintText: 'e.g. github.com',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel(theme, 'DATE RANGE'),
                  const SizedBox(height: 8),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, size: 20),
                    title: Text(
                      _savedAfter == null
                          ? 'Saved after'
                          : 'Saved after: ${MaterialLocalizations.of(context).formatShortDate(_savedAfter!)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _savedAfter == null ? Icons.edit_calendar : Icons.clear,
                      ),
                      onPressed: () {
                        if (_savedAfter == null) {
                          _pickDate(isAfter: true);
                        } else {
                          setState(() => _savedAfter = null);
                        }
                      },
                    ),
                    onTap: () => _pickDate(isAfter: true),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, size: 20),
                    title: Text(
                      _savedBefore == null
                          ? 'Saved before'
                          : 'Saved before: ${MaterialLocalizations.of(context).formatShortDate(_savedBefore!)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _savedBefore == null ? Icons.edit_calendar : Icons.clear,
                      ),
                      onPressed: () {
                        if (_savedBefore == null) {
                          _pickDate(isAfter: false);
                        } else {
                          setState(() => _savedBefore = null);
                        }
                      },
                    ),
                    onTap: () => _pickDate(isAfter: false),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          await widget.onApply(
                            viewMode: _view,
                            sortOption: _sort,
                            statusFilter: _status,
                            pinnedOnly: _pinnedOnly,
                            withDescriptionOnly: _withDescriptionOnly,
                            withImageOnly: _withImageOnly,
                            domainFilter: _domainController.text.trim(),
                            savedAfter: _savedAfter,
                            savedBefore: _savedBefore,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Bottom sheet: layout, sort, and visibility for nested folders.
class ChildFoldersFilterSortSheet extends StatefulWidget {
  final UrlViewMode currentLayout;
  final ChildFolderSort currentSort;
  final bool includeArchived;
  final Set<String> selectedCategories;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final Future<void> Function({
    required UrlViewMode layout,
    required ChildFolderSort sort,
    required bool includeArchived,
    required Set<String> categories,
    required DateTime? updatedAfter,
    required DateTime? updatedBefore,
  }) onApply;

  const ChildFoldersFilterSortSheet({
    super.key,
    required this.currentLayout,
    required this.currentSort,
    required this.includeArchived,
    this.selectedCategories = const {},
    this.updatedAfter,
    this.updatedBefore,
    required this.onApply,
  });

  @override
  State<ChildFoldersFilterSortSheet> createState() =>
      _ChildFoldersFilterSortSheetState();
}

class _ChildFoldersFilterSortSheetState extends State<ChildFoldersFilterSortSheet> {
  late UrlViewMode _layout;
  late ChildFolderSort _sort;
  late bool _includeArchived;
  late Set<String> _categories;
  DateTime? _updatedAfter;
  DateTime? _updatedBefore;
  static const List<String> _allCategories = [
    'Favorites',
    'General',
    'Development',
    'Reading',
    'Design',
    'Ideas',
    'Work',
    'Goals',
    'Learning',
    'Research',
    'Personal',
    'Finance',
    'Health',
    'Travel',
  ];

  @override
  void initState() {
    super.initState();
    _layout = widget.currentLayout;
    _sort = widget.currentSort;
    _includeArchived = widget.includeArchived;
    _categories = {...widget.selectedCategories};
    _updatedAfter = widget.updatedAfter;
    _updatedBefore = widget.updatedBefore;
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
    final initial = isAfter ? (_updatedAfter ?? now) : (_updatedBefore ?? now);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final maxSheetWidth = 520.0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final maxHeight = viewport.maxHeight * 0.85;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxSheetWidth,
                maxHeight: maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: subtle.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Folders',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Layout, sort order, and which folders to show.',
                    style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CATEGORY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: subtle,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allCategories
                        .map(
                          (category) => FilterChip(
                            label: Text(category),
                            selected: _categories.contains(category),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _categories.add(category);
                                } else {
                                  _categories.remove(category);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'LAYOUT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: subtle,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
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
                      if (constraints.maxWidth < 340) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: child,
                        );
                      }
                      return child;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SORT BY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: subtle,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ChildFolderSort>(
                    key: ValueKey(_sort),
                    initialValue: _sort,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
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
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    value: _includeArchived,
                    onChanged: (v) => setState(() => _includeArchived = v),
                    title: const Text('Include archived folders'),
                    subtitle: Text(
                      'When off, archived folders are hidden.',
                      style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DATE RANGE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: subtle,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, size: 20),
                    title: Text(
                      _updatedAfter == null
                          ? 'Updated after'
                          : 'Updated after: ${MaterialLocalizations.of(context).formatShortDate(_updatedAfter!)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(_updatedAfter == null ? Icons.edit_calendar : Icons.clear),
                      onPressed: () {
                        if (_updatedAfter == null) {
                          _pickDate(isAfter: true);
                        } else {
                          setState(() => _updatedAfter = null);
                        }
                      },
                    ),
                    onTap: () => _pickDate(isAfter: true),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, size: 20),
                    title: Text(
                      _updatedBefore == null
                          ? 'Updated before'
                          : 'Updated before: ${MaterialLocalizations.of(context).formatShortDate(_updatedBefore!)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(_updatedBefore == null ? Icons.edit_calendar : Icons.clear),
                      onPressed: () {
                        if (_updatedBefore == null) {
                          _pickDate(isAfter: false);
                        } else {
                          setState(() => _updatedBefore = null);
                        }
                      },
                    ),
                    onTap: () => _pickDate(isAfter: false),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          await widget.onApply(
                            layout: _layout,
                            sort: _sort,
                            includeArchived: _includeArchived,
                            categories: _categories,
                            updatedAfter: _updatedAfter,
                            updatedBefore: _updatedBefore,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Bottom sheet: collection actions (replaces overflow menu).
class CollectionHubActionsSheet extends StatelessWidget {
  final String title;
  final String metadata;
  final bool isRoot;
  final bool isLinksTab;
  final bool isReorderMode;
  final bool showShare;
  final VoidCallback onAddSubfolder;
  final VoidCallback onAddLink;
  final VoidCallback onEditCollection;
  final VoidCallback onTogglePinCollection;
  final VoidCallback onToggleArchiveCollection;
  final VoidCallback onViewSettings;
  final VoidCallback onDeleteCollection;
  final VoidCallback onToggleReorderLinks;
  final VoidCallback onShare;

  const CollectionHubActionsSheet({
    super.key,
    required this.title,
    required this.metadata,
    required this.isRoot,
    required this.isLinksTab,
    required this.isReorderMode,
    this.showShare = false,
    required this.onAddSubfolder,
    required this.onAddLink,
    required this.onEditCollection,
    required this.onTogglePinCollection,
    required this.onToggleArchiveCollection,
    required this.onViewSettings,
    required this.onDeleteCollection,
    required this.onToggleReorderLinks,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final maxHeight = viewport.maxHeight * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: subtle.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metadata,
                    style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                  ),
                ],
              ),
            ),
            Divider(color: subtle.withValues(alpha: 0.4), height: 1),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Add subfolder'),
              onTap: () {
                Navigator.pop(context);
                onAddSubfolder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Add link'),
              onTap: () {
                Navigator.pop(context);
                onAddLink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              subtitle: const Text('Rename, cover, or settings'),
              onTap: () {
                Navigator.pop(context);
                onEditCollection();
              },
            ),
            if (!isRoot)
              ListTile(
                leading: Icon(
                  isReorderMode
                      ? Icons.check_circle_outline
                      : Icons.drag_handle_rounded,
                ),
                title: Text(
                  isReorderMode ? 'Done reordering links' : 'Reorder links',
                ),
                subtitle: Text(
                  isLinksTab
                      ? 'Drag links in list view.'
                      : 'Switches to Links tab first.',
                  style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggleReorderLinks();
                },
              ),
            Divider(color: subtle.withValues(alpha: 0.4), height: 1),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin collection'),
              onTap: () {
                Navigator.pop(context);
                onTogglePinCollection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive collection'),
              onTap: () {
                Navigator.pop(context);
                onToggleArchiveCollection();
              },
            ),
            Divider(color: subtle.withValues(alpha: 0.4), height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('View settings'),
              onTap: () {
                Navigator.pop(context);
                onViewSettings();
              },
            ),
            if (showShare)
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
            Divider(color: subtle.withValues(alpha: 0.4), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete collection',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onDeleteCollection();
              },
            ),
                ],
              ),
            ),
          );
        },
        ),
    );
  }
}
