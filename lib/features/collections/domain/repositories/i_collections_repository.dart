import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/collection.dart';

abstract class ICollectionsRepository {
  Stream<List<Collection>> watchCollections();
  Future<Either<Failure, Collection?>> getCollectionById(String id);
  Future<Either<Failure, void>> createCollection(Collection collection);
  Future<Either<Failure, void>> updateCollection(Collection collection);
  Future<Either<Failure, void>> deleteCollection(String id);
  Future<Either<Failure, void>> updateCollectionPosition(
      String id, double newPosition);
  Future<Either<Failure, List<Collection>>> getAllCollections();

  /// Sets [Collection.lastAccessedAt] (and typically `updated_at` remotely).
  Future<Either<Failure, void>> recordCollectionAccess(String id);

  /// Ensures a single library root exists (`parent_id` null). Idempotent.
  ///
  /// Migrates legacy multi–top-level trees by reparenting former roots under
  /// a new library row. Repairs legacy item collection IDs when needed.
  Future<Either<Failure, Collection>> ensureLibraryRootCollection();
}
