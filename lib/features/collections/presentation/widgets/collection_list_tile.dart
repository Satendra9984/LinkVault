import 'package:flutter/material.dart';
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
    final baseColor =
        Color(int.parse(collection.colorHex.replaceFirst('#', '0xFF')));
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest
        : baseColor.withValues(alpha: 0.15);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: baseColor.withValues(alpha: 0.3), width: 1),
      ),
      tileColor: backgroundColor,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode
              ? baseColor.withValues(alpha: 0.15)
              : baseColor.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDarkMode
                  ? baseColor
                  : Color.lerp(baseColor, Colors.black, 0.6)!,
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
