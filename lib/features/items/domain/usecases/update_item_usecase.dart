import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/architecture/usecase.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class UpdateItemUseCase implements UseCase<void, Item> {
  final IItemsRepository _repository;

  UpdateItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(Item item) {
    return _repository.updateItem(item);
  }
}
