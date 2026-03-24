import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_entity.dart';

abstract class CollectionRepository {
  // Collection CRUD
  Future<Either<Failure,List<CollectionEntity>>> getUserCollections(String userId);
  Future<Either<Failure,List<CollectionEntity>>> getRootCollections(String userId);
  Future<Either<Failure,List<CollectionEntity>>> getSubCollections(String parentId);
  Future<Either<Failure,CollectionEntity?>> getCollectionById(String id);
  Future<Either<Failure,CollectionEntity>> createCollection(CollectionEntity collection);
  Future<Either<Failure,CollectionEntity>> updateCollection(CollectionEntity collection);
  Future<Either<Failure,void>> deleteCollection(String id);
  
  // Specific queries for home screen features
  Future<Either<Failure,List<CollectionEntity>>> getPinnedCollections(String userId);
  Future<Either<Failure,List<CollectionEntity>>> getArchivedCollections(String userId);
  
  // Collection hierarchy operations
  Future<Either<Failure,List<CollectionEntity>>> getCollectionHierarchy(String collectionId);
  Future<Either<Failure,void>> moveCollection(String collectionId, String? newParentId);
  
  // Offline sync
  Stream<List<CollectionEntity>> watchUserCollections(String userId);
  Future<Either<Failure,void>> syncCollections();
}