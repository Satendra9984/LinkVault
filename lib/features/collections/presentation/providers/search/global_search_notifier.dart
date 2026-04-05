import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../items/domain/entities/item.dart';
import '../../../../items/domain/url_sort_option.dart';
import '../../../../items/presentation/providers/items_list_models.dart';
import 'global_search_state.dart';
import 'search_notifier.dart';

class GlobalSearchNotifier extends Notifier<GlobalSearchState> {
  @override
  GlobalSearchState build() => const GlobalSearchState();

  void setActiveTab(GlobalSearchTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setCollectionsViewMode(UrlViewMode value) {
    state = state.copyWith(collectionsViewMode: value);
  }

  void updateCollectionsSearchDraft(String value) {
    state = state.copyWith(collectionsSearchDraft: value);
  }

  void clearCollectionsSearchQuery() {
    state = state.copyWith(
      collectionsSearchDraft: '',
      collectionsCommittedQuery: '',
    );
  }

  Future<void> submitCollectionsSearchToHistory(String raw) async {
    final trimmed = raw.trim();
    state = state.copyWith(
      collectionsSearchDraft: raw,
      collectionsCommittedQuery: trimmed,
    );
    if (trimmed.isEmpty) return;
    await ref.read(searchHistoryRepositoryProvider).addQuery(trimmed);
  }

  void setCollectionsShowOnlyPrivate(bool value) {
    state = state.copyWith(collectionsShowOnlyPrivate: value);
  }

  void setCollectionsFolderSort(ChildFolderSort value) {
    state = state.copyWith(collectionsFolderSort: value);
  }

  void setCollectionsIncludeArchived(bool value) {
    state = state.copyWith(collectionsIncludeArchived: value);
  }

  void setCollectionsSelectedCategories(Set<String> value) {
    state = state.copyWith(collectionsSelectedCategories: value);
  }

  void setCollectionsUpdatedAfter(DateTime? value) {
    state = state.copyWith(
      collectionsUpdatedAfter: value,
      clearCollectionsUpdatedAfter: value == null,
    );
  }

  void setCollectionsUpdatedBefore(DateTime? value) {
    state = state.copyWith(
      collectionsUpdatedBefore: value,
      clearCollectionsUpdatedBefore: value == null,
    );
  }

  void resetCollectionsFilters() {
    state = state.copyWith(
      collectionsShowOnlyPrivate: false,
      collectionsFolderSort: ChildFolderSort.titleAsc,
      collectionsIncludeArchived: false,
      collectionsSelectedCategories: <String>{},
      clearCollectionsUpdatedAfter: true,
      clearCollectionsUpdatedBefore: true,
      collectionsViewMode: UrlViewMode.icons,
    );
  }

  void updateLinksSearchDraft(String value) {
    state = state.copyWith(linksSearchDraft: value);
  }

  Future<void> submitLinksSearch(String raw) async {
    final trimmed = raw.trim();
    state = state.copyWith(
      linksSearchDraft: raw,
      linksCommittedQuery: trimmed,
    );
    if (trimmed.isEmpty) return;
    await ref.read(searchHistoryRepositoryProvider).addQuery(trimmed);
  }

  void clearLinksSearch() {
    state = state.copyWith(
      linksSearchDraft: '',
      linksCommittedQuery: '',
    );
  }

  void setLinksViewMode(UrlViewMode value) {
    state = state.copyWith(linksViewMode: value);
  }

  void setLinksSortOption(UrlSortOption value) {
    state = state.copyWith(linksSortOption: value);
  }

  void setLinksStatusFilter(ItemStatus? value) {
    state = state.copyWith(
      linksStatusFilter: value,
      clearLinksStatusFilter: value == null,
    );
  }

  void setLinksPinnedOnly(bool value) {
    state = state.copyWith(linksPinnedOnly: value);
  }

  void setLinksWithDescriptionOnly(bool value) {
    state = state.copyWith(linksWithDescriptionOnly: value);
  }

  void setLinksWithImageOnly(bool value) {
    state = state.copyWith(linksWithImageOnly: value);
  }

  void setLinksDomainQuery(String value) {
    state = state.copyWith(linksDomainQuery: value);
  }

  void setLinksSavedAfter(DateTime? value) {
    state = state.copyWith(
      linksSavedAfter: value,
      clearLinksSavedAfter: value == null,
    );
  }

  void setLinksSavedBefore(DateTime? value) {
    state = state.copyWith(
      linksSavedBefore: value,
      clearLinksSavedBefore: value == null,
    );
  }

  void resetLinksFilters() {
    state = state.copyWith(
      linksSortOption: UrlSortOption.dateAdded,
      linksViewMode: UrlViewMode.icons,
      clearLinksStatusFilter: true,
      linksPinnedOnly: false,
      linksWithDescriptionOnly: false,
      linksWithImageOnly: false,
      linksDomainQuery: '',
      clearLinksSavedAfter: true,
      clearLinksSavedBefore: true,
    );
  }

  Future<void> removeHistoryEntry(int id) async {
    await ref.read(searchHistoryRepositoryProvider).removeQuery(id);
  }

  Future<void> clearHistory() async {
    await ref.read(searchHistoryRepositoryProvider).clearAll();
  }
}

final globalSearchNotifierProvider =
    NotifierProvider<GlobalSearchNotifier, GlobalSearchState>(
  GlobalSearchNotifier.new,
);
