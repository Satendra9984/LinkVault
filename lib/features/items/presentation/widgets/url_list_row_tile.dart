import 'package:flutter/material.dart';

import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/item.dart';
import 'url_favicon_tile.dart';

/// Shared list-mode URL row — exact visual match of [ItemsListScreen]'s
/// `_buildListItem` inner widget (without the [Dismissible] wrapper and
/// screen-specific callbacks).
///
/// Safe to place in any vertical [ListView] or [SliverList] because it uses a
/// [Row]/[Column] structure with self-determined height — no [Expanded] or
/// [Stack] in the main axis.
class UrlListRowTile extends StatelessWidget {
  const UrlListRowTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.trailing,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Optional widget appended after the main content (e.g. pin dot + overflow
  /// button in the hub; omit for read-only contexts like global search).
  final Widget? trailing;

  static String extractDomain(String rawUrl) {
    if (rawUrl.trim().isEmpty) return '';
    final normalized =
        rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
            ? rawUrl
            : 'https://$rawUrl';
    try {
      final host = Uri.parse(normalized).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return rawUrl;
    }
  }

  static String relativeAgo(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  static Color statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Colors.orange;
      case ItemStatus.read:
        return Colors.green;
      case ItemStatus.archived:
        return AppColors.primary;
    }
  }

  static String statusLabel(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return 'Unread';
      case ItemStatus.read:
        return 'Read';
      case ItemStatus.archived:
        return 'Archived';
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = extractDomain(item.link ?? '');
    final updatedAgo = relativeAgo(item.updatedAt);
    final tags = (item.tags ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final semanticsLabel = [
      item.title,
      if (domain.isNotEmpty) domain,
      statusLabel(item.status),
      'Updated $updatedAgo',
    ].join(', ');

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: semanticsLabel,
        hint: 'Double tap to open link. Long press for edit.',
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.45),
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: tags.isNotEmpty ? 76 : 60,
                    margin: const EdgeInsets.only(right: 10, top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(2),
                    ),
                          ),
                  UrlFaviconTile(item: item, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$domain · $updatedAgo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...tags.take(3).map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                            if (tags.length > 3)
                              Text(
                                '+${tags.length - 3}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(item.status)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusLabel(item.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor(item.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
