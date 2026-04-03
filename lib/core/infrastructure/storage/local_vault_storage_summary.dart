import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Sizes of on-device LinkVault data (ObjectBox + local images folder).
class LocalVaultStorageSummary {
  final int objectboxBytes;
  final int imagesBytes;

  const LocalVaultStorageSummary({
    required this.objectboxBytes,
    required this.imagesBytes,
  });

  int get totalBytes => objectboxBytes + imagesBytes;
}

/// Matches [AppDatabase.init]: ObjectBox under app documents `objectbox/`.
Future<String> objectboxDirectoryPath() async {
  final docs = await getApplicationDocumentsDirectory();
  return p.join(docs.path, 'objectbox');
}

/// Matches [FileService] image root: `images/` under the same directory
/// resolution as save paths (documents on mobile, support dir on desktop).
Future<String> imagesDirectoryPath() async {
  final root = await _vaultFileRootPath();
  return p.join(root, 'images');
}

Future<String> _vaultFileRootPath() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return (await getApplicationDocumentsDirectory()).path;
  }
  return (await getApplicationSupportDirectory()).path;
}

Future<int> _directorySizeBytes(Directory dir) async {
  if (!await dir.exists()) return 0;
  var total = 0;
  try {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
  } catch (_) {}
  return total;
}

/// Measures ObjectBox store and local `images/` folder (import thumbnails, etc.).
Future<LocalVaultStorageSummary> measureLocalVaultStorage() async {
  final objectbox = Directory(await objectboxDirectoryPath());
  final images = Directory(await imagesDirectoryPath());
  final ob = await _directorySizeBytes(objectbox);
  final im = await _directorySizeBytes(images);
  return LocalVaultStorageSummary(objectboxBytes: ob, imagesBytes: im);
}

/// Human-readable size (1–2 significant figures where sensible).
String formatVaultStorageBytes(int bytes) {
  if (bytes < 0) bytes = 0;
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) {
    return kb < 10
        ? '${kb.toStringAsFixed(1)} KB'
        : '${kb.round()} KB';
  }
  final mb = kb / 1024;
  if (mb < 1024) {
    return mb < 10
        ? '${mb.toStringAsFixed(1)} MB'
        : '${mb.toStringAsFixed(1)} MB';
  }
  final gb = mb / 1024;
  return gb < 10
      ? '${gb.toStringAsFixed(2)} GB'
      : '${gb.toStringAsFixed(1)} GB';
}

/// Soft tier for a non-device-relative progress hint (not % of disk).
(double progress01, String label) vaultStorageTier(int totalBytes) {
  const mb = 1024 * 1024;
  if (totalBytes < 5 * mb) {
    return (0.22, 'Light');
  }
  if (totalBytes < 25 * mb) {
    return (0.48, 'Moderate');
  }
  if (totalBytes < 100 * mb) {
    return (0.74, 'Large');
  }
  return (1.0, 'Very large');
}
