// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
// import 'package:link_vault/src/app_home/presentation/pages/app_home.dart';
// import 'package:link_vault/src/auth/presentation/pages/authentication_home.dart';
// import 'package:link_vault/src/onboarding/presentation/cubit/onboarding_cubit.dart';
// import 'package:link_vault/src/onboarding/presentation/models/loading_states.dart';
// import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';

// class OnBoardingHomePage extends StatefulWidget {
//   const OnBoardingHomePage({super.key});
//   static const routeName = '/';

//   @override
//   State<OnBoardingHomePage> createState() => _OnBoardingHomePageState();
// }

// class _OnBoardingHomePageState extends State<OnBoardingHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Call your BlocListener here
//       context.read<OnBoardCubit>().checkIfLoggedIn();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<OnBoardCubit, OnBoardState>(
//       listener: (context, state) {
//         // debugPrint('[log] : listening onboarding');
//         final onBoardCubit = context.read<OnBoardCubit>();
//         if (state.onBoardingStates == OnBoardingStates.isLoggedIn) {
//           context
//               .read<GlobalUserCubit>()
//               .initializeGlobalUser(state.globalUser!);

//           if (onBoardCubit.isCreditExpired()) {
//             Navigator.pushReplacementNamed(
//               context,
//               SubscriptionPage.routeName,
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 // builder: (ctx) => const DashboardHomePage(),
//                 builder: (ctx) => const AppHomePage(),

//               ),
//             );
//           }
//         }
//         if (state.onBoardingStates == OnBoardingStates.notLoggedIn) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (ctx) => const AuthenticationHomePage(),
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return const Scaffold(
//           body: Center(
//             child: Text(
//               'LinkVault',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/app_home/presentation/pages/app_home.dart';
import 'package:link_vault/src/auth/presentation/pages/authentication_home.dart';
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
  final ValueNotifier<bool> _isRendererChecked = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRenderer();
    });
  }

  Future<void> _checkRenderer() async {
    try {
      // Attempt to render a simple widget that might use problematic shaders
      // await _renderTestWidget().then((value) async {
        // _isRendererChecked.value = true;
        await context.read<OnBoardCubit>().checkIfLoggedIn();
      // });
      // If rendering is successful, proceed with onboarding
    } catch (e) {
      // if (e.toString().contains('ink_sparkle.frag') ||
      //     e
      //         .toString()
      //         .contains('does not contain appropriate runtime stage data')) {
      Logger.printLog('Impeller error occurred: $e');
      Logger.printLog('Switching to Skia renderer');
      // await _switchToSkia();
      // _restartApp();
    }
  }

  // Future<void> _renderTestWidget() async {
  //   // Render a simple widget to test shader compilation
  //   runApp(
  //     MaterialApp(
  //       home: Scaffold(
  //         body: Center(
  //           child: Container(
  //             decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [Colors.blue, Colors.green],
  //               ),
  //             ),
  //             child: const Text('Test'),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  //   await Future.delayed(const Duration(milliseconds: 100));
  // }
  // Future<void> _switchToSkia() async {
  //   try {
  //     // Communicate with the native platform to disable Impeller
  //     await const MethodChannel('flutter/settings').invokeMethod(
  //       'setString',
  //       {'key': 'FLUTTER_IMPELLER_ENABLED', 'value': 'false'},
  //     );
  //   } catch (e) {
  //     Logger.printLog('Failed to switch to Skia: $e');
  //   }
  // }
  // void _restartApp() {
  //   // Logic to restart the app
  //   SystemNavigator.pop();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isRendererChecked,
          builder: (context, isRendererChecked, child) {
            return BlocConsumer<OnBoardCubit, OnBoardState>(
              listener: (context, state) {
                // if (isRendererChecked) {
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
            );
          },
        ),
      ),
    );
  }
}
