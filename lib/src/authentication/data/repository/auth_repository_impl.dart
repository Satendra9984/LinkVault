import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';

import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:link_vault/src/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:link_vault/src/authentication/domain/entities/authentication_status.dart';
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

  final _authStatusController =
      StreamController<AuthenticationStatus>.broadcast();

  @override
  Stream<AuthenticationStatus> get authStatusChanges =>
      _authStatusController.stream;

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
  Future<Either<Failure, void>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
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

      _authStatusController.add(AuthenticationStatus.authenticated);

      // try {
      //   final userProfile =
      //       await remoteDataSource.getUserProfile(response.user!.id);
      //   await localDataSource.cacheUserProfile(userProfile);
      //   return Right(userProfile.toEntity());
      // } catch (e) {
      //   _authStatusController.add(AuthenticationStatus.unauthenticated);
      //   // If profile doesn't exist, ensure it's created
      //   return await _ensureUserProfile(response.user!.id);
      // }

      return const Right(unit);
    } on AuthException catch (ae) {
      _authStatusController.add(AuthenticationStatus.unauthenticated);
      return Left(
        AuthFailure(message: ae.message, statusCode: ae.statusCode),
      );
    } catch (e) {
      _authStatusController.add(AuthenticationStatus.unauthenticated);
      return Left(
        AuthFailure(message: 'Sign in failed', statusCode: 500),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String? bio,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final metaData = <String, dynamic>{
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (settings != null) 'settings': settings,
      };

      final response = await remoteDataSource.signUpWithEmailPassword(
        email.trim(),
        password,
        metaData,
      );

      if (response.user == null) {
        return Left(
          AuthFailure(message: 'Registration failed', statusCode: 400),
        );
      }

      return const Right(unit);
    } on AuthException catch (ae) {
      _authStatusController.add(AuthenticationStatus.unauthenticated);
      return Left(
        AuthFailure(message: ae.message, statusCode: ae.statusCode),
      );
    } catch (e) {
      _authStatusController.add(AuthenticationStatus.unauthenticated);
      return Left(
        AuthFailure(message: 'Failed to create user.', statusCode: 500),
      );
    }
  }

  // // Helper method to ensure profile exists
  // Future<Either<Failure, UserProfile>> _ensureUserProfile(String userId) async {
  //   try {
  //     // Call the database function to ensure profile exists
  //     final userProfile = await remoteDataSource.ensureUserProfile(userId);
  //     await localDataSource.cacheUserProfile(userProfile);
  //     return Right(userProfile.toEntity());
  //   } catch (e) {
  //     _authStatusController.add(AuthenticationStatus.unauthenticated);
  //     if (e is ServerException) {
  //       return Left(
  //         ServerFailure(message: e.message, statusCode: e.statusCode),
  //       );
  //     }
  //     return Left(
  //       AuthFailure(message: 'Failed to create user profile', statusCode: 500),
  //     );
  //   }
  // }

  // Private helper to handle signup errors
  // Future<void> _handleSignupError(String email, AuthException error) async {
  //   // Determine if cleanup is needed based on error type
  //   var needsCleanup = false;
  //   final reason = 'Auth error: ${error.message}';
  //   switch (error.statusCode) {
  //     case 422: // User already exists
  //       needsCleanup = false; // Don't clean up existing users
  //     case 400: // Bad request - might be partial creation
  //     case 500: // Server error - might be partial creation
  //     default:
  //       needsCleanup = true;
  //   }
  //   if (needsCleanup) {
  //     await _cleanupFailedSignup(email, reason);
  //   }
  // }

  // Private helper to cleanup failed signup
  // Future<void> _cleanupFailedSignup(String email, String reason) async {
  //   try {
  //     final result = await remoteDataSource.deleteUserByEmail(email);
  //     if (result['success'] == true) {
  //       Logger.printLog('Successfully cleaned up failed signup for: $email');
  //     } else {
  //       Logger.printLog('Cleanup attempt failed: ${result['error']}');
  //     }
  //   } catch (e) {
  //     Logger.printLog('Error during cleanup: $e');
  //   }
  // }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        remoteDataSource.signOut(),
        localDataSource.clearCache(),
      ]);
      _authStatusController.add(AuthenticationStatus.unauthenticated);

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

  void dispose() {
    _authStatusController.close();
  }
}
