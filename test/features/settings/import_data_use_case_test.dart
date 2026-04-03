import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/core/infrastructure/platform/file_service.dart';
import 'package:link_vault/core/utils/link_normalization.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/collections/domain/repositories/i_collections_repository.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/domain/models/url_items_query.dart';
import 'package:link_vault/features/items/domain/repositories/i_items_repository.dart';
import 'package:link_vault/features/settings/application/use_cases/import_data_use_case.dart';
import 'package:link_vault/features/settings/data/backup_schema.dart';

class _MemCollections implements ICollectionsRepository {
  final Map<String, Collection> byId = {};

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    byId[collection.id] = collection;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async =>
      Right(byId.values.toList());

  @override
  Future<Either<Failure, Collection?>> getCollectionById(String id) async =>
      Right(byId[id]);

  @override
  Stream<List<Collection>> watchCollections() => const Stream.empty();

  @override
  Future<Either<Failure, void>> recordCollectionAccess(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Collection>> ensureLibraryRootCollection() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    byId[collection.id] = collection;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateCollectionPosition(
          String id, double newPosition) async =>
      const Right(null);
}

/// Emulates cloud constraints relevant to import:
/// - parent collection must exist before child insert/update
/// - only one non-deleted root (parentId null/empty)
class _StrictMemCollections extends _MemCollections {
  bool _isRoot(Collection c) =>
      !c.isDeleted && (c.parentId == null || c.parentId!.trim().isEmpty);

  bool _hasAnotherRoot(String id) {
    for (final c in byId.values) {
      if (c.id != id && _isRoot(c)) return true;
    }
    return false;
  }

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    final p = collection.parentId;
    if (p != null && p.trim().isNotEmpty && !byId.containsKey(p)) {
      return const Left(DatabaseFailure('FK parent missing'));
    }
    if (_isRoot(collection) && _hasAnotherRoot(collection.id)) {
      return const Left(DatabaseFailure('duplicate root'));
    }
    return super.createCollection(collection);
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    final p = collection.parentId;
    if (p != null && p.trim().isNotEmpty && !byId.containsKey(p)) {
      return const Left(DatabaseFailure('FK parent missing'));
    }
    if (_isRoot(collection) && _hasAnotherRoot(collection.id)) {
      return const Left(DatabaseFailure('duplicate root'));
    }
    return super.updateCollection(collection);
  }
}

class _MemItems implements IItemsRepository {
  final Map<String, Item> byId = {};
  final List<Item> _all = [];

  @override
  Future<Either<Failure, void>> createItem(Item item) async {
    byId[item.id] = item;
    _all.add(item);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async => const Right(null);

  @override
  Future<Either<Failure, Item?>> getItem(String id) async => Right(byId[id]);

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async =>
      Right(byId.values.toList());

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
          String collectionId, int limit, int offset) async =>
      const Right([]);

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery query) async =>
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
  Future<Either<Failure, void>> updateItem(Item item) async {
    byId[item.id] = item;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateItemPosition(String id, double p) async =>
      const Right(null);

  @override
  Future<Either<Failure, Item?>> findItemByCollectionAndNormalizedLink(
    String collectionId,
    String link,
  ) async {
    final target = normalizeLinkForDedup(link);
    for (final it in _all) {
      if (it.collectionId == collectionId &&
          normalizeLinkForDedup(it.link) == target) {
        return Right(it);
      }
    }
    return const Right(null);
  }
}

class _FakeFileService extends FileService {
  _FakeFileService(this.content, {this.lengthOverride});

  final String content;
  final int? lengthOverride;

  @override
  Future<int?> fileLengthBytes(String filePath) async => lengthOverride;

  @override
  Future<String> readFileAsString(String filePath) async => content;
}

