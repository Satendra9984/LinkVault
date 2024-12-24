import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_image.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_model_isar.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:path_provider/path_provider.dart';

class LocalImageDataSource {
  LocalImageDataSource();

  Isar? _isar;

  Future<void> _initializeIsar() async {
    if (_isar != null) return; // Already initialized

    try {
      // Try to get an existing instance first
      _isar = Isar.getInstance();

      if (_isar == null) {
        // If no instance exists, create a new one
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [
            UrlImageSchema,
            ImagesByteDataSchema,
            UrlModelIsarSchema,
          ],
          directory: dir.path,
        );
      }

      // Logger.printLog('Isar initialized successfully');
    } catch (e) {
      // Logger.printLog('Error initializing Isar: $e');
      // You might want to rethrow the error or handle it in a way that's appropriate for your app
    }
  }

  Future<void> addImageData({
    required String imageUrl,
    required Uint8List imageBytes,
  }) async {
    try {
      await _initializeIsar(); // Ensure Isar is initialized
      if (_isar == null) {
        // Logger.printLog('Isar is not initialized');
        return;
      }

      await _isar!.writeTxn(() async {
        final urlImages = _isar!.collection<UrlImage>();
        await urlImages.put(
          UrlImage.fromBytes(
            imageUrl: imageUrl,
            bytes: imageBytes,
          ),
        );
      });
    } catch (e) {
      // Logger.printLog('[isar] addImageData error: $e');
    }
  }

  Future<Uint8List?> getImageData(String url) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlImages = _isar!.collection<UrlImage>();

      final urlImage =
          await urlImages.filter().imageUrlEqualTo(url).findFirst();

      if (urlImage == null) return null;

      final bytes =
          StringUtils.convertBase64ToUint8List(urlImage.base64ImageBytes);

      return bytes;
    } catch (e) {
      // Logger.printLog('[isar] getImageData $e');

      return null;
    }
  }

  Future<void> deleteImageData({
    required String imageUrl,
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) {
        // Logger.printLog('[isar] Isar not initialized');
        return;
      }

      await _isar!.writeTxn(() async {
        final urlImages = _isar!.collection<UrlImage>();

        final deleted = await urlImages.deleteAllByImageUrl([imageUrl]);
        // Logger.printLog('[deletedImages] : $deleted $imageUrl');
      });
    } catch (e) {
      // Logger.printLog('[isar] deleteImageData error: $e');
    }
  }

  Future<Uint8List?> getImageDataBytes(String url) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlImages = _isar!.collection<ImagesByteData>();

      final urlImage =
          await urlImages.filter().imageUrlEqualTo(url).findFirst();

      // Logger.printLog('[isar] getImageData $url ${urlImage == null}');

      if (urlImage == null) return null;

      final bytes = Uint8List.fromList(urlImage.imageBytes);

      return bytes;
    } catch (e) {
      // Logger.printLog('[isar] getImageData $e');

      return null;
    }
  }

  Future<void> addImageDataBytes({
    required String imageUrl,
    required Uint8List imageBytes,
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      await _isar!.writeTxn(() async {
        final urlImages = _isar!.collection<ImagesByteData>();
        await urlImages.put(
          ImagesByteData.fromBytes(
            imageUrl: imageUrl,
            bytes: imageBytes,
          ),
        );
      }).then((_) {
        // // Logger.printLog('[isar] getImageData $imageUrl addedSuccess');
      });
    } catch (e) {
      // Logger.printLog('[isar] addImageDataByBytes $e');

      return;
    }
  }
}
