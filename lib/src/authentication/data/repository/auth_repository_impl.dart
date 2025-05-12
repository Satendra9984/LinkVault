// lib/data/repositories/auth_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/constants/user_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/authentication/domain/repository/auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_profile_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    return localDataSource.getCachedUserId();
  }

  @override
  Future<Either<Failure, UserProfile>> signInWithEmailPassword(
      String email, String password) async {
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

      final response =
          await remoteDataSource.signInWithEmailPassword(email, password);

      if (response.user == null) {
        return Left(
          AuthFailure(
            message: 'Authentication failed',
            statusCode: 400,
          ),
        );
      }

      await localDataSource.cacheUserId(response.user!.id);

      try {
        final userProfile =
            await remoteDataSource.getUserProfile(response.user!.id);
        await localDataSource.cacheUserProfile(userProfile);
        return Right(userProfile.toEntity());
      } catch (e) {
        // If profile doesn't exist yet, return a basic profile
        return Right(
          UserProfile(
            id: response.user!.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastActiveAt: DateTime.now(),
            premiumExpiresAt: DateTime.now().add(
              const Duration(days: accountSingUpCreditLimit),
            ),
          ),
        );
      }
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUpWithEmailPassword(
      String email, String password) async {
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

      final response =
          await remoteDataSource.signUpWithEmailPassword(email, password);

      if (response.user == null) {
        return Left(
          AuthFailure(
            message: 'Registration failed',
            statusCode: 400,
          ),
        );
      }

      await localDataSource.cacheUserId(response.user!.id);

      // Create user profile in Supabase
      try {
        final userProfile = await remoteDataSource.createUserProfile(
          userId: response.user!.id,
          displayName: email.split('@').first, // Default display name
        );

        await localDataSource.cacheUserProfile(userProfile);
        return Right(userProfile.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Failed to create user profile',
            statusCode: 500,
          ),
        );
      }
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
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

      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = remoteDataSource.getCurrentUser();
    return currentUser != null;
  }
}
