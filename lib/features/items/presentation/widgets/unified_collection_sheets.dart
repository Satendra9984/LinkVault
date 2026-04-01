import 'package:flutter/material.dart';

/// Bottom sheet: collection actions (replaces overflow menu).
class CollectionHubActionsSheet extends StatelessWidget {
  final String title;
  final String metadata;
  final bool isRoot;
  final bool isLinksTab;
  final bool isReorderMode;
  final Future<void> Function() onAddSubfolder;
  final Future<void> Function() onAddLink;
  final Future<void> Function() onEditCollection;
  final VoidCallback onTogglePinCollection;
  final VoidCallback onToggleArchiveCollection;
  final VoidCallback onDeleteCollection;
  final VoidCallback onToggleReorderLinks;

  const CollectionHubActionsSheet({
    super.key,
    required this.title,
    required this.metadata,
    required this.isRoot,
    required this.isLinksTab,
    required this.isReorderMode,
    required this.onAddSubfolder,
    required this.onAddLink,
    required this.onEditCollection,
    required this.onTogglePinCollection,
    required this.onToggleArchiveCollection,
    required this.onDeleteCollection,
    required this.onToggleReorderLinks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final maxHeight = viewport.maxHeight * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: subtle.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metadata,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: subtle),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: subtle.withValues(alpha: 0.4), height: 1),
                  if (isRoot) ...[
                    ListTile(
                      leading: const Icon(Icons.create_new_folder_outlined),
                      title: const Text('Add subfolder'),
                      onTap: () async {
                        Navigator.pop(context);
                        await onAddSubfolder();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit'),
                      subtitle: const Text('Rename, cover, or settings'),
                      onTap: () async {
                        Navigator.pop(context);
                        await onEditCollection();
                      },
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.create_new_folder_outlined),
                      title: const Text('Add subfolder'),
                      onTap: () async {
                        Navigator.pop(context);
                        await onAddSubfolder();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.link_rounded),
                      title: const Text('Add link'),
                      onTap: () async {
                        Navigator.pop(context);
                        await onAddLink();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit'),
                      subtitle: const Text('Rename, cover, or settings'),
                      onTap: () async {
                        Navigator.pop(context);
                        await onEditCollection();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        isReorderMode
                            ? Icons.check_circle_outline
                            : Icons.drag_handle_rounded,
                      ),
                      title: Text(
                        isReorderMode
                            ? 'Done reordering links'
                            : 'Reorder links',
                      ),
                      subtitle: Text(
                        isLinksTab
                            ? 'Drag links in list view.'
                            : 'Switches to Links tab first.',
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: subtle),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onToggleReorderLinks();
                      },
                    ),
                    Divider(color: subtle.withValues(alpha: 0.4), height: 1),
                    ListTile(
                      leading: const Icon(Icons.push_pin_outlined),
                      title: const Text('Pin collection'),
                      onTap: () {
                        Navigator.pop(context);
                        onTogglePinCollection();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.archive_outlined),
                      title: const Text('Archive collection'),
                      onTap: () {
                        Navigator.pop(context);
                        onToggleArchiveCollection();
                      },
                    ),
                    Divider(color: subtle.withValues(alpha: 0.4), height: 1),
                    ListTile(
                      leading:
                          const Icon(Icons.delete_outline, color: Colors.red),
                      title: const Text(
                        'Delete collection',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onDeleteCollection();
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
