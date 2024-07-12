// ignore_for_file: public_member_api_docs, library_private_types_in_public_api
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/repositories/global_auth_repo.dart';
import 'package:link_vault/core/common/services/router.dart';
import 'package:link_vault/firebase_options.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/onboarding/data/data_sources/local_data_source_imple.dart';
import 'package:link_vault/src/onboarding/data/repositories/on_boarding_repo_impl.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/onboarding/presentation/pages/onboarding_home.dart';

/// Before you can use the hive, you need to initialize it.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// running the app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
      ],
      child: MaterialApp(
        title: 'link_vault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
          ),
        ),
        initialRoute: OnBoardingHomePage.routeName,
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
