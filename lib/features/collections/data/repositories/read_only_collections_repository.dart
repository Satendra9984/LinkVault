import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
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
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    AppLogger.w(
        '[collections] createCollection blocked (read-only cloud) title="${collection.title}"');
    return const Left(_error);
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    AppLogger.w(
        '[collections] updateCollection blocked (read-only cloud) id=${collection.id}');
    return const Left(_error);
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    AppLogger.w('[collections] deleteCollection blocked (read-only cloud) id=$id');
    return const Left(_error);
  }

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
      String id, double newPosition) async {
    AppLogger.w(
        '[collections] updateCollectionPosition blocked (read-only cloud) id=$id');
    return const Left(_error);
  }

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) =>
      _inner.recordCollectionAccess(id);

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() async {
    final all = await _inner.getAllCollections();
    return all.fold(
      (f) => Left(f),
      (list) {
        final tops = list
            .where((c) =>
                !c.isDeleted &&
                (c.parentId == null || c.parentId!.trim().isEmpty))
            .toList();
        if (tops.length == 1) {
          return Right(tops.single);
        }
        AppLogger.w(
            '[collections] ensureLibraryRoot blocked (read-only cloud) tops=${tops.length}');
        return const Left(_error);
      },
    );
  }
}
