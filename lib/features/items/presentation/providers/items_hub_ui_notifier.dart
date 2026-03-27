import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/unified_collection_sheets.dart';
import 'items_hub_ui_state.dart';

class ItemsHubUiNotifier
    extends AutoDisposeFamilyNotifier<ItemsHubUiState, String> {
  // Architecture guardrail: feature UI state belongs here, not in screen setState.
  @override
  ItemsHubUiState build(String arg) => const ItemsHubUiState();

  void setReorderMode(bool value) {
    state = state.copyWith(isReorderMode: value);
  }

  void toggleReorderMode() {
    state = state.copyWith(isReorderMode: !state.isReorderMode);
  }

  void updateUrlSearchQuery(String value) {
    state = state.copyWith(urlSearchQuery: value);
  }

  void clearUrlSearchQuery() {
    state = state.copyWith(urlSearchQuery: '');
  }

  void updateChildSearchQuery(String value) {
    state = state.copyWith(childSearchQuery: value);
  }

  void clearChildSearchQuery() {
    state = state.copyWith(childSearchQuery: '');
  }

  void updateUrlDomainQuery(String value) {
    state = state.copyWith(urlDomainQuery: value);
  }

  void clearUrlDomainQuery() {
    state = state.copyWith(urlDomainQuery: '');
  }

  void setUrlPinnedOnly(bool value) {
    state = state.copyWith(urlPinnedOnly: value);
  }

  void setUrlWithDescriptionOnly(bool value) {
    state = state.copyWith(urlWithDescriptionOnly: value);
  }

  void setUrlWithImageOnly(bool value) {
    state = state.copyWith(urlWithImageOnly: value);
  }

  void setUrlSavedAfter(DateTime? value) {
    state = state.copyWith(
      urlSavedAfter: value,
      clearUrlSavedAfter: value == null,
    );
  }

  void setUrlSavedBefore(DateTime? value) {
    state = state.copyWith(
      urlSavedBefore: value,
      clearUrlSavedBefore: value == null,
    );
  }

  void setChildFolderSort(ChildFolderSort value) {
    state = state.copyWith(childFolderSort: value);
  }

  void setChildIncludeArchived(bool value) {
    state = state.copyWith(childIncludeArchived: value);
  }

  void setChildSelectedCategories(Set<String> values) {
    state = state.copyWith(childSelectedCategories: values);
  }

  void toggleChildCategory(String category) {
    final next = Set<String>.from(state.childSelectedCategories);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }
    state = state.copyWith(childSelectedCategories: next);
  }

  void setChildUpdatedAfter(DateTime? value) {
    state = state.copyWith(
      childUpdatedAfter: value,
      clearChildUpdatedAfter: value == null,
    );
  }

  void setChildUpdatedBefore(DateTime? value) {
    state = state.copyWith(
      childUpdatedBefore: value,
      clearChildUpdatedBefore: value == null,
    );
  }

  void resetUrlFilters() {
    state = state.copyWith(
      urlPinnedOnly: false,
      urlWithDescriptionOnly: false,
      urlWithImageOnly: false,
      clearUrlSavedAfter: true,
      clearUrlSavedBefore: true,
      urlDomainQuery: '',
    );
  }

  void resetChildFilters() {
    state = state.copyWith(
      childFolderSort: ChildFolderSort.titleAsc,
      childIncludeArchived: false,
      childSelectedCategories: <String>{},
      clearChildUpdatedAfter: true,
      clearChildUpdatedBefore: true,
    );
  }
}

final itemsHubUiNotifierProvider = NotifierProvider.autoDispose
    .family<ItemsHubUiNotifier, ItemsHubUiState, String>(ItemsHubUiNotifier.new);
