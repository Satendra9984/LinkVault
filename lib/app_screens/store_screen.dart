import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_link_store/app_providers/receive_text.dart';
import 'package:web_link_store/app_screens/add_folder_screen.dart';
import 'package:web_link_store/app_widgets/favicons.dart';
import 'package:web_link_store/app_screens/update_folder_screen.dart';
import 'package:web_link_store/app_screens/update_url_screen.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import 'package:web_link_store/app_widgets/folder_icon_button.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/preview_grid.dart';
import 'add_url_screen.dart';

class StorePage extends StatefulWidget {
  final String parentFolderId;
  const StorePage({
    Key? key,
    required this.parentFolderId,
  }) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final backgroundColor = const Color(0xFFE7ECEF);
  String _view = 'Icons';
  String _folderName = "";
  List<LinkTreeFolder> folderList = [];
  List<Map<String, dynamic>> urlList = [];

  LinkTreeFolder _getLinkTree(String id) {
    return HiveService().getTreeData(id)!;
  }

  void setView({String view = 'Icons'}) {
    setState(() {
      _view = view;
    });
    // update parentFolderId
    // LinkTreeFolder newLinkTree = _getLinkTree(widget.parentFolderId);
    // if (view == 'Icons') {
    //   newLinkTree.isFavicon = true;
    // } else if (view == 'Preview') {
    //   newLinkTree.isPreview = true;
    // } else if (view == 'Icons && Preview') {
    //   newLinkTree.isPreview = true;
    //   newLinkTree.isFavicon = true;
    // }
    // HiveService().update(newLinkTree);
  }

  int _getCount() {
    double screenWidth = MediaQuery.of(context).size.width;
    int screenWidthInt = screenWidth.toInt();
    // print('width --> $screenWidthInt\n');
    int count = screenWidthInt ~/ 88;
    return count;
  }

  void _initializeLinkTreeList() {
    HiveService hiveService = HiveService();

    LinkTreeFolder? parentFolderId =
        hiveService.getTreeData(widget.parentFolderId);

    if (parentFolderId != null) {
      List<String> keys = parentFolderId.subFolders;
      setState(
        () {
          _folderName = parentFolderId.folderName;
          folderList = [];
          for (String id in keys) {
            LinkTreeFolder? subLinkTree = hiveService.getTreeData(id);

            if (subLinkTree != null) {
              folderList.add(subLinkTree);
            }
          }
          urlList = parentFolderId.urls;
        },
      );
    }
  }

