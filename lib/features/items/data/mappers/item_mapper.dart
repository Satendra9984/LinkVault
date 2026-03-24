import 'dart:convert';
import '../../domain/entities/item.dart' as domain;
import '../models/item_model.dart' as data;

class ItemMapper {
  static domain.Item toEntity(data.ItemModel model) {
    List<domain.CustomField> parsedFields = [];
    if (model.customFieldsJson != null && model.customFieldsJson!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(model.customFieldsJson!);
        parsedFields = decoded.map((f) {
            final map = f as Map<String, dynamic>;
            return domain.CustomField(
              id: map['id'] as String? ?? '',
              name: map['name'] as String? ?? '',
              type: domain.CustomFieldType.values.firstWhere(
                (e) => e.name == map['type'],
                orElse: () => domain.CustomFieldType.text,
              ),
              value: map['stringValue'] as String?,
            );
        }).toList();
      } catch (e) {
        // ignore parsing errors
      }
    }

    return domain.Item(
      id: model.uid,
      ownerId: model.ownerId,
      title: model.title,
      description: model.description,
      imagePath: model.imagePath,
      imageUrl: model.imageUrl,
      link: model.link,
      location: model.location,
      tags: model.tags,
      customFields: parsedFields,
      status: model.status,
      position: model.position,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      collectionId: model.collectionUid,
    );
  }

  static data.ItemModel toModel(domain.Item entity) {
    final fieldsList = entity.customFields.map((f) => {
      'id': f.id,
      'name': f.name,
      'type': f.type.name,
      'stringValue': f.value,
    }).toList();

    return data.ItemModel()
      ..uid = entity.id
      ..ownerId = entity.ownerId
      ..title = entity.title
      ..description = entity.description
      ..imagePath = entity.imagePath
      ..imageUrl = entity.imageUrl
      ..link = entity.link
      ..location = entity.location
      ..tags = entity.tags
      ..customFieldsJson = jsonEncode(fieldsList)
      ..status = entity.status
      ..position = entity.position
      ..collectionUid = entity.collectionId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
  }
}
