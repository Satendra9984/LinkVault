import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/models/url_items_query.dart';
import '../../domain/repositories/i_items_repository.dart';

/// Decorator that wraps any [IItemsRepository] and returns
/// [SubscriptionExpiredFailure] for every mutating operation.
///
/// Read operations are transparently delegated to the inner repository.
/// Used when `hasMigrated=true` but `isSubscriptionActive=false`.
class ReadOnlyItemsRepository implements IItemsRepository {
  final IItemsRepository _inner;

  const ReadOnlyItemsRepository(this._inner);

  static const _error = SubscriptionExpiredFailure(
    'Your subscription has lapsed. Renew to resume editing your items.',
  );

  // ── Read operations — delegate ────────────────────────────────────────────

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery query) =>
      _inner.queryUrlItems(query);

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
          String collectionId, int limit, int offset) =>
      _inner.getPaginatedItems(collectionId, limit, offset);

  @override
  Future<Either<Failure, Item?>> getItem(String id) => _inner.getItem(id);

  @override
  Future<Either<Failure, List<Item>>> getAllItems() => _inner.getAllItems();

  // ── Write operations — gate ───────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> createItem(Item item) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> updateItem(Item item) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> deleteItem(String id) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> reorderItems(
          String collectionId, List<String> orderedIds) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> updateItemPosition(
          String id, double newPosition) async =>
      const Left(_error);

  @override
  Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(
          String collectionId, String link) =>
      _inner.findItemByCollectionAndNormalizedLink(collectionId, link);
}
