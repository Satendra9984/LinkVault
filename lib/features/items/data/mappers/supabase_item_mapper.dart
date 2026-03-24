import '../../domain/entities/item.dart';

class SupabaseItemMapper {
  /// Maps a pure Dart [Item] entity into a JSON dictionary formatted
  /// specifically for the Supabase 'items' table.
  static Map<String, dynamic> toJson(
    Item entity, {
    String? uploadedImageUrl,
  }) {
    return {
      'id': entity.id,
      'collection_id': entity.collectionId,
      'title': entity.title,
      'description': entity.description,
      'image_url': uploadedImageUrl ?? entity.imagePath, // Favor the remote URL if provided, fallback to standard path
      'link': entity.link,
      'location': entity.location,
      'tags': entity.tags,
      'custom_fields': entity.customFields
          .map((f) => {
                'id': f.id,
                'name': f.name,
                'type': f.type.name,
                'value': f.value,
              })
          .toList(),
      'status': entity.status.name,
      'price': entity.customFields
          .where((f) => f.name.toLowerCase() == 'price' && f.type.name == 'number')
          .map((f) => double.tryParse(f.value.toString()))
          .firstOrNull, // Standardize price extraction if required by schema
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }
}
