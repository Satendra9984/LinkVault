import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/features/collections/data/repositories/read_only_collections_repository.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/domain/repositories/i_collections_repository.dart';

class _FakeCollectionsRepository implements ICollectionsRepository {
  _FakeCollectionsRepository(this.collections);

  final List<Collection> collections;

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async =>
      Right(collections);

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async {
    for (final c in collections) {
      if (c.id == id) return Right(c);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
          String id, double newPosition) async =>
      const Right(null);

  @override
  Stream<List<Collection>> watchCollections() => Stream.value(collections);

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() async =>
      const Left(DatabaseFailure('not used by read-only wrapper test'));
}

Collection _collection({
  required String id,
  String? parentId,
  bool isDeleted = false,
}) {
  final now = DateTime(2026, 1, 1);
  return Collection(
    id: id,
    parentId: parentId,
    title: 'C$id',
    category: 'general',
    colorHex: '#6366F1',
    iconName: '📚',
    position: 0,
    createdAt: now,
    updatedAt: now,
    isDeleted: isDeleted,
  );
}

void main() {
  group('ReadOnlyCollectionsRepository.ensureLibraryRootCollection', () {
    test('returns existing root when exactly one top-level row exists', () async {
      final inner = _FakeCollectionsRepository([
        _collection(id: 'root', parentId: null),
        _collection(id: 'child', parentId: 'root'),
      ]);
      final repo = ReadOnlyCollectionsRepository(inner);

      final result = await repo.ensureLibraryRootCollection();
      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => throw StateError('expected right')).id,
          'root');
    });

    test('returns subscription error when root is missing or ambiguous',
        () async {
      final inner = _FakeCollectionsRepository([
        _collection(id: 'a', parentId: null),
        _collection(id: 'b', parentId: null),
      ]);
      final repo = ReadOnlyCollectionsRepository(inner);

      final result = await repo.ensureLibraryRootCollection();
      expect(result.isLeft(), isTrue);
    });
  });

  group('ReadOnlyCollectionsRepository write gating', () {
    test('blocks create/update/delete/position updates', () async {
      final repo =
          ReadOnlyCollectionsRepository(_FakeCollectionsRepository(const []));
      final now = DateTime(2026, 1, 1);
      final collection = Collection(
        id: 'x',
        title: 'X',
        category: 'general',
        colorHex: '#000000',
        iconName: '📚',
        position: 0,
        createdAt: now,
        updatedAt: now,
      );

      final create = await repo.createCollection(collection);
      final update = await repo.updateCollection(collection);
      final delete = await repo.deleteCollection(collection.id);
      final position =
          await repo.updateCollectionPosition(collection.id, 10.0);

      expect(create.isLeft(), isTrue);
      expect(update.isLeft(), isTrue);
      expect(delete.isLeft(), isTrue);
      expect(position.isLeft(), isTrue);
    });
  });
}
