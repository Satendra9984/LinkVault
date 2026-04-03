import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer';

import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/platform/file_service.dart';
import '../../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../items/data/mappers/supabase_item_mapper.dart';
import '../../../items/domain/entities/item.dart';
import '../../data/backup_schema.dart';
import '../../../collections/domain/repositories/i_collections_repository.dart';
import '../../../items/domain/repositories/i_items_repository.dart';

class ExportDataUseCase {
  final ICollectionsRepository _collectionsRepository;
  final IItemsRepository _itemsRepository;
  final FileService _fileService;

  ExportDataUseCase(
    this._collectionsRepository,
    this._itemsRepository,
    this._fileService,
  );

  Future<Either<Failure, String>> execute() async {
    try {
      // 1. Get all collections
      final collectionsResult =
          await _collectionsRepository.getAllCollections();
      if (collectionsResult.isLeft()) {
        return Left(collectionsResult.fold((l) => l, (r) => throw Exception()));
      }
      final collections = collectionsResult.getRight().toNullable() ?? [];

      // 2. Get all items
      final itemsResult = await _itemsRepository.getAllItems();
      if (itemsResult.isLeft()) {
        return Left(itemsResult.fold((l) => l, (r) => throw Exception()));
      }
      final items = itemsResult.getRight().toNullable() ?? [];

      // 3. BFS-order collections (parent before children) + interleave URLs.
      //    Within each level siblings are sorted by position asc, created_at asc.
      //    URLs for each collection are sorted by position asc, updated_at desc.
      final _BfsResult bfsResult =
          await _buildBfsOrdered(collections, items);

      final appVersion = await _getAppVersion();

      final exportData = <String, dynamic>{
        BackupSchema.keyVersion: BackupSchema.version2_0,
        BackupSchema.keyExportedAt: DateTime.now().toIso8601String(),
        BackupSchema.keyAppVersion: appVersion,
        BackupSchema.keyPlatform: Platform.isIOS ? 'ios' : 'android',
        BackupSchema.keyLvCollections: bfsResult.lvCollectionsJson,
        BackupSchema.keyLvUrls: bfsResult.lvUrlsJson,
      };

      // 4. Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // 5. Save to file
      final fileName = 'linkvault_backup_${_getDateString()}.json';
      final filePath = await _fileService.saveToFile(fileName, jsonString);

      // Note: Mixpanel tracking will be handled in the controller securely

      return Right(filePath);
    } catch (e, stackTrace) {
      return Left(UnexpectedFailure('Failed to export data',
          error: e, stackTrace: stackTrace));
    }
  }

  /// BFS traversal: root first, then children sorted by position → created_at.
  /// For each collection, its URLs (sorted by position → updated_at desc) are
  /// appended immediately after the collection row so the output is hierarchical
  /// and self-describing even as flat arrays.
  Future<_BfsResult> _buildBfsOrdered(
    List<Collection> collections,
    List<Item> items,
  ) async {
    // Build adjacency: parent id → sorted children.
    final childrenOf = <String, List<Collection>>{};
    final rootCollections = <Collection>[];

    for (final c in collections) {
      final parent = c.parentId;
      if (parent == null || parent.trim().isEmpty) {
        rootCollections.add(c);
      } else {
        childrenOf.putIfAbsent(parent, () => []).add(c);
      }
    }

    int cmpCollections(Collection a, Collection b) {
      final posCmp = a.position.compareTo(b.position);
      if (posCmp != 0) return posCmp;
      return a.createdAt.compareTo(b.createdAt);
    }

    rootCollections.sort(cmpCollections);
    for (final list in childrenOf.values) {
      list.sort(cmpCollections);
    }

    // Build adjacency: collection id → sorted URLs.
    final urlsOf = <String, List<Item>>{};
    final validCollectionIds = collections.map((c) => c.id).toSet();
    for (final item in items) {
      if (!validCollectionIds.contains(item.collectionId)) continue;
      urlsOf.putIfAbsent(item.collectionId, () => []).add(item);
    }
    for (final list in urlsOf.values) {
      list.sort((a, b) {
        final posCmp = a.position.compareTo(b.position);
        if (posCmp != 0) return posCmp;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    }

    // BFS traversal.
    final lvCollectionsJson = <Map<String, dynamic>>[];
    final lvUrlsJson = <Map<String, dynamic>>[];
    final queue = Queue<Collection>()..addAll(rootCollections);
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (visited.contains(current.id)) continue;
      visited.add(current.id);

      // Emit collection row.
      lvCollectionsJson
          .add(SupabaseCollectionMapper.toLvCollectionsBackupRow(current));

      // Emit this collection's URLs immediately after the collection row.
      for (final item in urlsOf[current.id] ?? const <Item>[]) {
        String? base64Image;
        if (item.imagePath != null && item.imagePath!.isNotEmpty) {
          try {
            final imageBytes = await _fileService.readFile(item.imagePath!);
            base64Image = base64Encode(imageBytes);
          } catch (e) {
            log('Warning: Failed to encode image for backup item ${item.id}: $e');
          }
        }
        final row = SupabaseItemMapper.toLvUrlsBackupRow(item);
        if (base64Image != null) {
          row[BackupSchema.keyImageBase64] = base64Image;
        }
        lvUrlsJson.add(row);
      }

      // Enqueue sorted children.
      for (final child in childrenOf[current.id] ?? const <Collection>[]) {
        if (!visited.contains(child.id)) {
          queue.add(child);
        }
      }
    }

    // Append collections whose parent is not in the export set (orphans).
    for (final c in collections) {
      if (!visited.contains(c.id)) {
        lvCollectionsJson
            .add(SupabaseCollectionMapper.toLvCollectionsBackupRow(c));
        for (final item in urlsOf[c.id] ?? const <Item>[]) {
          lvUrlsJson.add(SupabaseItemMapper.toLvUrlsBackupRow(item));
        }
      }
    }

    return _BfsResult(lvCollectionsJson, lvUrlsJson);
  }

  String _getDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return "1.0.0";
    }
  }
}

class _BfsResult {
  final List<Map<String, dynamic>> lvCollectionsJson;
  final List<Map<String, dynamic>> lvUrlsJson;
  const _BfsResult(this.lvCollectionsJson, this.lvUrlsJson);
}
