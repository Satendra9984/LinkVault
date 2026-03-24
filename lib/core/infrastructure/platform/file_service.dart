import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> saveToFile(String fileName, String content) async {
    final directory = await _getDocumentDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> readFileAsString(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  Future<Uint8List> readFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  Future<String> saveImage(String fileName, Uint8List bytes) async {
    final directory = await _getDocumentDirectory();
    final imagesDir = Directory('${directory.path}/images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final file = File('${imagesDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<Directory> _getDocumentDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      // Fallback for desktop testing environments if needed
      return await getApplicationSupportDirectory();
    }
  }
}
