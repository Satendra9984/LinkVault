// ignore_for_file: public_member_api_docs

class CollectionModel {
  CollectionModel({
    required this.id,
    required this.userId,
    required this.parentCollection,
    required this.name,
    required this.category,
    required this.subcollections,
    required this.urls,
    required this.status,
    required this.sharedWith,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.icon,
    this.background,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      parentCollection: json['parent_collection'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      subcollections:
          (json['subcollections'] as List<dynamic>? ?? []).cast<String>(),
      urls: (json['urls'] as List<dynamic>? ?? []).cast<String>(),
      icon: json['icon'] as Map<String, dynamic>?,
      background: json['background'] as Map<String, dynamic>?,
      status: Map<String, dynamic>.from(json['status'] as Map<String, dynamic>),
      sharedWith: (json['shared_with'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(SharedWith.fromJson)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory CollectionModel.isEmpty({
    required String userId,
    required String name,
    required String parentCollection,
    required Map<String, dynamic> status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return CollectionModel(
      id: '',
      userId: userId,
      parentCollection: parentCollection,
      name: name,
      // description: null,
      category: '',
      subcollections: [],
      urls: [],
      // icon: null,
      // background: null,
      status: status,
      sharedWith: [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String userId; // Owner's user id
  final String parentCollection; // id

  final String name;
  final String? description;
  final String category; // tag
  final List<String> subcollections; // ids of subcollections
  final List<String> urls; // ids of URLs

  final Map<String, dynamic>? icon; // id
  final Map<String, dynamic>? background; // id
  final Map<String, dynamic>? status; // active, deleted
  final List<SharedWith> sharedWith; // Embedded list of JSON objects

  final DateTime createdAt; // timestamp
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parent_collection': parentCollection,
      'name': name,
      'description': description,
      'category': category,
      'subcollections': subcollections,
      'urls': urls,
      'icon': icon,
      'background': background,
      'status': status,
      'shared_with': sharedWith.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CollectionModel copyWith({
    String? id,
    String? userId,
    String? parentCollection,
    String? name,
    String? description,
    String? category,
    List<String>? subcollections,
    List<String>? urls,
    Map<String, dynamic>? icon,
    Map<String, dynamic>? background,
    Map<String, dynamic>? status,
    List<SharedWith>? sharedWith,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentCollection: parentCollection ?? this.parentCollection,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subcollections: subcollections ?? this.subcollections,
      urls: urls ?? this.urls,
      icon: icon ?? this.icon,
      background: background ?? this.background,
      status: status ?? this.status,
      sharedWith: sharedWith ?? this.sharedWith,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SharedWith {
  // e.g., 'admin', 'editor', 'viewer'
  SharedWith({
    required this.userId,
    required this.role,
  });

  factory SharedWith.fromJson(Map<String, dynamic> json) {
    return SharedWith(
      userId: json['user_id'] as String,
      role: json['role'] as String,
    );
  }
  final String userId;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
    };
  }
}

class SubCollection {
  SubCollection({
    required this.subCollectionId,
    required this.subCollectionName,
  });

  factory SubCollection.fromJson(Map<String, dynamic> json) {
    return SubCollection(
      subCollectionId: json['sub_collection_id'] as String,
      subCollectionName: json['sub_collection_name'] as String,
    );
  }

  final String subCollectionId;
  final String subCollectionName; // e.g., 'admin', 'editor', 'viewer'

  Map<String, dynamic> toJson() {
    return {
      'sub_collection_id': subCollectionId,
      'sub_collection_name': subCollectionName,
    };
  }
}
