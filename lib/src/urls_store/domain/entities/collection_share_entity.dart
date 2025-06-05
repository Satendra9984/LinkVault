

import 'package:equatable/equatable.dart';


enum PermissionLevel { read, edit, admin }
enum ShareStatus { pending, accepted, declined, revoked }

class CollectionShareEntity extends Equatable {
  final String id;
  final String collectionId;
  final String sharedByUserId;
  final String? sharedWithUserId;
  final String? sharedWithEmail;
  final PermissionLevel permissionLevel;
  final bool canReshare;
  final ShareStatus status;
  final String invitationToken;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const CollectionShareEntity({
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

  @override
  List<Object?> get props => [
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
}
