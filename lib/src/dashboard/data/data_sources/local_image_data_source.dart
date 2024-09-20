import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_image.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:path_provider/path_provider.dart';

class LocalImageDataSource {
  LocalImageDataSource();

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
      return;
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
      Logger.printLog('[isar] getImageData $e');

      return null;
    }
  }

  Future<void> addImageData({
    required String imageUrl,
    required Uint8List imageBytes,
  }) async {
    try {
      await _initializeIsar();
      if (_isar == null) return;

      final urlImages = _isar!.collection<UrlImage>();

      await _isar!.writeTxn(() async {
        await urlImages.put(
          UrlImage.fromBytes(
            imageUrl: imageUrl,
            bytes: imageBytes,
          ),
        );
      });
    } catch (e) {
      Logger.printLog('[isar] addImageData $e');

      return;
    }
  }

  Future<Uint8List?> getImageDataBytes(String url) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlImages = _isar!.collection<ImagesByteData>();

      final urlImage =
          await urlImages.filter().imageUrlEqualTo(url).findFirst();

      Logger.printLog('[isar] getImageData $url ${urlImage == null}');

      if (urlImage == null) return null;

      final bytes = Uint8List.fromList(urlImage.imageBytes);

      return bytes;
    } catch (e) {
      Logger.printLog('[isar] getImageData $e');

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

      final urlImages = _isar!.collection<ImagesByteData>();

      await _isar!.writeTxn(() async {
        await urlImages.put(
          ImagesByteData.fromBytes(
            imageUrl: imageUrl,
            bytes: imageBytes,
          ),
        );
      }).then((_) {
        Logger.printLog('[isar] getImageData $imageUrl addedSuccess');
      });
    } catch (e) {
      Logger.printLog('[isar] addImageData $e');

      return;
    }
  }
}
