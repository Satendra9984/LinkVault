import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';
import 'url_favicon_tile.dart';
import '../../../../core/theme/color_palette.dart';

class UrlPreviewTile extends StatelessWidget {
  const UrlPreviewTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.compact = false,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool compact;

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Icons.schedule_rounded;
      case ItemStatus.read:
        return Icons.check_circle_outline_rounded;
      case ItemStatus.archived:
        return Icons.star_border_rounded;
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Colors.orange;
      case ItemStatus.read:
        return Colors.green;
      case ItemStatus.archived:
        return AppColors.primary;
    }
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return 'Unread';
      case ItemStatus.read:
        return 'Read';
      case ItemStatus.archived:
        return 'Archived';
    }
  }

  ImageProvider? _previewImage(Item item) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return NetworkImage(item.imageUrl!);
    }
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return FileImage(File(item.imagePath!));
    }
    return null;
  }

  String _domain(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final normalized = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    try {
      final host = Uri.parse(normalized).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return rawUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _previewImage(item);
    final domain = _domain(item.link);
    final statusColor = _getStatusColor(item.status);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: compact
                  ? Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    UrlFaviconTile(item: item, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (domain.isNotEmpty)
                            Text(
                              domain,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _getStatusIcon(item.status),
                      size: 16,
                      color: statusColor,
                    ),
                  ],
                ),
              )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: image != null
                                ? Image(
                                    image: image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF2C2C2E)
                                        : Colors.grey.shade200,
                                    child: const Icon(Icons.image_outlined),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UrlFaviconTile(item: item, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null &&
                                  item.description!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  item.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                              if (domain.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  domain,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            if (!compact)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(item.status), size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(item.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
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

