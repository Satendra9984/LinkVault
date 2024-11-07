import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/auth/presentation/cubit/authentication/authentication_cubit.dart';
import 'package:link_vault/src/auth/presentation/pages/login_signup/login_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_store_screen.dart';
import 'package:link_vault/src/favourites/presentation/pages/favourite_store_screen.dart';
import 'package:link_vault/src/profile/presentation/pages/profile_home.dart';
import 'package:link_vault/src/recents/presentation/pages/recents_store_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/rss_feed_store_screen.dart';
import 'package:link_vault/src/search/presentation/pages/adv_search_store_page.dart';
import 'package:link_vault/src/subsciption/presentation/pages/subscription_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ReceiveSharingIntent.instance.getMediaStream().listen(
          context.read<SharedInputsCubit>().addInputFiles,
          onError: (err) {
            // debugPrint('getMediaStream error: $err');
          },
        );

        // For sharing images coming from outside the app while the app is closed
        ReceiveSharingIntent.instance.getInitialMedia().then(
              context.read<SharedInputsCubit>().addInputFiles,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = context.read<GlobalUserCubit>().state.globalUser!.id;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: ColourPallette.white,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 128,
          title: Column(
            children: [
              SvgPicture.asset(
                MediaRes.linkVaultLogoSVG,
                height: 60,
                width: 60,
              ),
              // const SizedBox(width: 16),
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
          children: [
            // Some Profile Details
            BlocBuilder<GlobalUserCubit, GlobalUserState>(
              builder: (context, state) {
                return ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    radius: 28,
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
                          builder: (ctx) => CollectionStorePage(
                            collectionId: globalUser,
                            isRootCollection: true,
                            appBarLeadingIcon: const Icon(
                              Icons.dashboard_rounded,
                              color: ColourPallette.mountainMeadow,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: const Icon(
                      Icons.dashboard_rounded,
                      color: ColourPallette.mountainMeadow,
                      size: 20,
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
                      color: ColourPallette.darkTeal,
                    ),
                  ),

                  // FAVOURITE COLLECTIONS STORE
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => FavouriteFolderCollectionPage(
                            collectionId: '$globalUser$favourites',
                            isRootCollection: true,
                            appBarLeadingIcon: SvgPicture.asset(
                              MediaRes.favouriteSVG,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: SvgPicture.asset(
                      MediaRes.favouriteSVG,
                      height: 18,
                      width: 18,
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
                      color: ColourPallette.darkTeal,
                    ),
                  ),

                  // RECENTS
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => RecentsStorePage(
                            collectionId: '$globalUser$recents',
                            isRootCollection: true,
                            appBarLeadingIcon: SvgPicture.asset(
                              MediaRes.recentSVG,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: SvgPicture.asset(
                      MediaRes.recentSVG,
                      height: 20,
                      width: 20,
                    ),
                    title: const Text(
                      'Recents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ColourPallette.darkTeal,
                    ),
                  ),

                  // SEARCH COLLECTIONS/URLS STORE
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AdvanceSearchPage(),
                        ),
                      );
                    },
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
                      color: ColourPallette.darkTeal,
                    ),
                  ),

                  // MY FEEDS
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => RssFeedCollectionStorePage(
                            collectionId: '$globalUser$RssFeed',
                            isRootCollection: true,
                            appBarLeadingIcon: SvgPicture.asset(
                              MediaRes.compassSVG,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: SvgPicture.asset(
                      MediaRes.compassSVG,
                      height: 20,
                      width: 20,
                    ),
                    title: const Text(
                      'My Feeds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ColourPallette.darkTeal,
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
                      color: ColourPallette.darkTeal,
                    ),
                  ),

                  // PROFILE
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ProfileHome(),
                        ),
                      );
                    },
                    leading: SvgPicture.asset(
                      MediaRes.personSVG,
                      height: 24,
                      width: 24,
                    ),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ColourPallette.darkTeal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
