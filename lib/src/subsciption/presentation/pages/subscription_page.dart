// ignore_for_file: public_member_api_docs, inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/constants/user_constants.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/container_button.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/show_snackbar_util.dart';
import 'package:link_vault/src/dashboard/presentation/dashboard_home_page.dart';
import 'package:link_vault/src/subsciption/presentation/cubit/subscription_cubit.dart';
import 'package:lottie/lottie.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});
  static const routeName = '/subscriptionPage';

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text(
          //   'Support Us',
          //   style: TextStyle(fontWeight: FontWeight.w500),
          // ),
          ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
                listener: (context, state) async {
                  if (state.videoWatchingStates == LoadingStates.loaded) {
                    // SHOW SUCCESS DIALOG
                    /// BELOW ONE HAS BUG AS NEED TO TAP 3 TIMES TO DISMISS DIALOG
                    //  await showAdaptiveDialog(
                    //     context: context,
                    //     builder: _showCustomDialog,
                    //   );
                  } else if (state.videoWatchingStates ==
                      LoadingStates.errorLoading) {
                    // SHOW SNACKBAR
                    showSnackbar(
                      context: context,
                      title: 'Something Went Wrong in Video Playback.',
                      subtitle: 'Check your internet connection and try again',
                    );
                  }
                },
                builder: (context, state) {
                  final subCubit = context.read<SubscriptionCubit>();
                  final globalUserCubit = context.read<GlobalUserCubit>();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Help Us Keeping this Platform Free',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Just watch a video and use the app for $rewardedAdCreditLimit days without any interruption.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.loadingStates == LoadingStates.initial)
                        ListTile(
                          onTap: subCubit.loadRewardedAd,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: ColourPallette.grey),
                          ),

                          // tileColor: Colors.green.shade300.withOpacity(0.5),
                          leading: const Icon(
                            Icons.repeat,
                            size: 32,
                          ),
                          title: const Text(
                            'Tap to Watch Again',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (state.loadingStates == LoadingStates.loading)
                        const ListTile(
                          leading: Icon(
                            Icons.video_library_rounded,
                            size: 32,
                            // color: ColourPallette.mountainMeadow,
                          ),
                          title: Text(
                            'Loading Video...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: CircularProgressIndicator(
                            color: ColourPallette.white,
                            backgroundColor: ColourPallette.black,
                          ),
                        ),
                      if (state.loadingStates == LoadingStates.loaded)
                        ContainerButton(
                          text: 'Watch a Video',
                          onPressed: () async {
                            await subCubit
                                .showRewardedAd(
                              globalUser: globalUserCubit.state.globalUser!,
                            )
                                .then(
                              (isLoaded) async {
                                if (subCubit.state.globalUser == null) {
                                  return;
                                }

                                globalUserCubit.initializeGlobalUser(
                                  subCubit.state.globalUser!,
                                );
                                if (isLoaded) {
                                  // SHOW SUCCESS DIALOG
                                  await showAdaptiveDialog(
                                    context: context,
                                    builder: _showCustomDialog,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      if (state.loadingStates == LoadingStates.errorLoading)
                        ContainerButton(
                          text: 'Someting Went Wrong. Try Again',
                          onPressed: subCubit.loadRewardedAd,
                          backgroundColor: ColourPallette.error,
                        ),
                      const SizedBox(height: 8),
                      if (state.videoWatchingStates == LoadingStates.loaded)
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const DashboardHomePage(),
                            ),
                            (route) => false,
                          ),
                          label: const Icon(
                            Icons.arrow_forward_rounded,
                            color: ColourPallette.mountainMeadow,
                          ),
                          icon: const Text(
                            'Go To Dashboard',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColourPallette.mountainMeadow,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // const SizedBox(height: 16.0),
          Expanded(
            child: SvgPicture.asset(
              MediaRes.solidaritySVG,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCustomDialog(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: ColourPallette.white,
      icon: Lottie.asset(
        MediaRes.hurrayANIMATION,
        height: 120,
        width: double.maxFinite,
        fit: BoxFit.cover,
      ),
      title: const Text(
        'Thanks for Supporting Us.',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Now you can enjoy $rewardedAdCreditLimit days of uniterrupted usage.',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      alignment: Alignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ContainerButton(
                text: 'Back',
                onPressed: () => Navigator.pop(context),
                // backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomElevatedButton(
                text: 'Dashboard',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const DashboardHomePage(),
                  ),
                  (route) => false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
