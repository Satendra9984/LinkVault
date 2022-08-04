import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:web_link_store/app_providers/receive_text.dart';
import 'package:web_link_store/app_screens/store_screen.dart';
import 'package:web_link_store/app_services/databases/database_constants.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import '../app_services/databases/link_tree_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late StreamSubscription _intentDataStreamSubscription;

  LinkTree _getBaseTree() {
    final HiveService hiveService = HiveService();
    LinkTree? n = hiveService.getTreeData(kRootDirectory);

    if (n != null) {
      return n;
    }
    hiveService.add(hiveService.defaultLinkTreeBoxValue);
    // debugPrint('lintTree --> ${n!.id}\n${n!.urls}\n${n.folders}\n');
    n = hiveService.getTreeData(kRootDirectory);
    return n!;
  }

  @override
  void initState() {
    super.initState();
    _intentDataStreamSubscription =

        /// This is used when app is running
        ReceiveSharingIntent.getTextStream().listen((String value) {
      final rec = ref.read(receiveTextProvider.notifier);
      if (value.isNotEmpty) {
        rec.changeState(true, value);
      } else {
        rec.changeState(false, '');
      }
    });

    /// This stream is used when app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      final rec = ref.read(receiveTextProvider.notifier);
      if (value != null && value.isNotEmpty) {
        rec.changeState(true, value);
      } else {
        rec.changeState(false, '');
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StorePage(
        linkTree: _getBaseTree().id,
      ),
    );
  }
}
