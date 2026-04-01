import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:objectbox/objectbox.dart' show Admin;
import 'package:path_provider/path_provider.dart';
import '../../../../objectbox.g.dart'; // created by `flutter pub run build_runner build`
import 'package:path/path.dart' as p;

/// Central ObjectBox database. Opened once in [bootstrap.dart].
class AppDatabase {
  late final Store store;
  // Dev-only: keep Admin alive in debug builds so the HTTP server isn't
  // garbage-collected. Ignored in release.
  Admin? _admin;

  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "objectbox");

    // Future-proofing: Create directory if it doesn't exist
    final dir = Directory(storeDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    store = await openStore(directory: storeDir);

    // Dev-only: start ObjectBox Admin inside the app so we can inspect the
    // live database via browser + ADB port-forward (Android).
    if (kDebugMode && Admin.isAvailable()) {
      try {
        _admin = Admin(store); // listens on 127.0.0.1:8090 on the device
        debugPrint(
          '🗄️ ObjectBox Admin started on device localhost:8090 (debug/dev only). '
          'Run: adb forward tcp:8090 tcp:8090 then open http://127.0.0.1:8090',
        );
      } catch (e, st) {
        debugPrint('⚠️ ObjectBox Admin failed to start: $e\n$st');
      }
    } else if (kDebugMode) {
      debugPrint(
        '🗄️ ObjectBox store initialised at $storeDir (Admin not available on this platform).',
      );
    }
  }
}
