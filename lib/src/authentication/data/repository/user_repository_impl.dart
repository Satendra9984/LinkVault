// lib/data/repositories/user_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/authentication/domain/entities/user_profile.dart';
import 'package:link_vault/src/authentication/domain/repository/user_repository.dart';

import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_profile_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final currentUser = remoteDataSource.getCurrentUser();
      if (currentUser == null) {
        return Left(
          AuthFailure(
            message: 'User not authenticated',
            statusCode: 400,
          ),
        );
      }

      // Try to get from local cache first
      final cachedProfile =
          await localDataSource.getCachedUserProfile(currentUser.id);
      if (cachedProfile != null) {
        return Right(cachedProfile.toEntity());
      }

      // If not in cache, try to get from server
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(
          NetworkFailure(
            message: 'No internet connection',
            statusCode: 400,
          ),
        );
      }

      final profile = await remoteDataSource.getUserProfile(currentUser.id);
      await localDataSource.cacheUserProfile(profile);
      return Right(profile.toEntity());
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
      UserProfile profile) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(
          NetworkFailure(
            message: 'No internet connection',
            statusCode: 400,
          ),
        );
      }

      final profileModel = UserProfileModel.fromEntity(profile);
      final updatedProfile =
          await remoteDataSource.updateUserProfile(profileModel);
      await localDataSource.cacheUserProfile(updatedProfile);
      return Right(updatedProfile.toEntity());
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> createUserProfile(
    String userId, {
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(
          NetworkFailure(
            message: 'No internet connection',
            statusCode: 400,
          ),
        );
      }

      final profile = await remoteDataSource.createUserProfile(
        userId: userId,
        displayName: displayName,
        profilePictureUrl: profilePictureUrl,
        bio: bio,
        settings: settings,
      );

      await localDataSource.cacheUserProfile(profile);
      return Right(profile.toEntity());
    } catch (e) {
      return Left(
        ServerFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Stream<UserProfile?> userProfileStream() async* {
    final currentUser = remoteDataSource.getCurrentUser();
    if (currentUser == null) {
      yield null;
      return;
    }

    yield* localDataSource
        .watchUserProfile(currentUser.id)
        .map((profile) => profile?.toEntity());
  }
}
