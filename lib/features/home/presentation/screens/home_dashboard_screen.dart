import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/content_state_widgets.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/presentation/widgets/collection_list_tile.dart';
import '../../../collections/presentation/widgets/collection_subtitle.dart';

/// Landing screen at `/` — Quick stats, pinned collections, quick-resume.
/// Layout follows the wireframe spec:
///   AppBar → Quick-stats strip → Quick-resume card → Pinned collections →
///   Pinned links (coming sprint) → Recent links (coming sprint) → Recent collections.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  static List<Collection> _childrenOfLibrary(
    List<Collection> all,
    String libraryRootId,
  ) =>
      all
          .where((c) =>
              c.parentId == libraryRootId &&
              !c.isDeleted &&
              !c.isArchived)
          .toList();

  static List<Collection> _pinnedRoot(List<Collection> root) {
    final pinned = root.where((c) => c.isPinned).toList()
      ..sort((a, b) {
        final p = a.position.compareTo(b.position);
        return p != 0 ? p : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    return pinned;
  }

  static DateTime _recentKey(Collection c) => c.lastAccessedAt ?? c.updatedAt;

  static List<Collection> _recentRoot(List<Collection> root, {int max = 15}) {
    final candidates = root.where((c) => !c.isPinned).toList()
      ..sort((a, b) => _recentKey(b).compareTo(_recentKey(a)));
    return candidates.length <= max ? candidates : candidates.sublist(0, max);
  }

  Future<void> _openCollection(
      BuildContext context, WidgetRef ref, Collection c) async {
    final ok = await DayPassGate.check(context, ref);
    if (!ok || !context.mounted) return;
    context.push('/collections/${c.id}', extra: c.title);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final libraryRootAsync = ref.watch(libraryRootCollectionProvider);
    final collectionsAsync = ref.watch(collectionsListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: libraryRootAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(e.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (libraryRoot) => collectionsAsync.when(
        data: (all) {
          final root = _childrenOfLibrary(all, libraryRoot.id);
          final pinned = _pinnedRoot(root);
          final recent = _recentRoot(root);

          if (!all.any((c) => !c.isDeleted)) {
            return _EmptyHomeBody(
              onCreate: () {
                ref.read(libraryRootCollectionProvider.future).then((lr) {
                  if (!context.mounted) return;
                  context.push('/collections/create?parent=${lr.id}', extra: lr);
                });
              },
            );
          }

          // Aggregate stats
          final totalCollections = root.length;
          final totalLinks = root.fold<int>(0, (s, c) => s + c.itemCount);

          return CustomScrollView(
            slivers: [
              // ── App bar ─────────────────────────────────────────────────
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

              // ── Quick stats strip ─────────────────────────────────────
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

              // ── Quick resume ──────────────────────────────────────────
              if (recent.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Material(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openCollection(context, ref, recent[0]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Continue where you left off',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      recent[0].title,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Pinned collections ────────────────────────────────────
              if (pinned.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Pinned folders',
                  action: TextButton(
                    onPressed: () => context.go('/collections'),
                    child: const Text('See all'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 132,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: pinned.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => _PinnedCollectionChip(
                        collection: pinned[i],
                        onTap: () => _openCollection(context, ref, pinned[i]),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Pinned links (placeholder) ────────────────────────────
              _SectionHeader(
                title: 'Pinned links',
                action: TextButton(
                  onPressed: () => context.go('/search'),
                  child: const Text('Search'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EmptySectionCard(
                    message: 'Pin links to see them here. Open a folder and pin a link.',
                    icon: Icons.push_pin_outlined,
                  ),
                ),
              ),

              // ── Recent links (placeholder) ─────────────────────────────
              _SectionHeader(
                title: 'Recent links',
                action: TextButton(
                  onPressed: () => context.go('/search'),
                  child: const Text('Browse'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EmptySectionCard(
                    message: 'Links you recently opened will appear here.',
                    icon: Icons.history_rounded,
                  ),
                ),
              ),

              // ── Recent collections ────────────────────────────────────
              if (recent.isNotEmpty) ...[
                _SectionHeader(title: 'Recent folders'),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CollectionListTile(
                          collection: recent[index],
                          onTap: () =>
                              _openCollection(context, ref, recent[index]),
                          onLongPress: () async {
                            final ok = await DayPassGate.check(context, ref);
                            if (!ok || !context.mounted) return;
                            context.push(
                                '/collections/${recent[index].id}/edit');
                          },
                        ),
                      ),
                      childCount: recent.length > 5 ? 5 : recent.length,
                    ),
                  ),
                ),
                if (recent.length > 5)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: TextButton(
                        onPressed: () => context.go('/collections'),
                        child: const Text('See all folders'),
                      ),
                    ),
                  ),
              ] else if (root.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EmptySectionCard(
                      message: 'Open folders from Collections to see them here.',
                      icon: Icons.folder_open_outlined,
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

// ── Pinned collection chip ────────────────────────────────────────────────────

class _PinnedCollectionChip extends StatelessWidget {
  const _PinnedCollectionChip(
      {required this.collection, required this.onTap});

  final Collection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 128,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.iconName,
                    style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  collection.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  collectionSummarySubtitle(collection),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty home body ──────────────────────────────────────────────────────────

class _EmptyHomeBody extends StatelessWidget {
  const _EmptyHomeBody({required this.onCreate});

  final VoidCallback onCreate;

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
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 20),
                Text(
                  'Save your first link',
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
                    onPressed: onCreate,
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
