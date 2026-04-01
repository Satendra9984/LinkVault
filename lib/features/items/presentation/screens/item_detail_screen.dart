import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/item.dart';
import '../../domain/link_open_behavior.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/domain/collection_display_defaults.dart';
import '../providers/items_providers.dart';
import '../providers/items_hub_notifier.dart';
import '../widgets/url_favicon_tile.dart';

import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemDetailScreen extends ConsumerWidget {
  static const _radiusLg = 16.0;
  final String collectionId;
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.collectionId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsNotifierProvider(collectionId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return itemsAsync.when(
      data: (state) {
        final items = state.items;
        final item = items.firstWhereOrNull((i) => i.id == itemId);

        if (item == null) {
          return const Scaffold(body: Center(child: Text('Item deleted')));
        }

        final hasImage = item.imageUrl != null ||
            (item.imagePath != null && File(item.imagePath!).existsSync());

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Main Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    // Edge-to-edge Hero Image (if available)
                    if (hasImage)
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context, item),
                        child: _buildHeroImage(item, context),
                      ),

                    if (!hasImage)
                      SizedBox(height: MediaQuery.of(context).padding.top + 64),

                    // Overlapping Content Card
                    Transform.translate(
                      offset: Offset(0, hasImage ? -32 : 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(hasImage ? 32 : 0)),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(item.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                )),
                            const SizedBox(height: 16),

                            // URL identity
                            if (item.link != null && item.link!.isNotEmpty) ...[
                              Row(
                                children: [
                                  UrlFaviconTile(item: item, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _extractDomain(item.link!),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Status Badge
                            Row(
                              children: [
                                _buildStatusChip(item, theme),
                                const Spacer(),
                                Switch(
                                  value: item.isPinned,
                                  onChanged: (_) async {
                                    await ref
                                        .read(itemsHubNotifierProvider.notifier)
                                        .togglePin(
                                          collectionId: collectionId,
                                          itemId: item.id,
                                        );
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pinned',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            _buildMetadataBlock(context, ref, item),
                            const SizedBox(height: 24),

                            // Notes (lv_urls.annotation)
                            if (item.annotation != null &&
                                item.annotation!.isNotEmpty) ...[
                              Text(
                                "NOTES",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.annotation!,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Link
                            if (item.link != null && item.link!.isNotEmpty) ...[
                              FilledButton.icon(
                                onPressed: () =>
                                    _openItemLinkFromDetail(context, ref, item),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Open link'),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: item.link!),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('URL copied'),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.content_copy_rounded),
                                      label: const Text('Copy URL'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push(
                                        '/collections/$collectionId/items/${item.id}/edit',
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Edit'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Tags
                            if (item.tags != null && item.tags!.isNotEmpty) ...[
                              Text(
                                "TAGS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.tags!
                                    .split(',')
                                    .map((t) => t.trim())
                                    .where((t) => t.isNotEmpty)
                                    .map((tag) =>
                                        _buildTagChip(tag, theme, isDark))
                                    .toList(),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Curate-style custom fields/extra sections are intentionally not shown
                            // for the URL-detail UX (notes + tags are the per-URL fields).
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Custom AppBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        _FloatingGlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => context.pop(),
                        ),
                        // Action Buttons
                        Row(
                          children: [
                            _FloatingGlassButton(
                              icon: Icons.edit_rounded,
                              onTap: () => context.push(
                                  '/collections/$collectionId/items/${item.id}/edit'),
                            ),
                            const SizedBox(width: 8),
                            _buildPopupMenu(context, ref, item),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  // Helper Methods

  void _showFullScreenImage(BuildContext context, Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: _buildRawImage(item),
          ),
        ),
      ),
    ));
  }

  Widget _buildRawImage(Item item) {
    if (item.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      return Image.file(File(item.imagePath!), fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeroImage(Item item, BuildContext context) {
    if (item.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      return Image.file(
        File(item.imagePath!),
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatusChip(Item item, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case ItemStatus.unread:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        break;
      case ItemStatus.read:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case ItemStatus.archived:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.star_border_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            _getStatusText(item.status),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataBlock(BuildContext context, WidgetRef ref, Item item) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final added = _relativeTime(now, item.createdAt);
    final lastVisited = item.lastAccessedAt == null
        ? 'Never'
        : _relativeTime(now, item.lastAccessedAt!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(_radiusLg),
      ),
      child: Column(
        children: [
          _metaRow('Collection', item.collectionId),
          const SizedBox(height: 8),
          _metaRow('Added', added),
          const SizedBox(height: 8),
          _metaRow('Last visited', lastVisited),
          const SizedBox(height: 8),
          _metaRow('Visited', '${item.clickCount} times'),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _openItemLinkFromDetail(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final link = item.link;
    if (link == null || link.trim().isEmpty) return;
    final normalized =
        link.startsWith('http://') || link.startsWith('https://')
            ? link
            : 'https://$link';
    final url = Uri.tryParse(normalized);
    if (url == null ||
        !url.hasScheme ||
        (url.host.isEmpty && url.scheme != 'file')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link')),
        );
      }
      return;
    }
    final collections =
        ref.read(collectionsListProvider).valueOrNull ?? [];
    final coll =
        collections.firstWhereOrNull((c) => c.id == item.collectionId);
    final resolved = effectiveOpenLinksIn(
      itemOpenLinksInOverride: item.openLinksInOverride,
      collectionOpenLinksIn: coll?.openLinksIn,
    );
    final launchMode = resolved == CollectionOpenLinksIn.externalBrowser
        ? LaunchMode.externalApplication
        : LaunchMode.inAppBrowserView;
    if (!await canLaunchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
      return;
    }
    try {
      final launched = await launchUrl(url, mode: launchMode);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  String _relativeTime(DateTime now, DateTime value) {
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final months = (diff.inDays / 30).floor();
    return '${months}mo ago';
  }

  Widget _buildTagChip(String tag, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.2)
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.9)
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, Item item) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
      ),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (action) async {
        if (action == 'toggle_pin') {
          await ref.read(itemsHubNotifierProvider.notifier).togglePin(
                collectionId: item.collectionId,
                itemId: item.id,
              );
        } else if (action == 'toggle_archive') {
          await ref.read(itemsHubNotifierProvider.notifier).toggleArchive(
                collectionId: item.collectionId,
                item: item,
              );
        } else if (action == 'delete') {
          _confirmDelete(context, ref, item.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle_pin',
          child: Row(
            children: [
              const Icon(Icons.push_pin_outlined, size: 20),
              const SizedBox(width: 12),
              Text('Toggle Pin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_archive',
          child: Row(
            children: [
              Icon(
                item.status == ItemStatus.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                  item.status == ItemStatus.archived ? 'Unarchive' : 'Archive'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String itemId) {
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => dialogCtx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              dialogCtx.pop(); // Close dialog immediately

              await ref.read(itemsHubNotifierProvider.notifier).deleteItem(
                    collectionId: collectionId,
                    itemId: itemId,
                  );

              router.pop(); // Go back to items list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  String _extractDomain(String rawUrl) {
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
}

// Private widget for floating buttons over the hero image
class _FloatingGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingGlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
