


import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_share_entity.dart';

@Collection()
class CollectionShareModel extends Equatable {
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

  @override
  List<Object?> get props => [
        isarId,
        id,
        collectionId,
        sharedByUserId,
        sharedWithUserId,
        sharedWithEmail,
        permissionLevel,
        canReshare,
        status,
        invitationToken,
        expiresAt,
        createdAt,
        acceptedAt,
      ];

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
      permissionLevel: permissionLevel,
      canReshare: canReshare,
      status: status,
      invitationToken: invitationToken,
      expiresAt: expiresAt,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
    );
  }
}