import 'package:equatable/equatable.dart';

enum ItemStatus { pending, visited, completed }

enum CustomFieldType { text, number, url, date, boolean }

class CustomField extends Equatable {
  final String id;
  final String name;
  final CustomFieldType type;
  final dynamic value;

  const CustomField({
    required this.id,
    required this.name,
    required this.type,
    this.value,
  });

  @override
  List<Object?> get props => [id, name, type, value];
}

class Item extends Equatable {
  final String id;
  final String? ownerId;
  final String title;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  final String? link;
  final String? location;
  final String? tags; // Comma-separated e.g. "coffee,cafe,cozy"
  final List<CustomField> customFields;

  final ItemStatus status;
  final double position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String collectionId; // Foreign key

  const Item({
    required this.id,
    this.ownerId,
    required this.title,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.link,
    this.location,
    this.tags,
    this.customFields = const [],
    required this.status,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.collectionId,
  });

  Item copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? imagePath,
    String? imageUrl,
    String? link,
    String? location,
    String? tags,
    List<CustomField>? customFields,
    ItemStatus? status,
    double? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? collectionId,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collectionId: collectionId ?? this.collectionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        imagePath,
        imageUrl,
        link,
        location,
        tags,
        customFields,
        status,
        position,
        createdAt,
        updatedAt,
        collectionId,
      ];
}
