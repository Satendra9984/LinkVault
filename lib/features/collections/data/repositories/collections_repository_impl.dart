import 'package:fpdart/fpdart.dart';
import '../../../../objectbox.g.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/collection.dart';
import '../../domain/collection_sibling_order.dart';
import '../../domain/repositories/i_collections_repository.dart';
import '../../../items/data/models/item_model.dart';
import '../mappers/collection_mapper.dart';
import '../models/collection_model.dart';

class CollectionsRepositoryImpl implements ICollectionsRepository {
  final Store store;
  late final Box<CollectionModel> _box;
  late final Box<ItemModel> _itemBox;

  CollectionsRepositoryImpl(this.store) {
    _box = store.box<CollectionModel>();
    _itemBox = store.box<ItemModel>();
  }

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    try {
      final String finalId =
          collection.id.isEmpty ? const Uuid().v4() : collection.id;
      final collectionToSave = Collection(
        id: finalId,
        ownerId: collection.ownerId,
        parentId: collection.parentId,
        isShared: collection.isShared,
        title: collection.title,
        category: collection.category,
        colorHex: collection.colorHex,
        iconName: collection.iconName,
        position: collection.position,
        isPinned: collection.isPinned,
        isArchived: collection.isArchived,
        isDeleted: collection.isDeleted,
        childCount: collection.childCount,
        createdAt: collection.createdAt,
        updatedAt: collection.updatedAt,
        itemCount: collection.itemCount,
      );

      final model = CollectionMapper.toModel(collectionToSave);
      
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(model.uid)).build().findFirst();
        if (existing != null) {
          model.id = existing.id;
        }
        _box.put(model);
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to create collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
        if (existing != null) {
          _box.remove(existing.id);
        }
        
        // Delete associated items
        final itemsQuery = _itemBox.query(ItemModel_.collectionUid.equals(id)).build();
        final items = itemsQuery.find();
        if (items.isNotEmpty) {
          _itemBox.removeMany(items.map((e) => e.id).toList());
        }
        itemsQuery.close();
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to delete collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async {
    try {
      final model = _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
      if (model == null) {
        return const Right(null);
      }
      return Right(CollectionMapper.toEntity(model));
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    try {
      final model = CollectionMapper.toModel(collection);

      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(model.uid)).build().findFirst();
        if (existing != null) {
          model.id = existing.id;
        }
        _box.put(model);
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to update collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
      String id, double newPosition) async {
    try {
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
        if (existing != null) {
          existing.position = newPosition;
          _box.put(existing);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to update collection position',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    return _box.query().watch(triggerImmediately: true).map((query) {
      final models = query.find();
      final entities = models.map(CollectionMapper.toEntity).toList();
      sortCollectionsSiblings(entities);
      return entities;
    });
  }

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      final models = _box.getAll();
      return Right(models.map(CollectionMapper.toEntity).toList());
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get all collections',
          error: e, stackTrace: stackTrace));
    }
  }
}
