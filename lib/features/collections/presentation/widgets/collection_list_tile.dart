import 'package:flutter/material.dart';
import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/collection.dart';
import 'collection_subtitle.dart';

class CollectionListTile extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CollectionListTile({
    super.key,
    required this.collection,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final coverHex = collection.colorHex;
    final parsed = AppColors.tryParseCollectionColorHex(coverHex);
    final noCover = AppColors.isCollectionCoverNoColor(coverHex);
    final accent = AppColors.collectionCoverEmojiTint(coverHex, theme);

    final backgroundColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest
        : noCover
            ? theme.colorScheme.surfaceContainerHighest
            : (parsed ?? const Color(0xFFB3E0FF)).withValues(alpha: 0.15);

    final borderColor = noCover
        ? theme.colorScheme.outline.withValues(alpha: 0.35)
        : (parsed ?? const Color(0xFFB3E0FF)).withValues(alpha: 0.3);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      tileColor: backgroundColor,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: noCover
              ? theme.colorScheme.surfaceContainerHighest
              : (isDarkMode
                  ? accent.withValues(alpha: 0.15)
                  : accent.withValues(alpha: 0.6)),
          shape: BoxShape.circle,
          border: noCover
              ? Border.all(
                  color:
                      theme.colorScheme.outline.withValues(alpha: 0.28),
                )
              : null,
        ),
        child: Center(
          child: noCover
              ? Text(
                  collection.iconName,
                  style: const TextStyle(fontSize: 24),
                )
              : ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isDarkMode
                        ? accent
                        : Color.lerp(accent, Colors.black, 0.6)!,
                    BlendMode.srcIn,
                  ),
                  child: Text(
                    collection.iconName,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
        ),
      ),
      title: Text(
        collection.title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        collectionSummarySubtitle(collection),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: collection.isShared
          ? Icon(Icons.group,
              size: 20, color: theme.colorScheme.onSurfaceVariant)
          : null,
    );
  }
}
