import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:flutter/widgets.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_image.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:path_provider/path_provider.dart';

class UrlLocalDataSourcesImpl {
  UrlLocalDataSourcesImpl({
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
            UrlImageSchema,
            ImagesByteDataSchema,
            UrlModelOfflineSchema,
          ],
          directory: dir.path,
        );
      }
    } catch (e) {
      Logger.printLog('urloffline: initialize ${e}');

      return;
    }
  }

  // Fetch UrlModelOffline by id
  Future<UrlModel?> fetchUrl(String urlId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      final urlModelOffline =
          await urlModelOfflineCollection.getByIndex('firestoreId', [urlId]);

      if (urlModelOffline == null) {
        return null;
      }
      Logger.printLog('urloffline: fetchedUrl');
      return urlModelOffline.toUrlModel();
    } catch (e) {
      Logger.printLog('fetchUrlLocal : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  Future<UrlModelOffline?> fetchUrlModelOffline(String urlId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;
      Logger.printLog(
          'urloffline: fetchedUrlOfflineModel isar ${_isar != null}');

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      final urlModelOffline =
          await urlModelOfflineCollection.getByIndex('firestoreId', [urlId]);

      if (urlModelOffline == null) {
        return null;
      }
      Logger.printLog('urloffline: fetchedUrlOfflineModel');

      return urlModelOffline;
    } catch (e) {
      Logger.printLog('fetchUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Add UrlModelOffline
  Future<UrlModel?> addUrl(UrlModel urlModel) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      final urlModelOffline = UrlModelOffline.fromUrlModel(urlModel);

      // Insert the UrlModelOffline into Isar
      await _isar!.writeTxn(
        () async {
          await urlModelOfflineCollection.put(urlModelOffline);
        },
      );

      Logger.printLog('urloffline: addedUrl');

      return urlModelOffline.toUrlModel();
    } catch (e) {
      Logger.printLog('addUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Update UrlModelOffline
  Future<UrlModel?> updateUrl(UrlModel urlModel) async {
    try {
      await _initializeIsar();
      Logger.printLog('urloffline: updatedUrl isar ${_isar != null}');
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      final urlModelOffline = UrlModelOffline.fromUrlModel(urlModel);

      // Update the UrlModelOffline in Isar
      await _isar!.writeTxn(
        () async {
          await urlModelOfflineCollection.put(urlModelOffline);
        },
      );
      Logger.printLog('urloffline: updatedUrl');

      return urlModelOffline.toUrlModel();
    } catch (e) {
      Logger.printLog('updateUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return null;
    }
  }

  // Delete UrlModelOffline by id
  Future<void> deleteUrl(String urlId) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      await fetchUrlModelOffline(urlId).then(
        (urlModelOffline) async {
          if (urlModelOffline == null) return;
          await _isar!.writeTxn(
            () async {
              await urlModelOfflineCollection.delete(urlModelOffline.id);
            },
          );
        },
      );
      Logger.printLog('urloffline: deletedUrl');
    } catch (e) {
      Logger.printLog('deleteUrlOffline : $e');
      // throw ServerException(
      //   message: 'Something Went Wrong',
      //   statusCode: 400,
      // );
      return;
    }
  }
}
