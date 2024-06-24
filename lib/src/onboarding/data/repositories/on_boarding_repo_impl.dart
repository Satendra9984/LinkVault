import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/onboarding/data/data_sources/local_data_source_imple.dart';

class OnBoardingRepoImpl {
  final LocalDataSourceImpl _localDataSourceImpl;

  OnBoardingRepoImpl({
    required LocalDataSourceImpl localDataSourceImpl,
  }) : _localDataSourceImpl = localDataSourceImpl;

  // Future<Either<Failure, bool>> checkIfFirstTimer() {}

  // Future<Either<Failure, bool>> cacheFirstTimer() {}

  Either<Failure, bool> isLoggedIn() {
    try {
      var result = _localDataSourceImpl.isLoggedIn() != null;

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
}
