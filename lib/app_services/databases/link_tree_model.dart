import 'package:hive/hive.dart';

part 'link_tree_model.g.dart';

@HiveType(typeId: 1)
class LinkTree {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String folderName;

  @HiveField(2)
  final List<String> subFolders;

  /// changed this field from string to map
  @HiveField(3)
  final List<Map<String, dynamic>> urls;

  /*
   url = {
      'url_title' = urlTitle;
      'user_note' = desc ?? '';
      'favicon': faviconUint,
      'image': imageUint,
      'image_title': title ?? 'No title available',
      'description': description ?? 'No description available',
      'size': {
        'height': desc['height'] ?? 0,
        'width': desc['width'] ?? 0,
    },
  */
  /// TODO : OTHER DATA FOR INDIVIDUAL PAGE CONFIGURATION
  @HiveField(4)
  bool isPreview = false;
  @HiveField(5)
  bool isFavicon = true;

  /// enum isGridView / isListView

  LinkTree({
    required this.id,
    required this.subFolders,
    required this.urls,
    required this.folderName,
    this.isPreview = false,
  });
}
