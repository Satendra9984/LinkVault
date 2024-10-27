// ignore_for_file: public_member_api_docs, library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/collection_local_data_source.dart';
import 'package:link_vault/core/common/data_layer/data_sources/local_data_sources/url_local_data_sources.dart';
import 'package:link_vault/core/common/data_layer/data_sources/remote_data_sources/collection_remote_data_source.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_image.dart';
import 'package:link_vault/core/common/data_layer/isar_db_models/url_model_offline.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_preload_manager_cubit/url_preload_manager_cubit.dart';
import 'package:link_vault/core/common/repository_layer/repositories/collections_repo_impl.dart';
import 'package:link_vault/core/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/core/common/repository_layer/repositories/url_repo_impl.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/router.dart';
import 'package:link_vault/dependency_provider.dart';
import 'package:link_vault/firebase_options.dart' as prod;
import 'package:link_vault/firebase_options_test.dart' as development;
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/onboarding/data/data_sources/onboard_local_data_source_impl.dart';
import 'package:link_vault/src/onboarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/onboarding/presentation/pages/onboarding_home.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:link_vault/src/search/data/local_data_source.dart';
import 'package:link_vault/src/search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/search/repositories/searching_repo_impl.dart';
import 'package:link_vault/src/subsciption/data/datasources/subsciption_remote_data_sources.dart';
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
    MobileAds.instance.initialize(),
    _initializeIsar(),
  ]);
}

Future<void> _initializeFirebase() async {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  var firebaseOptions = prod.DefaultFirebaseOptions.currentPlatform;

  if (flavor == 'development') {
    firebaseOptions = development.DefaultFirebaseOptions.currentPlatform;
  }

  debugPrint('IsProduction: $flavor ${firebaseOptions.projectId}');

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
              subsciptionRemoteDataSources: SubsciptionRemoteDataSources(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => OnBoardCubit(
            onBoardingRepoImpl: OnBoardingRepoImpl(
              localDataSourceImpl: OnBoardingLocalDataSourceImpl(
                auth: FirebaseAuth.instance,
                globalAuthDataSourceImpl: GlobalAuthDataSourceImpl(),
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
                globalAuthDataSourceImpl: GlobalAuthDataSourceImpl(),
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
        ),
        initialRoute: OnBoardingHomePage.routeName,
        onGenerateRoute: generateRoute,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MultiBlocProvider(
  //     providers: [
  //       // FOR MANAGING EXTERNAL DATA LIKE URL SHARED WITH APP
  //       BlocProvider(create: (_) => SharedInputsCubit()),

  //       // FOR ACCESSING USER-DETAILS THROUGH-OUT THE APP
  //       BlocProvider(create: (_) => GlobalUserCubit()),

  //       // STORING IMAGES-FETCHED FROM THE NETWORK(HTTP REQUESTS)
  //       BlocProvider(create: (_) => NetworkImageCacheCubit()),

  //       // STORING STATES OF PREFETCHING THE URL FOR CHECKING DATA LIKE
  //       // DNS, TCP, TLS etc.
  //       BlocProvider(create: (_) => UrlPreloadManagerCubit()),

  //       // FOR MANAGING SUBSCRIPTION OR CREDIT RELATED DATA
  //       BlocProvider(
  //         create: (_) => SubscriptionCubit(
  //           adRepoImpl: RewardedAdRepoImpl(
  //             subsciptionRemoteDataSources: SubsciptionRemoteDataSources(),
  //           ),
  //         ),
  //       ),

  //       // FOR ON-BOARDING MANAGEMENT
  //       BlocProvider(
  //         create: (_) => OnBoardCubit(
  //           onBoardingRepoImpl: OnBoardingRepoImpl(
  //             localDataSourceImpl: OnBoardingLocalDataSourceImpl(
  //               auth: DependencyProvider.auth,
  //               globalAuthDataSourceImpl:
  //                   DependencyProvider.globalAuthDataSource,
  //             ),
  //           ),
  //         )..checkIfLoggedIn(),
  //       ),

  //       // FOR MANAGING LOGIN AND LOGOUT
  //       BlocProvider(
  //         create: (_) => AuthenticationCubit(
  //           authRepositoryImpl: DependencyProvider.authRepository,
  //         ),
  //       ),

  //       // FOR MANAGING COLLECTION STATES OF URLS AND SUB-FOLDERS MAINLY
  //       BlocProvider(
  //         create: (_) => CollectionsCubit(
  //           collectionsRepoImpl: DependencyProvider.collectionsRepo,
  //           globalUserCubit: context.read<GlobalUserCubit>(),
  //         ),
  //       ),

  //       // FOR MANAGING CRUD OPERATION ON SUB-FOLDERS ONLY
  //       BlocProvider(
  //         create: (_) => CollectionCrudCubit(
  //           collectionRepoImpl: DependencyProvider.collectionsRepo,
  //           collectionsCubit: context.read<CollectionsCubit>(),
  //           globalUserCubit: context.read<GlobalUserCubit>(),
  //         ),
  //       ),

  //      // FOR MANAGING CRUD OPERATION ON URLS ONLY
  //       BlocProvider(
  //         create: (_) => UrlCrudCubit(
  //           urlRepoImpl: DependencyProvider.urlRepo,
  //           collectionsCubit: context.read<CollectionsCubit>(),
  //           globalUserCubit: context.read<GlobalUserCubit>(),
  //           collectionRepoImpl: DependencyProvider.collectionsRepo,
  //         ),
  //       ),

  //       // FOR MANAGING ADVANCE-SEARCH STATE
  //       BlocProvider(
  //         create: (_) => AdvanceSearchCubit(
  //           searchingRepoImpl: SearchingRepoImpl(
  //             searchLocalDataSourcesImpl:
  //                 DependencyProvider.searchLocalDataSources,
  //           ),
  //         ),
  //       ),

  //       // FOR MANAGIN ALL RSS-FEED RELATED DATA
  //       BlocProvider(
  //         create: (_) => RssFeedCubit(
  //           collectionCubit: context.read<CollectionsCubit>(),
  //           collectionCrudCubit: context.read<CollectionCrudCubit>(),
  //           globalUserCubit: context.read<GlobalUserCubit>(),
  //           urlRepoImpl: DependencyProvider.urlRepo,
  //         ),
  //       ),
  //     ],
  //     child: MaterialApp(
  //       title: 'link_vault',
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData(
  //         scaffoldBackgroundColor: Colors.white,
  //         appBarTheme: const AppBarTheme(
  //           backgroundColor: Colors.white,
  //         ),
  //         primarySwatch: Colors.green,
  //       ),
  //       initialRoute: OnBoardingHomePage.routeName,
  //       onGenerateRoute: generateRoute,
  //     ),
  //   );
  // }
}
