import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_collections_repository.dart';

class UpdateCollectionPositionUseCase {
  final ICollectionsRepository _repository;

  UpdateCollectionPositionUseCase(this._repository);

  Future<Either<Failure, void>> call(String id, double newPosition) {
    return _repository.updateCollectionPosition(id, newPosition);
  }
}
