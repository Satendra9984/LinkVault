import 'dart:convert';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/platform/file_service.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/repositories/i_collections_repository.dart';
import '../../../items/data/mappers/supabase_item_mapper.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/repositories/i_items_repository.dart';
import '../../data/backup_schema.dart';

/// Maximum backup file size accepted for import (bytes).
const int kMaxImportFileBytes = 32 * 1024 * 1024; // 32 MiB

class ImportResult {
  final int collectionsCreated;
  final int collectionsUpdated;
  final int collectionsFailed;
  final int itemsCreated;
  final int itemsUpdated;
  final int itemsSkippedDuplicate;
  final int itemsSkippedOrphan;
  final int itemsFailed;

  const ImportResult({
    required this.collectionsCreated,
    required this.collectionsUpdated,
    required this.collectionsFailed,
    required this.itemsCreated,
    required this.itemsUpdated,
    required this.itemsSkippedDuplicate,
    required this.itemsSkippedOrphan,
    required this.itemsFailed,
  });

  int get collectionsTouched => collectionsCreated + collectionsUpdated;
  int get itemsTouched => itemsCreated + itemsUpdated;
}

class ValidationResult {
  final bool isValid;
  final String? error;
  ValidationResult(this.isValid, this.error);
}

class ImportDataUseCase {
  final ICollectionsRepository _collectionsRepository;
  final IItemsRepository _itemsRepository;
  final FileService _fileService;

  ImportDataUseCase(
    this._collectionsRepository,
    this._itemsRepository,
    this._fileService,
  );

  static bool _isVersionV2(String v) =>
      v == BackupSchema.version2_0 || v.startsWith('2.');

  Future<Either<Failure, ImportResult>> execute(String filePath) async {
    try {
      final len = await _fileService.fileLengthBytes(filePath);
      if (len != null && len > kMaxImportFileBytes) {
        return Left(ValidationFailure(
          'Backup file is too large (${(len / (1024 * 1024)).toStringAsFixed(1)} MB). '
          'Maximum is ${kMaxImportFileBytes ~/ (1024 * 1024)} MB.',
        ));
      }

      final jsonString = await _fileService.readFileAsString(filePath);
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final validation = _validateSchema(data);
      if (!validation.isValid) {
        return Left(ValidationFailure(validation.error!));
      }

      final version = data['version']?.toString() ?? '';

      if (_isVersionV2(version)) {
        return _importV2(data);
      }
      return _importV1(data);
    } on FormatException catch (_) {
      return const Left(ValidationFailure(
          'Invalid JSON format. The backup file might be corrupted.'));
    } catch (e, stackTrace) {
      return Left(UnexpectedFailure('Failed to import data',
          error: e, stackTrace: stackTrace));
    }
  }

  Future<Either<Failure, ImportResult>> _importV1(
      Map<String, dynamic> data) async {
    final collectionsList = data[BackupSchema.keyCollections]! as List;
    final itemsList = data[BackupSchema.keyItems]! as List;
    return _importCore(
      collectionsList: collectionsList,
      itemsList: itemsList,
      parseCollection: _collectionFromJson,
      parseItem: _itemFromJson,
    );
  }

  Future<Either<Failure, ImportResult>> _importV2(
      Map<String, dynamic> data) async {
    final collectionsListRaw =
        (data[BackupSchema.keyLvCollections] ?? data[BackupSchema.keyCollections])!
            as List;
    final itemsListRaw =
        (data[BackupSchema.keyLvUrls] ?? data[BackupSchema.keyItems])! as List;
    final prepared =
        await _prepareV2Rows(collectionsListRaw, itemsListRaw);
    return _importCore(
      collectionsList: prepared.collectionsRows,
      itemsList: prepared.itemsRows,
      parseCollection: (m) => SupabaseCollectionMapper.fromRow(m),
      parseItem: (m) => SupabaseItemMapper.fromLvUrlsBackupRow(m),
    );
  }

