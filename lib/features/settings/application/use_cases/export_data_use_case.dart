import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer';

import '../../../../core/errors/failures.dart';
import '../../../../core/infrastructure/platform/file_service.dart';
import '../../data/mappers/export_data_mapper.dart';
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

      // 3. Convert to export format
      final validCollectionIds = collections.map((c) => c.id).toSet();

      final collectionsJson = collections
          .map((collection) => ExportDataMapper.collectionToJson(collection))
          .toList();

      final List<Map<String, dynamic>> itemsJson = [];
      for (final item in items) {
        if (validCollectionIds.contains(item.collectionId)) {
          String? base64Image;
          if (item.imagePath != null && item.imagePath!.isNotEmpty) {
            try {
              final imageBytes = await _fileService.readFile(item.imagePath!);
              base64Image = base64Encode(imageBytes);
            } catch (e) {
              log('Warning: Failed to encode image for backup item ${item.id}: $e');
            }
          }
          itemsJson.add(
            ExportDataMapper.itemToJson(item, imageBase64: base64Image),
          );
        }
      }

      final appVersion = await _getAppVersion();

      final exportData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': appVersion,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'collections': collectionsJson,
        'items': itemsJson,
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
