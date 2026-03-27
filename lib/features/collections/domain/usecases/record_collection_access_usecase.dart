import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_collections_repository.dart';

class RecordCollectionAccessUseCase {
  final ICollectionsRepository _repository;

  RecordCollectionAccessUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.recordCollectionAccess(id);
  }
}
