import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/collection_store_page.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalUser = context.read<GlobalUserCubit>().state.globalUser!.id;

    return MultiBlocProvider(
      providers: [
        // [TODO] : Create the collections cubit for managing global list of all collections
        BlocProvider(
          create: (BuildContext context) => CollectionsCubit(
            collectionsRepoImpl: CollectionsRepoImpl(
                remoteDataSourceImpl: RemoteDataSourcesImpl(
              firestore: FirebaseFirestore.instance,
            ),),
          ),
        ),
        // [TODO] : Create a CRUD cubit for managing crud operation a single collection

        BlocProvider(
          create: (BuildContext context) => UrlCrudCubit(
            urlRepoImpl: UrlRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
            ),
            collectionsCubit: context.read<CollectionsCubit>(),
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
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => NetworkImageCacheCubit(),
        ),

        // [TODO] : We can further add more cubits like Offlineview editor,
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
