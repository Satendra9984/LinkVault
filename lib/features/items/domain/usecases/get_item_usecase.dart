import 'package:fpdart/fpdart.dart';
import '../../../../core/architecture/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class GetItemUseCase implements UseCase<Item?, String> {
  final IItemsRepository _repository;

  GetItemUseCase(this._repository);

  @override
  Future<Either<Failure, Item?>> call(String itemId) {
    return _repository.getItem(itemId);
  }
}
