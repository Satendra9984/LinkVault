import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../objectbox.g.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/i_items_repository.dart';
import '../mappers/item_mapper.dart';
import '../../../collections/data/models/collection_model.dart';
import 'package:link_vault/features/items/data/models/item_model.dart';

class ItemsRepositoryImpl implements IItemsRepository {
  final Store store;
  late final Box<ItemModel> _box;
  late final Box<CollectionModel> _collectionBox;

  ItemsRepositoryImpl(this.store) {
    _box = store.box<ItemModel>();
    _collectionBox = store.box<CollectionModel>();
  }

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
    String collectionId,
    int limit,
    int offset,
  ) async {
    try {
      final query = _box.query(ItemModel_.collectionUid.equals(collectionId))
          .order(ItemModel_.createdAt, flags: Order.descending)
          .build();
      
      query.offset = offset;
      query.limit = limit;
      final models = query.find();
      query.close();
      
      return Right(models.map(ItemMapper.toEntity).toList());
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get items', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Item?>> getItem(String id) async {
    try {
      final model = _box.query(ItemModel_.uid.equals(id)).build().findFirst();
      return Right(model != null ? ItemMapper.toEntity(model) : null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get item', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> createItem(Item item) async {
    try {
      final model = ItemMapper.toModel(item);
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(ItemModel_.uid.equals(model.uid)).build().findFirst();
        if (existing != null) {
            model.id = existing.id;
        }
        _box.put(model);

        final collection = _collectionBox.query(CollectionModel_.uid.equals(item.collectionId)).build().findFirst();
        if (collection != null) {
          collection.itemCount++;
          _collectionBox.put(collection);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to create item', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(Item item) async {
    try {
      final newModel = ItemMapper.toModel(item);
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(ItemModel_.uid.equals(newModel.uid)).build().findFirst();
        if (existing != null) {
            newModel.id = existing.id;
        }
        _box.put(newModel);
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to update item', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final item = _box.query(ItemModel_.uid.equals(id)).build().findFirst();
        if (item != null) {
          final collection = _collectionBox.query(CollectionModel_.uid.equals(item.collectionUid)).build().findFirst();
          if (collection != null && collection.itemCount > 0) {
            collection.itemCount--;
            _collectionBox.put(collection);
          }
          _box.remove(item.id);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to delete item', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async {
    // Local schema currently doesn't persist URL pin state.
    // Cloud pin state will be reconciled during sync once offline queue lands.
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final item = _box.query(ItemModel_.uid.equals(id)).build().findFirst();
        if (item == null) return;

        item.status = item.status == ItemStatus.archived
            ? ItemStatus.unread
            : ItemStatus.archived;
        item.updatedAt = DateTime.now();
        _box.put(item);
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to toggle url archive', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final item = _box.query(ItemModel_.uid.equals(id)).build().findFirst();
        if (item == null) return;

        if (item.status == ItemStatus.unread) {
          item.status = ItemStatus.read;
          item.updatedAt = DateTime.now();
          _box.put(item);
        }
        // Local click tracking is not implemented yet.
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to mark url as read/track', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> reorderItems(
    String collectionId,
    List<String> orderedIds,
  ) async {
    try {
      const step = 1024.0;
      store.runInTransaction(TxMode.write, () {
        var i = 0;
        for (final urlId in orderedIds) {
          final item = _box.query(ItemModel_.uid.equals(urlId)).build().findFirst();
          if (item == null) continue;
          if (item.collectionUid != collectionId) continue;
          item.position = (i + 1) * step;
          item.updatedAt = DateTime.now();
          _box.put(item);
          i++;
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to reorder urls', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateItemPosition(String id, double newPosition) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final item = _box.query(ItemModel_.uid.equals(id)).build().findFirst();
        if (item != null) {
          item.position = newPosition;
          _box.put(item);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to update item position', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    try {
      final models = _box.getAll();
      return Right(models.map(ItemMapper.toEntity).toList());
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get all items', error: e, stackTrace: stackTrace));
    }
  }
}
