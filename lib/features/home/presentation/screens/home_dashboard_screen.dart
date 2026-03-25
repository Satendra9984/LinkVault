import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/presentation/widgets/day_pass_gate.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../collections/presentation/widgets/collection_list_tile.dart';
import '../../../collections/presentation/widgets/collection_subtitle.dart';

/// Landing screen at `/` (ADR-0003): pinned + recent **root** collections,
/// Library entry to `/collections`, search and profile affordances.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  static List<Collection> _rootActive(List<Collection> all) {
    return all
        .where((c) =>
            c.parentId == null && !c.isDeleted && !c.isArchived)
        .toList();
  }

  static List<Collection> _pinnedRoot(List<Collection> root) {
    final pinned = root.where((c) => c.isPinned).toList()
      ..sort((a, b) {
        final p = a.position.compareTo(b.position);
        if (p != 0) return p;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    return pinned;
  }

  static DateTime _recentKey(Collection c) =>
      c.lastAccessedAt ?? c.updatedAt;

  static List<Collection> _recentRoot(List<Collection> root, {int max = 15}) {
    final candidates = root.where((c) => !c.isPinned).toList()
      ..sort((a, b) => _recentKey(b).compareTo(_recentKey(a)));
    if (candidates.length <= max) return candidates;
    return candidates.sublist(0, max);
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
    final collectionsAsync = ref.watch(collectionsListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: collectionsAsync.when(
        data: (all) {
          final root = _rootActive(all);
          final pinned = _pinnedRoot(root);
          final recent = _recentRoot(root);

          if (all.isEmpty) {
            return _EmptyHomeBody(
              onCreate: () => context.push('/collections/create'),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: theme.scaffoldBackgroundColor,
                centerTitle: true,
                title: Text(
                  'LinkVault',
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                leading: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: theme.colorScheme.primary),
                    onPressed: () => context.push('/search_collections'),
                  ),
                  if (AppConfig.instance.isDev)
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => context.push('/activity'),
                    ),
                ],
              ),
              if (pinned.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pinned lists',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/collections'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
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
                      itemBuilder: (context, i) {
                        final c = pinned[i];
                        return _PinnedCollectionChip(
                          collection: c,
                          onTap: () => _openCollection(context, ref, c),
                        );
                      },
                    ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    pinned.isNotEmpty ? 16 : 8,
                    16,
                    8,
                  ),
                  child: Text(
                    'Recent lists',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (recent.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      pinned.isEmpty
                          ? 'Open a list from Library to see it here.'
                          : 'No other recent lists yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final c = recent[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CollectionListTile(
                            collection: c,
                            onTap: () => _openCollection(context, ref, c),
                            onLongPress: () async {
                              final ok =
                                  await DayPassGate.check(context, ref);
                              if (!ok || !context.mounted) return;
                              context.push('/collections/${c.id}/edit');
                            },
                          ),
                        ),
                      );
                    },
                    childCount: recent.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Pinned links and recent links on Home are planned for a later phase.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/collections'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Library',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'All folders',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: collectionsAsync.maybeWhen(
        data: (all) => all.isEmpty
            ? null
            : FloatingActionButton(
                heroTag: 'home_dashboard_fab',
                onPressed: () async {
                  final ok = await DayPassGate.check(context, ref);
                  if (!ok || !context.mounted) return;
                  context.push('/collections/create');
                },
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _PinnedCollectionChip extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;

  const _PinnedCollectionChip({
    required this.collection,
    required this.onTap,
  });

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
                Text(
                  collection.iconName,
                  style: const TextStyle(fontSize: 28),
                ),
                const Spacer(),
                Text(
                  collection.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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

class _EmptyHomeBody extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyHomeBody({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: theme.scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            'LinkVault',
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: theme.colorScheme.primary),
              onPressed: () => context.push('/search_collections'),
            ),
          ],
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nothing here yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a list or open Library to get started.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onCreate,
                  child: const Text('New list'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/collections'),
                  child: const Text('Open Library'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
