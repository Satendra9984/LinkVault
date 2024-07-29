import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/src/app_home/presentation/pages/app_home.dart';
import 'package:link_vault/src/auth/presentation/pages/authentication_home.dart';
import 'package:link_vault/src/dashboard/presentation/dashboard_home_page.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';
import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';

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
        // debugPrint('[log] : listening onboarding');
        final onBoardCubit = context.read<OnBoardCubit>();
        if (state.onBoardingStates == OnBoardingStates.isLoggedIn) {
          context
              .read<GlobalUserCubit>()
              .initializeGlobalUser(state.globalUser!);

          if (onBoardCubit.isCreditExpired()) {
            Navigator.pushReplacementNamed(
              context,
              SubscriptionPage.routeName,
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // builder: (ctx) => const DashboardHomePage(),
                builder: (ctx) => const AppHomePage()

              ),
            );
          }
        }
        if (state.onBoardingStates == OnBoardingStates.notLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => const AuthenticationHomePage(),
            ),
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
