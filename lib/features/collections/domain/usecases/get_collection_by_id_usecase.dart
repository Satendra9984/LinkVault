import 'package:fpdart/fpdart.dart';
import '../../../../core/architecture/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/collection.dart';
import '../repositories/i_collections_repository.dart';

class GetCollectionByIdUseCase implements UseCase<Collection?, String> {
  final ICollectionsRepository _repository;

  GetCollectionByIdUseCase(this._repository);

  @override
  Future<Either<Failure, Collection?>> call(String id) {
    return _repository.getCollectionById(id);
  }
}
