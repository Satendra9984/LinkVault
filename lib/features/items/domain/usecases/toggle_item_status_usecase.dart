import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/i_items_repository.dart';

class ToggleItemStatusUseCase {
  final IItemsRepository _repository;

  ToggleItemStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(Item item) async {
    // Temporary behavior: archive/unarchive by mapping
    // unread <-> archived until URL read/unread behavior is wired in later phases.
    final newStatus = item.status == ItemStatus.archived
        ? ItemStatus.unread
        : ItemStatus.archived;

    final updatedItem = item.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    return _repository.updateItem(updatedItem);
  }
}
