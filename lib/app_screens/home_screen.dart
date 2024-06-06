import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:web_link_store/app_providers/receive_text.dart';
import 'package:web_link_store/app_screens/dashboard.dart';
import 'package:web_link_store/app_screens/store_screen.dart';
import 'package:web_link_store/app_services/databases/database_constants.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late StreamSubscription _intentDataStreamSubscription;
  late final PageController _pageController;
  int _currentIndex = 0;
  LinkTreeFolder _getBaseTree() {
    final HiveService hiveService = HiveService();
    LinkTreeFolder? baseFolder = hiveService.getTreeData(kRootDirectory);

    if (baseFolder != null) {
      return baseFolder;
    }
    hiveService.add(
      LinkTreeFolder(
        id: kRootDirectory,
        parentFolderId: kRootDirectory + "Parent",
        subFolders: [],
        urls: [],
        folderName: 'LinkVault',
      ),
    );

    baseFolder = hiveService.getTreeData(kRootDirectory);
    return baseFolder!;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _intentDataStreamSubscription =

        /// This is used when app is running
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      final rec = ref.read(receiveTextProvider.notifier);

      for (var file in value) {
        if (file.type == SharedMediaType.text) {
          if (value.isNotEmpty) {
            rec.changeState(true, file.path);
          } else {
            rec.changeState(false, '');
          }
        }
      }
    });

    /// This stream is used when app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      final rec = ref.read(receiveTextProvider.notifier);

      for (var file in value) {
        if (file.type == SharedMediaType.text) {
          if (value.isNotEmpty) {
            rec.changeState(true, file.path);
          } else {
            rec.changeState(false, '');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (currentPage) {
          _pageController.jumpToPage(currentPage);
          setState(() {
            _currentIndex = currentPage;
          });
        },
        selectedItemColor: const Color(0xff3cac7c),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.line_style_rounded,
            ),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
            ),
            label: 'Utils',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          StorePage(
            parentFolderId: _getBaseTree().id
          ),
          const DashboardScreen(),
        ],
      ),
    );
  }
}
