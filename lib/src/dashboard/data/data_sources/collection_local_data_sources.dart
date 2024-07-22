import 'package:isar/isar.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
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

  Future<CollectionModelOffline?> fetchCollectionModelOffline(
    String collectionId,
  ) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;
      // Logger.printLog(
      //   'Collectionoffline: fetchedCollectionOfflineModel isar ${_isar != null}',
      // );

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      final collectionModelOffline = await collectionModelOfflineCollection
          .getByIndex('firestoreId', [collectionId]);

      if (collectionModelOffline == null) {
        return null;
      }
      // Logger.printLog('Collectionoffline: fetchedCollectionOfflineModel');

      return collectionModelOffline;
    } catch (e) {
      Logger.printLog('fetchCollectionOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Add CollectionModelOffline
  Future<CollectionModel?> addCollection(
    CollectionModel collectionModel,
  ) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      final collectionModelOffline =
          CollectionModelOffline.fromCollectionModel(collectionModel);

      // Insert the CollectionModelOffline into Isar
      await _isar!.writeTxn(
        () async {
          await collectionModelOfflineCollection.put(collectionModelOffline);
        },
      );

      // Logger.printLog('Collectionoffline: addedCollection');

      return collectionModelOffline.toCollectionModel();
    } catch (e) {
      Logger.printLog('addCollectionOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Update CollectionModelOffline
  Future<void> updateCollection(
    CollectionModel collectionModel,
  ) async {
    try {
      await _initializeIsar();
      // Logger.printLog(
      //   'Collectionoffline: updatedCollection isar ${_isar != null}',
      // );
      if (_isar == null) return;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      await fetchCollectionModelOffline(collectionModel.id).then(
        (collectionModelOffline) async {
          // if (collectionModelOffline == null) return;

          final updatedUrlOffline = collectionModelOffline?.copyWith(
                collectionModel: collectionModel,
              ) ??
              CollectionModelOffline.fromCollectionModel(collectionModel);

          await _isar!.writeTxn(
            () async {
              await collectionModelOfflineCollection.put(updatedUrlOffline);
            },
          );
        },
      );
      // Logger.printLog('urloffline: updatedUrl');

      return;
    } catch (e) {
      Logger.printLog('updateUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }

  // Delete CollectionModelOffline by id
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final collectionModelOfflineCollection =
          _isar!.collection<CollectionModelOffline>();

      await fetchCollectionModelOffline(collectionId).then(
        (collectionModelOffline) async {
          // Logger.printLog(
          //   'Collectionoffline: deletedCollection ${collectionModelOffline?.id}, ${collectionModelOffline?.firestoreId}',
          // );

          if (collectionModelOffline == null) return;
          await _isar!.writeTxn(
            () async {
              await collectionModelOfflineCollection.delete(
                collectionModelOffline.id!,
              );
            },
          );
        },
      );
      // Logger.printLog('Collectionoffline: deletedCollection');
    } catch (e) {
      Logger.printLog('deleteCollectionOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }
}
