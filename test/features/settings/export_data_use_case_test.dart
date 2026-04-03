import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/core/infrastructure/platform/file_service.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/domain/repositories/i_collections_repository.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/domain/models/url_items_query.dart';
import 'package:link_vault/features/items/domain/repositories/i_items_repository.dart';
import 'package:link_vault/features/settings/application/use_cases/export_data_use_case.dart';
import 'package:link_vault/features/settings/data/backup_schema.dart';

// ── Stubs ─────────────────────────────────────────────────────────────────────

class _FakeCollections implements ICollectionsRepository {
  final List<Collection> data;
  _FakeCollections(this.data);

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async =>
      Right(data);

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async =>
      Right(data.cast<Collection?>().firstWhere((c) => c?.id == id,
          orElse: () => null));

  @override
  Future<Either<Failure, void>> createCollection(Collection c) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCollection(Collection c) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
          String id, double p) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() async =>
      throw UnimplementedError();

  @override
  Stream<List<Collection>> watchCollections() => const Stream.empty();
}

class _FakeItems implements IItemsRepository {
  final List<Item> data;
  _FakeItems(this.data);

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async => Right(data);

  @override
  Future<Either<Failure, Item?>> getItem(String id) async =>
      Right(data.cast<Item?>().firstWhere((i) => i?.id == id,
          orElse: () => null));

  @override
  Future<Either<Failure, void>> createItem(Item item) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItem(Item item) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteItem(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItemPosition(String id, double p) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
          String collectionId, int limit, int offset) async =>
      const Right([]);

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(
          UrlItemsQuery query) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> reorderItems(
          String collectionId, List<String> orderedIds) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(
          String collectionId, String link) async =>
      const Right(null);
}

class _FakeFileService extends FileService {
  final List<String> savedFiles = [];

  @override
  Future<int?> fileLengthBytes(String filePath) async => null;

  @override
  Future<String> readFileAsString(String filePath) async => '';

  @override
  Future<String> saveToFile(String fileName, String content) async {
    savedFiles.add(content);
    return '/tmp/$fileName';
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Collection _col(String id, String? parentId,
    {double position = 0,
    DateTime? createdAt,
    String title = 'Col'}) {
  return Collection(
    id: id,
    parentId: parentId,
    title: title,
    category: 'general',
    colorHex: '#000000',
    iconName: 'folder',
    position: position,
    createdAt: createdAt ?? DateTime(2020),
    updatedAt: DateTime(2020),
  );
}

Item _url(String id, String collectionId,
    {double position = 0, DateTime? updatedAt}) {
  return Item(
    id: id,
    collectionId: collectionId,
    title: 'URL $id',
    link: 'https://example.com/$id',
    status: ItemStatus.unread,
    position: position,
    createdAt: DateTime(2020),
    updatedAt: updatedAt ?? DateTime(2020),
  );
}

Future<Map<String, dynamic>> _doExport(
    List<Collection> cols, List<Item> items) async {
  final fs = _FakeFileService();
  final uc = ExportDataUseCase(_FakeCollections(cols), _FakeItems(items), fs);
  final r = await uc.execute();
  expect(r.isRight(), true, reason: r.fold((l) => l.message, (_) => ''));
  return jsonDecode(fs.savedFiles.first) as Map<String, dynamic>;
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  test('export produces version 2.0 and lv_* root keys', () async {
    final data = await _doExport([_col('root', null)], []);
    expect(data[BackupSchema.keyVersion], BackupSchema.version2_0);
    expect(data.containsKey(BackupSchema.keyLvCollections), true);
    expect(data.containsKey(BackupSchema.keyLvUrls), true);
  });

  test('export emits root before children (BFS order)', () async {
    final cols = [
      _col('child', 'root', position: 1),
      _col('root', null, position: 0),
    ];
    final data = await _doExport(cols, []);
    final exported =
        (data[BackupSchema.keyLvCollections] as List).cast<Map<String, dynamic>>();
    expect(exported.first['id'], 'root');
    expect(exported.last['id'], 'child');
  });

  test('export siblings ordered by position then created_at', () async {
    final t1 = DateTime(2020, 1, 1);
    final t2 = DateTime(2020, 1, 2);
    final cols = [
      _col('root', null),
      _col('b', 'root', position: 2, createdAt: t1),
      _col('a', 'root', position: 1, createdAt: t2),
      _col('c', 'root', position: 2, createdAt: t2),
    ];
    final data = await _doExport(cols, []);
    final ids = (data[BackupSchema.keyLvCollections] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['id'] as String)
        .toList();
    expect(ids, ['root', 'a', 'b', 'c']);
  });

  test('export URLs per collection before children in BFS traversal', () async {
    final cols = [
      _col('root', null),
      _col('child', 'root'),
    ];
    final items = [
      _url('url-root', 'root'),
      _url('url-child', 'child'),
    ];
    final data = await _doExport(cols, items);
    final colOrder = (data[BackupSchema.keyLvCollections] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['id'] as String)
        .toList();
    final urlOrder = (data[BackupSchema.keyLvUrls] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['id'] as String)
        .toList();
    expect(colOrder, ['root', 'child']);
    expect(urlOrder, ['url-root', 'url-child']);
  });

  test('export URLs within collection sorted by position asc, updated_at desc',
      () async {
    final newer = DateTime(2021);
    final older = DateTime(2020);
    final cols = [_col('root', null)];
    final items = [
      _url('b', 'root', position: 2, updatedAt: newer),
      _url('a', 'root', position: 1, updatedAt: older),
      _url('c', 'root', position: 2, updatedAt: older),
    ];
    final data = await _doExport(cols, items);
    final urlIds = (data[BackupSchema.keyLvUrls] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['id'] as String)
        .toList();
    expect(urlIds, ['a', 'b', 'c']);
  });

  test('export deep hierarchy root → L1 → L2 in correct BFS order', () async {
    final cols = [
      _col('l2', 'l1'),
      _col('l1', 'root'),
      _col('root', null),
    ];
    final data = await _doExport(cols, []);
    final ids = (data[BackupSchema.keyLvCollections] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => m['id'] as String)
        .toList();
    expect(ids, ['root', 'l1', 'l2']);
  });

  test('export with no collections or items produces empty arrays', () async {
    final data = await _doExport([], []);
    expect((data[BackupSchema.keyLvCollections] as List).isEmpty, true);
    expect((data[BackupSchema.keyLvUrls] as List).isEmpty, true);
  });
}
