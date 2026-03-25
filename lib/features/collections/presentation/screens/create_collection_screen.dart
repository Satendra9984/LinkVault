import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../../../core/theme/color_palette.dart';
import '../providers/forms/collection_form_notifier.dart';
import '../providers/collections_providers.dart';
import '../widgets/collection_category_sheet.dart';
import '../widgets/collection_color_sheet.dart';
import '../widgets/collection_extended_fields_section.dart';
import '../../domain/entities/collection.dart';

class CreateCollectionScreen extends ConsumerStatefulWidget {
  final String? parentId;

  /// When starting from a folder screen, pass the parent so the form can show its title.
  final Collection? parentCollection;

  const CreateCollectionScreen({
    super.key,
    this.parentId,
    this.parentCollection,
  });

  @override
  ConsumerState<CreateCollectionScreen> createState() =>
      _CreateCollectionScreenState();
}

class _CreateCollectionScreenState
    extends ConsumerState<CreateCollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifier = ref.read(collectionFormNotifierProvider.notifier);
        final effectiveParentId =
            widget.parentId ?? widget.parentCollection?.id;
        notifier.initialize(
          null,
          parentIdForNew: effectiveParentId,
          parentTitleHint: widget.parentCollection?.title,
        );
      }
    });
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
        // Refetch so Home updates even if Realtime publication is missing or delayed.
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
    final naturalEmoji = AppColors.isCollectionCoverNoColor(state.colorHex);

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
                    'New list',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showParentPicker(
                          context, collectionsAsync, state.parentId, notifier),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: inputBgColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parent collection',
                                    style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  state.parentId == null
                                      ? 'Root (Home)'
                                      : (state.parentTitleHint != null &&
                                              state.parentTitleHint!.isNotEmpty
                                          ? state.parentTitleHint!
                                          : 'Nested folder'),
                                  style:
                                      TextStyle(color: textColor, fontSize: 16),
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
                        autofocus: true,
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category row: emoji opens emoji picker; label/chevron open category sheet.
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Category',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: naturalEmoji
                                                ? Text(
                                                    state.iconName,
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  )
                                                : ColorFiltered(
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      isDark
                                                          ? accentColor
                                                          : Color.lerp(
                                                                  accentColor,
                                                                  Colors.black,
                                                                  0.6) ??
                                                              accentColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                    child: Text(
                                                      state.iconName,
                                                      style: const TextStyle(
                                                          fontSize: 16),
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
                                          onTap: () => CollectionCategorySheet
                                              .showPicker(
                                            rootContext: context,
                                            ref: ref,
                                            isDark: isDark,
                                            accentColor: accentColor,
                                            colorHex: state.colorHex,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 4),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
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
                              onTap: () => CollectionCategorySheet.showPicker(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cover colour',
                                style:
                                    TextStyle(color: textColor, fontSize: 16)),
                            CollectionCoverSwatch(colorHex: state.colorHex),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    CollectionExtendedFieldsSection(
                      inputBgColor: inputBgColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 32),
                    // Shared Toggle — hidden until Sprint 10 social features ship
                    // if (AppConfig.instance.isDev)
                    //   SwitchListTile(
                    //     contentPadding: EdgeInsets.zero,
                    //     title: Text('Shared Collection',
                    //         style: TextStyle(
                    //             color: textColor, fontWeight: FontWeight.bold)),
                    //     subtitle: Text('Allow friends to view this collection',
                    //         style: TextStyle(
                    //             color: theme.colorScheme.onSurfaceVariant,
                    //             fontSize: 12)),
                    //     value: state.isShared,
                    //     activeThumbColor: theme.colorScheme.primary,
                    //     onChanged: notifier.updateShared,
                    //   ),
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
                      : () => notifier.submit(),
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
                      : const Text('Create',
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

  void _showIconPicker(BuildContext context, dynamic notifier) {
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
          itemBuilder: (context, index) {
            final icon = icons[index];
            return InkWell(
              onTap: () {
                notifier.updateIconName(icon);
                context.pop();
              },
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showParentPicker(
      BuildContext context,
      AsyncValue<List<Collection>> data,
      String? selectedParentId,
      dynamic notifier) {
    final collections = data.valueOrNull ?? const [];
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
                .where((c) => !c.isDeleted)
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
