import 'dart:convert';
import 'dart:developer';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/platform/file_service.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/domain/repositories/i_collections_repository.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/repositories/i_items_repository.dart';

class ImportResult {
  final int collectionsImported;
  final int itemsImported;
  ImportResult({
    required this.collectionsImported,
    required this.itemsImported,
  });
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

  Future<Either<Failure, ImportResult>> execute(String filePath) async {
    try {
      // 1. Read file
      final jsonString = await _fileService.readFileAsString(filePath);

      // 2. Parse JSON
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 3. Validate schema
      final validation = _validateSchema(data);
      if (!validation.isValid) {
        return Left(ValidationFailure(validation.error!));
      }

      // 4. Check version compatibility
      final version = data['version'] as String;
      if (!_isVersionCompatible(version)) {
        return Left(ValidationFailure(
          'Incompatible backup version: $version. Please update the app.',
        ));
      }

      // 5. Import collections
      final collectionsList = data['collections'] as List;
      int collectionsImported = 0;

      for (final json in collectionsList) {
        try {
          final collection = _collectionFromJson(json as Map<String, dynamic>);

          // Check if collection exists to avoid duplicates
          final existingOrFailure =
              await _collectionsRepository.getCollectionById(collection.id);

          if (existingOrFailure.isRight()) {
            final existing = existingOrFailure.getOrElse((_) => null);
            if (existing == null) {
              await _collectionsRepository.createCollection(collection);
              collectionsImported++;
            } else {
              // Update existing collection entirely instead of duplicating
              await _collectionsRepository.updateCollection(collection);
              collectionsImported++;
            }
          }
        } catch (e) {
          log('Warning: Failed to import collection: $e');
        }
      }

      // 6. Import items
      final itemsList = data['items'] as List;
      int itemsImported = 0;

      for (final json in itemsList) {
        try {
          final item = _itemFromJson(json as Map<String, dynamic>);

          Item itemToSave = item;

          // Hydrate Image Base64 Back to OS Disk
          if (json['imageBase64'] != null) {
            final base64String = json['imageBase64'] as String;
            final newImagePath = await _saveImage(item.id, base64String);
            itemToSave = item.copyWith(imagePath: newImagePath);
          }

          // Validate parent collection exists before importing item
          final parentCollectionOrFailure = await _collectionsRepository
              .getCollectionById(itemToSave.collectionId);

          final parentCollection =
              parentCollectionOrFailure.getOrElse((_) => null);
          if (parentCollection == null) {
            continue; // Skip orphaned items
          }

          // Check for existing
          final existingOrFailure =
              await _itemsRepository.getItem(itemToSave.id);
          if (existingOrFailure.isRight()) {
            final existing = existingOrFailure.getOrElse((_) => null);
            if (existing == null) {
              await _itemsRepository.createItem(itemToSave);
              itemsImported++;
            } else {
              // Update instead of duplicating
              await _itemsRepository.updateItem(itemToSave);
              itemsImported++;
            }
          }
        } catch (e) {
          log('Warning: Failed to import item: $e');
        }
      }

      // Analytics tracked natively in the Settings screen logic
      return Right(ImportResult(
        collectionsImported: collectionsImported,
        itemsImported: itemsImported,
      ));
    } on FormatException catch (_) {
      return const Left(ValidationFailure(
          'Invalid .curate JSON format. File might be corrupted.'));
    } catch (e, stackTrace) {
      return Left(UnexpectedFailure('Failed to import data',
          error: e, stackTrace: stackTrace));
    }
  }

  ValidationResult _validateSchema(Map<String, dynamic> data) {
    if (!data.containsKey('version')) {
      return ValidationResult(false, 'Missing version field');
    }
    if (!data.containsKey('collections')) {
      return ValidationResult(false, 'Missing collections field');
    }
    if (!data.containsKey('items')) {
      return ValidationResult(false, 'Missing items field');
    }

    final collections = data['collections'];
    if (collections is! List) {
      return ValidationResult(false, 'Collections must be an array');
    }

    for (final collection in collections) {
      if (collection is! Map<String, dynamic>) {
        return ValidationResult(false, 'Invalid collection format');
      }
      if (!collection.containsKey('id') || !collection.containsKey('name')) {
        return ValidationResult(
            false, 'Collection missing required fields (id, name)');
      }
    }

    final items = data['items'];
    if (items is! List) {
      return ValidationResult(false, 'Items must be an array');
    }

    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        return ValidationResult(false, 'Invalid item format');
      }
      if (!item.containsKey('id') || !item.containsKey('collectionId')) {
        return ValidationResult(
            false, 'Item missing required fields (id, collectionId)');
      }
    }

    return ValidationResult(true, null);
  }

  bool _isVersionCompatible(String version) {
    return version == '1.0';
  }

  Collection _collectionFromJson(Map<String, dynamic> json) {
    final desc = json['description'];
    return Collection(
      id: json['id'],
      title: json['name'],
      description: desc is String ? desc : desc?.toString(),
      category: json['category'] ?? 'default',
      colorHex: json['colorHex'] ?? '#000000',
      iconName: AppCategories.getIconForCategory(json['category'] ?? 'default'),
      position: 0.0, // newly imported collections fall to top
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
      id: json['id'],
      collectionId: json['collectionId'],
      title: json['name'],
      description: json['description'],
      link: json['link'],
      imagePath: null,
      imageUrl: null,
      tags: '', // Standard 1.0 backup drops customfields entirely right now unless added in a future spec update.
      status: parsedStatus,
      position: 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Future<String> _saveImage(String itemId, String base64Str) async {
    final bytes = base64Decode(base64Str);
    final fileName = 'import_$itemId.jpg';
    return await _fileService.saveImage(fileName, bytes);
  }
}
