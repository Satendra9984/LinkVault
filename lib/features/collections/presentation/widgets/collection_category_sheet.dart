import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_categories.dart';
import '../../../../core/theme/color_palette.dart';
import '../providers/forms/collection_form_notifier.dart';

/// Category preset bottom sheet + custom name/emoji dialog for collection forms.
class CollectionCategorySheet {
  CollectionCategorySheet._();

  static void showPicker({
    required BuildContext rootContext,
    required WidgetRef ref,
    required bool isDark,
    required Color accentColor,
    required String colorHex,
  }) {
    final theme = Theme.of(rootContext);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final tileColor = theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest;

    showModalBottomSheet<void>(
      context: rootContext,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
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
                        onTap: () => sheetContext.pop(),
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
                  child: _CategoryPickerScrollView(
                    scrollController: scrollController,
                    sheetContext: sheetContext,
                    rootContext: rootContext,
                    theme: theme,
                    isDark: isDark,
                    accentColor: accentColor,
                    colorHex: colorHex,
                    tileColor: tileColor,
                    textColor: textColor,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showCustomDialog({
    required BuildContext rootContext,
    required WidgetRef ref,
    required String initialName,
    required String initialEmoji,
  }) {
    final nameCtrl = TextEditingController(text: initialName);
    final emojiCtrl = TextEditingController(text: initialEmoji);

    showDialog<void>(
      context: rootContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Custom category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    hintText: 'e.g. Side projects',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emojiCtrl,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    labelText: 'Emoji',
                    hintText: '🎨',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use your keyboard emoji picker, or paste a symbol.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(rootContext)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                ref
                    .read(collectionFormNotifierProvider.notifier)
                    .applyCustomCategory(name, emojiCtrl.text);
                dialogContext.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPickerScrollView extends ConsumerWidget {
  const _CategoryPickerScrollView({
    required this.scrollController,
    required this.sheetContext,
    required this.rootContext,
    required this.theme,
    required this.isDark,
    required this.accentColor,
    required this.colorHex,
    required this.tileColor,
    required this.textColor,
  });

  final ScrollController scrollController;
  final BuildContext sheetContext;
  final BuildContext rootContext;
  final ThemeData theme;
  final bool isDark;
  final Color accentColor;
  final String colorHex;
  final Color tileColor;
  final Color textColor;

  static const double _emojiFontSize = 27;
  static const double _emojiCircle = 50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(
      collectionFormNotifierProvider.select((s) => s.category),
    );
    final naturalEmoji = AppColors.isCollectionCoverNoColor(colorHex);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () {
                final s = ref.read(collectionFormNotifierProvider);
                sheetContext.pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CollectionCategorySheet.showCustomDialog(
                    rootContext: rootContext,
                    ref: ref,
                    initialName:
                        s.usesCustomCategory ? s.category : '',
                    initialEmoji:
                        s.usesCustomCategory ? s.iconName : '📁',
                  );
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      AppCategories.customOptionLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 158,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = AppCategories.list[index];
                final selected = selectedCategory == category;
                return InkWell(
                  key: ValueKey<String>(category),
                  onTap: () {
                    ref
                        .read(collectionFormNotifierProvider.notifier)
                        .updateCategory(category);
                    sheetContext.pop();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.12),
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CategoryEmojiChip(
                          emoji: AppCategories.getIconForCategory(category),
                          naturalEmoji: naturalEmoji,
                          isDark: isDark,
                          accentColor: accentColor,
                          theme: theme,
                          fontSize: _emojiFontSize,
                          circleSize: _emojiCircle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.12,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selected)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              childCount: AppCategories.list.length,
              addAutomaticKeepAlives: false,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _CategoryEmojiChip extends StatelessWidget {
  const _CategoryEmojiChip({
    required this.emoji,
    required this.naturalEmoji,
    required this.isDark,
    required this.accentColor,
    required this.theme,
    required this.fontSize,
    required this.circleSize,
  });

  final String emoji;
  final bool naturalEmoji;
  final bool isDark;
  final Color accentColor;
  final ThemeData theme;
  final double fontSize;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    if (naturalEmoji) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.28),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, height: 1.1),
        ),
      );
    }

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.15)
            : accentColor.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isDark
              ? accentColor
              : Color.lerp(accentColor, Colors.black, 0.6) ?? accentColor,
          BlendMode.srcIn,
        ),
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, height: 1.1),
        ),
      ),
    );
  }
}
