import 'package:link_vault/src/urls_store/domain/entities/collection_background.dart';
import 'package:link_vault/src/urls_store/domain/entities/collection_icon.dart';

class CreateCollectionParams {
  final String userId;
  final String? parentCollectionId;
  final String name;
  final String? description;
  final CollectionIcon icon;
  final CollectionBackground background;
  final bool isPinned;

  CreateCollectionParams({
    required this.userId,
    this.parentCollectionId,
    required this.name,
    this.description,
    required this.icon,
    required this.background,
    this.isPinned = false,
  });
}