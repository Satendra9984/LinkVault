import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleStatus;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived = item.status == ItemStatus.archived;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imagePath != null &&
                      File(item.imagePath!).existsSync())
                    Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C2C2E)
                          : Colors.grey.shade200,
                      child: Icon(Icons.image,
                          size: 48, color: Colors.grey.shade400),
                    ),
                  // Status Overlay
                  if (isArchived)
                    Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: const Center(
                        child: Icon(Icons.check_circle,
                            color: Colors.white, size: 48),
                      ),
                    ),
                  // Toggle Status Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          onToggleStatus();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1),
                          ),
                          child: Icon(
                            isArchived
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                isArchived ? Colors.greenAccent : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Details Section
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    decoration:
                        isArchived ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(item.status),
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(item.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return 'unread';
      case ItemStatus.read:
        return 'read';
      case ItemStatus.archived:
        return 'archived';
    }
  }

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
}
