import 'package:isar/isar.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/query_builder.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/collection_model_isar.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_model_isar.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_filter_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_filters_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class CollectionLocalDataSourcesImpl {
  CollectionLocalDataSourcesImpl({
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
            CollectionModelIsarSchema,
            UrlModelIsarSchema,
            ImagesByteDataSchema,
            // CollectionModelIsarSchema,
          ],
          directory: dir.path,
        );
      }
    } catch (e) {
      // Logger.printLog('Collectionoffline: initialize $e');

      return;
    }
  }

  Future<List<CollectionModel>?> fetchCollectionWithFilters(
    CollectionFilter filter,
  ) async {
    await _initializeIsar();
    if (_isar == null) return null;

    final collectionModelOfflineCollection =
        _isar!.collection<CollectionModelIsar>();

    final isarCollections =
        await QueryBuilderHelper.buildCollectionModelIsarQuery(
      filter,
      collectionModelOfflineCollection,
    ).findAll();

    // Logger.printLog('Collectionoffline: fetchedCollection');

    final collections = isarCollections
        .map((isarCollection) => isarCollection.toCollectionModel())
        .toList();

    return collections;
  }

  Future<CollectionModelIsar?> fetchCollectionModelIsar(
    String collectionId,
  ) async {
    await _initializeIsar();
    if (_isar == null) return null;

    final collectionModelOfflineCollection =
        _isar!.collection<CollectionModelIsar>();

    final collectionModelOffline =
        await collectionModelOfflineCollection.getByIndex(
      'firestoreId',
      [collectionId],
    );

    if (collectionModelOffline == null) {
      return null;
    }

    return collectionModelOffline;
  }

  // Add CollectionModelOffline
  Future<CollectionModel?> addCollectionInLocalDB(
    CollectionModel collectionModel,
  ) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelIsar>();

      final collectionModelOffline =
          CollectionModelIsar.fromCollectionModel(collectionModel);

      // Insert the CollectionModelOffline into Isar
      await _isar!.writeTxn(
        () async {
          await collectionModelOfflineCollection.put(collectionModelOffline);
        },
      );

      // Logger.printLog('Collectionoffline: addedCollection');

      return collectionModelOffline.toCollectionModel();
    } catch (e) {
      // Logger.printLog('addCollectionOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Update CollectionModelOffline
  Future<void> updateCollectionInLocalDB(
    CollectionModel collectionModel,
  ) async {
    try {
      await _initializeIsar();

      if (_isar == null) return;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelIsar>();

      await fetchCollectionModelIsar(collectionModel.id).then(
        (collectionIsarModel) async {
          if (collectionIsarModel == null) {
            await _isar!.writeTxn(
              () async {
                await collectionModelOfflineCollection.put(
                  CollectionModelIsar.fromCollectionModel(collectionModel),
                );
              },
            );
          } else {
            final updatedIsarCollection =
                collectionIsarModel.copyWithCollectionModel(collectionModel);

            await _isar!.writeTxn(
              () async {
                await collectionModelOfflineCollection
                    .put(updatedIsarCollection);
              },
            );
          }
        },
      );

      return;
    } catch (e) {
      // Logger.printLog('updateUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }

  Future<bool> deleteCollectionAndAssociatedDataInLocalDB({
    required String collectionId,
    int batchSize = 30,
  }) async {
    var isMainCollectionDeleted = false;
    try {
      await _initializeIsar();

      if (_isar == null) return false;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelIsar>();

      await Future.wait(
        [
          Future(
            () async {
              // 1. Delete the main collection document
              await _isar!.writeTxn(() async {
                final deleted =
                    await collectionModelOfflineCollection.deleteByIndex(
                  'firestoreId',
                  [collectionId],
                );
                isMainCollectionDeleted = deleted;
              });
            },
          ),
          _deleteUrlsForCollectionInLocalDB(
            collectionId: collectionId,
            batchSize: batchSize,
          ),
        ],
      );

      // 3. Recursively delete subcollections and their URLs
      final collectionsToProcess = [collectionId];

      while (collectionsToProcess.isNotEmpty) {
        final currentCollectionId = collectionsToProcess.removeAt(0);

        // Fetch subcollections
        final subcollections = await collectionModelOfflineCollection
            .filter()
            .parentCollectionEqualTo(currentCollectionId)
            .findAll();

        for (final subCollection in subcollections) {
          collectionsToProcess.add(subCollection.firestoreId);

          await Future.wait(
            [
              _deleteUrlsForCollectionInLocalDB(
                collectionId: subCollection.firestoreId,
                batchSize: batchSize,
              ),
              _isar!.writeTxn(
                () async => collectionModelOfflineCollection.deleteByIndex(
                  'firebaseId',
                  [subCollection.firestoreId],
                ),
              ),
            ],
          );
        }
      }
    } catch (e) {
      Logger.printLog('[log] : Error in deletion: $e');
      if (isMainCollectionDeleted) {
        return isMainCollectionDeleted;
      }

      throw Exception('Failed to delete collection and associated data');
    }

    return isMainCollectionDeleted;
  }

  // Helper method to delete URLs for a specific collection
  Future<void> _deleteUrlsForCollectionInLocalDB({
    required String collectionId,
    required int batchSize,
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      final urlsToDelete = await urlModelOfflineCollection
          .filter()
          .collectionIdEqualTo(collectionId)
          .findAll();

      for (final url in urlsToDelete) {
        await _isar!.writeTxn(
          () async {
            await urlModelOfflineCollection.deleteByIndex(
              'collectionId',
              [url.collectionId],
            );
          },
        );
      }
    } catch (e) {
      Logger.printLog('[log] : Error deleting URLs: $e');
      throw Exception('Failed to delete associated URLs');
    }
  }

  Future<List<UrlModel>?> fetchUrlsFromLocalDB({
    required UrlModelFilters filter,
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      final query = QueryBuilderHelper.buildUrlModelIsarQuery(
        filter,
        urlModelOfflineCollection,
      );

      final urls = await query.findAll();

      return urls.map((isarUrlModel) => isarUrlModel.toUrlModel()).toList();
    } catch (e) {
      Logger.printLog('[log]: fetchUrlsFromLocalDB $e');
      throw Exception('Failed to fetch associated URLs');
    }
  }

  // Fetch UrlModelOffline by id
  Future<UrlModel?> fetchUrlFromLocalDB(String urlId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      final urlModelOffline =
          await urlModelOfflineCollection.getByIndex('firestoreId', [urlId]);

      if (urlModelOffline == null) {
        return null;
      }
      // Logger.printLog('urloffline: fetchedUrl');
      return urlModelOffline.toUrlModel();
    } catch (e) {
      // Logger.printLog('fetchUrlLocal : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  Future<UrlModelIsar?> fetchUrlModelInLocalDB(String urlId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      final urlModelOffline =
          await urlModelOfflineCollection.getByIndex('firestoreId', [urlId]);

      if (urlModelOffline == null) {
        return null;
      }

      return urlModelOffline;
    } catch (e) {
      // Logger.printLog('fetchUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Add UrlModelOffline
  Future<UrlModel?> addUrlInLocalDB(UrlModel urlModel) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      final urlModelOffline = UrlModelIsar.fromUrlModel(urlModel);

      // Insert the UrlModelOffline into Isar
      await _isar!.writeTxn(
        () async {
          await urlModelOfflineCollection.put(urlModelOffline);
        },
      );

      return urlModelOffline.toUrlModel();
    } catch (e) {
      // Logger.printLog('addUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Update UrlModelOffline
  Future<void> updateUrlInLocalDB(UrlModel urlModel) async {
    try {
      await _initializeIsar();
      // Logger.printLog('urloffline: updatedUrl isar ${_isar != null}');
      if (_isar == null) return;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      // final urlModelOffline = UrlModelOffline.fromUrlModel(urlModel);
      await fetchUrlModelInLocalDB(urlModel.firestoreId).then(
        (urlModelOffline) async {
          final updatedUrlOffline =
              urlModelOffline?.copyWithUrlModel(urlModel) ??
                  UrlModelIsar.fromUrlModel(urlModel);

          await _isar!.writeTxn(
            () async {
              await urlModelOfflineCollection.put(updatedUrlOffline);
            },
          );
        },
      );
      // Logger.printLog('urloffline: updatedUrl');

      return;
    } catch (e) {
      // Logger.printLog('updateUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }

  // Delete UrlModelOffline by id
  Future<void> deleteUrlInLocalDB(String urlFirestoreId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final urlModelOfflineCollection = _isar!.collection<UrlModelIsar>();

      await fetchUrlModelInLocalDB(urlFirestoreId).then(
        (urlModelOffline) async {
          if (urlModelOffline == null) return;
          await _isar!.writeTxn(
            () async {
              await urlModelOfflineCollection.delete(urlModelOffline.id!);
            },
          );
        },
      );
      // Logger.printLog('urloffline: deletedUrl');
    } catch (e) {
      // Logger.printLog('deleteUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }
}
