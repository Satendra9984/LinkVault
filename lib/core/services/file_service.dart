import 'dart:io';
import 'package:link_vault/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileServicesCustom {
  /// Writes content to a file in the app's documents directory
  /// [fileName]: The name of the file to create or overwrite.
  /// [content]: The string data to write to the file.
  /// Returns the file path.
  static Future<String> writeFile(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      Logger.printLog('[FILE] : PATH: $filePath ');

      final file = File(filePath);
      await file.writeAsString(content);

      return filePath;
    } catch (e) {
      Logger.printLog('[FILE] : Error writing file: $e');
      rethrow;
    }
  }

  /// Writes content to a file at a custom location
  /// [filePath]: The absolute path to the file.
  /// [content]: The string data to write to the file.
  /// If the file or directory does not exist, it will create them.
  static Future<void> writeToCustomLocation(
    String filePath,
    String content,
  ) async {
    try {
      Logger.printLog('[FILE] : filepath $filePath');

      final file = File(filePath);

      // Ensure the directory exists
      await file.parent.create(recursive: true);

      // Write content to the file
      await file.writeAsString(content);
      print('File written successfully to $filePath');
    } catch (e) {
      Logger.printLog('[FILE] :Error writing to custom location: $e');
      rethrow;
    }
  }

  /// Reads the content of a file in the app's documents directory
  /// [fileName]: The name of the file to read.
  static Future<String?> readFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        Logger.printLog('[FILE] :File does not exist: $filePath');
        return null;
      }
    } catch (e) {
      Logger.printLog('[FILE] :Error reading file: $e');
      rethrow;
    }
  }

  /// Reads the content of a file from a custom location
  /// [filePath]: The absolute path to the file.
  static Future<String?> readFromCustomLocation(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        print('File does not exist at $filePath');
        return null;
      }
    } catch (e) {
      Logger.printLog('[FILE] : Error reading from custom location: $e');
      rethrow;
    }
  }

  /// Deletes a file at the specified path
  /// [filePath]: The absolute path to the file.
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
      } else {
        Logger.printLog('[FILE] : File does not exist: $filePath');
      }
    } catch (e) {
      Logger.printLog('[FILE] : Error deleting file: $e');
      rethrow;
    }
  }
}
