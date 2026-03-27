import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collections_providers.dart';
import '../../../items/presentation/screens/items_list_screen.dart';

/// Shell tab route for `/collections`: resolves persisted library root then shows
/// the unified [ItemsListScreen] (same as nested folders).
class CollectionsBranchRootScreen extends ConsumerWidget {
  const CollectionsBranchRootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootAsync = ref.watch(libraryRootCollectionProvider);
    return rootAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(libraryRootCollectionProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (root) => ItemsListScreen(
        collectionId: root.id,
        collectionName: root.title,
        isRoot: true,
      ),
    );
  }
}
