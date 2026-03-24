import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/collection.dart';
import '../collections_providers.dart';
import 'search_notifier.dart';

final filteredSearchCollectionsProvider =
    AutoDisposeProvider<AsyncValue<List<Collection>>>((ref) {
  final collectionsAsyncValue = ref.watch(collectionsListProvider);
  final searchState = ref.watch(searchNotifierProvider);

  return collectionsAsyncValue.whenData((collections) {
    // 1. Filter
    var filtered = collections.where((c) {
      if (c.isDeleted) return false;
      // Archived: hidden from home (option A) but still searchable for edit/unarchive.
      if (searchState.showOnlyPrivate && c.isShared) return false;

      if (searchState.query.isEmpty) return true;

      final queryLower = searchState.query.toLowerCase();
      return c.title.toLowerCase().contains(queryLower) ||
          c.category.toLowerCase().contains(queryLower);
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      if (searchState.sortOption == 'date_added') {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return b.updatedAt.compareTo(a.updatedAt);
      }
    });

    return filtered;
  });
});