  @override
  initState() {
    super.initState();
    _initializeLinkTreeList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 5,
        title: Text(
          _folderName,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Folders",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: folderList.length + 1,
                crossAxisCount: _getCount(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 2.0,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              CupertinoPageRoute(
                                builder: (ctx) => AddFolderScreen(
                                  parentFolderId: widget.parentFolderId,
                                ),
                              ),
                            )
                            .then(
                              (value) => _initializeLinkTreeList(),
                            );
                        _initializeLinkTreeList();
                      },
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.create_new_folder_outlined,
                              size: 28.0,
                              color: Colors.grey.shade800,
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 5,
                                bottom: 5,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Add Folder',
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  index = index - 1;
                  return FolderIconButton(
                    folder: folderList[index],
                    onLongPress: () async {
                      Navigator.of(context)
                          .push(
                        CupertinoPageRoute(
                          builder: (context) => UpdateFolder(
                            currentFolder: _getLinkTree(folderList[index].id),
                            
                          ),
                        ),
                      )
                          .then(
                        (value) async {
                          _initializeLinkTreeList();
                          await HiveService()
                              .addRecentFolder(folderList[index]);
                          debugPrint('[log] : added recent folder');
                        },
                      );
                    },
                    onPress: () {
                      Navigator.of(context)
                          .push(
                        CupertinoPageRoute(
                          builder: (context) => StorePage(
                            parentFolderId: folderList[index].id,
                          ),
                        ),
                      )
                          .then(
                        (value) async {
                          _initializeLinkTreeList();
                          await HiveService()
                              .addRecentFolder(folderList[index]);
                          debugPrint('[log] : added recent folder');
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Links",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.4,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.grey.shade900,
                      ),
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text('Icons only'),
                            value: 'Icons',
                          ),
                          const PopupMenuItem(
                            child: Text('Preview only'),
                            value: 'Preview',
                          ),
                          // const PopupMenuItem(
                          //   child: Text('Icons && Preview'),
                          //   value: 'Icons && Preview',
                          // ),
                        ];
                      },
                      onSelected: (String value) {
                        setView(view: value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              if (_view == 'Icons' || _view == 'Icons && Preview')
                AlignedGridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: urlList.length + 1,
                  crossAxisCount: _getCount(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                CupertinoPageRoute(
                                  builder: (ctx) => AddUrlScreen(
                                    rootFolderKey: widget.parentFolderId,
                                  ),
                                ),
                              )
                              .then(
                                (value) => _initializeLinkTreeList(),
                              );
                          _initializeLinkTreeList();
                        },
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_link_rounded,
                                size: 28.0,
                                color: Colors.grey.shade800,
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 5,
                                  bottom: 5,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Add Link',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    index = index - 1;
                    return FaviconsGrid(
                      imageUrl: urlList[index],
                      onLongPress: () {
                        Navigator.of(context)
                            .push(
                              CupertinoPageRoute(
                                builder: (context) => UpdateUrlScreen(
                                  rootFolder:
                                      _getLinkTree(widget.parentFolderId),
                                  urlIndex: index,
                                ),
                              ),
                            )
                            .then(
                              (value) => _initializeLinkTreeList(),
                            );
                      },
                      onPress: () async {
                        if (await canLaunchUrl(
                            Uri.parse(urlList[index]['url']))) {
                          await launchUrl(Uri.parse(urlList[index]['url']));
                        } else {
                          throw 'Could not launch ${urlList[index]['url']}';
                        }

                        //  _initializeLinkTreeList();
                        await HiveService().addRecentLinks(urlList[index]);
                        debugPrint('[log] : added recent url');
                      },
                    );
                  },
                ),
              if (_view == 'Preview' || _view == 'Icons && Preview')
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: urlList.length,
                  itemBuilder: (context, ind) {
                    return Column(
                      children: [
                        Preview(
                          webUrl: urlList[ind],
                          onLongPress: () {
                            Navigator.of(context)
                                .push(
                                  CupertinoPageRoute(
                                    builder: (context) => UpdateUrlScreen(
                                      rootFolder:
                                          _getLinkTree(widget.parentFolderId),
                                      urlIndex: ind,
                                    ),
                                  ),
                                )
                                .then(
                                  (value) => _initializeLinkTreeList(),
                                );
                          },
                          onPress: () async {
                            if (await canLaunchUrl(
                                Uri.parse(urlList[ind]['url']))) {
                              await launchUrl(Uri.parse(urlList[ind]['url']));
                            } else {
                              throw 'Could not launch ${urlList[ind]['url']}';
                            }
                            await HiveService().addRecentLinks(urlList[ind]);
                            debugPrint('[log] : added recent url');
                          },
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final receiveNotifier = ref.watch(receiveTextProvider);
          final changeNotifier = ref.read(receiveTextProvider.notifier);

          final TextStyle labelStyle = TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          );

          return receiveNotifier.isSharing == true
              ? BottomAppBar(
                  // alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          changeNotifier.changeState(false, '');
                        },
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Cancel',
                              style: labelStyle,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (ctx) {
                              return AddUrlScreen(
                                rootFolderKey: widget.parentFolderId,
                                sharedUrl: receiveNotifier.receivedText,
                              );
                            }),

                            /// changed to false again
                          ).then((value) {
                            changeNotifier.changeState(false, '');
                            _initializeLinkTreeList();
                          });
                        },
                        child: Column(
                          children: [
                            const Icon(
                              Icons.file_copy,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Paste',
                              style: labelStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const Text('');
        },
      ),
    );
  }

  // _launchURL(String url) async {
  //   if (await canLaunchUrlString(url)) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}

/// @{https://pub.dev/packages/flutter_layout_grid#sizing-of-columns-and-rows}
/*
          urlList = [
            'https://google.com',
            'https://github.com',
            'https://www.youtube.com/watch?v=T0liuCwygow',
            'https://web.whatsapp.com/',
            'https://www.microsoft.com',
            'https://stackoverflow.com/questions/10456663/any-way-to-grab-a-logo-icon-from-website-url-programmatically',
            'https://www.linkedin.com/',
            'https://www.udemy.com/?deal_code=&utm_term=Homepage&utm_content=Textlink&utm_campaign=Rakuten-default&ranMID=39197&ranEAID=%2F68Yt01SgtI&ranSiteID=_68Yt01SgtI-Xs7xxC0PYnU1BQvzLVaMXg&LSNPUBID=%2F68Yt01SgtI&utm_source=aff-campaign&utm_medium=udemyads',
            'https://leetcode.com/',
            'https://twitter.com/home?lang=en',
            'https://docs.flutter.dev/',
            'https://sound.pressbooks.com/chapter/intensity-and-distance-april-2019-version/',
            'https://www.reddit.com/r/FlutterDev/',
            'https://firebase.google.com/',
            'https://www.codegrepper.com/code-examples/javascript/add+a+field+to+a+firebase+collection+programmatically',
          ];
*/
// GUEST
// password
