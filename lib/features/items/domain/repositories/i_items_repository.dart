import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';

abstract class IItemsRepository {
  Future<Either<Failure, List<Item>>> getPaginatedItems(
      String collectionId, int limit, int offset);
  Future<Either<Failure, Item?>> getItem(String id);
  Future<Either<Failure, void>> createItem(Item item);
  Future<Either<Failure, void>> updateItem(Item item);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> updateItemPosition(
      String id, double newPosition);
  Future<Either<Failure, List<Item>>> getAllItems();
}