  Future<_PreparedV2Rows> _prepareV2Rows(
    List<dynamic> collectionsListRaw,
    List<dynamic> itemsListRaw,
  ) async {
    final collectionsRows = collectionsListRaw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final itemsRows =
        itemsListRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    // Remap backup root id to existing local/cloud root id to avoid unique-root conflicts.
    final idRemap = <String, String>{};
    final allRes = await _collectionsRepository.getAllCollections();
    if (allRes.isRight()) {
      final existing = allRes.getRight().toNullable() ?? const <Collection>[];
      final existingRoots = existing
          .where((c) => !c.isDeleted && (c.parentId == null || c.parentId!.trim().isEmpty))
          .toList();
      final backupRoots = collectionsRows.where((row) {
        final deleted = row['is_deleted'] == true;
        final p = row['parent_id']?.toString();
        return !deleted && (p == null || p.trim().isEmpty);
      }).toList();

      if (existingRoots.length == 1 && backupRoots.length == 1) {
        final backupRootId = backupRoots.first['id']?.toString();
        final existingRootId = existingRoots.first.id;
        if (backupRootId != null &&
            backupRootId.isNotEmpty &&
            backupRootId != existingRootId) {
          idRemap[backupRootId] = existingRootId;
        }
      }
    }

    for (final row in collectionsRows) {
      final oldId = row['id']?.toString();
      if (oldId != null && idRemap.containsKey(oldId)) {
        row['id'] = idRemap[oldId];
      }
      final oldParent = row['parent_id']?.toString();
      if (oldParent != null && idRemap.containsKey(oldParent)) {
        row['parent_id'] = idRemap[oldParent];
      }
    }
    for (final row in itemsRows) {
      final oldCollectionId = row['collection_id']?.toString();
      if (oldCollectionId != null && idRemap.containsKey(oldCollectionId)) {
        row['collection_id'] = idRemap[oldCollectionId];
      }
      final oldCollectionIdCamel = row['collectionId']?.toString();
      if (oldCollectionIdCamel != null &&
          idRemap.containsKey(oldCollectionIdCamel)) {
        row['collectionId'] = idRemap[oldCollectionIdCamel];
      }
    }

    // Parent-first ordering avoids FK failures when child appears before parent.
    final sortedCollections = _topologicalSortCollectionsByParent(collectionsRows);
    return _PreparedV2Rows(sortedCollections, itemsRows);
  }

  List<Map<String, dynamic>> _topologicalSortCollectionsByParent(
      List<Map<String, dynamic>> rows) {
    final remaining = <Map<String, dynamic>>[...rows];
    final remainingIds = remaining
        .map((r) => r['id']?.toString())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet();
    final emittedIds = <String>{};
    final ordered = <Map<String, dynamic>>[];

    while (remaining.isNotEmpty) {
      final batch = <Map<String, dynamic>>[];
      for (final row in remaining) {
        final parent = row['parent_id']?.toString();
        final parentEmpty = parent == null || parent.trim().isEmpty;
        final parentResolved = parentEmpty ||
            emittedIds.contains(parent) ||
            !remainingIds.contains(parent);
        if (parentResolved) {
          if (!parentEmpty && !emittedIds.contains(parent) && !remainingIds.contains(parent)) {
            // Missing parent in payload: promote to root so import can proceed.
            row['parent_id'] = null;
          }
          batch.add(row);
        }
      }

      if (batch.isEmpty) {
        // Break cycles defensively by promoting one unresolved row.
        final row = remaining.removeAt(0);
        row['parent_id'] = null;
        final id = row['id']?.toString();
        if (id != null && id.isNotEmpty) {
          emittedIds.add(id);
          remainingIds.remove(id);
        }
        ordered.add(row);
        continue;
      }

      for (final row in batch) {
        remaining.remove(row);
        final id = row['id']?.toString();
        if (id != null && id.isNotEmpty) {
          emittedIds.add(id);
          remainingIds.remove(id);
        }
        ordered.add(row);
      }
    }

    return ordered;
  }

