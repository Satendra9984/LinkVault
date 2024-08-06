import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:path_provider/path_provider.dart';

class SearchLocalDataSourcesImpl {
  SearchLocalDataSourcesImpl({
    required Isar? isar,
  }) : _isar = isar;

  Isar? _isar;

  Future<void> _initializeIsar() async {
    try {
      final currentInstance = Isar.getInstance();
      _isar = currentInstance;
      if (_isar == null) {
        final dir = await getApplicationDocumentsDirectory();

        _isar = await Isar.open(
          [
            CollectionModelOfflineSchema,
            UrlModelOfflineSchema,
            ImagesByteDataSchema,
            CollectionModelOfflineSchema,
          ],
          directory: dir.path,
        );
      }
    } catch (e) {
      Logger.printLog('Collectionoffline: initialize $e');

      return;
    }
  }

  // Fetch CollectionModelOffline by id
  Future<CollectionModel?> fetchCollection(String collectionId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      final collectionModelOffline = await collectionModelOfflineCollection
          .getByIndex('firestoreId', [collectionId]);

      if (collectionModelOffline == null) {
        return null;
      }
      // Logger.printLog('Collectionoffline: fetchedCollection');
      final coll = collectionModelOffline.toCollectionModel();

      return coll;
    } catch (e) {
      Logger.printLog('fetchCollectionLocal : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  Future<void> migrateCollections() async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      final docs = await collectionModelOfflineCollection.where().findAll();

      for (final doc in docs) {
        final coll = doc.toCollectionModel();
        final updated = doc.copyWith(
          collectionModel: coll,
        );
        await _isar!.writeTxn(() async {
          await collectionModelOfflineCollection.put(updated);
        });
      }
    } catch (e) {
      Logger.printLog('Error migrating collections : $e');
      throw ServerException(
        message: 'Error migrating collections',
        statusCode: 500,
      );
    }
  }

  Future<void> migrateURLs() async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final collectionModelOfflineCollection =
          _isar!.collection<UrlModelOffline>();

      final docs = await collectionModelOfflineCollection.where().findAll();

