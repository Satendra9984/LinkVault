import 'package:flutter/material.dart';
import 'package:link_vault/core/theme/color_palette.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';

import 'collection_subtitle.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Tighter padding and typography for compact grids (e.g. nested unified screen).
  final bool compact;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    required this.onLongPress,
    this.compact = false,
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
            : (parsed ?? const Color(0xFFB3E0FF)).withValues(alpha: 0.3);

    final borderColor = noCover
        ? theme.colorScheme.outline.withValues(alpha: 0.35)
        : (parsed ?? const Color(0xFFB3E0FF)).withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(compact ? 14 : 20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDarkMode && !noCover && parsed != null
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: EdgeInsets.all(compact ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shared indicator on the top-left
                if (collection.isShared)
                  Container(
                    padding: EdgeInsets.all(compact ? 4 : 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.group,
                        size: compact ? 14 : 16,
                        color: theme.colorScheme.onSurfaceVariant),
                  )
                else
                  const SizedBox.shrink(),

                // Category icon on the top-right
                Container(
                  width: compact ? 24 : 40,
                  height: compact ? 24 : 40,
                  decoration: BoxDecoration(
                    color: noCover
                        ? theme.colorScheme.surfaceContainerHighest
                        : (isDarkMode
                            ? accent.withValues(alpha: 0.15)
                            : accent.withValues(alpha: 0.6)),
                    shape: BoxShape.circle,
                    border: noCover
                        ? Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.28),
                          )
                        : null,
                  ),
                  child: Center(
                    child: noCover
                        ? Text(
                            collection.iconName,
                            style: TextStyle(fontSize: compact ? 12 : 20),
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
                              style: TextStyle(fontSize: compact ? 12 : 20),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.15,
                      ),
                      maxLines: compact ? 2 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: compact ? 1 : 2),
                    Text(
                      collectionSummarySubtitle(collection),
                      style: TextStyle(
                        fontSize: compact ? 9 : 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: isDarkMode && !noCover && parsed != null
                            ? accent
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.85),
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
