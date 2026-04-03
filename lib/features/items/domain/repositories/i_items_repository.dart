import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../models/url_items_query.dart';

abstract class IItemsRepository {
  /// Filtered, sorted, paginated URLs for one collection (preferred path).
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery query);

  Future<Either<Failure, List<Item>>> getPaginatedItems(
      String collectionId, int limit, int offset);
  Future<Either<Failure, Item?>> getItem(String id);
  Future<Either<Failure, void>> createItem(Item item);
  Future<Either<Failure, void>> updateItem(Item item);
  Future<Either<Failure, void>> deleteItem(String id);

  /// Toggles `lv_urls.is_pinned` for the given url id.
  Future<Either<Failure, void>> toggleItemPin(String id);

  /// Toggles archive state by setting `lv_urls.status` to `archived`/unarchived.
  Future<Either<Failure, void>> toggleItemArchive(String id);

  /// Marks url as read (if currently unread), increments click count and updates last access.
  Future<Either<Failure, void>> markItemReadAndTrack(String id);

  /// Reorders all URLs within a collection (updates their `position` values).
  Future<Either<Failure, void>> reorderItems(
      String collectionId, List<String> orderedIds);
  Future<Either<Failure, void>> updateItemPosition(
      String id, double newPosition);
  Future<Either<Failure, List<Item>>> getAllItems();

  /// Finds an item in [collectionId] whose [link] matches after normalization
  /// (used for import de-duplication when backup IDs differ).
  Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(
    String collectionId,
    String link,
  );
}
