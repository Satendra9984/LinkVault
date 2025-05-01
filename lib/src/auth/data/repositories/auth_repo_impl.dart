import 'package:fpdart/fpdart.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/src/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/core/constants/user_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl({
    required AuthRemoteDataSourcesImpl authRemoteDataSourcesImpl,
    required GlobalUserRepositoryImpl globalUserRepositoryImpl,
  })  : _authRemoteDataSourcesImpl = authRemoteDataSourcesImpl,
        _globalUserRepositoryImpl = globalUserRepositoryImpl;

  final AuthRemoteDataSourcesImpl _authRemoteDataSourcesImpl;
  final GlobalUserRepositoryImpl _globalUserRepositoryImpl;

  Future<Either<Failure, GlobalUser?>> isLoggedIn() async {
    try {
      final user = _authRemoteDataSourcesImpl.isLoggedIn();

      if (user == null) {
        return Left(
          AuthFailure(
            message: 'Something Went Wrong.',
            statusCode: 402,
          ),
        );
      }

      return await _globalUserRepositoryImpl.getUserById(user.uid);
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Something Went Wrong.',
          statusCode: 402,
        ),
      );
    }
  }

  Future<Either<Failure, GlobalUser?>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userId =
          await _authRemoteDataSourcesImpl.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userId == null) {
        return Left(
          AuthFailure(
            message: 'Could Not Authenticate. Something Went Wrong',
            statusCode: 402,
          ),
        );
      }

      GlobalUser? globalUser;
      await _globalUserRepositoryImpl.getUserById(userId).then(
            (result) => result.fold(
              (failure) {},
              (globalUserR) => globalUser = globalUserR,
            ),
          );

      return Right(globalUser);
    } on LocalAuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: 402,
        ),
      );
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
      final credential =
          await _authRemoteDataSourcesImpl.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      if (credential == null) {
        return Left(
          AuthFailure(
            message: 'Could Not Sign Up. Something Went Wrong',
            statusCode: 402,
          ),
        );
      }
      final todayDate = DateTime.now().toUtc();
      final creditExpiryDate = todayDate.add(
        const Duration(
          days: accountSingUpCreditLimit, // [TODO] : WILL CHANGE TO DAYS
        ),
      );

      final globalUser = GlobalUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        createdAt: todayDate,
        creditExpiryDate: creditExpiryDate,
      );

      await _globalUserRepositoryImpl.addUser(globalUser);

      return Right(globalUser);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: 402,
        ),
      );
    } catch (e) {
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

  Future<Either<Failure, void>> deleteUserAccount() async {
    try {
      await _authRemoteDataSourcesImpl.deleteUser();

      return const Right(unit);
    } catch (e) {
      // Logger.printLog('[account] : error $e');
      return Left(
        AuthFailure(
          message: 'Could Not Deleted ',
          statusCode: 402,
        ),
      );
    }
  }
  
}
