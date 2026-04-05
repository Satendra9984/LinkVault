import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/collection.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../monetization/presentation/providers/ad_gate_provider.dart';
import '../collections_providers.dart';
import 'global_search_filtering.dart';
import 'global_search_notifier.dart';
import 'global_search_tier.dart';

/// Async DayPass + premium resolution for link item source selection.
final globalSearchItemsDataModeProvider =
    FutureProvider<GlobalSearchItemsDataMode>((ref) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) {
    return GlobalSearchItemsDataMode.activeRepository;
  }
  final status = await ref.watch(adGateProvider.future);
  return resolveGlobalSearchItemsDataMode(
    isPremium: isPremium,
    dayPassStatus: status,
  );
});

/// Filtered + sorted collections for global search tab (in-memory, no pagination needed).
final globalSearchFilteredCollectionsProvider =
    Provider<AsyncValue<List<Collection>>>((ref) {
  final collectionsAsync = ref.watch(collectionsListProvider);
  final _ = ref.watch(
    globalSearchNotifierProvider.select(
      (s) => (
        s.collectionsCommittedQuery,
        s.collectionsShowOnlyPrivate,
        s.collectionsFolderSort,
        s.collectionsIncludeArchived,
        s.collectionsSelectedCategories,
        s.collectionsUpdatedAfter,
        s.collectionsUpdatedBefore,
      ),
    ),
  );
  final gs = ref.read(globalSearchNotifierProvider);
  return collectionsAsync.whenData(
    (list) => filterAndSortCollectionsForGlobalSearch(list, gs),
  );
});

/// True when DayPass expired path limits link search to local DB only.
final globalSearchLinksLocalOnlyProvider = Provider<bool>((ref) {
  final modeAsync = ref.watch(globalSearchItemsDataModeProvider);
  return modeAsync.maybeWhen(
    data: (m) => m == GlobalSearchItemsDataMode.localRepositoryOnly,
    orElse: () => false,
  );
});
