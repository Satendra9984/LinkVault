import 'package:isar/isar.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/url_image.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:path_provider/path_provider.dart';

class IsarAuthDataSourceImpl {

  IsarAuthDataSourceImpl(this._isar);
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
            UrlImageSchema,
            ImagesByteDataSchema,
            UrlModelOfflineSchema,
            GlobalUserSchema,
          ],
          directory: dir.path,
        );
      }
    } catch (e) {
      return;
    }
  }

  Future<void> cacheUserInLocalDB(GlobalUser user) async {
    await _initializeIsar();
    if (_isar == null) return;

    await _isar!.writeTxn(() async {
      // Remove existing user with same ID if exists
      final existingUser =
          await _isar!.globalUsers.filter().idEqualTo(user.id).findFirst();

      if (existingUser != null) {
        await _isar!.globalUsers.delete(existingUser.isarId!);
      }

      // Add new user
      await _isar!.globalUsers.put(user);
    });
  }

  Future<GlobalUser?> getCachedUserFromLocalDB(String userId) async {
    await _initializeIsar();
    if (_isar == null) return null;

    final user =
        await _isar!.globalUsers.filter().idEqualTo(userId).findFirst();

    if (user == null) {
      throw LocalAuthException(
        message: 'No cached user found',
        statusCode: 404,
      );
    }

    return user;
  }

  Future<void> clearCachedUser(String userId) async {
    await _initializeIsar();
    if (_isar == null) return;

    await _isar!.writeTxn(() async {
      final user =
          await _isar!.globalUsers.filter().idEqualTo(userId).findFirst();

      if (user != null) {
        await _isar!.globalUsers.delete(user.isarId!);
      }
    });
  }
}
