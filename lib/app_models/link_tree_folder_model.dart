import 'package:hive/hive.dart';
part 'link_tree_folder_model.g.dart';

@HiveType(typeId: 1)
class LinkTreeFolder {

  LinkTreeFolder({
    required this.id,
    required this.parentFolderId,
    required this.subFolders,
    required this.urls,
    required this.folderName,
    this.isFavourite = false,
    this.category = 'Default',
    this.description,
  });
  /// id of this LinkTree
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String parentFolderId;

  /// name of the current folder
  @HiveField(2)
  final String folderName;

  /// for storing id of subfolders
  @HiveField(3)
  final List<String> subFolders;

  /// list of urls in this folder
  @HiveField(4)
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

  /// OTHER DATA FOR INDIVIDUAL PAGE CONFIGURATION
  @HiveField(5)
  bool isFavourite;

  @HiveField(6)
  String? category;

  @HiveField(7)
  String? description;
}
