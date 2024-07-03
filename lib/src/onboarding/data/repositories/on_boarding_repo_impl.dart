import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/common/models/global_user_model.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/onboarding/data/data_sources/local_data_source_imple.dart';

class OnBoardingRepoImpl {
  OnBoardingRepoImpl({
    required LocalDataSourceImpl localDataSourceImpl,
  }) : _localDataSourceImpl = localDataSourceImpl;
  final LocalDataSourceImpl _localDataSourceImpl;

  // Future<Either<Failure, bool>> checkIfFirstTimer() {}

  // Future<Either<Failure, bool>> cacheFirstTimer() {}

  Future<Either<Failure, GlobalUser?>> isLoggedIn() async {
    try {
      final globalUser = await _localDataSourceImpl.isLoggedIn();

      if (globalUser == null) {
        return Left(
          AuthFailure(
            message: 'Something Went Wrong.',
            statusCode: 402,
          ),
        );
      }

      return Right(globalUser);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Something Went Wrong.',
          statusCode: 402,
        ),
      );
    }
  }
}
