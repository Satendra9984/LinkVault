import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/presentation/providers/items_providers.dart';
import 'collections_list_ui_state.dart';

class CollectionsListUiNotifier
    extends AutoDisposeNotifier<CollectionsListUiState> {
  // Architecture guardrail: list/filter feature state is notifier-owned.
  @override
  CollectionsListUiState build() => const CollectionsListUiState();

  void setIsGrid(bool value) {
    state = state.copyWith(isGrid: value);
  }

  void toggleGrid() {
    state = state.copyWith(isGrid: !state.isGrid);
  }

  void updateFolderSearchQuery(String value) {
    state = state.copyWith(folderSearchQuery: value);
  }

  void clearFolderSearchQuery() {
    state = state.copyWith(folderSearchQuery: '');
  }

  void updateRootLinksSearchQuery(String value) {
    state = state.copyWith(rootLinksSearchQuery: value);
  }

  void clearRootLinksSearchQuery() {
    state = state.copyWith(rootLinksSearchQuery: '');
  }

  void setRootLinksStatusFilter(ItemStatus? value) {
    state = state.copyWith(
      rootLinksStatusFilter: value,
      clearRootLinksStatusFilter: value == null,
    );
  }

  void setRootLinksViewMode(UrlViewMode value) {
    state = state.copyWith(rootLinksViewMode: value);
  }

  void resetRootLinksFilters() {
    state = state.copyWith(
      rootLinksSearchQuery: '',
      clearRootLinksStatusFilter: true,
      rootLinksViewMode: UrlViewMode.list,
    );
  }
}

final collectionsListUiNotifierProvider = NotifierProvider.autoDispose<
    CollectionsListUiNotifier, CollectionsListUiState>(
  CollectionsListUiNotifier.new,
);
