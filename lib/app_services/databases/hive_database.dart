import 'package:hive/hive.dart';
import 'package:web_link_store/app_services/databases/database_constants.dart';
import '../../app_models/link_tree_folder_model.dart';

class HiveService {
  /// -----------* read tree structure *-------------
  LinkTreeFolder? getTreeData(String key) {
    // getting the linkTree box
    Box<LinkTreeFolder> box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // getting the data from the local database
    LinkTreeFolder? tree = box.get(key);
    // returning the treeData
    return tree;
  }

  /// -----------* adding folder *----------------
  void add(LinkTreeFolder data) {
    // getting the linkTree box
    Box box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // adding new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// -----------* update folder *----------------
  void update(LinkTreeFolder data) {
    // getting the linkTree box
    Box<LinkTreeFolder> box = Hive.box<LinkTreeFolder>(kLinkTreeBox);
    // updating new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// ----------* delete folder *------------------
  void delete(String key) {
    // getting the linkTree box
    Box<LinkTreeFolder> box = Hive.box<LinkTreeFolder>(kLinkTreeBox);

    // deleting the
    box.delete(key);
  }

  // <------------------------------ RECENT FOLDERS ----------------------------->

  Future<void> addRecentFolder(LinkTreeFolder linkFolder) async {
    Box box = Hive.box(kRecentLinkTreeFolders);

    List<LinkTreeFolder> prevRecFoldList = getRecentFolders();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (int i = 0; i < prevRecFoldList.length; i++) {
      LinkTreeFolder folder = prevRecFoldList[i];

      if (folder.id == linkFolder.id) {
        prevRecFoldList.removeAt(i);
      }
    }

    prevRecFoldList.add(linkFolder);

    if (prevRecFoldList.length > 10) {
      int lastIndextoremove = prevRecFoldList.length - 10 - 1;
      prevRecFoldList.removeRange(
        0,
        lastIndextoremove,
      );
    }

    await box.put(kRecentLinkTreeFolders, prevRecFoldList);
  }

  List<LinkTreeFolder> getRecentFolders() {
    // getting the linkTree box
    Box box = Hive.box(kRecentLinkTreeFolders);

    // getting the data from the local database
    List<dynamic> recentFolders = box.get(
      kRecentLinkTreeFolders,
      defaultValue: [],
    );

    // returning the treeData
    return recentFolders.cast<LinkTreeFolder>();
  }

  // <------------------------------ RECENT LINKS ----------------------------->

  Future<void> addRecentLinks(Map link) async {
    Box box = Hive.box(kRecentLinks);

    List<Map> prevRecLinkList = getRecentLinks();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (int i = 0; i < prevRecLinkList.length; i++) {
      Map clink = prevRecLinkList[i];

      if (clink['url'] == link['url']) {
        prevRecLinkList.removeAt(i);
      }
    }

    prevRecLinkList.add(link);

    if (prevRecLinkList.length > 10) {
      int lastIndextoremove = prevRecLinkList.length - 10 - 1;
      prevRecLinkList.removeRange(
        0,
        lastIndextoremove,
      );
    }

    await box.put(kRecentLinks, prevRecLinkList);
  }

  List<Map> getRecentLinks() {
    // getting the linkTree box
    Box box = Hive.box(kRecentLinks);

    // getting the data from the local database
    List<dynamic> recentFolders = box.get(
      kRecentLinks,
      defaultValue: [],
    );

    // returning the treeData
    return recentFolders.cast<Map>();
  }




 // <------------------------------ Favourite Folders -------------------------->

  Future<void> addFavouriteFolder(LinkTreeFolder linkFolder) async {
    Box box = Hive.box(kLinkTreeBox);

    List<LinkTreeFolder> prevRecFoldList = getRecentFolders();

    // prevRecFoldList.add(linkFolder);
    // Check if already exist
    for (int i = 0; i < prevRecFoldList.length; i++) {
      LinkTreeFolder folder = prevRecFoldList[i];

      if (folder.id == linkFolder.id) {
        prevRecFoldList.removeAt(i);
      }
    }

    prevRecFoldList.add(linkFolder);

    if (prevRecFoldList.length > 10) {
      int lastIndextoremove = prevRecFoldList.length - 10 - 1;
      prevRecFoldList.removeRange(
        0,
        lastIndextoremove,
      );
    }

    await box.put(kRecentLinkTreeFolders, prevRecFoldList);
  }

  List<LinkTreeFolder> getFavouriteFolders() {
    // getting the linkTree box
    Box box = Hive.box(kRecentLinkTreeFolders);

    // getting the data from the local database
    List<dynamic> recentFolders = box.get(
      kRecentLinkTreeFolders,
      defaultValue: [],
    );

    // returning the treeData
    return recentFolders.cast<LinkTreeFolder>();
  }







}
