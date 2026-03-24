import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/i_collections_repository.dart';

/// Decorator that wraps any [ICollectionsRepository] and returns
/// [SubscriptionExpiredFailure] for every mutating operation.
///
/// Read operations are transparently delegated to the inner repository.
/// Used when `hasMigrated=true` but `isSubscriptionActive=false`.
class ReadOnlyCollectionsRepository implements ICollectionsRepository {
  final ICollectionsRepository _inner;

  const ReadOnlyCollectionsRepository(this._inner);

  static const _error = SubscriptionExpiredFailure(
    'Your subscription has lapsed. Renew to resume editing your collections.',
  );

  // ── Read operations — delegate ────────────────────────────────────────────

  @override
  Stream<List<Collection>> watchCollections() => _inner.watchCollections();

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) =>
      _inner.getCollectionById(id);

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() =>
      _inner.getAllCollections();

  // ── Write operations — gate ───────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async =>
      const Left(_error);

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
          String id, double newPosition) async =>
      const Left(_error);
}
