import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/collection.dart';
import 'global_search_query_providers.dart';

/// Back-compat: same data as [globalSearchFilteredCollectionsProvider].
final filteredSearchCollectionsProvider =
    Provider<AsyncValue<List<Collection>>>((ref) {
  return ref.watch(globalSearchFilteredCollectionsProvider);
});
