import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_items_repository.dart';

class ReorderItemsUseCase {
  final IItemsRepository _repository;

  ReorderItemsUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String collectionId,
    required List<String> orderedIds,
  }) {
    return _repository.reorderItems(collectionId, orderedIds);
  }
}

