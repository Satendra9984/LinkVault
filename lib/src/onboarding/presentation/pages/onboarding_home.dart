import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/auth/presentation/pages/authentication_home.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';

class OnBoardingHomePage extends StatefulWidget {
  const OnBoardingHomePage({super.key});
  static const routeName = '/';

  @override
  State<OnBoardingHomePage> createState() => _OnBoardingHomePageState();
}

class _OnBoardingHomePageState extends State<OnBoardingHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call your BlocListener here
      context.read<OnBoardCubit>().checkIfLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnBoardCubit, OnBoardState>(
      listener: (context, state) {
        debugPrint('[log] : listening onboarding');

        if (state.onBoardingStates == OnBoardingStates.isLoggedIn) {
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (ctx) => const NewsListPage()));
        }
        if (state.onBoardingStates == OnBoardingStates.notLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (ctx) => const AuthenticationHomePage()),
          );
        }
      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: Text(
              'LinkVault',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
