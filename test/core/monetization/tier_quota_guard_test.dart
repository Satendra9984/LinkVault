import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/core/monetization/tier_quota_guard.dart';
import 'package:link_vault/features/auth/domain/entities/auth_user.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/domain/repositories/i_collections_repository.dart';
import 'package:link_vault/features/items/domain/entities/item.dart'
    show Item, ItemStatus;
import 'package:link_vault/features/items/domain/repositories/i_items_repository.dart';
import 'package:link_vault/features/items/domain/models/url_items_query.dart';

class _StubCollectionsRepo implements ICollectionsRepository {
  _StubCollectionsRepo(this._all);
  final List<Collection> _all;

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async =>
      Right(_all);

  @override
  Stream<List<Collection>> watchCollections() => Stream.value(_all);

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
    String id,
    double newPosition,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() async =>
      throw UnimplementedError();
}

class _StubItemsRepo implements IItemsRepository {
  _StubItemsRepo(this._all);
  final List<Item> _all;

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async => Right(_all);

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery query) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
    String collectionId,
    int limit,
    int offset,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Item?>> getItem(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> createItem(Item item) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateItem(Item item) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteItem(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> reorderItems(
    String collectionId,
    List<String> orderedIds,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateItemPosition(
    String id,
    double newPosition,
  ) async =>
      throw UnimplementedError();
      
        @override
        Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(String collectionId, String link) {
          // TODO: implement findItemByCollectionAndNormalizedLink
          throw UnimplementedError();
        }
}

Collection _coll(String id, {String? parentId}) => Collection(
      id: id,
      title: 't',
      category: 'g',
      colorHex: '#000',
      iconName: 'f',
      parentId: parentId,
      position: 0,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
    );

void main() {
  final guest = AuthUser(supabaseId: null, email: 'x@y.z', isPremium: false);
  final freeUser = AuthUser(supabaseId: 'u1', email: 'a@b.c', isPremium: false);

  test('premium bypasses collection quota', () async {
    final repo = _StubCollectionsRepo([
      for (var i = 0; i < 200; i++) _coll('$i', parentId: 'p'),
    ]);
    final r = await TierQuotaGuard.ensureCanCreateCollection(
      isPremium: true,
      user: guest,
      collectionsRepo: repo,
    );
    expect(r.isRight(), isTrue);
  });

  test('guest at collection limit is blocked', () async {
    final repo = _StubCollectionsRepo([
      for (var i = 0; i < TierQuotaLimits.guestMaxCollections; i++)
        _coll('$i', parentId: 'parent'),
    ]);
    final r = await TierQuotaGuard.ensureCanCreateCollection(
      isPremium: false,
      user: guest,
      collectionsRepo: repo,
    );
    expect(r.isLeft(), isTrue);
    r.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('library root rows do not count toward guest collection cap', () async {
    final repo = _StubCollectionsRepo([
      for (var i = 0; i < TierQuotaLimits.guestMaxCollections - 1; i++)
        _coll('c$i', parentId: 'p'),
      _coll('root', parentId: null),
    ]);
    final r = await TierQuotaGuard.ensureCanCreateCollection(
      isPremium: false,
      user: guest,
      collectionsRepo: repo,
    );
    expect(r.isRight(), isTrue);
  });

  test('deleted items do not count toward URL quota', () async {
    final repo = _StubItemsRepo([
      Item(
        id: '1',
        title: 't',
        collectionId: 'c',
        status: ItemStatus.unread,
        position: 0,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        isDeleted: true,
      ),
    ]);
    final r = await TierQuotaGuard.ensureCanCreateItem(
      isPremium: false,
      user: freeUser,
      itemsRepo: repo,
    );
    expect(r.isRight(), isTrue);
  });
}
