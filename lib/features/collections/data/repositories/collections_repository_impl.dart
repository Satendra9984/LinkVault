import 'package:fpdart/fpdart.dart';
import '../../../../objectbox.g.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/collection_display_defaults.dart';
import '../../domain/entities/collection.dart';
import '../../domain/library_root_collection.dart';
import '../../domain/collection_sibling_order.dart';
import '../../domain/repositories/i_collections_repository.dart';
import '../../../items/data/models/item_model.dart';
import '../mappers/collection_mapper.dart';
import '../models/collection_model.dart';

class CollectionsRepositoryImpl implements ICollectionsRepository {
  final Store store;
  late final Box<CollectionModel> _box;
  late final Box<ItemModel> _itemBox;
  static final Map<int, Future<Either<Failure, Collection>>> _ensureInFlight =
      {};
  static int _ensureAttempts = 0;
  static int _ensureSuccesses = 0;
  static int _ensureFailures = 0;

  CollectionsRepositoryImpl(this.store) {
    _box = store.box<CollectionModel>();
    _itemBox = store.box<ItemModel>();
  }

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    try {
      AppLogger.d(
          '[collections] createCollection local title="${collection.title}" id=${collection.id}');
      final String finalId =
          collection.id.isEmpty ? const Uuid().v4() : collection.id;
      final collectionToSave = Collection(
        id: finalId,
        ownerId: collection.ownerId,
        parentId: collection.parentId,
        isShared: collection.isShared,
        title: collection.title,
        description: collection.description,
        category: collection.category,
        colorHex: collection.colorHex,
        iconName: collection.iconName,
        iconJson: collection.iconJson,
        position: collection.position,
        isPinned: collection.isPinned,
        isArchived: collection.isArchived,
        isDeleted: collection.isDeleted,
        childCount: collection.childCount,
        createdAt: collection.createdAt,
        updatedAt: collection.updatedAt,
        lastAccessedAt: collection.lastAccessedAt,
        itemsLayout: collection.itemsLayout,
        childCollectionsLayout: collection.childCollectionsLayout,
        itemsSortDefault: collection.itemsSortDefault,
        openLinksIn: collection.openLinksIn,
        showLinkPreviews: collection.showLinkPreviews,
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
      AppLogger.d('[collections] createCollection local ok id=$finalId');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] createCollection local failed', e, stackTrace);
      return Left(DatabaseFailure('Failed to create collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    try {
      final allRes = await getAllCollections();
      final guard = allRes.fold<Failure?>((_) => null, (list) {
        Collection? target;
        for (final c in list) {
          if (c.id == id) {
            target = c;
            break;
          }
        }
        if (target != null &&
            !target.isDeleted &&
            (target.parentId == null || target.parentId!.trim().isEmpty)) {
          return const ValidationFailure(
            'Top-level collections cannot be deleted directly. Repair library root first.',
          );
        }
        final rootId = LibraryRootCollection.libraryRootIdIfExactlyOne(list);
        if (rootId != null && id == rootId) {
          return const ValidationFailure(
            'The Library folder cannot be deleted.',
          );
        }
        return null;
      });
      if (guard != null) return Left(guard);

      AppLogger.d('[collections] deleteCollection local id=$id');
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
      AppLogger.d('[collections] deleteCollection local ok id=$id');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] deleteCollection local failed id=$id', e, stackTrace);
      return Left(DatabaseFailure('Failed to delete collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async {
    try {
      final model = _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
      if (model == null) {
        AppLogger.d('[collections] getCollectionById local not found id=$id');
        return const Right(null);
      }
      AppLogger.d('[collections] getCollectionById local ok id=$id');
      return Right(CollectionMapper.toEntity(model));
    } catch (e, stackTrace) {
      AppLogger.e('[collections] getCollectionById local failed id=$id', e, stackTrace);
      return Left(DatabaseFailure('Failed to get collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    try {
      AppLogger.d(
          '[collections] updateCollection local id=${collection.id} title="${collection.title}"');
      final model = CollectionMapper.toModel(collection);

      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(model.uid)).build().findFirst();
        if (existing != null) {
          model.id = existing.id;
        }
        _box.put(model);
      });
      AppLogger.d('[collections] updateCollection local ok id=${collection.id}');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] updateCollection local failed id=${collection.id}', e, stackTrace);
      return Left(DatabaseFailure('Failed to update collection',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
      String id, double newPosition) async {
    try {
      AppLogger.d(
          '[collections] updateCollectionPosition local id=$id position=$newPosition');
      store.runInTransaction(TxMode.write, () {
        final existing = _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
        if (existing != null) {
          existing.position = newPosition;
          _box.put(existing);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] updateCollectionPosition local failed id=$id', e, stackTrace);
      return Left(DatabaseFailure('Failed to update collection position',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Stream<List<Collection>> watchCollections() {
    AppLogger.d('[collections] watchCollections local subscribed');
    return _box.query().watch(triggerImmediately: true).map((query) {
      final models = query.find();
      final entities = models.map(CollectionMapper.toEntity).toList();
      sortCollectionsSiblings(entities);
      AppLogger.t('[collections] watchCollections local emit n=${entities.length}');
      return entities;
    });
  }

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      final models = _box.getAll();
      AppLogger.d('[collections] getAllCollections local n=${models.length}');
      return Right(models.map(CollectionMapper.toEntity).toList());
    } catch (e, stackTrace) {
      AppLogger.e('[collections] getAllCollections local failed', e, stackTrace);
      return Left(DatabaseFailure('Failed to get all collections',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async {
    try {
      AppLogger.t('[collections] recordCollectionAccess local id=$id');
      store.runInTransaction(TxMode.write, () {
        final existing =
            _box.query(CollectionModel_.uid.equals(id)).build().findFirst();
        if (existing != null) {
          existing.lastAccessedAt = DateTime.now();
          // Do not bump updatedAt — avoids delta-sync pushes for browse-only access.
          _box.put(existing);
        }
      });
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] recordCollectionAccess local failed id=$id', e, stackTrace);
      return Left(DatabaseFailure('Failed to record collection access',
          error: e, stackTrace: stackTrace));
    }
  }

  Collection _newLibraryRootEntity(String id) {
    final now = DateTime.now();
    return Collection(
      id: id,
      title: LibraryRootCollection.defaultTitle,
      category: LibraryRootCollection.defaultCategory,
      colorHex: '#6366F1',
      iconName: LibraryRootCollection.defaultIcon,
      position: 0,
      createdAt: now,
      updatedAt: now,
      itemsLayout: CollectionLayoutMode.list,
      childCollectionsLayout: CollectionLayoutMode.list,
      itemsSortDefault: CollectionItemsSortDefault.manual,
      openLinksIn: CollectionOpenLinksIn.inApp,
      showLinkPreviews: true,
      parentId: null,
    );
  }

  void _repairLegacyRootItemsInTx(String libraryRootId) {
    for (final legacy in LibraryRootCollection.legacyRootItemCollectionIds) {
      final q = _itemBox.query(ItemModel_.collectionUid.equals(legacy)).build();
      final items = q.find();
      q.close();
      for (final m in items) {
        m.collectionUid = libraryRootId;
        _itemBox.put(m);
      }
    }
  }

  Future<Either<Failure, Collection>> _doEnsureLibraryRootCollection() async {
    try {
      Collection? resolved;
      store.runInTransaction(TxMode.write, () {
        final models = _box.getAll();
        final entities =
            models.map(CollectionMapper.toEntity).where((c) => !c.isDeleted).toList();
        var tops = entities
            .where((c) =>
                c.parentId == null || c.parentId!.trim().isEmpty)
            .toList();

        if (tops.length > 1) {
          final newId = const Uuid().v4();
          final rootEntity = _newLibraryRootEntity(newId);
          _box.put(CollectionMapper.toModel(rootEntity));
          for (final c in tops) {
            final m =
                _box.query(CollectionModel_.uid.equals(c.id)).build().findFirst();
            if (m != null) {
              m.parentId = newId;
              m.updatedAt = DateTime.now();
              _box.put(m);
            }
          }
          _repairLegacyRootItemsInTx(newId);
          resolved = rootEntity;
          AppLogger.d(
              '[collections] ensureLibraryRoot local: created root + reparented ${tops.length} legacy tops');
        } else if (tops.length == 1) {
          final existingRoot = tops.single;
          _repairLegacyRootItemsInTx(existingRoot.id);
          resolved = existingRoot;
          AppLogger.d(
              '[collections] ensureLibraryRoot local: existing root ${existingRoot.id}');
        } else {
          final newId = const Uuid().v4();
          final rootEntity = _newLibraryRootEntity(newId);
          _box.put(CollectionMapper.toModel(rootEntity));
          _repairLegacyRootItemsInTx(newId);
          resolved = rootEntity;
          AppLogger.d('[collections] ensureLibraryRoot local: created root $newId');
        }
      });
      final out = resolved;
      if (out == null) {
        return Left(DatabaseFailure('Failed to resolve library root'));
      }
      return Right(out);
    } catch (e, stackTrace) {
      AppLogger.e('[collections] ensureLibraryRoot local failed', e, stackTrace);
      return Left(DatabaseFailure('Failed to ensure library root',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() {
    final key = store.hashCode;
    final inFlight = _ensureInFlight[key];
    if (inFlight != null) {
      return inFlight;
    }
    _ensureAttempts++;
    final started = DateTime.now();
    final future = _doEnsureLibraryRootCollection();
    _ensureInFlight[key] = future;
    future.then((result) {
      result.fold(
        (_) => _ensureFailures++,
        (_) => _ensureSuccesses++,
      );
    });
    future.whenComplete(() {
      if (identical(_ensureInFlight[key], future)) {
        _ensureInFlight.remove(key);
      }
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      AppLogger.d(
          '[collections] ensureLibraryRoot local metrics attempts=$_ensureAttempts success=$_ensureSuccesses failed=$_ensureFailures elapsedMs=$elapsed');
    });
    return future;
  }
}
