import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/onboarding/data/data_sources/local_data_source_imple.dart';

class OnBoardingRepoImpl {

  OnBoardingRepoImpl({
    required LocalDataSourceImpl localDataSourceImpl,
  }) : _localDataSourceImpl = localDataSourceImpl;
  final LocalDataSourceImpl _localDataSourceImpl;

  // Future<Either<Failure, bool>> checkIfFirstTimer() {}

  // Future<Either<Failure, bool>> cacheFirstTimer() {}

  Either<Failure, bool> isLoggedIn() {
    try {
      final result = _localDataSourceImpl.isLoggedIn() != null;

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