  Future<Either<Failure, ImportResult>> _importCore({
    required List<dynamic> collectionsList,
    required List<dynamic> itemsList,
    required Collection Function(Map<String, dynamic> map) parseCollection,
    required Item Function(Map<String, dynamic> map) parseItem,
  }) async {
    var collectionsCreated = 0;
    var collectionsUpdated = 0;
    var collectionsFailed = 0;

    for (final json in collectionsList) {
      try {
        final map = Map<String, dynamic>.from(json as Map);
        final collection = parseCollection(map);
        final existingRes =
            await _collectionsRepository.getCollectionById(collection.id);
        if (existingRes.isLeft()) {
          collectionsFailed++;
          continue;
        }
        final existing = existingRes.fold(
          (_) => throw StateError('expected Right after isLeft check'),
          (r) => r,
        );
        if (existing == null) {
          final createRes =
              await _collectionsRepository.createCollection(collection);
          createRes.fold(
            (_) => collectionsFailed++,
            (_) => collectionsCreated++,
          );
        } else {
          final updateRes =
              await _collectionsRepository.updateCollection(collection);
          updateRes.fold(
            (_) => collectionsFailed++,
            (_) => collectionsUpdated++,
          );
        }
      } catch (e) {
        log('Warning: Failed to import collection: $e');
        collectionsFailed++;
      }
    }

    var itemsCreated = 0;
    var itemsUpdated = 0;
    var itemsSkippedDuplicate = 0;
    var itemsSkippedOrphan = 0;
    var itemsFailed = 0;

    for (final json in itemsList) {
      try {
        final row = Map<String, dynamic>.from(json as Map);
        var item = parseItem(row);

        final imageBase64 = row[BackupSchema.keyImageBase64] ??
            row[BackupSchema.keyImageBase64Snake];
        if (imageBase64 != null) {
          try {
            final base64String = imageBase64 as String;
            final newImagePath = await _saveImage(item.id, base64String);
            item = item.copyWith(imagePath: newImagePath);
          } catch (e) {
            log('Warning: image decode failed for item ${item.id}: $e');
          }
        }

        final parentRes =
            await _collectionsRepository.getCollectionById(item.collectionId);
        if (parentRes.isLeft()) {
          itemsSkippedOrphan++;
          continue;
        }
        final parent = parentRes.fold(
          (_) => throw StateError('expected Right after isLeft check'),
          (r) => r,
        );
        if (parent == null) {
          itemsSkippedOrphan++;
          continue;
        }

        final byIdRes = await _itemsRepository.getItem(item.id);
        if (byIdRes.isLeft()) {
          itemsFailed++;
          continue;
        }
        final existingById = byIdRes.fold(
          (_) => throw StateError('expected Right after isLeft check'),
          (r) => r,
        );

        if (existingById != null) {
          final up = await _itemsRepository.updateItem(item);
          up.fold(
            (_) => itemsFailed++,
            (_) => itemsUpdated++,
          );
          continue;
        }

        final dupRes = await _itemsRepository
            .findItemByCollectionAndNormalizedLink(
                item.collectionId, item.link ?? '');
        if (dupRes.isLeft()) {
          itemsFailed++;
          continue;
        }
        final dup = dupRes.fold(
          (_) => throw StateError('expected Right after isLeft check'),
          (r) => r,
        );
        if (dup != null) {
          itemsSkippedDuplicate++;
          continue;
        }

        final cr = await _itemsRepository.createItem(item);
        cr.fold(
          (_) => itemsFailed++,
          (_) => itemsCreated++,
        );
      } catch (e) {
        log('Warning: Failed to import item: $e');
        itemsFailed++;
      }
    }

    return Right(ImportResult(
      collectionsCreated: collectionsCreated,
      collectionsUpdated: collectionsUpdated,
      collectionsFailed: collectionsFailed,
      itemsCreated: itemsCreated,
      itemsUpdated: itemsUpdated,
      itemsSkippedDuplicate: itemsSkippedDuplicate,
      itemsSkippedOrphan: itemsSkippedOrphan,
      itemsFailed: itemsFailed,
    ));
  }

  ValidationResult _validateSchema(Map<String, dynamic> data) {
    if (!data.containsKey(BackupSchema.keyVersion)) {
      return ValidationResult(false, 'Missing version field');
    }
    final version = data[BackupSchema.keyVersion]?.toString();
    if (version == null || version.isEmpty) {
      return ValidationResult(false, 'Missing version field');
    }
    if (_isVersionV2(version)) {
      return _validateSchemaV2(data);
    }
    if (version == BackupSchema.version1_0) {
      return _validateSchemaV1(data);
    }
    return ValidationResult(
        false, 'Unsupported backup version: $version. Please update the app.');
  }

