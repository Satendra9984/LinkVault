import 'package:fpdart/fpdart.dart';
import 'package:link_vault/src/common/data_layer/data_sources/local_data_sources/global_user_local_data_source.dart';
import 'package:link_vault/src/common/data_layer/data_sources/remote_data_sources/global_user_remote_data_source.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';

class GlobalUserRepositoryImpl {

  const GlobalUserRepositoryImpl({
    required FirebaseAuthDataSourceImpl remoteDataSource,
    required IsarAuthDataSourceImpl localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;
  final FirebaseAuthDataSourceImpl _remoteDataSource;
  final IsarAuthDataSourceImpl _localDataSource;

  Future<Either<Failure, GlobalUser?>> getUserById(String userId) async {
    try {
      // First, try to get user from local cache
      try {
        final cachedUser =
            await _localDataSource.getCachedUserFromLocalDB(userId);
        if (cachedUser == null) {
          // If no cached user, fetch from remote and cache
          final remoteUser =
              await _remoteDataSource.getUserFromRemoteDatabase(userId);
          await _localDataSource.cacheUserInLocalDB(remoteUser);
          return Right(remoteUser);
        }

        return Right(cachedUser);
      } on LocalAuthException catch (e) {
        Logger.printLog('[AUTH] : NO USER FOUND $e');
        final remoteUser =
            await _remoteDataSource.getUserFromRemoteDatabase(userId);
        await _localDataSource.cacheUserInLocalDB(remoteUser);
        return Right(remoteUser);
      } catch (_) {
        // If no cached user, fetch from remote and cache
        return const Right(null);
      }
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 400,
        ),
      );
    }
  }

  Future<Either<Failure, void>> addUser(GlobalUser user) async {
    try {
      await _remoteDataSource.addUserToRemoteDatabase(user);
      await _localDataSource.cacheUserInLocalDB(user);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          message: e.toString(),
          statusCode: 400,
        ),
      );
    }
  }
}
