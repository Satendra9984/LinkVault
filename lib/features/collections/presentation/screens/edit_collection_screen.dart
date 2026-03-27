import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../../../core/theme/color_palette.dart';
import '../providers/collections_providers.dart';
import '../providers/collections_hub_notifier.dart';
import '../providers/forms/collection_form_notifier.dart';
import '../widgets/collection_category_sheet.dart';
import '../widgets/collection_color_sheet.dart';
import '../widgets/collection_extended_fields_section.dart';
import '../../../items/presentation/providers/items_providers.dart';
import '../../../items/presentation/providers/items_hub_notifier.dart';
import '../../domain/collection_parent_validation.dart';
import '../../domain/entities/collection.dart';

class EditCollectionScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const EditCollectionScreen({
    super.key,
    required this.collectionId,
  });

  @override
  ConsumerState<EditCollectionScreen> createState() =>
      _EditCollectionScreenState();
}

class _EditCollectionScreenState extends ConsumerState<EditCollectionScreen> {
  final ScrollController _scrollController = ScrollController();
  Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await ref
            .read(collectionsHubNotifierProvider.notifier)
            .recordAccess(widget.collectionId);
        ref
            .read(collectionFormNotifierProvider.notifier)
            .initialize(widget.collectionId);
        await ref
            .read(itemsNotifierProvider(widget.collectionId).notifier)
            .ensureUrlsLoaded();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionFormNotifierProvider);
    final notifier = ref.read(collectionFormNotifierProvider.notifier);
    final collectionsAsync = ref.watch(collectionsListProvider);
    final libraryRootAsync = ref.watch(libraryRootCollectionProvider);
    final libraryRootId = libraryRootAsync.valueOrNull?.id;
    final isLibraryRoot =
        libraryRootId != null && widget.collectionId == libraryRootId;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen(collectionFormNotifierProvider, (previous, next) {
      if (next.isSuccess && mounted) {
        ref.invalidate(collectionsListProvider);
        context.pop();
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final accentColor =
        AppColors.collectionCoverEmojiTint(state.colorHex, theme);
    final naturalEmoji =
        AppColors.isCollectionCoverNoColor(state.colorHex);

    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final inputBgColor = theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back,
                        color: theme.colorScheme.primary),
                  ),
                  Text(
                    'Edit collection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditOptionsModal(context),
                    child:
                        Icon(Icons.more_vert, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: state.isInit
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Controllerless Title Input
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: SmartFormField(
                              hint: 'List title',
                              initialValue: state.title,
                              onChanged: notifier.updateTitle,
                              errorText: state.fieldErrors['title'],
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          CollectionExtendedFieldsSection(
                            inputBgColor: inputBgColor,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 16),

                          // Category row: emoji vs category sheet
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Category',
                                          style: TextStyle(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Semantics(
                                            button: true,
                                            label: 'Change emoji',
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                onTap: () => _showIconPicker(
                                                    context, notifier),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: naturalEmoji
                                                      ? Text(
                                                          state.iconName,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16),
                                                        )
                                                      : ColorFiltered(
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                            isDark
                                                                ? accentColor
                                                                : Color.lerp(
                                                                        accentColor,
                                                                        Colors
                                                                            .black,
                                                                        0.6) ??
                                                                    accentColor,
                                                            BlendMode.srcIn,
                                                          ),
                                                          child: Text(
                                                            state.iconName,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () =>
                                                    CollectionCategorySheet
                                                        .showPicker(
                                                  rootContext: context,
                                                  ref: ref,
                                                  isDark: isDark,
                                                  accentColor: accentColor,
                                                  colorHex: state.colorHex,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 4),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      state.category,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        CollectionCategorySheet.showPicker(
                                      rootContext: context,
                                      ref: ref,
                                      isDark: isDark,
                                      accentColor: accentColor,
                                      colorHex: state.colorHex,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.keyboard_arrow_down,
                                          color: theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.fieldErrors['category'] != null) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                state.fieldErrors['category']!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Color Selector
                          GestureDetector(
                            onTap: () => CollectionColorSheet.showPicker(
                              context: context,
                              selectedColor: state.colorHex,
                              onSelect: notifier.updateColor,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: inputBgColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Cover colour',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16)),
                                  CollectionCoverSwatch(
                                      colorHex: state.colorHex),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (isLibraryRoot)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: inputBgColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parent collection',
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Top-level (${libraryRootAsync.valueOrNull?.title ?? 'Library'})',
                                    style: TextStyle(
                                        color: textColor, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => _showParentPicker(
                                context,
                                collectionsAsync,
                                state.parentId,
                                notifier,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: inputBgColor,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Parent collection',
                                            style: TextStyle(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 12)),
                                        const SizedBox(height: 2),
                                        Text(
                                          (libraryRootId != null &&
                                                  state.parentId ==
                                                      libraryRootId)
                                              ? (libraryRootAsync
                                                      .valueOrNull?.title ??
                                                  'Library')
                                              : (state.parentTitleHint !=
                                                          null &&
                                                      state.parentTitleHint!
                                                          .isNotEmpty
                                                  ? state.parentTitleHint!
                                                  : 'Nested folder'),
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.keyboard_arrow_down,
                                        color: theme.colorScheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Shared Toggle — hidden until Sprint 10 social features ship
                          if (AppConfig.instance.isDev)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Shared Collection',
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Allow friends to view this collection',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12)),
                              value: state.isShared,
                              activeThumbColor: theme.colorScheme.primary,
                              onChanged: notifier.updateShared,
                            ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Pin collection',
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold)),
                            value: state.isPinned,
                            activeThumbColor: theme.colorScheme.primary,
                            onChanged: notifier.updatePinned,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Archive collection',
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold)),
                            value: state.isArchived,
                            activeThumbColor: theme.colorScheme.primary,
                            onChanged: notifier.updateArchived,
                          ),

                          const SizedBox(height: 32),
                          if (!isLibraryRoot) ...[
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Danger zone',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Deleting this collection will also delete all nested subfolders and links inside them.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _deleteCollection,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete collection'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side:
                                      BorderSide(color: theme.colorScheme.error),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildItemsManagementSection(context),
                        ],
                      ),
                    ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.only(
                  left: 32.0, right: 32.0, bottom: 24.0, top: 8.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.isSubmitting || state.isInit
                      ? null
                      : () => notifier.submit(
                          existingCollectionId: widget.collectionId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor:
                        theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsManagementSection(BuildContext context) {
    final itemsAsync = ref.watch(itemsNotifierProvider(widget.collectionId));

    return itemsAsync.when(
      data: (state) {
        final items = state.items;
        if (items.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items (${items.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (_selectedItems.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmBatchDelete(context),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedItems.length == items.length) {
                          _selectedItems.clear();
                        } else {
                          _selectedItems = items.map((e) => e.id).toSet();
                        }
                      });
                    },
                    child: Text(_selectedItems.length == items.length
                        ? 'Deselect all'
                        : 'Select all'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = _selectedItems.contains(item.id);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedItems.add(item.id);
                      } else {
                        _selectedItems.remove(item.id);
                      }
                    });
                  },
                  title: Text(item.title),
                  subtitle: Text(item.status.name),
                );
              },
            ),
            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Error loading items: $e'),
    );
  }

  void _confirmBatchDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Items?'),
        content: Text(
            'Are you sure you want to delete ${_selectedItems.length} items? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              context.pop();
              for (final id in _selectedItems) {
                await ref.read(itemsHubNotifierProvider.notifier).deleteItem(
                      collectionId: widget.collectionId,
                      itemId: id,
                    );
              }
              setState(() {
                _selectedItems.clear();
              });
              await ref
                  .read(itemsNotifierProvider(widget.collectionId).notifier)
                  .refresh();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Collection',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                context.pop();
                _deleteCollection();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCollection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: const Text(
          'This cannot be undone. All child collections and links under this collection will be permanently deleted.',
        ),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref
                  .read(collectionsHubNotifierProvider.notifier)
                  .deleteCollection(widget.collectionId);
              context.pop(); // dialog
              context.pop(); // screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showIconPicker(BuildContext context, CollectionFormNotifier notifier) {
    final icons = AppCategories.allPickerEmojis;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: icons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              notifier.updateIconName(icons[index]);
              context.pop();
            },
            child: Center(
              child: Text(icons[index], style: const TextStyle(fontSize: 24)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showParentPicker(BuildContext context,
      AsyncValue<List<Collection>> data, String? selectedParentId,
      CollectionFormNotifier notifier) async {
    final collections = data.valueOrNull ?? const <Collection>[];
    final excluded = excludedParentIdsForEditing(
      editingId: widget.collectionId,
      allCollections: collections,
    );
    final root = await ref.read(libraryRootCollectionProvider.future);
    if (!context.mounted) return;
    final rootId = root.id;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(root.title),
              trailing: selectedParentId == rootId
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateParentId(rootId, titleHint: root.title);
                context.pop();
              },
            ),
            ...collections
                .where((collection) =>
                    !excluded.contains(collection.id) &&
                    collection.id != rootId)
                .map((collection) => ListTile(
                      leading: Text(collection.iconName),
                      title: Text(collection.title),
                      subtitle: Text(collection.category),
                      trailing: selectedParentId == collection.id
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        notifier.updateParentId(collection.id,
                            titleHint: collection.title);
                        context.pop();
                      },
                    )),
          ],
        ),
      ),
    );
  }
}
