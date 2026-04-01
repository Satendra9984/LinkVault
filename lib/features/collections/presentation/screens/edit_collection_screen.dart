import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../../../core/theme/color_palette.dart';
import '../providers/collections_providers.dart';
import '../providers/collections_hub_notifier.dart';
import '../providers/forms/collection_form_notifier.dart';
import '../widgets/collection_category_sheet.dart';
import '../widgets/collection_color_sheet.dart';
import '../widgets/collection_extended_fields_section.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await ref
            .read(collectionsHubNotifierProvider.notifier)
            .recordAccess(widget.collectionId);
        ref
            .read(collectionFormNotifierProvider.notifier)
            .initialize(widget.collectionId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 48,
                      child: Icon(Icons.arrow_back,
                          color: theme.colorScheme.primary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Edit collection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  title: Text('Pin collection',
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold)),
                                  value: state.isPinned,
                                  activeThumbColor: theme.colorScheme.primary,
                                  onChanged: notifier.updatePinned,
                                ),
                                SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  title: Text('Archive collection',
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold)),
                                  value: state.isArchived,
                                  activeThumbColor: theme.colorScheme.primary,
                                  onChanged: notifier.updateArchived,
                                ),
                              ],
                            ),
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