  ValidationResult _validateSchemaV1(Map<String, dynamic> data) {
    if (!data.containsKey(BackupSchema.keyCollections)) {
      return ValidationResult(false, 'Missing collections field');
    }
    if (!data.containsKey(BackupSchema.keyItems)) {
      return ValidationResult(false, 'Missing items field');
    }

    final collections = data[BackupSchema.keyCollections];
    if (collections is! List) {
      return ValidationResult(false, 'Collections must be an array');
    }

    for (final collection in collections) {
      if (collection is! Map) {
        return ValidationResult(false, 'Invalid collection format');
      }
      final c = Map<String, dynamic>.from(collection);
      if (!c.containsKey('id') || !c.containsKey('name')) {
        return ValidationResult(
            false, 'Collection missing required fields (id, name)');
      }
    }

    final items = data[BackupSchema.keyItems];
    if (items is! List) {
      return ValidationResult(false, 'Items must be an array');
    }

    for (final item in items) {
      if (item is! Map) {
        return ValidationResult(false, 'Invalid item format');
      }
      final it = Map<String, dynamic>.from(item);
      if (!it.containsKey('id') || !it.containsKey('collectionId')) {
        return ValidationResult(
            false, 'Item missing required fields (id, collectionId)');
      }
    }

    return ValidationResult(true, null);
  }

  ValidationResult _validateSchemaV2(Map<String, dynamic> data) {
    final cols =
        data[BackupSchema.keyLvCollections] ?? data[BackupSchema.keyCollections];
    final urls = data[BackupSchema.keyLvUrls] ?? data[BackupSchema.keyItems];

    if (cols == null) {
      return ValidationResult(false,
          'Missing lv_collections field (or collections alias for v2)');
    }
    if (urls == null) {
      return ValidationResult(
          false, 'Missing lv_urls field (or items alias for v2)');
    }
    if (cols is! List) {
      return ValidationResult(false, 'lv_collections must be an array');
    }
    if (urls is! List) {
      return ValidationResult(false, 'lv_urls must be an array');
    }

    for (final collection in cols) {
      if (collection is! Map) {
        return ValidationResult(false, 'Invalid collection format');
      }
      final c = Map<String, dynamic>.from(collection);
      if (!c.containsKey('id')) {
        return ValidationResult(false, 'Collection missing required field id');
      }
      final title = c['title'] ?? c['name'];
      if (title == null || title.toString().trim().isEmpty) {
        return ValidationResult(
            false, 'Collection missing required fields (title or name)');
      }
    }

    for (final item in urls) {
      if (item is! Map) {
        return ValidationResult(false, 'Invalid item format');
      }
      final it = Map<String, dynamic>.from(item);
      if (!it.containsKey('id')) {
        return ValidationResult(false, 'Item missing required field id');
      }
      final cid = it['collection_id'] ?? it['collectionId'];
      if (cid == null || cid.toString().trim().isEmpty) {
        return ValidationResult(
            false, 'Item missing required fields (collection_id or collectionId)');
      }
    }

    return ValidationResult(true, null);
  }

  Collection _collectionFromJson(Map<String, dynamic> json) {
    final desc = json['description'];
    return Collection(
      id: json['id'] as String,
      title: json['name'] as String,
      description: desc is String ? desc : desc?.toString(),
      category: json['category'] as String? ?? 'default',
      colorHex: json['colorHex'] as String? ?? '#000000',
      iconName:
          AppCategories.getIconForCategory(json['category'] as String? ?? 'default'),
      position: 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Item _itemFromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] ?? 'unread';
    final statusStr = switch (rawStatus) {
      'pending' => 'unread',
      'visited' => 'read',
      'completed' => 'archived',
      _ => rawStatus.toString(),
    };
    final parsedStatus = ItemStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ItemStatus.unread,
    );

    return Item(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      title: json['name'] as String,
      description: json['description'] as String?,
      link: json['link'] as String? ?? '',
      imagePath: null,
      imageUrl: null,
      tags: '',
      status: parsedStatus,
      position: 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Future<String> _saveImage(String itemId, String base64Str) async {
    final bytes = base64Decode(base64Str);
    final fileName = 'import_$itemId.jpg';
    return _fileService.saveImage(fileName, bytes);
  }
}

class _PreparedV2Rows {
  final List<Map<String, dynamic>> collectionsRows;
  final List<Map<String, dynamic>> itemsRows;

  const _PreparedV2Rows(this.collectionsRows, this.itemsRows);
}
