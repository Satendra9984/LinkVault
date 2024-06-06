import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_link_store/app_models/link_tree_folder_model.dart';
import 'package:web_link_store/app_screens/store_screen.dart';
import 'package:web_link_store/app_screens/update_folder_screen.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import 'package:web_link_store/app_widgets/favicons.dart';
import 'package:web_link_store/app_widgets/folder_icon_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<LinkTreeFolder> _recentFolders = [], _favouriteFolder = [];
  final List<Map> _recentUrl = [], _favouriteLinks = [];

  void _initializeRecentFoldersList() {
    List<LinkTreeFolder> recentFolders = HiveService().getRecentFolders();
    _recentFolders.addAll(recentFolders);

    debugPrint('[log] : ${_recentFolders.length}');
  }

  void _initializeFavouriteFoldersList() {
    List<String> favouriteFoldersId = HiveService().getFavouriteFolders();

    List<LinkTreeFolder> favouriteFolders = [];

    for (String id in favouriteFoldersId) {
      LinkTreeFolder folder = HiveService().getTreeData(id)!;

      _favouriteFolder.add(folder);
    }

    _favouriteFolder.addAll(favouriteFolders);

    debugPrint('[log] :  favourite ${_favouriteFolder.length}');
  }

  void _initializeRecentUrlsList() {
    List<Map> recentFolders = HiveService().getRecentLinks();
    _recentUrl.addAll(recentFolders);

    debugPrint('[log] : ${_recentUrl.length}');
  }

  void _initializeFavouriteUrlsList() {
    List<Map> recentFolders = HiveService().getFavouriteLinks();
    _favouriteLinks.addAll(recentFolders);

    debugPrint('[log] : ${_favouriteLinks.length}');
  }

  @override
  void initState() {
    _initializeRecentFoldersList();
    _initializeFavouriteFoldersList();
    _initializeRecentUrlsList();
    _initializeFavouriteUrlsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 5,
        title: Text(
          '',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Add recent visited folders functionality
              const Text(
                "Recent Folders",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _recentFolders.length,
                crossAxisCount: _getCount(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 2.0,
                itemBuilder: (context, index) {
                  return FolderIconButton(
                    folder: _recentFolders[index],
                    onLongPress: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => UpdateFolder(
                            currentFolder: _recentFolders[index],
                          ),
                        ),
                      );
                    },
                    onPress: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => StorePage(
                              parentFolderId: _recentFolders[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 48.0),

              /// Recently visited urls functionality
              const Text(
                "Recent Links",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _recentUrl.length,
                crossAxisCount: _getCount(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 2.0,
                itemBuilder: (context, index) {
                  return FaviconsGrid(
                      imageUrl: _recentUrl[index],
                      onLongPress: () {},
                      onPress: () async {
                        if (await canLaunchUrl(
                            Uri.parse(_recentUrl[index]['url']))) {
                          await launchUrl(Uri.parse(_recentUrl[index]['url']));
                        } else {
                          throw 'Could not launch ${_recentUrl[index]['url']}';
                        }
                      });
                },
              ),

              const SizedBox(height: 48.0),

              /// [TODO] : Add favourite folders functionality
              const Text(
                "Favourite Folders",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _favouriteFolder.length,
                crossAxisCount: _getCount(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 2.0,
                itemBuilder: (context, index) {
                  return FolderIconButton(
                    folder: _favouriteFolder[index],
                    onLongPress: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => UpdateFolder(
                            currentFolder: _favouriteFolder[index],
                          ),
                        ),
                      );
                    },
                    onPress: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => StorePage(
                              parentFolderId: _favouriteFolder[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 48.0),

              /// [TODO] : Add Favourite urls functionality
              const Text(
                "Favourite Links",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),
              AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _favouriteLinks.length,
                crossAxisCount: _getCount(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 2.0,
                itemBuilder: (context, index) {
                  return FaviconsGrid(
                      imageUrl: _favouriteLinks[index],
                      onLongPress: () {},
                      onPress: () async {
                        if (await canLaunchUrl(
                            Uri.parse(_favouriteLinks[index]['url']))) {
                          await launchUrl(Uri.parse(_favouriteLinks[index]['url']));
                        } else {
                          throw 'Could not launch ${_favouriteLinks[index]['url']}';
                        }
                      });
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  int _getCount() {
    double screenWidth = MediaQuery.of(context).size.width;
    int screenWidthInt = screenWidth.toInt();
    // print('width --> $screenWidthInt\n');
    int count = screenWidthInt ~/ 88;
    return count;
  }
}
