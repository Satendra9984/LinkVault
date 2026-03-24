import 'package:flutter/material.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';

import 'collection_subtitle.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Parse color hex string to Color
    final baseColor =
        Color(int.parse(collection.colorHex.replaceFirst('#', '0xFF')));
    // Improved dark mode logic with subtle glow
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest // Dark surface
        : baseColor.withValues(alpha: 0.3); // Pastel background in light mode

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20), // Highly rounded
          border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1),
          boxShadow: isDarkMode
              ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16.0),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.group,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                  )
                else
                  const SizedBox(), // Spacer to keep icon on right

                // Category icon on the top-right
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? baseColor.withValues(alpha: 0.15)
                        : baseColor.withValues(
                            alpha: 0.6), // Lighter background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    // Use ColorFiltered to tint the emoji a darker shade of the card color
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isDarkMode
                            ? baseColor // Glow the emoji in dark mode
                            : Color.lerp(baseColor, Colors.black,
                                0.6)!, // Darker shade of the pastel in light mode
                        BlendMode.srcIn,
                      ),
                      child: Text(
                        collection.iconName,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              collection.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700, 
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              collectionSummarySubtitle(collection),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? baseColor
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
