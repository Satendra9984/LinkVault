import 'package:link_vault/features/collections/domain/collection_display_defaults.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CollectionModel {
  @Id()
  int id = 0;

  @Unique()
  late String uid;

  String? ownerId;
  String? parentId;
  bool isShared = false;

  late String title;
  String? description;
  late String category;
  late String colorHex;
  late String iconName;
  String? iconJson;
  late double position;
  bool isPinned = false;
  bool isArchived = false;
  bool isDeleted = false;

  String itemsLayout = CollectionLayoutMode.compactGrid;
  String childCollectionsLayout = CollectionLayoutMode.compactGrid;
  String itemsSortDefault = CollectionItemsSortDefault.manual;
  String openLinksIn = CollectionOpenLinksIn.inApp;
  bool showLinkPreviews = true;

  @Property(type: PropertyType.date)
  late DateTime createdAt;

  @Property(type: PropertyType.date)
  late DateTime updatedAt;

  @Property(type: PropertyType.date)
  DateTime? lastAccessedAt;

  int itemCount = 0;
  int childCount = 0;
}
