import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_share_entity.dart';
import 'package:link_vault/src/urls_store/domain/entities/permission_level.dart';
import 'package:link_vault/src/urls_store/domain/entities/share_status.dart';

part 'collection_share_model.g.dart';

@Collection()
class CollectionShareModel {
  CollectionShareModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.collectionId,
    required this.sharedByUserId,
    this.sharedWithUserId,
    this.sharedWithEmail,
    required this.permissionLevel,
    required this.canReshare,
    required this.status,
    required this.invitationToken,
    this.expiresAt,
    required this.createdAt,
    this.acceptedAt,
  });

  final Id isarId;

  @Index()
  final String id;

  @Index()
  final String collectionId;

  @Index()
  final String sharedByUserId;

  final String? sharedWithUserId;
  final String? sharedWithEmail;
  final String permissionLevel;
  final bool canReshare;

  @Index()
  final String status;

  final String invitationToken;
  final DateTime? expiresAt;

  @Index()
  final DateTime createdAt;

  final DateTime? acceptedAt;

  // ---------------- ENTITY CONVERSION ---------------- //

  factory CollectionShareModel.fromEntity(CollectionShareEntity e) {
    return CollectionShareModel(
      id: e.id,
      collectionId: e.collectionId,
      sharedByUserId: e.sharedByUserId,
      sharedWithUserId: e.sharedWithUserId,
      sharedWithEmail: e.sharedWithEmail,
      permissionLevel: e.permissionLevel.name,
      canReshare: e.canReshare,
      status: e.status.name,
      invitationToken: e.invitationToken,
      expiresAt: e.expiresAt,
      createdAt: e.createdAt,
      acceptedAt: e.acceptedAt,
    );
  }

  CollectionShareEntity toEntity() {
    return CollectionShareEntity(
      id: id,
      collectionId: collectionId,
      sharedByUserId: sharedByUserId,
      sharedWithUserId: sharedWithUserId,
      sharedWithEmail: sharedWithEmail,
      permissionLevel: PermissionLevel.values.byName(permissionLevel),
      canReshare: canReshare,
      status: ShareStatus.values.byName(status),
      invitationToken: invitationToken,
      expiresAt: expiresAt,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
    );
  }

  // ---------------- JSON CONVERSION ---------------- //

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection_id': collectionId,
      'shared_by_user_id': sharedByUserId,
      'shared_with_user_id': sharedWithUserId,
      'shared_with_email': sharedWithEmail,
      'permission_level': permissionLevel,
      'can_reshare': canReshare,
      'status': status,
      'invitation_token': invitationToken,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
    };
  }

  factory CollectionShareModel.fromJson(Map<String, dynamic> json) {
    return CollectionShareModel(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      sharedByUserId: json['shared_by_user_id'] as String,
      sharedWithUserId: json['shared_with_user_id'] as String?,
      sharedWithEmail: json['shared_with_email'] as String?,
      permissionLevel: json['permission_level'] as String,
      canReshare: json['can_reshare'] as bool,
      status: json['status'] as String,
      invitationToken: json['invitation_token'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
    );
  }

  // ---------------- COPYWITH ---------------- //

  CollectionShareModel copyWith({
    Id? isarId,
    String? id,
    String? collectionId,
    String? sharedByUserId,
    String? sharedWithUserId,
    String? sharedWithEmail,
    String? permissionLevel,
    bool? canReshare,
    String? status,
    String? invitationToken,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return CollectionShareModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      sharedWithUserId: sharedWithUserId ?? this.sharedWithUserId,
      sharedWithEmail: sharedWithEmail ?? this.sharedWithEmail,
      permissionLevel: permissionLevel ?? this.permissionLevel,
      canReshare: canReshare ?? this.canReshare,
      status: status ?? this.status,
      invitationToken: invitationToken ?? this.invitationToken,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
