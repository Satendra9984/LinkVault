import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class GetPaginatedItemsUseCase {
  final IItemsRepository _repository;

  GetPaginatedItemsUseCase(this._repository);

  Future<Either<Failure, List<Item>>> call(
      String collectionId, int limit, int offset) {
    return _repository.getPaginatedItems(collectionId, limit, offset);
  }
}
