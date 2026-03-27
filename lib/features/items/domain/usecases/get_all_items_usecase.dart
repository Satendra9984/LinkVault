import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class GetAllItemsUseCase {
  final IItemsRepository _repository;

  GetAllItemsUseCase(this._repository);

  Future<Either<Failure, List<Item>>> call() {
    return _repository.getAllItems();
  }
}
