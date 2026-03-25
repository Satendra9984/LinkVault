import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_items_repository.dart';

class MarkItemReadAndTrackUseCase {
  final IItemsRepository _repository;

  MarkItemReadAndTrackUseCase(this._repository);

  Future<Either<Failure, void>> call(String itemId) {
    return _repository.markItemReadAndTrack(itemId);
  }
}

