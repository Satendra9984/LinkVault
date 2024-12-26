import 'package:isar/isar.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_image.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_model_isar.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
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
            UrlModelIsarSchema,
          ],
          directory: dir.path,
        );
      }
    } catch (e) {
      // Logger.printLog('urloffline: initialize $e');

      return;
    }
  }

  Future<List<UrlModel>?> fetchRssFeeds({required String firestoreId}) async {
    try {
      await _initializeIsar();
      if (_isar == null) return null;

      final urlModelIsarSchemaCollection = _isar!.collection<UrlModelIsar>();

      final UrlModelIsarSchema = await urlModelIsarSchemaCollection.filter()
          .firestoreIdEqualTo(firestoreId)
          .findAll();

      final feeds = UrlModelIsarSchema.map(
        (feed) => feed.toUrlModel(),
      ) // No need for nullable check if results are guaranteed
          .toList();

      return feeds;
    } catch (e) {
      // Logger.printLog('could not fetch RSS feed');
    }

    return null;
  }

  Future<bool> deleteRssFeeds({required String firestoreId}) async {
    await _initializeIsar();
    if (_isar == null) return false;

    final urlModelIsarSchemaCollection = _isar!.collection<UrlModelIsar>();

    // Filter by firestoreId and retrieve the records
    final feedsToDelete = await urlModelIsarSchemaCollection.filter()
        .firestoreIdEqualTo(firestoreId) // Filter by the firestoreId
        .findAll();

    await _isar?.writeTxn(
      () async {
        await urlModelIsarSchemaCollection.deleteAll(
          feedsToDelete.map((e) => e.id!).toList(),
        );
      },
    );

    return true;
  }

  Future<bool> addAllRssFeeds({required List<UrlModel> urlModels}) async {
    try {
      await _initializeIsar();
      if (_isar == null) return false;
      final urlModelIsarSchemaCollection = _isar!.collection<UrlModelIsar>();

      await _isar!.writeTxn(() async {
        for (final urlModel in urlModels) {
          final urlModelIsar = UrlModelIsar.fromUrlModel(urlModel);
          await urlModelIsarSchemaCollection.put(urlModelIsar);
        }
      });

      return true;
    } catch (e) {
      // Logger.printLog('could not fetch RSS feed');
    }
    return false;
  }

  Future<bool> updateRssFeed({required UrlModel urlModel}) async {
    await _initializeIsar();
    if (_isar == null) return false;

    final urlModelIsarSchemaCollection = _isar!.collection<UrlModelIsar>();

    if (urlModel.metaData == null || urlModel.metaData!.rssFeedUrl == null) {
      return false;
    }

    // Filter by rssFeedUrl in the jsonData and retrieve the record
    final feedInDbAll = await urlModelIsarSchemaCollection
        .filter()
        .collectionIdEqualTo(urlModel.collectionId)
        .metaDataContains(urlModel.metaData!.rssFeedUrl!)
        .findAll();

    final feedInDb = feedInDbAll
        .where(
          (feed) => feed.toUrlModel().collectionId == urlModel.collectionId,
        )
        .firstOrNull;

    if (feedInDb == null) return false;

    final localUrlModel = feedInDb.toUrlModel();

    final feedToUpdate = feedInDb.copyWithUrlModel(
      localUrlModel.copyWith(
        isOffline: urlModel.isOffline,
        isFavourite: urlModel.isFavourite,
        metaData: urlModel.metaData,
        title: urlModel.title,
        description: urlModel.description,
        tag: urlModel.tag,
        createdAt: urlModel.createdAt,
        updatedAt: urlModel.updatedAt,
        htmlContent: urlModel.htmlContent,
      ),
    ); // Create a new entry

    try {
      // Transaction to write data to the database
      await _isar?.writeTxn(() async {
        await urlModelIsarSchemaCollection.put(feedToUpdate);
      });

      return true;
    } catch (e) {
      // Logger.printLog('Error updating feed: $e');
      return false;
    }
  }
}
