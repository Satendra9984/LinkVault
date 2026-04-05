import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/url_sort_option.dart';
import '../../../items/presentation/providers/items_list_models.dart';
import '../../../items/presentation/widgets/filter_section_widgets.dart';
import '../providers/search/global_search_notifier.dart';

/// Global search — Links tab filters (parity with hub URL filters; no collection persistence).
class SearchFiltersLinksScreen extends ConsumerStatefulWidget {
  const SearchFiltersLinksScreen({super.key});

  @override
  ConsumerState<SearchFiltersLinksScreen> createState() =>
      _SearchFiltersLinksScreenState();
}

class _SearchFiltersLinksScreenState
    extends ConsumerState<SearchFiltersLinksScreen> {
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
    final gs = ref.read(globalSearchNotifierProvider);
    _view = gs.linksViewMode;
    _sort = gs.linksSortOption;
    _status = gs.linksStatusFilter;
    _pinnedOnly = gs.linksPinnedOnly;
    _withDescriptionOnly = gs.linksWithDescriptionOnly;
    _withImageOnly = gs.linksWithImageOnly;
    _domainController = TextEditingController(text: gs.linksDomainQuery);
    _savedAfter = gs.linksSavedAfter;
    _savedBefore = gs.linksSavedBefore;
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

  void _apply() {
    final n = ref.read(globalSearchNotifierProvider.notifier);
    n.setLinksViewMode(_view);
    n.setLinksSortOption(_sort);
    n.setLinksStatusFilter(_status);
    n.setLinksPinnedOnly(_pinnedOnly);
    n.setLinksWithDescriptionOnly(_withDescriptionOnly);
    n.setLinksWithImageOnly(_withImageOnly);
    n.setLinksDomainQuery(_domainController.text.trim());
    n.setLinksSavedAfter(_savedAfter);
    n.setLinksSavedBefore(_savedBefore);
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
              key: const PageStorageKey('global_search_links_filters'),
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
