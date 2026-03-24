import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:objectbox/objectbox.dart';
import '../../../collections/data/models/collection_model.dart';

@Entity()
class ItemModel {
  @Id()
  int id = 0;

  @Unique()
  late String uid;

  String? ownerId;

  late String title;
  String? description;
  String? imagePath;
  String? imageUrl;
  String? link;
  String? location;
  String? tags;

  String? customFieldsJson;

  int dbStatus = ItemStatus.pending.index;

  @Transient()
  ItemStatus get status => ItemStatus.values[dbStatus];
  set status(ItemStatus s) => dbStatus = s.index;

  @Index()
  late String collectionUid;

  double position = 0.0;

  @Property(type: PropertyType.date)
  DateTime createdAt = DateTime.now();

  @Property(type: PropertyType.date)
  DateTime updatedAt = DateTime.now();

  final collection = ToOne<CollectionModel>();
}
