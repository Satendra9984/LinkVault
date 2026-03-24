import '../../../collections/domain/entities/collection.dart';
import '../../../items/domain/entities/item.dart';

class ExportDataMapper {
  /// Converts a [Collection] to the unified backup export JSON format.
  /// Retains camelCase to preserve backwards compatibility with older backups.
  static Map<String, dynamic> collectionToJson(Collection collection) {
    return {
      'id': collection.id,
      'name': collection.title, // Standardizing to spec 'name'
      'category': collection.category,
      'colorHex': collection.colorHex,
      'description': null, // Currently not in schema
      'createdAt': collection.createdAt.toIso8601String(),
      'updatedAt': collection.updatedAt.toIso8601String(),
    };
  }

  /// Converts an [Item] to the unified backup export JSON format.
  static Map<String, dynamic> itemToJson(Item item, {String? imageBase64}) {
    return {
      'id': item.id,
      'collectionId': item.collectionId,
      'name': item.title, // Standardizing to spec 'name'
      'description': item.description,
      'link': item.link,
      'imagePath': null, // Never export internal OS path
      'imageBase64': imageBase64,
      'status': item.status.name,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }
}
