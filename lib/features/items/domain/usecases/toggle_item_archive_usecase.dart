import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_items_repository.dart';

class ToggleItemArchiveUseCase {
  final IItemsRepository _repository;

  ToggleItemArchiveUseCase(this._repository);

  Future<Either<Failure, void>> call(String itemId) {
    return _repository.toggleItemArchive(itemId);
  }
}

