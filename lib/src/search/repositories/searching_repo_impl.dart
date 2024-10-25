import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/search/data/local_data_source.dart';

class SearchingRepoImpl {
  SearchingRepoImpl({
    required SearchLocalDataSourcesImpl searchLocalDataSourcesImpl,
  }) : _searchLocalDataSourcesImpl = searchLocalDataSourcesImpl;

  final SearchLocalDataSourcesImpl _searchLocalDataSourcesImpl;

  Future<void> migrateDatabase() async {
    try {
      await _searchLocalDataSourcesImpl.migrateCollections();

      await _searchLocalDataSourcesImpl.migrateURLs();
      // // Logger.printLog('Migration successful');
    } on ServerException {
      // // Logger.printLog('Migration exception: ${e.message}');
    }
  }

  Future<Either<Failure, List<CollectionModel>>> searchLocalDatabase({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final collections = await _searchLocalDataSourcesImpl.searchCollections(
        pageSize: pageSize,
        startIndex: startIndex,
        nameSearch: nameSearch,
        categoryFilters: categories,
        createdAtStart: createStartDate,
        createdAtEnd: createEndDate,
        updatedAtStart: updatedStartDate,
        updatedAtEnd: updatedEndDate,
      );

      return Right(collections);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    }
  }

  Future<Either<Failure, List<UrlModel>>> searchLocalURLs({
    required String nameSearch,
    required List<String> categories,
    required DateTime createStartDate,
    required DateTime createEndDate,
    required DateTime updatedStartDate,
    required DateTime updatedEndDate,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final urls = await _searchLocalDataSourcesImpl.searchUrls(
        pageSize: pageSize,
        startIndex: startIndex,
        nameSearch: nameSearch,
        url: nameSearch,
        categoryFilters: categories,
        createdAtStart: createStartDate,
        createdAtEnd: createEndDate,
        updatedAtStart: updatedStartDate,
        updatedAtEnd: updatedEndDate,
      );

      return Right(urls);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    }
  }
}
