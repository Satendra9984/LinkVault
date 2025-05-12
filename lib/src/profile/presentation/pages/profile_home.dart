import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/src/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/models/auth_states_enum.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/login_page.dart';
import 'package:link_vault/src/authentication/presentation/screens/login_signup/signup_page.dart';
import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';
import 'package:lottie/lottie.dart';

class ProfileHome extends StatelessWidget {
  const ProfileHome({super.key});

  // final _accountDeletionState = ValueNotifier(LoadingStates.initial);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
      clipBehavior: Clip.none,

        title: const Text(
          'Profile Home',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      body: BlocBuilder<GlobalUserCubit, GlobalUserState>(
        builder: (ctx, state) {
          final globalUserCubit = context.read<GlobalUserCubit>();

          final user = globalUserCubit.getGlobalUser();

          if (user == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor:
                                ColourPallette.mountainMeadow.withOpacity(0.5),
                            child: SvgPicture.asset(
                              MediaRes.personSVG,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${state.globalUser?.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '@${state.globalUser?.email}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        // color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _getDetailsWidget(
                      title: 'Name',
                      value: user.name,
                    ),
                    const SizedBox(height: 12),
                    _getDetailsWidget(
                      title: 'Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 12),
                    _getDetailsWidget(
                      title: 'Joined In',
                      value: _getDate(user.createdAt.toLocal()),
                    ),
                    const SizedBox(height: 12),
                    _getDetailsWidget(
                      title: 'Next Recharge',
                      value: _getDateTime(user.creditExpiryDate.toLocal()),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        // color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SUPPORT US
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const SubscriptionPage(),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 0,
                      dense: true,
                      leading: const Icon(
                        Icons.support_rounded,
                        size: 24,
                        color: ColourPallette.black,
                      ),
                      title: const Text(
                        'Support Us',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: ColourPallette.grey,
                      ),
                    ),

                    // DELETE ACCOUNT FOREVER
                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, authState) {
                        final authCubit = context.read<AuthenticationCubit>();

                        return ListTile(
                          onTap: () async {
                            final navigator = Navigator.of(context);

                            // globalUserCubit
                            if (authState.authenticationStates ==
                                AuthenticationStates.deletingAccount) {
                              return;
                            }
                            await showDeleteConfirmationDialog(
                              context,
                              () async {
                                await authCubit.deleteAccount().then(
                                  (_) async {
                                    await navigator.pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (ctx) => const SignUpPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(
                            Icons.delete_rounded,
                            size: 24,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              // color: Colors.red.shade900,
                            ),
                          ),
                          trailing: authState.authenticationStates ==
                                  AuthenticationStates.deletingAccount
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.red.shade900,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: ColourPallette.grey,
                                ),
                        );
                      },
                    ),
                    // const SizedBox(height: 8),
                    
                    // LOG OUT
                    ListTile(
                      onTap: () async {
                        await context
                            .read<AuthenticationCubit>()
                            .signOut()
                            .then(
                          (value) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (ctx) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 0,
                      dense: true,
                      leading: const Icon(
                        Icons.logout,
                        size: 24,
                        color: ColourPallette.black,
                        textDirection: TextDirection.ltr,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: ColourPallette.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    await showDialog<Widget>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          backgroundColor: ColourPallette.white,
          shadowColor: ColourPallette.mystic,
          title: Row(
            children: [
              LottieBuilder.asset(
                MediaRes.errorANIMATION,
                height: 28,
                width: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete account forever."?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'All your data will be deleted forever.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the confirm callback
              },
              child: Text(
                'DELETE',
                style: TextStyle(
                  color: ColourPallette.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getDetailsWidget({
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  String _getDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateTime(DateTime date) {
    return '${date.hour}:${date.minute}:${date.second} , ${date.day}/${date.month}/${date.year}';
  }
}
