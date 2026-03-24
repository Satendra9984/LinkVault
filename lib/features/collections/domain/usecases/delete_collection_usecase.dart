import 'package:fpdart/fpdart.dart';
import '../../../../core/architecture/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_collections_repository.dart';

class DeleteCollectionUseCase implements UseCase<void, String> {
  final ICollectionsRepository repository;

  DeleteCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteCollection(params);
  }
}
