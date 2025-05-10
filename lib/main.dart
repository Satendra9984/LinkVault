import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/src/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
import 'package:link_vault/src/common/data_layer/data_sources/local_data_sources/global_user_local_data_source.dart';
import 'package:link_vault/src/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
import 'package:link_vault/src/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
import 'package:link_vault/src/common/data_layer/data_sources/remote_data_sources/global_user_remote_data_source.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/url_image.dart';
import 'package:link_vault/src/common/data_layer/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/url_preload_manager_cubit/url_preload_manager_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/webview_cubit/webviews_cubit.dart';
import 'package:link_vault/src/common/repository_layer/models/global_user_model.dart';
import 'package:link_vault/src/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/src/common/repository_layer/repositories/url_repo_impl.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/router.dart';
import 'package:link_vault/firebase_options.dart' as prod;
import 'package:link_vault/firebase_options_test.dart' as development;
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/on_boarding/presentation/bloc/onboarding_cubit.dart';
import 'package:link_vault/src/app_initializaiton/presentation/pages/onboarding/onboarding_home.dart';
import 'package:link_vault/src/recents/presentation/cubit/recents_url_cubit.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:link_vault/src/search/data/local_data_source.dart';
import 'package:link_vault/src/search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/search/repositories/searching_repo_impl.dart';
import 'package:link_vault/src/subsciption/data/repositories/rewarded_ad_repo_impl.dart';
import 'package:link_vault/src/subsciption/presentation/cubit/subscription_cubit.dart';
import 'package:path_provider/path_provider.dart';

// [todo]: https://groups.google.com/g/flutter-dev/c/7ua_tM7znxU/m/x165-JZuBAAJ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app immediately, do other inits in the background
  runApp(
    ProviderScope(
      child: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              title: 'link_vault',
              debugShowCheckedModeBanner: false,
              color: ColourPallette.white,
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                ),
                primarySwatch:
                    Colors.green, // Change to your desired primary color
              ),
              home: Scaffold(
                body: Center(
                  child: SvgPicture.asset(
                    MediaRes.linkVaultLogoSVG,
                    height: 136,
                    width: 136,
                  ),
                ),
              ),
            );
          }

          return const MyApp(); // Create a simple splash screen widget
        },
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  await Future.wait([
    _initializeFirebase(),
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    ),
    _initializeIsar(),
  ]);
}

Future<void> _initializeFirebase() async {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');
  var firebaseOptions = prod.DefaultFirebaseOptions.currentPlatform;

  if (flavor == 'development') {
    firebaseOptions = development.DefaultFirebaseOptions.currentPlatform;
  }

  // debugPrint('IsProduction: $flavor ${firebaseOptions.projectId}');

  // Start Firebase initialization
  await Firebase.initializeApp(
    name: 'LinkVault Singleton',
    options: firebaseOptions,
  );
  

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: 5 * 1024 * 1024,
  );
  await FirebaseFirestore.instance.enableNetwork();
}

Future<void> _initializeIsar() async {
  if (Isar.instanceNames.isEmpty) {
    final dir = await getApplicationDocumentsDirectory();
    await Isar.open(
      [
        CollectionModelOfflineSchema,
        UrlImageSchema,
        ImagesByteDataSchema,
        UrlModelOfflineSchema,
        GlobalUserSchema,
      ],
      directory: dir.path,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SharedInputsCubit(),
        ),

        BlocProvider(
          create: (context) => SubscriptionCubit(
            adRepoImpl: RewardedAdRepoImpl(
              globalUserRepositoryImpl: GlobalUserRepositoryImpl(
                remoteDataSource: FirebaseAuthDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
                localDataSource: IsarAuthDataSourceImpl(null),
              ),
            ),
          ),
        ),

        BlocProvider(
          create: (context) => OnBoardCubit(
            authRepoImpl: AuthRepositoryImpl(
              globalUserRepositoryImpl: GlobalUserRepositoryImpl(
                remoteDataSource: FirebaseAuthDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
                localDataSource: IsarAuthDataSourceImpl(null),
              ),
              authRemoteDataSourcesImpl: AuthRemoteDataSourcesImpl(
                auth: FirebaseAuth.instance,
              ),
            ),
          )..checkIfLoggedIn(),
        ),

        BlocProvider(
          create: (context) => GlobalUserCubit(),
        ),

        BlocProvider(
          create: (context) => AuthenticationCubit(
            authRepositoryImpl: AuthRepositoryImpl(
              authRemoteDataSourcesImpl: AuthRemoteDataSourcesImpl(
                auth: FirebaseAuth.instance,
              ),
              globalUserRepositoryImpl: GlobalUserRepositoryImpl(
                remoteDataSource: FirebaseAuthDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
                localDataSource: IsarAuthDataSourceImpl(null),
              ),
            ),
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => CollectionsCubit(
            collectionsRepoImpl: CollectionsRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
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
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
            ),
            collectionsCubit: context.read<CollectionsCubit>(),
            globalUserCubit: context.read<GlobalUserCubit>(),
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => RecentsUrlCubit(
            collectionRepoImpl: CollectionsRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
            ),
            urlRepoImpl: UrlRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
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
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
            ),
            collectionsCubit: context.read<CollectionsCubit>(),
            globalUserCubit: context.read<GlobalUserCubit>(),
          ),
        ),

        BlocProvider(
          create: (BuildContext context) => NetworkImageCacheCubit(),
        ),

        BlocProvider(
          create: (BuildContext context) => AdvanceSearchCubit(
            searchingRepoImpl: SearchingRepoImpl(
              searchLocalDataSourcesImpl:
                  SearchLocalDataSourcesImpl(isar: null),
            ),
          ),
        ),

        BlocProvider(
          create: (context) => RssFeedCubit(
            collectionCubit: context.read<CollectionsCubit>(),
            collectionCrudCubit: context.read<CollectionCrudCubit>(),
            globalUserCubit: context.read<GlobalUserCubit>(),
            urlRepoImpl: UrlRepoImpl(
              remoteDataSourceImpl: RemoteDataSourcesImpl(
                firestore: FirebaseFirestore.instance,
              ),
              collectionLocalDataSourcesImpl:
                  CollectionLocalDataSourcesImpl(isar: null),
              urlLocalDataSourcesImpl: UrlLocalDataSourcesImpl(isar: null),
            ),
          ),
        ),

        BlocProvider(
          create: (ctx) => UrlPreloadManagerCubit(),
        ),

        BlocProvider(
          create: (ctx) => WebviewsCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'link_vault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
          ),
          primarySwatch: Colors.green, // Change to your desired primary color
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        initialRoute: OnBoardingHomePage.routeName,
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
