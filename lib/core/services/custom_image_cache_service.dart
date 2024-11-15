import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/rss_feeds/data/constants/rss_feed_constants.dart';
import 'package:path_provider/path_provider.dart';

class CustomImagesCacheManager {
  // Private constructor for singleton pattern
  CustomImagesCacheManager._privateConstructor();

  // Singleton instance
  static final CustomImagesCacheManager _instance =
      CustomImagesCacheManager._privateConstructor();

  // Public getter to access the singleton instance
  static CustomImagesCacheManager get instance => _instance;

  // A map to hold CacheManagers for different collections (cacheKey)
  final Map<String, CacheManager> _cacheManagers = {};

  // Method to initialize the CacheManager for a specific collection
  void initCacheManager({
    required String cacheKey,
    required Duration stalePeriod,
    required int maxNrOfCacheObjects,
  }) {
    if (!_cacheManagers.containsKey(cacheKey)) {
      _cacheManagers[cacheKey] = CacheManager(
        Config(
          cacheKey,
          stalePeriod: stalePeriod,
          maxNrOfCacheObjects: maxNrOfCacheObjects,
        ),
      );
    }
  }

  // Get CacheManager instance for a specific collection (cacheKey)
  CacheManager? _getCacheManager(String cacheKey) {
    return _cacheManagers[cacheKey];
  }

  // Method to fetch images from the cache or network for a specific collection
  Future<FileInfo?> getImageFile(String imageUrl, String cacheKey) async {
    try {
      var cacheManager = _getCacheManager(cacheKey);
      if (cacheManager == null) {
        // Logger.printLog(
        //   'CacheManager for cacheKey $cacheKey is not initialized. Please call initCacheManager first.',
        // );

        initCacheManager(
          cacheKey: cacheKey,
          stalePeriod: const Duration(hours: rssFeedStalePeriodHours * 3 * 7),
          maxNrOfCacheObjects: maxNrOfCacheObjects,
        );
      }
      cacheManager = _getCacheManager(cacheKey);
      final fileInfo = await cacheManager?.getFileFromCache(imageUrl) ??
          await cacheManager?.downloadFile(imageUrl);

      return fileInfo;
    } catch (e) {
      // throw const FileSystemException('Could not get image');
      // Logger.printLog('[CACHE IMAGE] : $e');
    }
  }

  // Clear the cache for a specific collection using the collectionId (cacheKey)
  Future<void> clearCacheForCollection(String cacheKey) async {
    final cacheManager = _getCacheManager(cacheKey);
    if (cacheManager == null) return;

    // Clear cache in CacheManager
    await cacheManager.emptyCache();

    // Remove from the map and delete directory if necessary
    _cacheManagers.remove(cacheKey);
    final cacheDirectory = await getTemporaryDirectory();
    final cachePath = '${cacheDirectory.path}/$cacheKey';
    final cacheDir = Directory(cachePath);

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  // Method to clear the entire cache for all collections
  Future<void> clearAllCaches() async {
    for (final cacheManager in _cacheManagers.values) {
      await cacheManager.emptyCache();
    }
    _cacheManagers.clear();
  }

  // Method to remove a specific image from the cache of a collection
  Future<void> removeImageFromCache(String imageUrl, String cacheKey) async {
    final cacheManager = _getCacheManager(cacheKey);
    if (cacheManager == null) {
      throw Exception(
        'CacheManager for cacheKey $cacheKey is not initialized. Please call initCacheManager first.',
      );
    }
    await cacheManager.removeFile(imageUrl);
  }

  // Function to calculate cache size for a specific collection
  Future<int> getCacheSize(String cacheKey) async {
    final cacheManager = _getCacheManager(cacheKey);
    if (cacheManager == null) {
      throw Exception(
        'CacheManager for cacheKey $cacheKey is not initialized. Please call initCacheManager first.',
      );
    }

    final cacheDirectory = await getTemporaryDirectory();
    final cachePath = '${cacheDirectory.path}/$cacheKey';
    final cacheDir = Directory(cachePath);

    var totalSize = 0;
    if (cacheDir.existsSync()) {
      final files = cacheDir.listSync();
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    return totalSize;
  }

  // Method to check if a particular image is already cached in a collection
  Future<bool> isImageCached(String imageUrl, String cacheKey) async {
    final cacheManager = _getCacheManager(cacheKey);
    if (cacheManager == null) {
      throw Exception(
        'CacheManager for cacheKey $cacheKey is not initialized. Please call initCacheManager first.',
      );
    }
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);
    return fileInfo != null;
  }
}
