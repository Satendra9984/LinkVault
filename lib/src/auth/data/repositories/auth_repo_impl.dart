import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl({
    required AuthRemoteDataSourcesImpl authRemoteDataSourcesImpl,
  }) : _authRemoteDataSourcesImpl = authRemoteDataSourcesImpl;
  final AuthRemoteDataSourcesImpl _authRemoteDataSourcesImpl;

  Either<Failure, bool> isLoggedIn() {
    try {
      final result = _authRemoteDataSourcesImpl.isLoggedIn() != null;

      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Something Went Wrong.',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, GlobalUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result =
          await _authRemoteDataSourcesImpl.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result == null) {
        return Left(
          AuthFailure(
            message: 'Could Not Authenticate. Something Went Wrong',
            statusCode: 402,
          ),
        );
      }
      
      // [TODO] : Return a Global User
      
      return Right(result);
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Could Not Login. Something Went Wrong',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, GlobalUser>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final globalUser =
          await _authRemoteDataSourcesImpl.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      if (globalUser == null) {
        return Left(
          AuthFailure(
            message: 'Could Not Sign Up. Something Went Wrong',
            statusCode: 402,
          ),
        );
      }

      return Right(globalUser);
    } catch (e) {
      // debugPrint()
      return Left(
        AuthFailure(
          message: 'Could Not Authenticate. Something Went Wrong',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDataSourcesImpl.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure(message: 'Could signout ', statusCode: 402));
    }
  }

  Future<Either<Failure, Unit>> sendPasswordResetLink({
    required String emailAddress,
  }) async {
    try {
      // return Left(AuthFailure(message: 'Could Not Process ', statusCode: 402));
      // return Right(unit);

      await _authRemoteDataSourcesImpl.sendPasswordResetLink(
        emailAddress: emailAddress,
      );
      return const Right(unit);
    } on AuthException catch (authException) {
      return Left(AuthFailure(message: authException.message, statusCode: 402));
    } catch (e) {
      // debugPrint('[log] : $e');
      return Left(
        AuthFailure(message: 'Something Went Wrong', statusCode: 402),
      );
    }
  }
}
