import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item.dart';
import 'items_providers.dart';

class ItemsHubNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> togglePin({
    required String collectionId,
    required String itemId,
  }) async {
    await ref.read(toggleItemPinUseCaseProvider).call(itemId);
    await ref.read(itemsNotifierProvider(collectionId).notifier).refresh();
    ref.invalidate(homePinnedItemsProvider);
  }

  Future<void> toggleArchive({
    required String collectionId,
    required Item item,
  }) async {
    await ref.read(toggleItemArchiveUseCaseProvider).call(item.id);
    final newStatus =
        item.status == ItemStatus.archived ? ItemStatus.unread : ItemStatus.archived;
    final updatedItem = item.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    ref.read(itemsNotifierProvider(collectionId).notifier).updateItemInState(updatedItem);
  }

  Future<void> deleteItem({
    required String collectionId,
    required String itemId,
    bool refreshAfter = false,
  }) async {
    await ref.read(deleteItemUseCaseProvider).call(itemId);
    final notifier = ref.read(itemsNotifierProvider(collectionId).notifier);
    if (refreshAfter) {
      await notifier.refresh();
      ref.invalidate(homePinnedItemsProvider);
      return;
    }
    notifier.removeItemFromState(itemId);
    ref.invalidate(homePinnedItemsProvider);
  }

  Future<void> markReadAndTrack({
    required String collectionId,
    required String itemId,
  }) async {
    await ref.read(markItemReadAndTrackUseCaseProvider).call(itemId);
    await ref.read(itemsNotifierProvider(collectionId).notifier).refresh();
  }

  Future<void> toggleReadStatus({
    required String collectionId,
    required Item item,
  }) async {
    await ref.read(toggleItemStatusUseCaseProvider).call(item);
    await ref.read(itemsNotifierProvider(collectionId).notifier).refresh();
  }

  Future<void> reorderItems({
    required String collectionId,
    required List<String> orderedIds,
  }) async {
    await ref.read(reorderItemsUseCaseProvider).call(
          collectionId: collectionId,
          orderedIds: orderedIds,
        );
    await ref.read(itemsNotifierProvider(collectionId).notifier).refresh();
  }

  Future<void> moveItem({
    required String sourceCollectionId,
    required Item item,
    required String targetCollectionId,
  }) async {
    final updated = item.copyWith(
      collectionId: targetCollectionId,
      updatedAt: DateTime.now(),
    );
    await ref.read(updateItemUseCaseProvider).call(updated);
    ref.read(itemsNotifierProvider(sourceCollectionId).notifier).removeItemFromState(item.id);
    ref.invalidate(homePinnedItemsProvider);
  }
}

final itemsHubNotifierProvider =
    NotifierProvider.autoDispose<ItemsHubNotifier, void>(ItemsHubNotifier.new);
