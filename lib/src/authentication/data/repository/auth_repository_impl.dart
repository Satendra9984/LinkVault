// lib/data/repositories/auth_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';

import 'package:link_vault/core/constants/user_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:link_vault/src/authentication/data/models/user_profile_model.dart';
import 'package:link_vault/src/authentication/domain/entities/user_profile.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Stream<bool> get authStateChanges =>
      remoteDataSource.authStateChanges().map((state) => state.session != null);

  @override
  Future<String?> getCurrentUserId() async {
    final currentUser = remoteDataSource.getCurrentUser();
    if (currentUser != null) {
      return currentUser.id;
    }
    return null;
  }

  // SINGING IN USER THROUGH SUPABASE AUTHENTICATION
  @override
  Future<Either<Failure, UserProfile>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // final connectivityResult = await connectivity.checkConnectivity();

      // if (connectivityResult == ConnectivityResult.none) {
      //   return Left(
      //     NetworkFailure(
      //       message: 'No internet connection',
      //       statusCode: 400,
      //     ),
      //   );
      // }

      final response =
          await remoteDataSource.signInWithEmailPassword(email, password);

      if (response.user == null) {
        return Left(
          AuthFailure(
            message: 'Authentication failed.',
            statusCode: 400,
          ),
        );
      }

      late UserProfileModel userProfile;
      try {
        userProfile = await remoteDataSource.getUserProfile(response.user!.id);

        await localDataSource.cacheUserProfile(userProfile);

        return Right(userProfile.toEntity());
      } on CacheException catch (_) {
        // If profile doesn't exist yet, return a basic profile
        return Right(
          userProfile.toEntity(),
        );
      } on ServerException catch (se) {
        return Left(
          ServerFailure(
            message: se.message,
            statusCode: se.statusCode,
          ),
        );
      } catch (e) {
        return Left(
          AuthFailure(
            message: 'Something went wrong while signing.',
            statusCode: 500,
          ),
        );
      }
    } on AuthException catch (ae) {
      return Left(
        AuthFailure(
          message: ae.message,
          statusCode: ae.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Something went wrong while signing.',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String? bio,
    Map<String, dynamic>? settings,
  }) async {
    try {
      // final connectivityResult = await connectivity.checkConnectivity();
      // if (connectivityResult == ConnectivityResult.none) {
      //   return Left(
      //     NetworkFailure(
      //       message: 'No internet connection',
      //       statusCode: 400,
      //     ),
      //   );
      // }

      final response =
          await remoteDataSource.signUpWithEmailPassword(email, password);

      if (response.user == null) {
        return Left(
          AuthFailure(message: 'Registration failed', statusCode: 400),
        );
      }

      // Create user profile in Supabase
      final currentTime = DateTime.now();

      final userProfile = UserProfileModel(
        id: response.user!.id,
        displayName: displayName,
        bio: bio,
        usageCredits: 100,
        premiumExpiresAt: currentTime.add(
          const Duration(days: accountSingUpCreditLimit),
        ),
        createdAt: currentTime,
        updatedAt: currentTime,
        lastActiveAt: currentTime,
        settings: settings ?? {},
      );
      try {
        await localDataSource.cacheUserProfile(userProfile);

        return Right(userProfile.toEntity());
      } on CacheException catch (_) {
        // If profile doesn't exist yet, return a basic profile
        return Right(
          userProfile.toEntity(),
        );
      } on ServerException catch (se) {
        return Left(
          ServerFailure(message: se.message, statusCode: se.statusCode),
        );
      } catch (e) {
        return Left(
          AuthFailure(message: 'Failed to create user.', statusCode: 500),
        );
      }
    } on AuthException catch (ae) {
      return Left(
        AuthFailure(message: ae.message, statusCode: ae.statusCode),
      );
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to create user.', statusCode: 500),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        remoteDataSource.signOut(),
        localDataSource.clearCache(),
      ]);
      return const Right(null);
    } on AuthException catch (ae) {
      return Left(
        AuthFailure(message: ae.message, statusCode: ae.statusCode),
      );
    } on CacheException catch (ce) {
      return Left(
        CacheFailure(message: ce.message, statusCode: ce.statusCode),
      );
    } catch (e) {
      return Left(
        AuthFailure(message: e.toString(), statusCode: 500),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      // final connectivityResult = await connectivity.checkConnectivity();
      // if (connectivityResult == ConnectivityResult.none) {
      //   return Left(
      //     NetworkFailure(
      //       message: 'No internet connection',
      //       statusCode: 400,
      //     ),
      //   );
      // }

      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (ae) {
      return Left(
        AuthFailure(message: ae.message, statusCode: ae.statusCode),
      );
    } catch (e) {
      return Left(
        AuthFailure(message: e.toString(), statusCode: 500),
      );
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = remoteDataSource.getCurrentUser();
    return currentUser != null;
  }
}
