import 'package:path_provider/path_provider.dart';
import '../../../../objectbox.g.dart'; // created by `flutter pub run build_runner build`
import 'dart:io';
import 'package:path/path.dart' as p;

/// Central ObjectBox database. Opened once in [bootstrap.dart].
class AppDatabase {
  late final Store store;

  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "objectbox");
    
    // Future-proofing: Create directory if it doesn't exist
    final dir = Directory(storeDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    store = await openStore(directory: storeDir);
  }
}
