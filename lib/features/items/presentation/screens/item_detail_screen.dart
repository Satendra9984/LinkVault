import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/item.dart';
import '../providers/items_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/monetization/tier_quota_guard.dart';

import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends ConsumerWidget {
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
    final isPremium = ref.watch(isPremiumProvider);
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
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Status Badge
                            _buildStatusChip(item, theme),
                            const SizedBox(height: 32),

                            // Description
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
                              Text(
                                "DESCRIPTION",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.description!,
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
                              Text(
                                "LINK",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildLinkRow(item.link!, isDark),
                              const SizedBox(height: 32),
                            ],

                            // Location
                            if (item.location != null &&
                                item.location!.isNotEmpty) ...[
                              Text(
                                "LOCATION",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildLocationRow(item.location!, isDark),
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

                            // Custom Fields
                            if (item.customFields.isNotEmpty) ...[
                              Text(
                                "DETAILS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...item.customFields
                                  .map((f) => _buildCustomFieldRow(f, isDark)),
                            ],
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
                            _buildPopupMenu(context, ref, item, isPremium),
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
      return Image.network(item.imageUrl!, fit: BoxFit.contain);
    } else if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      return Image.file(File(item.imagePath!), fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeroImage(Item item, BuildContext context) {
    if (item.imageUrl != null) {
      return Image.network(
        item.imageUrl!,
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
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
      case ItemStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        break;
      case ItemStatus.visited:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case ItemStatus.completed:
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

  Widget _buildLinkRow(String link, bool isDark) {
    return InkWell(
      onTap: () async {
        final url = Uri.tryParse(link.startsWith('http') ? link : 'https://$link');
        if (url != null && await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_rounded, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                link,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location, bool isDark) {
    return InkWell(
      onTap: () async {
        final query = Uri.encodeComponent(location);
        final url = Uri.parse('https://maps.google.com/?q=$query');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded,
                  size: 18, color: Colors.blueGrey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Icon(Icons.map_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
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

  Widget _buildCustomFieldRow(CustomField field, bool isDark) {
    IconData fieldIcon;
    switch (field.type) {
      case CustomFieldType.text:
        fieldIcon = Icons.notes_rounded;
        break;
      case CustomFieldType.number:
        fieldIcon = Icons.numbers_rounded;
        break;
      case CustomFieldType.url:
        fieldIcon = Icons.link_rounded;
        break;
      case CustomFieldType.date:
        fieldIcon = Icons.calendar_today_rounded;
        break;
      case CustomFieldType.boolean:
        fieldIcon = Icons.check_box_outlined;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () async {
          if (field.type == CustomFieldType.url) {
            final urlStr = field.value.toString();
            final url = Uri.tryParse(urlStr.startsWith('http') ? urlStr : 'https://$urlStr');
            if (url != null && await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          } else if (field.name.toLowerCase().contains('phone')) {
            final url = Uri.tryParse('tel:${field.value}');
            if (url != null && await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(fieldIcon, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field.value.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                        decoration: (field.type == CustomFieldType.url || field.name.toLowerCase().contains('phone')) 
                            ? TextDecoration.underline : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (field.type == CustomFieldType.url)
                 const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
              if (field.name.toLowerCase().contains('phone'))
                 const Icon(Icons.phone_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
      BuildContext context, WidgetRef ref, Item item, bool isPremium) {
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
      onSelected: (action) {
        if (action == 'duplicate') {
          _duplicateItem(context, ref, item);
        } else if (action == 'share') {
          _shareItem(context, isPremium);
        } else if (action == 'delete') {
          _confirmDelete(context, ref, item.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 20),
              SizedBox(width: 12),
              Text('Duplicate'),
            ],
          ),
        ),
        // Share — hidden until Sprint 10 social features ship
        if (AppConfig.instance.isDev)
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_rounded, size: 20),
                SizedBox(width: 12),
                Text('Share (Premium)'),
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

  Future<void> _duplicateItem(
      BuildContext context, WidgetRef ref, Item item) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final newItem = Item(
      id: const Uuid().v4(),
      ownerId: item.ownerId,
      title: '${item.title} (copy)',
      description: item.description,
      imagePath: item.imagePath,
      imageUrl: item.imageUrl,
      link: item.link,
      status: item.status,
      position: item.position + 0.1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      collectionId: item.collectionId,
      customFields: item.customFields, // Important to clone custom fields!
    );

    final quota = await TierQuotaGuard.ensureCanCreateItem(
      isPremium: ref.read(isPremiumProvider),
      user: ref.read(currentUserProvider),
      itemsRepo: ref.read(itemsRepositoryProvider),
    );
    await quota.fold(
      (failure) async {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) async {
        await ref.read(createItemUseCaseProvider).call(newItem);
        ref
            .read(itemsNotifierProvider(item.collectionId).notifier)
            .addItemToState(newItem);
        scaffoldMessenger
            .showSnackBar(const SnackBar(content: Text('Item duplicated')));
        router.pop();
      },
    );
  }

  void _shareItem(BuildContext context, bool isPremium) {
    if (!isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Premium Feature'),
          content: const Text(
              'Upgrade to Premium to share individual items with friends.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                // Navigate to paywall
              },
              child: const Text('Upgrade'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating sharing link...')));
    }
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

              await ref.read(deleteItemUseCaseProvider).call(itemId);
              ref
                  .read(itemsNotifierProvider(collectionId).notifier)
                  .removeItemFromState(itemId);

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
      case ItemStatus.pending:
        return 'Pending';
      case ItemStatus.visited:
        return 'Visited';
      case ItemStatus.completed:
        return 'Completed';
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
