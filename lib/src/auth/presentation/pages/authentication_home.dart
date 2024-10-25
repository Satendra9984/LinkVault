import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/repository_layer/repositories/global_auth_repo.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/auth/presentation/cubit/forget_password/forget_password_cubit.dart';
import 'package:link_vault/src/auth/presentation/pages/login_signup/login_page.dart';

class AuthenticationHomePage extends StatefulWidget {
  const AuthenticationHomePage({super.key});

  @override
  State<AuthenticationHomePage> createState() => _AuthenticationHomePageState();
}

class _AuthenticationHomePageState extends State<AuthenticationHomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [
        // SystemUiOverlay.bottom,
        // SystemUiOverlay.top,
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ForgetPasswordCubit(
            authRepoIml: AuthRepositoryImpl(
              authRemoteDataSourcesImpl: AuthRemoteDataSourcesImpl(
                auth: FirebaseAuth.instance,
                // firestore: FirebaseFirestore.instance,
                globalAuthDataSourceImpl: GlobalAuthDataSourceImpl(),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: ColourPallette.white,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
