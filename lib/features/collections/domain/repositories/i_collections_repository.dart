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
}
