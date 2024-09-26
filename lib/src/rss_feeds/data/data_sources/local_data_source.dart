import 'package:isar/isar.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_image.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:path_provider/path_provider.dart';

class LocalDataSource {
  LocalDataSource({
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
      Logger.printLog('urloffline: initialize $e');

      return;
    }
  }

  Future<List<UrlModel>?> fetchRssFeeds({required String firestoreId}) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      final urlModelOffline = await urlModelOfflineCollection.getAllByIndex(
        'firestoreId',
        [
          [firestoreId],
        ],
      );

      final feeds = urlModelOffline
          .map((feed) => feed?.toUrlModel())
          .whereType<UrlModel>()
          .toList();

      return feeds;
    } catch (e) {
      Logger.printLog('could not fetch RSS feed');
    }

    return null;
  }

  Future<bool> deleteRssFeeds({required String firestoreId}) async {
    await _initializeIsar();
    if (_isar == null) return false;

    final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

    await urlModelOfflineCollection.deleteAllByIndex(
      'firestoreId',
      [
        [firestoreId],
      ],
    );

    return true;
  }

  Future<bool> addAllRssFeeds({required List<UrlModel> urlModels}) async {
    try {
      await _initializeIsar();
      if (_isar == null) return false;
      final urlModelOfflineCollection = _isar!.collection<UrlModelOffline>();

      await _isar!.writeTxn(() async {
        for (final urlModel in urlModels) {
          final urlModelOffline = UrlModelOffline.fromUrlModel(urlModel);
          await urlModelOfflineCollection.put(urlModelOffline);
        }
      });

      return true;
    } catch (e) {
      Logger.printLog('could not fetch RSS feed');
    }

    return false;
  }
}