void main() {
  test('rejects oversized file via preflight', () async {
    final json = jsonEncode({
      'version': '1.0',
      'collections': <Map<String, dynamic>>[],
      'items': <Map<String, dynamic>>[],
    });
    final fs = _FakeFileService(json, lengthOverride: kMaxImportFileBytes + 1);
    final uc = ImportDataUseCase(_MemCollections(), _MemItems(), fs);
    final r = await uc.execute('/tmp/x.json');
    expect(r.isLeft(), true);
  });

  test('skips duplicate URL in same collection when ID differs', () async {
    final collections = [
      {
        'id': 'col1',
        'name': 'A',
        'category': 'general',
        'colorHex': '#000000',
        'createdAt': '2020-01-01T00:00:00.000Z',
        'updatedAt': '2020-01-01T00:00:00.000Z',
      },
    ];
    final items = [
      {
        'id': 'newid',
        'collectionId': 'col1',
        'name': 'Dup',
        'link': 'https://example.com/path',
        'status': 'unread',
        'createdAt': '2020-01-01T00:00:00.000Z',
        'updatedAt': '2020-01-01T00:00:00.000Z',
      },
    ];
    final mem = _MemItems();
    await mem.createItem(Item(
      id: 'existing',
      collectionId: 'col1',
      title: 'Old',
      link: 'https://example.com/path',
      status: ItemStatus.unread,
      position: 0,
      createdAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
    ));

    final payload = jsonEncode({
      'version': '1.0',
      'collections': collections,
      'items': items,
    });
    final fs = _FakeFileService(payload, lengthOverride: 4000);
    final uc = ImportDataUseCase(_MemCollections(), mem, fs);
    final r = await uc.execute('/tmp/x.json');
    final res = r.getOrElse((l) => throw Exception('$l'));
    expect(res.itemsSkippedDuplicate, 1);
    expect(res.itemsCreated, 0);
  });

  test('imports v2.0 lv_collections and lv_urls with full rows', () async {
    final payload = jsonEncode({
      BackupSchema.keyVersion: BackupSchema.version2_0,
      BackupSchema.keyLvCollections: [
        {
          'id': 'col-v2',
          'owner_id': null,
          'parent_id': null,
          'title': 'V2 Folder',
          'description': 'notes',
          'category': 'general',
          'color_hex': '#6366F1',
          'icon_name': 'folder',
          'position': 2.5,
          'is_pinned': true,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 0,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-02T00:00:00.000Z',
          'last_accessed_at': '2020-01-01T12:00:00.000Z',
          'items_layout': 'grid',
          'child_collections_layout': 'compact_grid',
          'items_sort_default': 'title_asc',
          'open_links_in': 'external_browser',
          'show_link_previews': false,
          'is_shared': false,
          'icon_json': null,
        },
      ],
      BackupSchema.keyLvUrls: [
        {
          'id': 'item-v2',
          'owner_id': null,
          'collection_id': 'col-v2',
          'url': 'https://example.com/v2',
          'title': 'V2 Link',
          'description': 'summary',
          'annotation': 'ann',
          'tags': 'a,b',
          'thumbnail_url': 'https://cdn.example/thumb.png',
          'favicon_url': 'https://cdn.example/fav.ico',
          'dominant_color': '#112233',
          'status': 'read',
          'is_pinned': true,
          'position': 3.0,
          'click_count': 5,
          'last_accessed_at': '2020-01-03T00:00:00.000Z',
          'is_deleted': false,
          'deleted_at': null,
          'site_name': 'Example',
          'canonical_url': 'https://example.com/canonical',
          'content_type': 'text/html',
          'published_at': '2020-01-01T08:00:00.000Z',
          'open_links_in_override': 'external_browser',
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-02T00:00:00.000Z',
        },
      ],
    });
    final cols = _MemCollections();
    final items = _MemItems();
    final fs = _FakeFileService(payload, lengthOverride: 8000);
    final uc = ImportDataUseCase(cols, items, fs);
    final r = await uc.execute('/tmp/v2.json');
    final res = r.getOrElse((l) => throw Exception('$l'));
    expect(res.collectionsCreated, 1);
    expect(res.itemsCreated, 1);
    final c = cols.byId['col-v2']!;
    expect(c.title, 'V2 Folder');
    expect(c.description, 'notes');
    expect(c.itemsLayout, 'grid');
    expect(c.openLinksIn, 'external_browser');
    final i = items.byId['item-v2']!;
    expect(i.title, 'V2 Link');
    expect(i.annotation, 'ann');
    expect(i.description, 'summary');
    expect(i.tags, 'a,b');
    expect(i.status, ItemStatus.read);
    expect(i.clickCount, 5);
    expect(i.openLinksInOverride, 'external_browser');
  });

  test('v2.0 accepts collections/items alias with snake_case rows', () async {
    final payload = jsonEncode({
      BackupSchema.keyVersion: BackupSchema.version2_0,
      BackupSchema.keyCollections: [
        {
          'id': 'col-alias',
          'title': 'Alias',
          'category': 'general',
          'color_hex': '#000000',
          'icon_name': 'folder',
          'position': 0.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 0,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
          'is_shared': false,
        },
      ],
      BackupSchema.keyItems: [
        {
          'id': 'it-alias',
          'collection_id': 'col-alias',
          'url': 'https://a.com',
          'title': 'A',
          'status': 'unread',
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        },
      ],
    });
    final uc = ImportDataUseCase(_MemCollections(), _MemItems(), _FakeFileService(payload));
    final r = await uc.execute('/tmp/a.json');
    expect(r.isRight(), true);
    final res = r.getOrElse((l) => throw Exception('$l'));
    expect(res.collectionsCreated, 1);
    expect(res.itemsCreated, 1);
  });

  test('rejects unsupported backup version', () async {
    final payload = jsonEncode({
      'version': '9.9',
      'collections': <Map<String, dynamic>>[],
      'items': <Map<String, dynamic>>[],
    });
    final uc = ImportDataUseCase(_MemCollections(), _MemItems(), _FakeFileService(payload));
    final r = await uc.execute('/tmp/bad.json');
    expect(r.isLeft(), true);
  });

  test('v2 imports child-before-parent payload by parent-first ordering', () async {
    final payload = jsonEncode({
      BackupSchema.keyVersion: BackupSchema.version2_0,
      BackupSchema.keyLvCollections: [
        {
          'id': 'child-1',
          'parent_id': 'root-1',
          'title': 'Child',
          'category': 'general',
          'color_hex': '#000000',
          'icon_name': 'folder',
          'position': 2.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 0,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
        },
        {
          'id': 'root-1',
          'parent_id': null,
          'title': 'Library',
          'category': 'general',
          'color_hex': '#6366F1',
          'icon_name': 'folder',
          'position': 0.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 1,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
        },
      ],
      BackupSchema.keyLvUrls: [
        {
          'id': 'url-1',
          'collection_id': 'child-1',
          'url': 'https://example.com',
          'title': 'A',
          'status': 'unread',
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        },
      ],
    });
    final cols = _StrictMemCollections();
    final items = _MemItems();
    final uc = ImportDataUseCase(cols, items, _FakeFileService(payload));
    final r = await uc.execute('/tmp/shuffled.json');
    final res = r.getOrElse((l) => throw Exception('$l'));
    expect(res.collectionsFailed, 0);
    expect(res.collectionsCreated, 2);
    expect(res.itemsCreated, 1);
    expect(cols.byId['child-1']?.parentId, 'root-1');
  });

  test('v2 remaps backup root id when one root already exists', () async {
    final cols = _StrictMemCollections();
    await cols.createCollection(
      Collection(
        id: 'existing-root',
        title: 'Library',
        category: 'general',
        colorHex: '#6366F1',
        iconName: 'folder',
        position: 0,
        createdAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
      ),
    );
    final payload = jsonEncode({
      BackupSchema.keyVersion: BackupSchema.version2_0,
      BackupSchema.keyLvCollections: [
        {
          'id': 'backup-root',
          'parent_id': null,
          'title': 'Library',
          'category': 'general',
          'color_hex': '#6366F1',
          'icon_name': 'folder',
          'position': 0.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 1,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
        },
        {
          'id': 'backup-child',
          'parent_id': 'backup-root',
          'title': 'Child',
          'category': 'general',
          'color_hex': '#111111',
          'icon_name': 'folder',
          'position': 1.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 0,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
        },
      ],
      BackupSchema.keyLvUrls: [
        {
          'id': 'url-root',
          'collection_id': 'backup-root',
          'url': 'https://example.com/root',
          'title': 'Root link',
          'status': 'unread',
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
        },
      ],
    });
    final items = _MemItems();
    final uc = ImportDataUseCase(cols, items, _FakeFileService(payload));
    final r = await uc.execute('/tmp/root-remap.json');
    final res = r.getOrElse((l) => throw Exception('$l'));
    expect(res.collectionsFailed, 0);
    expect(res.itemsFailed, 0);
    expect(cols.byId.containsKey('backup-root'), false);
    expect(cols.byId.containsKey('existing-root'), true);
    expect(cols.byId['backup-child']?.parentId, 'existing-root');
    expect(items.byId['url-root']?.collectionId, 'existing-root');
  });

  test('accepts semver-like 2.x version for v2 import', () async {
    final payload = jsonEncode({
      BackupSchema.keyVersion: '2.0.1',
      BackupSchema.keyLvCollections: [
        {
          'id': 'col-semver',
          'parent_id': null,
          'title': 'Folder',
          'category': 'general',
          'color_hex': '#000000',
          'icon_name': 'folder',
          'position': 0.0,
          'is_pinned': false,
          'is_archived': false,
          'is_deleted': false,
          'url_count': 0,
          'child_count': 0,
          'created_at': '2020-01-01T00:00:00.000Z',
          'updated_at': '2020-01-01T00:00:00.000Z',
          'items_layout': 'list',
          'child_collections_layout': 'list',
          'items_sort_default': 'manual',
          'open_links_in': 'in_app',
          'show_link_previews': true,
        },
      ],
      BackupSchema.keyLvUrls: [],
    });
    final uc =
        ImportDataUseCase(_MemCollections(), _MemItems(), _FakeFileService(payload));
    final r = await uc.execute('/tmp/semver-v2.json');
    expect(r.isRight(), true);
  });
}
