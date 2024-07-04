import 'package:hive/hive.dart';
import 'package:link_vault/app_models/link_tree_folder_model.dart';
import 'package:link_vault/app_services/databases/database_constants.dart';

class HiveService {
  /// -----------* read tree structure *-------------
  LinkTreeFolder? getTreeData(String key) {
    // getting the linkTree box
    final box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // getting the data from the local database
    final tree = box.get(key);
    // returning the treeData
    return tree;
  }

  /// -----------* adding folder *----------------
  void add(LinkTreeFolder data) {
    // getting the linkTree box
    final Box box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // adding new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// -----------* update folder *----------------
  void update(LinkTreeFolder data) {
    // getting the linkTree box
    final box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // updating new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// ----------* delete folder *------------------
  void delete(String key) {
    // getting the linkTree box
    final box = Hive.box<LinkTreeFolder>(kLinkTreeBox);

    // deleting the
    box.delete(key);
  }

  // <------------------------------ RECENT FOLDERS ---------------------------->

  Future<void> addRecentFolder(String linkFolderId) async {
    final box = Hive.box(kRecentLinkTreeFolders);

    final prevRecFoldList = getRecentFolders();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (var i = 0; i < prevRecFoldList.length; i++) {
      final folder = prevRecFoldList[i];

      if (folder == linkFolderId) {
        prevRecFoldList.removeAt(i);
      }
    }

    if (prevRecFoldList.length > 9) {
      prevRecFoldList.removeRange(9, prevRecFoldList.length);
    }
    // prevRecFoldList.add(linkFolderId);
    final newlist = <String>[linkFolderId, ...prevRecFoldList];

    await box.put(kRecentLinkTreeFolders, newlist);
  }

  Future<void> removeRecentFolder(String id) async {
    final box = Hive.box(kRecentLinkTreeFolders);

    final prevRecFoldList = getRecentFolders();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    prevRecFoldList.removeWhere((element) => element == id);

    await box.put(kRecentLinkTreeFolders, prevRecFoldList);
  }

  List<String> getRecentFolders() {
    // getting the linkTree box
    final box = Hive.box(kRecentLinkTreeFolders);

    // getting the data from the local database
    final recentFolders = box.get(
      kRecentLinkTreeFolders,
      defaultValue: [],
    ) as List;

    // returning the treeData
    return recentFolders.cast<String>();
  }

  // <------------------------------ RECENT LINKS ----------------------------->

  Future<void> addRecentLinks(Map link) async {
    final box = Hive.box(kRecentLinks);

    final prevRecLinkList = getRecentLinks();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (var i = 0; i < prevRecLinkList.length; i++) {
      final clink = prevRecLinkList[i];

      if (clink['url'] == link['url']) {
        prevRecLinkList.removeAt(i);
      }
    }

    prevRecLinkList.add(link);

    if (prevRecLinkList.length > 10) {
      final lastIndextoremove = prevRecLinkList.length - 10 - 1;
      prevRecLinkList.removeRange(
        0,
        lastIndextoremove,
      );
    }

    await box.put(kRecentLinks, prevRecLinkList);
  }

  List<Map> getRecentLinks() {
    // getting the linkTree box
    final box = Hive.box(kRecentLinks);

    // getting the data from the local database
    final recentFolders = box.get(
      kRecentLinks,
      defaultValue: [],
    ) as List;

    // returning the treeData
    return recentFolders.cast<Map>();
  }

  // <------------------------------ Favourite Folders -------------------------->

  Future<void> addFavouriteFolder(String linkFolderId) async {
    final box = Hive.box(kFavouriteLinkTreeFolders);

    final prevRecFoldList = getFavouriteFolders();

    // Check if already exist
    for (var i = 0; i < prevRecFoldList.length; i++) {
      final folder = prevRecFoldList[i];

      if (folder == linkFolderId) {
        prevRecFoldList.removeAt(i);
      }
    }

    prevRecFoldList.add(linkFolderId);

    await box.put(kFavouriteLinkTreeFolders, prevRecFoldList);
    // getFavouriteFolders();
  }

  Future<void> removeFavouriteFolder(String id) async {
    final box = Hive.box(kFavouriteLinkTreeFolders);

    final prevRecFoldList = getFavouriteFolders();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    prevRecFoldList.removeWhere((element) => element == id);

    await box.put(kFavouriteLinkTreeFolders, prevRecFoldList);
  }

  List<String> getFavouriteFolders() {
    // getting the linkTree box
    final box = Hive.box(kFavouriteLinkTreeFolders);

    // getting the data from the local database
    final recentFolders = box.get(
      kFavouriteLinkTreeFolders,
      defaultValue: [],
    ) as List;

    // print(recentFolders);
    // returning the treeData
    return recentFolders.cast<String>();
  }

  // <------------------------------ Favourite LINKS ----------------------------->

  Future<void> addFavouriteLinks(Map link) async {
    final box = Hive.box(kFavouriteLinks);

    final prevRecLinkList = getFavouriteLinks();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (var i = 0; i < prevRecLinkList.length; i++) {
      final clink = prevRecLinkList[i];

      if (clink['url'] == link['url']) {
        prevRecLinkList.removeAt(i);
      }
    }

    prevRecLinkList.add(link);

    // if (prevRecLinkList.length > 10) {
    //   int lastIndextoremove = prevRecLinkList.length - 10 - 1;
    //   prevRecLinkList.removeRange(
    //     0,
    //     lastIndextoremove,
    //   );
    // }

    await box.put(kFavouriteLinks, prevRecLinkList);
  }

  List<Map> getFavouriteLinks() {
    // getting the linkTree box
    final box = Hive.box(kFavouriteLinks);

    // getting the data from the local database
    final recentFolders = box.get(
      kFavouriteLinks,
      defaultValue: [],
    ) as List;

    // returning the treeData
    return recentFolders.cast<Map>();
  }
}
