import 'package:fpdart/fpdart.dart';
import '../../../../core/architecture/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/collection.dart';
import '../repositories/i_collections_repository.dart';

class UpdateCollectionUseCase implements UseCase<void, Collection> {
  final ICollectionsRepository repository;

  UpdateCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Collection params) {
    return repository.updateCollection(params);
  }
}
