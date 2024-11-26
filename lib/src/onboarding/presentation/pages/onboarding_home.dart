// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/src/app_home/presentation/pages/app_home.dart';
import 'package:link_vault/src/auth/presentation/pages/authentication_home.dart';
import 'package:link_vault/src/onboarding/data/repositories/models/loading_states.dart';
import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';

class OnBoardingHomePage extends StatelessWidget {
  const OnBoardingHomePage({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BlocConsumer<OnBoardCubit, OnBoardState>(
          listener: (context, state) {
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
                    builder: (ctx) => const AppHomePage(),
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
            // }
          },
          builder: (context, state) {
            return const Text(
              'LinkVault',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }
}
