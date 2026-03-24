import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/architecture/usecase.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class CreateItemUseCase implements UseCase<void, Item> {
  final IItemsRepository _repository;

  CreateItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(Item item) {
    return _repository.createItem(item);
  }
}
