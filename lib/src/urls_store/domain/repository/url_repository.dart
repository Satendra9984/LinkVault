import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/urls_store/domain/entities/url_entity.dart';

abstract class UrlsRepository {
  // CRUD Operations
  Future<Either<Failure,UrlEntity>> createUrl(UrlEntity url);
  Future<Either<Failure,UrlEntity>> getUrl(String id);
  Future<Either<Failure,List<UrlEntity>>> getUrlsByCollection(
    String collectionId, {
    bool includeArchived = false,
  });
  Future<Either<Failure,UrlEntity>> updateUrl(UrlEntity url);
  Future<Either<Failure,void>> deleteUrl(String id);

  // Batch Operations
  Future<Either<Failure,List<UrlEntity>>> createUrls(List<UrlEntity> urls);
  Future<Either<Failure,void>> deleteUrls(List<String> ids);
  Future<Either<Failure,List<UrlEntity>>> moveUrls(List<String> urlIds, String targetCollectionId);

  // Favorites & Pins
  Future<Either<Failure,UrlEntity>> togglePin(String id);
  Future<Either<Failure,List<UrlEntity>>> getPinnedUrls();
  Future<Either<Failure,List<UrlEntity>>> getPinnedUrlsByCollection(String collectionId);

  // Archiving
  Future<Either<Failure,UrlEntity>> toggleArchive(String id);
  Future<Either<Failure,List<UrlEntity>>> getArchivedUrls();

  // Analytics & Interaction
  Future<Either<Failure,UrlEntity>> incrementClickCount(String id);
  Future<Either<Failure,UrlEntity>> updateLastAccessed(String id);
  Future<Either<Failure,List<UrlEntity>>> getMostVisitedUrls({int limit = 10});

  // Positioning
  Future<Either<Failure,UrlEntity>> updatePosition(String id, int newPosition);
  Future<Either<Failure,void>> reorderUrls(String collectionId, List<String> orderedIds);

  // Metadata & Enrichment
  Future<Either<Failure,UrlEntity>> updateMetadata(String id, Map<String, dynamic> metadata);
  Future<Either<Failure,UrlEntity>> enrichUrlData(String id); // Fetch title, favicon, etc.

  // Search & Filter
  Future<Either<Failure,List<UrlEntity>>> searchUrls(String query);
  Future<Either<Failure,List<UrlEntity>>> getUrlsByTag(String tagId);
  Future<Either<Failure,List<UrlEntity>>> getRecentUrls({int limit = 20});

  // Sync Operations
  Future<Either<Failure,void>> syncFromRemote();
  Future<Either<Failure,void>> syncToRemote();
}