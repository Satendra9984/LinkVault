import 'package:hive/hive.dart';
import 'package:web_link_store/app_services/databases/database_constants.dart';
import '../../app_models/link_tree_model.dart';

class HiveService {
  final LinkTree defaultLinkTreeBoxValue = LinkTree(
    id: kRootDirectory,
    folderName: kRootDirectory,
    subFolders: [],
    urls: [],
  );

  /// -----------* read tree structure *-------------
  LinkTree? getTreeData(String key) {
    // getting the linkTree box
    Box<LinkTree> box = Hive.box<LinkTree>(kLinkTreeBox);

    // getting the data from the local database
    LinkTree? tree = box.get(
      key,
    );
    // returning the treeData
    return tree;
  }

  /// -----------* adding folder *----------------
  void add(LinkTree data) {
    // getting the linkTree box
    Box box = Hive.box<LinkTree>(kLinkTreeBox);

    // adding new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// -----------* update folder *----------------
  void update(LinkTree data) {
    // getting the linkTree box
    Box<LinkTree> box = Hive.box<LinkTree>(kLinkTreeBox);

    // updating new LinkTree in database with a unique key
    box.put(data.id, data);
  }

  /// ----------* delete folder *------------------
  void delete(String key) {
    // getting the linkTree box
    Box<LinkTree> box = Hive.box<LinkTree>(kLinkTreeBox);

    // deleting the
    box.delete(key);
  }

  /// TODO :hive box for sharing_intent teller
}
