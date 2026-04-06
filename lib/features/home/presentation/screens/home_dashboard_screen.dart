import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_vault/core/constants/app_assets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/content_state_widgets.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../collections/domain/collection_display_defaults.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/presentation/widgets/collection_card.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/link_open_behavior.dart';
import '../../../items/presentation/providers/items_providers.dart';
import '../../../items/presentation/widgets/url_icon_link_tile.dart';

/// Responsive grid metrics (aligned with [ItemsListScreen] hub grids).
class _HomeGridMetrics {
  const _HomeGridMetrics({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final int crossAxisCount;
  final double childAspectRatio;
}

_HomeGridMetrics _homePinnedFoldersGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 88.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(2, 6);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  final targetH = cellW * 0.48 + 58;
  var ratio = cellW / targetH;
  ratio = ratio.clamp(0.82, 1.08);
  return _HomeGridMetrics(
    crossAxisCount: count,
    childAspectRatio: ratio,
  );
}

_HomeGridMetrics _homePinnedLinksIconsGridMetrics(double innerWidth) {
  const spacing = 16.0;
  const minCell = 92.0;
  var count = ((innerWidth + spacing) / (minCell + spacing)).floor();
  count = count.clamp(2, 6);
  final cellW = (innerWidth - spacing * (count - 1)) / count;
  const targetH = 118.0;
  var ratio = cellW / targetH;
  ratio = ratio.clamp(0.72, 1.05);
  return _HomeGridMetrics(
    crossAxisCount: count,
    childAspectRatio: ratio,
  );
}

/// Landing screen at `/` — Quick stats and pinned content.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  static List<Collection> _childrenOfLibrary(
    List<Collection> all,
    String libraryRootId,
  ) =>
      all
          .where((c) =>
              c.parentId == libraryRootId && !c.isDeleted && !c.isArchived)
          .toList();

  static List<Collection> _pinnedRoot(List<Collection> root) {
    final pinned = root.where((c) => c.isPinned).toList()
      ..sort((a, b) {
        final p = a.position.compareTo(b.position);
        return p != 0 ? p : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    return pinned;
  }

  static Collection? _collectionById(
    List<Collection> all,
    String id,
  ) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Future<void> _openCollection(
    BuildContext context,
    WidgetRef ref,
    Collection c,
  ) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;
    context.push('/collections/${c.id}', extra: c.title);
  }

  static Future<void> _openPinnedItemLink(
    BuildContext context,
    WidgetRef ref,
    Item item,
    List<Collection> allCollections,
  ) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;

    if (item.status == ItemStatus.unread) {
      await ref.read(markItemReadAndTrackUseCaseProvider).call(item.id);
      ref.invalidate(homePinnedItemsProvider);
    }

    final raw = item.link?.trim();
    if (raw == null || raw.isEmpty) {
      if (!context.mounted) return;
      context.push('/collections/${item.collectionId}/items/${item.id}');
      return;
    }

    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.host.isEmpty && uri.scheme != 'file')) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }

    final collection = _collectionById(allCollections, item.collectionId);
    final resolved = effectiveOpenLinksIn(
      itemOpenLinksInOverride: item.openLinksInOverride,
      collectionOpenLinksIn: collection?.openLinksIn,
    );
    final launchMode = resolved == CollectionOpenLinksIn.externalBrowser
        ? LaunchMode.externalApplication
        : LaunchMode.inAppBrowserView;

    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: launchMode);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final libraryRootAsync = ref.watch(libraryRootCollectionProvider);
    final collectionsAsync = ref.watch(collectionsListProvider);
    final pinnedItemsAsync = ref.watch(homePinnedItemsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: libraryRootAsync.when(
        loading: () => const HomeSectionSkeleton(),
        error: (e, _) => AppErrorState(
          error: e,
          title: 'Could not load your home dashboard',
          onRetry: () => ref.invalidate(libraryRootCollectionProvider),
        ),
        data: (libraryRoot) => collectionsAsync.when(
          data: (all) {
            final root = _childrenOfLibrary(all, libraryRoot.id);
            final pinned = _pinnedRoot(root);

            if (!all.any((c) => !c.isDeleted)) {
              return _EmptyHomeBody(
                onCreate: () async {
                  final ok = await DayPassGate.check(context, ref);
                  if (!ok || !context.mounted) return;
                  final lr = await ref.read(libraryRootCollectionProvider.future);
                  if (!context.mounted) return;
                  context.push('/collections/create?parent=${lr.id}', extra: lr);
                },
              );
            }

            final totalCollections = root.length;
            final totalLinks = root.fold<int>(0, (s, c) => s + c.itemCount);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  surfaceTintColor: theme.scaffoldBackgroundColor,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Home',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications_none_outlined,
                          color: theme.colorScheme.primary),
                      onPressed: () {},
                      tooltip: 'Notifications',
                    ),
                    if (AppConfig.instance.isDev)
                      IconButton(
                        icon: Icon(Icons.bug_report_outlined,
                            color: theme.colorScheme.primary),
                        onPressed: () => context.push('/profile/debug'),
                      ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _StatChip(
                            value: '$totalCollections',
                            label: 'Folders',
                            icon: Icons.grid_view_rounded),
                        const SizedBox(width: 10),
                        _StatChip(
                            value: '$totalLinks',
                            label: 'Links',
                            icon: Icons.link_rounded),
                        const SizedBox(width: 10),
                        _StatChip(
                            value: '${pinned.length}',
                            label: 'Pinned',
                            icon: Icons.push_pin_outlined),
                      ],
                    ),
                  ),
                ),

                if (pinned.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Pinned folders',
                    action: TextButton(
                      onPressed: () => context.go('/collections'),
                      child: const Text('See all'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final m = _homePinnedFoldersGridMetrics(
                            constraints.crossAxisExtent);
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: m.crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: m.childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final c = pinned[i];
                              return CollectionCard(
                                collection: c,
                                compact: true,
                                onTap: () =>
                                    _openCollection(context, ref, c),
                                onLongPress: () async {
                                  final ok =
                                      await DayPassGate.check(context, ref);
                                  if (!ok || !context.mounted) return;
                                  context.push('/collections/${c.id}/edit');
                                },
                              );
                            },
                            childCount: pinned.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],

                _SectionHeader(
                  title: 'Pinned links',
                  action: TextButton(
                    onPressed: () => context.go('/search'),
                    child: const Text('Search'),
                  ),
                ),
                pinnedItemsAsync.when(
                  data: (pinnedItems) {
                    if (pinnedItems.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _EmptySectionCard(
                            message:
                                'Pin links to see them here. Open a folder and pin a link.',
                            icon: Icons.push_pin_outlined,
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final m = _homePinnedLinksIconsGridMetrics(
                              constraints.crossAxisExtent);
                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: m.crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: m.childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = pinnedItems[index];
                                return UrlIconLinkTile(
                                  item: item,
                                  onTap: () => _openPinnedItemLink(
                                    context,
                                    ref,
                                    item,
                                    all,
                                  ),
                                  onLongPress: () async {
                                    final ok =
                                        await DayPassGate.check(context, ref);
                                    if (!ok || !context.mounted) return;
                                    context.push(
                                      '/collections/${item.collectionId}/items/${item.id}/edit',
                                    );
                                  },
                                );
                              },
                              childCount: pinnedItems.length,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _EmptySectionCard(
                        message: 'Loading pinned links...',
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _EmptySectionCard(
                        message: 'Could not load pinned links.',
                        icon: Icons.error_outline,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            );
          },
          loading: () => const HomeSectionSkeleton(),
          error: (e, _) => AppErrorState(
            error: e,
            title: 'Could not load your library',
            onRetry: () => ref.invalidate(collectionsListProvider),
          ),
        ),
      ),
      floatingActionButton: libraryRootAsync.maybeWhen(
        data: (_) => collectionsAsync.maybeWhen(
          data: (all) => !all.any((c) => !c.isDeleted)
              ? null
              : FloatingActionButton(
                  heroTag: 'home_dashboard_fab',
                  onPressed: () async {
                    final ok = await DayPassGate.check(context, ref);
                    if (!ok || !context.mounted) return;
                    final lr =
                        await ref.read(libraryRootCollectionProvider.future);
                    if (!context.mounted) return;
                    context.push(
                      '/collections/create?parent=${lr.id}',
                      extra: lr,
                    );
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
          orElse: () => null,
        ),
        orElse: () => null,
      ),
    );
  }
}

// ── Shared sliver section header ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty section placeholder card ───────────────────────────────────────────

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty home body ──────────────────────────────────────────────────────────

class _EmptyHomeBody extends StatelessWidget {
  const _EmptyHomeBody({required this.onCreate});

  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          automaticallyImplyLeading: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Home',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.emptyCollections,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No folders yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a folder to start organizing your links. Your vault is empty — let\'s fill it.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () async => onCreate(),
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: const Text('New folder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
