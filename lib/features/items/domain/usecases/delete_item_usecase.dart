import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/architecture/usecase.dart';
import '../repositories/i_items_repository.dart';

class DeleteItemUseCase implements UseCase<void, String> {
  final IItemsRepository _repository;

  DeleteItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteItem(id);
  }
}
