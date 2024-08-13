// ignore_for_file: public_member_api_docs, library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/repositories/global_auth_repo.dart';
import 'package:link_vault/core/common/services/router.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/firebase_options.dart' as prod;
import 'package:link_vault/firebase_options_test.dart' as dev;

import 'package:link_vault/src/advance_search/data/local_data_source.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/advance_search/repositories/searching_repo_impl.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/dashboard/data/data_sources/collection_local_data_sources.dart';
import 'package:link_vault/src/dashboard/data/data_sources/remote_data_sources.dart';
import 'package:link_vault/src/dashboard/data/data_sources/url_local_data_sources.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/collection_model_offline.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/image_with_bytes.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_image.dart';
import 'package:link_vault/src/dashboard/data/isar_db_models/url_model_offline.dart';
import 'package:link_vault/src/dashboard/data/repositories/collections_repo_impl.dart';
import 'package:link_vault/src/dashboard/data/repositories/url_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/onboarding/data/data_sources/local_data_source_imple.dart';
import 'package:link_vault/src/onboarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/onboarding/presentation/pages/onboarding_home.dart';
import 'package:link_vault/src/subsciption/data/datasources/subsciption_remote_data_sources.dart';
import 'package:link_vault/src/subsciption/data/repositories/rewarded_ad_repo_impl.dart';
import 'package:link_vault/src/subsciption/presentation/cubit/subscription_cubit.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  const isProduction = bool.fromEnvironment('dart.vm.product');

  // Logger.printLog('isProd: $isProduction');

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'LinkVault Singleton',
      options: isProduction
          ? prod.DefaultFirebaseOptions.currentPlatform
          : dev.DefaultFirebaseOptions.currentPlatform,
    );
  }

  // await FirebaseApp.initializeApp();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: 5 * 1024 * 1024,
  );

  await FirebaseFirestore.instance.enableNetwork();

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

  /// running the app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class FirebaseApp {
  static FirebaseApp? _instance;
  static FirebaseApp? get instance => _instance;

  static Future<void> initializeApp() async {
    if (_instance == null) {
      const isProduction = bool.fromEnvironment('dart.vm.product');

      _instance = (await Firebase.initializeApp(
        options: isProduction
            ? prod.DefaultFirebaseOptions.currentPlatform
            : dev.DefaultFirebaseOptions.currentPlatform,
      )) as FirebaseApp?;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
              localDataSourceImpl: LocalDataSourceImpl(
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
            collectionRepoImpl: CollectionsRepoImpl(
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
}
