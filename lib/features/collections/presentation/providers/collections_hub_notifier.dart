import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/collection_fractional_reorder.dart';
import '../../domain/entities/collection.dart';
import 'collections_providers.dart';

class CollectionsHubNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> reorderSiblings({
    required List<Collection> siblings,
    required int oldIndex,
    required int newIndex,
  }) async {
    var to = newIndex;
    if (to > oldIndex) to--;
    if (oldIndex == to) return;
    final result = computeSiblingReorderPositions(
      siblings: siblings,
      oldIndex: oldIndex,
      newIndex: to,
    );
    final updatePosition = ref.read(updateCollectionPositionUseCaseProvider);
    if (result.rebalanceAll != null) {
      for (final e in result.rebalanceAll!.entries) {
        await updatePosition.call(e.key, e.value);
      }
      return;
    }
    await updatePosition.call(result.primaryId, result.primaryPosition);
  }

  Future<void> togglePin(Collection collection) async {
    final updated = Collection(
      id: collection.id,
      ownerId: collection.ownerId,
      parentId: collection.parentId,
      isShared: collection.isShared,
      title: collection.title,
      description: collection.description,
      category: collection.category,
      colorHex: collection.colorHex,
      iconName: collection.iconName,
      iconJson: collection.iconJson,
      position: collection.position,
      isPinned: !collection.isPinned,
      isArchived: collection.isArchived,
      isDeleted: collection.isDeleted,
      childCount: collection.childCount,
      createdAt: collection.createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: collection.lastAccessedAt,
      itemsLayout: collection.itemsLayout,
      childCollectionsLayout: collection.childCollectionsLayout,
      itemsSortDefault: collection.itemsSortDefault,
      openLinksIn: collection.openLinksIn,
      showLinkPreviews: collection.showLinkPreviews,
      itemCount: collection.itemCount,
    );
    await ref.read(updateCollectionUseCaseProvider).call(updated);
    ref.invalidate(collectionsListProvider);
  }

  Future<void> deleteCollection(String id) async {
    await ref.read(deleteCollectionUseCaseProvider).call(id);
    ref.invalidate(collectionsListProvider);
  }

  Future<void> saveCollection(Collection collection) async {
    await ref.read(updateCollectionUseCaseProvider).call(collection);
    ref.invalidate(collectionsListProvider);
  }

  Future<void> recordAccess(String id) async {
    await ref.read(recordCollectionAccessUseCaseProvider).call(id);
  }
}

final collectionsHubNotifierProvider =
    NotifierProvider.autoDispose<CollectionsHubNotifier, void>(
      CollectionsHubNotifier.new,
    );
