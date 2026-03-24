import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/collection.dart';
import 'collections_providers.dart';

// 1. State class for Home Tabs
enum HomeTab { recent, private, shared }

// 2. Notifier to manage the currently selected tab
class HomeTabNotifier extends AutoDisposeNotifier<HomeTab> {
  @override
  HomeTab build() {
    return HomeTab.recent; // Default tab
  }

  void setTab(HomeTab tab) {
    state = tab;
  }
}

final homeTabNotifierProvider =
    AutoDisposeNotifierProvider<HomeTabNotifier, HomeTab>(HomeTabNotifier.new);

// 3. Computed Provider for the active tab's data
final homeCollectionsProvider =
    Provider.autoDispose<AsyncValue<List<Collection>>>((ref) {
  final collectionsAsyncValue = ref.watch(collectionsListProvider);
  final currentTab = ref.watch(homeTabNotifierProvider);

  return collectionsAsyncValue.whenData((collections) {
    // Option A (Sprint UI flows): hide archived from home lists.
    var filtered = collections
        .where((c) => !c.isDeleted && !c.isArchived)
        .toList();

    // Filter and Sort based on the active tab
    switch (currentTab) {
      case HomeTab.recent:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case HomeTab.private:
        filtered = filtered.where((c) => !c.isShared).toList();
        filtered.sort((a, b) => a.position.compareTo(b.position));
        break;
      case HomeTab.shared:
        filtered = filtered.where((c) => c.isShared).toList();
        filtered.sort((a, b) => a.position.compareTo(b.position));
        break;
    }

    return filtered;
  });
});
