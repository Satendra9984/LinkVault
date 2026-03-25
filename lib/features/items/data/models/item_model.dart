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
  /// Notes stored in `lv_urls.annotation`.
  String? annotation;
  String? tags;

  // URL identity / preview
  String? faviconUrl;
  String? dominantColor;
  String? siteName;

  // Future URL metadata
  String? canonicalUrl;
  String? contentType;
  @Property(type: PropertyType.date)
  DateTime? publishedAt;

  int dbStatus = ItemStatus.unread.index;

  @Transient()
  ItemStatus get status => ItemStatus.values[dbStatus];
  set status(ItemStatus s) => dbStatus = s.index;

  bool isPinned = false;
  int clickCount = 0;
  @Property(type: PropertyType.date)
  DateTime? lastAccessedAt;

  bool isDeleted = false;
  @Property(type: PropertyType.date)
  DateTime? deletedAt;

  @Index()
  late String collectionUid;

  double position = 0.0;

  @Property(type: PropertyType.date)
  DateTime createdAt = DateTime.now();

  @Property(type: PropertyType.date)
  DateTime updatedAt = DateTime.now();

  final collection = ToOne<CollectionModel>();
}
