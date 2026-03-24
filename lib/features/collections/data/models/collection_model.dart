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
  late String category;
  late String colorHex;
  late String iconName;
  late double position;
  bool isPinned = false;
  bool isArchived = false;
  bool isDeleted = false;
  
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  @Property(type: PropertyType.date)
  late DateTime updatedAt;
  
  int itemCount = 0;
  int childCount = 0;
}
