import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../../../core/theme/color_palette.dart';
import '../providers/collections_providers.dart';
import '../providers/forms/collection_form_notifier.dart';
import '../../../items/presentation/providers/items_providers.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(collectionFormNotifierProvider.notifier)
            .initialize(widget.collectionId);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen(collectionFormNotifierProvider, (previous, next) {
      if (next.isSuccess && mounted) {
        context.pop();
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    Color baseColor;
    try {
      baseColor = Color(int.parse(state.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      baseColor = const Color(0xFFB3E0FF);
    }

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
                    'Edit list',
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

                          // Category Selector
                          GestureDetector(
                            onTap: () => _showCategoryPicker(context, isDark,
                                state.category, baseColor, notifier),
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
                                      Text('Category',
                                          style: TextStyle(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                              fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              isDark
                                                  ? baseColor
                                                  : Color.lerp(baseColor,
                                                          Colors.black, 0.6) ??
                                                      baseColor,
                                              BlendMode.srcIn,
                                            ),
                                            child: Text(
                                              AppCategories.getIconForCategory(
                                                  state.category),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            state.category,
                                            style: TextStyle(
                                                color: textColor, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: theme.colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Color Selector
                          GestureDetector(
                            onTap: () => _showColorPicker(
                                context, isDark, state.colorHex, notifier),
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
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: baseColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _showIconPicker(context, notifier),
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
                                  Text('Icon',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16)),
                                  Text(state.iconName,
                                      style: const TextStyle(fontSize: 20)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _showParentPicker(context,
                                collectionsAsync, state.parentId, notifier),
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
                                        state.parentId == null
                                            ? 'Root (Home)'
                                            : 'Nested collection',
                                        style: TextStyle(
                                            color: textColor, fontSize: 16),
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
                          const Divider(),
                          const SizedBox(height: 16),
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
              final deleteUseCase = ref.read(deleteItemUseCaseProvider);
              for (final id in _selectedItems) {
                await deleteUseCase.call(id);
              }
              setState(() {
                _selectedItems.clear();
              });
              ref
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
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref
                  .read(deleteCollectionUseCaseProvider)
                  .call(widget.collectionId);
              context.pop(); // dialog
              context.pop(); // screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, bool isDark,
      String selectedCategory, Color baseColor, dynamic notifier) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final tileColor = theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back,
                            color: theme.colorScheme.primary),
                      ),
                      Text('Choose category',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      Icon(Icons.more_vert, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: AppCategories.list.length,
                    itemBuilder: (context, index) {
                      final category = AppCategories.list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () {
                            notifier.updateCategory(category);
                            context.pop();
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? baseColor.withValues(alpha: 0.15)
                                        : baseColor.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        isDark
                                            ? baseColor
                                            : Color.lerp(baseColor,
                                                    Colors.black, 0.6) ??
                                                baseColor,
                                        BlendMode.srcIn,
                                      ),
                                      child: Text(
                                        AppCategories.getIconForCategory(
                                            category),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(category,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, bool isDark, String selectedColor,
      dynamic notifier) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back,
                            color: theme.colorScheme.primary),
                      ),
                      Text('Choose colour',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Center(
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children:
                            AppColors.collectionColorHexes.map((colorHex) {
                          Color color;
                          try {
                            color = Color(
                                int.parse(colorHex.replaceFirst('#', '0xFF')));
                          } catch (e) {
                            color = const Color(0xFFB3E0FF);
                          }
                          final isSelected = colorHex == selectedColor;
                          return GestureDetector(
                            onTap: () {
                              notifier.updateColor(colorHex);
                              context.pop();
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? Border.all(color: textColor, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIconPicker(BuildContext context, dynamic notifier) {
    final icons = {
      for (final category in AppCategories.list)
        AppCategories.getIconForCategory(category),
      '📁',
      '🗂️',
      '🧩',
      '📰',
      '🔖',
    }.toList();
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

  void _showParentPicker(BuildContext context, AsyncValue<List<Collection>> data,
      String? selectedParentId, dynamic notifier) {
    final collections = data.valueOrNull ?? const <Collection>[];
    final excluded = excludedParentIdsForEditing(
      editingId: widget.collectionId,
      allCollections: collections,
    );
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Root (Home)'),
              trailing: selectedParentId == null
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                notifier.updateParentId(null);
                context.pop();
              },
            ),
            ...collections
                .where((collection) => !excluded.contains(collection.id))
                .map((collection) => ListTile(
                      leading: Text(collection.iconName),
                      title: Text(collection.title),
                      subtitle: Text(collection.category),
                      trailing: selectedParentId == collection.id
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        notifier.updateParentId(collection.id);
                        context.pop();
                      },
                    )),
          ],
        ),
      ),
    );
  }
}
