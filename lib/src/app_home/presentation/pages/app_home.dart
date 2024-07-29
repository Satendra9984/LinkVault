import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/pages/login_signup/login_page.dart';
import 'package:link_vault/src/dashboard/presentation/dashboard_home_page.dart';
import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              MediaRes.linkVaultLogoSVG,
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 16),
            const Text(
              'LinkVault',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        // padding: EdgeInsets.symmetric(horizontal: 8),
        children: [
          const SizedBox(height: 8),

          // Some Profile Details
          BlocBuilder<GlobalUserCubit, GlobalUserState>(
            builder: (context, state) {
              return ListTile(
                onTap: () {},
                leading: CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      ColourPallette.mountainMeadow.withOpacity(0.5),
                  child: SvgPicture.asset(
                    MediaRes.personSVG,
                  ),
                ),
                title: Text(
                  '${state.globalUser?.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '@${state.globalUser?.email}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await context.read<AuthenticationCubit>().signOut().then(
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
                  icon: const Icon(
                    Icons.logout,
                    // color: ColourPallette.mountainMeadow,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Dashboard
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const DashboardHomePage(),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.dashboard_rounded,
                    color: ColourPallette.mountainMeadow,
                    size: 24,
                  ),
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                // FAVOURITE COLLECTIONS STORE
                ListTile(
                  onTap: () {},
                  // leading: const Icon(
                  //   Icons.bookmark_rounded,
                  //   color: ColourPallette.mountainMeadow,
                  // ),
                  leading: SvgPicture.asset(
                    MediaRes.favouriteSVG,
                    height: 20,
                    width: 20,
                  ),
                  title: const Text(
                    'Favourite',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                // RECENT COLLECTIONS STORE
                ListTile(
                  onTap: () {},
                  // leading: const Icon(
                  //   Icons.restore_rounded,
                  //   color: ColourPallette.mountainMeadow,
                  // ),
                  leading: SvgPicture.asset(
                    MediaRes.recentSVG,
                    height: 20,
                    width: 20,
                  ),
                  title: const Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                // SEARCH COLLECTIONS/URLS STORE
                ListTile(
                  onTap: () {},
                  // leading: const Icon(
                  //   Icons.restore_rounded,
                  //   color: ColourPallette.mountainMeadow,
                  // ),
                  leading: SvgPicture.asset(
                    MediaRes.searchSVG,
                    height: 20,
                    width: 20,
                  ),
                  title: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                // SUPPORT US
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const SubscriptionPage(),
                      ),
                    );
                  },
                  // leading: const Icon(
                  //   Icons.support,
                  //   color: ColourPallette.mountainMeadow,
                  // ),
                  leading: SvgPicture.asset(
                    MediaRes.collaborateSVG,
                    height: 20,
                    width: 20,
                  ),
                  title: const Text(
                    'Support Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColourPallette.mountainMeadow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
