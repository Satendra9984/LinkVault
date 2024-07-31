// ignore_for_file: inference_failure_on_untyped_parameter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard/collection_store_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) {
    //     ReceiveSharingIntent.instance.getMediaStream().listen(
    //       context.read<SharedInputsCubit>().addInputFiles,
    //       onError: (err) {
    //         debugPrint('getMediaStream error: $err');
    //       },
    //     );

    //     // For sharing images coming from outside the app while the app is closed
    //     ReceiveSharingIntent.instance.getInitialMedia().then(
    //           context.read<SharedInputsCubit>().addInputFiles,
    //         );
    //   },
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = context.read<GlobalUserCubit>().state.globalUser!.id;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      home: FolderCollectionPage(
        collectionId: globalUser,
        isRootCollection: true,
      ),
    );
  }
}