      for (final doc in docs) {
        final url = doc.toUrlModel();
        final updated = doc.copyWith(
          urlModel: url,
        );
        await _isar!.writeTxn(() async {
          await collectionModelOfflineCollection.put(updated);
        });
      }
    } catch (e) {
      Logger.printLog('Error migrating URLs : $e');
      throw ServerException(
        message: 'Error migrating URLs',
        statusCode: 500,
      );
    }
  }

  Future<List<CollectionModel>> searchCollections({
    required int pageSize,
    required int startIndex,
    required String nameSearch, // Assumes nameSearch is always provided
    required List<String>
        categoryFilters, // Assumes categoryFilters is always provided and non-empty
    required DateTime
        createdAtStart, // Assumes createdAtStart is always provided
    required DateTime createdAtEnd, // Assumes createdAtEnd is always provided
    required DateTime
        updatedAtStart, // Assumes updatedAtStart is always provided
    required DateTime updatedAtEnd, // Assumes updatedAtEnd is always provided
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) {
        throw ServerException(
          message: 'Error Searching collections',
          statusCode: 500,
        );
      }

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      // await _isar!.collectionModelOfflines;
      Logger.printLog('nameSearch: $nameSearch');
      var queryBuilder = collectionModelOfflineCollection
          .filter()
          .group((q) => q
              .nameIsNull()
              .or()
              .nameIsEmpty()
              .or()
              .nameContains(nameSearch, caseSensitive: false))
          .createdAtBetween(createdAtStart, createdAtEnd)
          .updatedAtBetween(
            updatedAtStart,
            updatedAtEnd,
          ); // Filter by updatedAt range

      // Start building the category filter logic
      // Add category filter logic
      if (categoryFilters.isNotEmpty) {
        queryBuilder = queryBuilder.and().group(
          (q) {
            var categoryQuery = q.categoryEqualTo(categoryFilters.first);
            for (var i = 1; i < categoryFilters.length; i++) {
              categoryQuery =
                  categoryQuery.or().categoryEqualTo(categoryFilters[i]);
            }
            return categoryQuery;
          },
        );
        // final combinedCategories = '|${categoryFilters.join('|')}|';
        // Logger.printLog('combinedcat: $combinedCategories');
        // queryBuilder = queryBuilder.and().categoryMatches(
        //       '.*\\|$combinedCategories.*',
        //       caseSensitive: false,
        //     );
      }

      final results = await queryBuilder
          .offset(startIndex) // Set the offset to start at the startIndex
          .limit(pageSize) // Set the limit to the pageSize
          .findAll(); // Execute the query and return all matching records

      final collections = <CollectionModel>[];
      for (final coll in results) {
        collections.add(coll.toCollectionModel());
      }

      return collections;
    } catch (e) {
      Logger.printLog('Error searching collections : $e');
      throw ServerException(
        message: 'Error Searching collections',
        statusCode: 500,
      );
    }
  }

  Future<List<UrlModel>> searchUrls({
    required int pageSize,
    required int startIndex,
    required String nameSearch, // Assumes nameSearch is always provided
    required String url,
    required List<String>
        categoryFilters, // Assumes categoryFilters is always provided and non-empty
    required DateTime
        createdAtStart, // Assumes createdAtStart is always provided
    required DateTime createdAtEnd, // Assumes createdAtEnd is always provided
    required DateTime
        updatedAtStart, // Assumes updatedAtStart is always provided
    required DateTime updatedAtEnd, // Assumes updatedAtEnd is always provided
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) {
        throw ServerException(
          message: 'Error Searching collections',
          statusCode: 500,
        );
      }

      final collectionModelOfflineCollection =
          _isar!.collection<UrlModelOffline>();

      // await _isar!.collectionModelOfflines;
      Logger.printLog('nameSearch: $nameSearch');
      var queryBuilder = collectionModelOfflineCollection
          .filter()
          .group(
            (q) => q
                .titleIsNull()
                .or()
                .titleIsEmpty()
                .or()
                .titleContains(nameSearch, caseSensitive: false),
          )
          .and()
          .group(
            (q) => q
                .urlIsNull()
                .or()
                .urlIsEmpty()
                .or()
                .urlContains(nameSearch, caseSensitive: false),
          )
          .createdAtBetween(createdAtStart, createdAtEnd)
          .updatedAtBetween(
            updatedAtStart,
            updatedAtEnd,
          ); // Filter by updatedAt range

      // Start building the category filter logic
      // Add category filter logic
      if (categoryFilters.isNotEmpty) {
        queryBuilder = queryBuilder.and().group(
          (q) {
            var categoryQuery = q.tagEqualTo(categoryFilters.first);
            for (var i = 1; i < categoryFilters.length; i++) {
              categoryQuery = categoryQuery.or().tagEqualTo(categoryFilters[i]);
            }
            return categoryQuery;
          },
        );
        // final combinedCategories = '|${categoryFilters.join('|')}|';
        // Logger.printLog('combinedcat: $combinedCategories');
        // queryBuilder = queryBuilder.and().categoryMatches(
        //       '.*\\|$combinedCategories.*',
        //       caseSensitive: false,
        //     );
      }

      final results = await queryBuilder
          .offset(startIndex) // Set the offset to start at the startIndex
          .limit(pageSize) // Set the limit to the pageSize
          .findAll(); // Execute the query and return all matching records

      final collections = <UrlModel>[];
      for (final coll in results) {
        collections.add(coll.toUrlModel());
      }

      return collections;
    } catch (e) {
      Logger.printLog('Error searching collections : $e');
      throw ServerException(
        message: 'Error Searching collections',
        statusCode: 500,
      );
    }
  }
}
