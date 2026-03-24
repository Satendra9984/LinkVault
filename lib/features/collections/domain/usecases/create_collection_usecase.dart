import 'package:fpdart/fpdart.dart';
import '../../../../core/architecture/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/collection.dart';
import '../repositories/i_collections_repository.dart';

class CreateCollectionUseCase implements UseCase<void, Collection> {
  final ICollectionsRepository repository;

  CreateCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Collection params) {
    if (params.title.isEmpty) {
      // Just a basic check, though UI should handle validation.
      // Ideally returns a ValidationFailure.
      // But we'll rely on Repository or handle it here if needed.
    }
    return repository.createCollection(params);
  }
}
