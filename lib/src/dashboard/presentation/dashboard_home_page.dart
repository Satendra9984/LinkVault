// ignore_for_file: inference_failure_on_untyped_parameter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/collection_store_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/collection_store_root_page.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ReceiveSharingIntent.instance.getMediaStream().listen(
        context.read<SharedInputsCubit>().addInputFiles,
        onError: (err) {
          debugPrint('getMediaStream error: $err');
        },
      );

      // For sharing images coming from outside the app while the app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then(
            context.read<SharedInputsCubit>().addInputFiles,
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = context.read<GlobalUserCubit>().state.globalUser!.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => CollectionsCubit(
            collectionsRepoImpl: CollectionsRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
            ),
            globalUserCubit: context.read<GlobalUserCubit>(),
          ),
        ),
        //  Create a CRUD cubit for managing crud operation a single collection

        BlocProvider(
          create: (BuildContext context) => UrlCrudCubit(
            urlRepoImpl: UrlRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
            ),
            collectionsCubit: context.read<CollectionsCubit>(),
            globalUserCubit: context.read<GlobalUserCubit>(),
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => CollectionCrudCubit(
            collectionRepoImpl: CollectionsRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
            ),
            collectionsCubit: context.read<CollectionsCubit>(),
            globalUserCubit: context.read<GlobalUserCubit>(),
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => NetworkImageCacheCubit(),
        ),

        //  We can further add more cubits like Offlineview editor,
        // webpage reader, openai summariser etc.
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
