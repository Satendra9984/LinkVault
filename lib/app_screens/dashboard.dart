import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:link_vault/app_models/link_tree_folder_model.dart';
import 'package:link_vault/app_screens/store_screen.dart';
import 'package:link_vault/app_screens/update_folder_screen.dart';
import 'package:link_vault/app_services/databases/hive_database.dart';
import 'package:link_vault/app_widgets/favicons.dart';
import 'package:link_vault/app_widgets/folder_icon_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<LinkTreeFolder> _recentFolders = [];
  final List<LinkTreeFolder> _favouriteFolder = [];
  final List<Map> _recentUrl = [];
  final List<Map> _favouriteLinks = [];

  void _initializeRecentFoldersList() {
    final recentFolders = HiveService().getRecentFolders();

    for (final id in recentFolders) {
      _recentFolders.add(HiveService().getTreeData(id)!);
    }
    // _recentFolders.addAll(recentFolders);

    debugPrint('[log] : ${_recentFolders.length}');
  }

  void _initializeFavouriteFoldersList() {
    final favouriteFoldersId = HiveService().getFavouriteFolders();

    final favouriteFolders = <LinkTreeFolder>[];

    for (final id in favouriteFoldersId) {
      final folder = HiveService().getTreeData(id)!;

      _favouriteFolder.add(folder);
    }

    _favouriteFolder.addAll(favouriteFolders);

    debugPrint('[log] :  favourite ${_favouriteFolder.length}');
  }

  void _initializeRecentUrlsList() {
    final recentFolders = HiveService().getRecentLinks();
    _recentUrl.addAll(recentFolders);

    debugPrint('[log] : ${_recentUrl.length}');
  }

  void _initializeFavouriteUrlsList() {
    final recentFolders = HiveService().getFavouriteLinks();
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
    const utilsgap = 32.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 5,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Add recent visited folders functionality
              const Text(
                'Recent Folders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade100,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _recentFolders.length,
                  crossAxisCount: _getCount(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 2,
                  itemBuilder: (context, index) {
                    return FolderIconButton(
                      folder: _recentFolders[index],
                      onDoubleTap: () async {
                        // Navigator.of(context).push(
                        //   CupertinoPageRoute(
                        //     builder: (context) => UpdateFolder(
                        //       currentFolder: _recentFolders[index],
                        //     ),
                        //   ),
                        // );
                      },
                      onPress: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => StorePage(
                                parentFolderId: _recentFolders[index].id,),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: utilsgap),

              /// Recently visited urls functionality
              const Text(
                'Recent Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade100,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _recentUrl.length,
                  crossAxisCount: _getCount(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 2,
                  itemBuilder: (context, index) {
                    return FaviconsGrid(
                        imageUrl: _recentUrl[index],
                        onDoubleTap: () {},
                        onPress: () async {
                          if (await canLaunchUrl(
                              Uri.parse(_recentUrl[index]['url'].toString()),)) {
                            await launchUrl(
                                Uri.parse(_recentUrl[index]['url'].toString()),);
                          } else {
                            throw 'Could not launch ${_recentUrl[index]['url']}';
                          }
                        },);
                  },
                ),
              ),

              const SizedBox(height: utilsgap),

              /// Add favourite folders functionality
              const Text(
                'Favourite Folders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade100,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _favouriteFolder.length,
                  crossAxisCount: _getCount(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 2,
                  itemBuilder: (context, index) {
                    return FolderIconButton(
                      folder: _favouriteFolder[index],
                      onDoubleTap: () async {
                        // Navigator.of(context).push(
                        //   CupertinoPageRoute(
                        //     builder: (context) => UpdateFolder(
                        //       currentFolder: _favouriteFolder[index],
                        //     ),
                        //   ),
                        // );
                      },
                      onPress: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => StorePage(
                                parentFolderId: _favouriteFolder[index].id,),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: utilsgap),

              /// Add Favourite urls functionality
              const Text(
                'Favourite Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade100,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _favouriteLinks.length,
                  crossAxisCount: _getCount(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 2,
                  itemBuilder: (context, index) {
                    return FaviconsGrid(
                        imageUrl: _favouriteLinks[index],
                        onDoubleTap: () {},
                        onPress: () async {
                          if (await canLaunchUrl(Uri.parse(
                              _favouriteLinks[index]['url'].toString(),),)) {
                            await launchUrl(Uri.parse(
                                _favouriteLinks[index]['url'].toString(),),);
                          } else {
                            throw 'Could not launch ${_favouriteLinks[index]['url']}';
                          }
                        },);
                  },
                ),
              ),

              const SizedBox(height: utilsgap),
            ],
          ),
        ),
      ),
    );
  }

  int _getCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenWidthInt = screenWidth.toInt();
    // print('width --> $screenWidthInt\n');
    final count = screenWidthInt ~/ 88;
    return count;
  }
}
