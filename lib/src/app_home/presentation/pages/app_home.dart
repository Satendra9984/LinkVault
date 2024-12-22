import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/webview_cubit/webviews_cubit.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_store_screen.dart';
import 'package:link_vault/src/favourites/presentation/pages/favourite_store_screen.dart';
import 'package:link_vault/src/profile/presentation/pages/profile_home.dart';
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

    _initializeWebViews();
  }

  void _initializeWebViews() {
    try {
      // INITIALIZING WEBVIEWS
      final globarUserId = context.read<GlobalUserCubit>().getGlobalUser()!.id;

      // FOR OPENING WEBAPPS
      context.read<WebviewsCubit>().createWebView(
            globarUserId,
          );

      // SEPECIFICALLY FOR RSSFEEDS    
      context.read<WebviewsCubit>().createWebView(
            globarUserId + RssFeed,
          );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final globalUser = context.read<GlobalUserCubit>().state.globalUser!.id;
    const sectionTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    final trailingIcon = Icon(
      Icons.arrow_forward_ios_rounded,
      color: ColourPallette.mountainMeadow.withOpacity(0.75),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: ColourPallette.white,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        splashFactory: NoSplash.splashFactory,
        primarySwatch: Colors.green, // Change to your desired primary color
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: CupertinoColors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 120,
          clipBehavior: Clip.none,
          backgroundColor: ColourPallette.mountainMeadow.withOpacity(0.1),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your All In One URLs Manager',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        body: Center(
          child: ListView(
            children: [
              // Some Profile Details
              BlocBuilder<GlobalUserCubit, GlobalUserState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      color: ColourPallette.mountainMeadow.withOpacity(0.1),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const ProfileHome(),
                          ),
                        );
                      },
                      contentPadding:
                          const EdgeInsets.only(left: 12 + 12, bottom: 8),

                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: ColourPallette.mountainMeadow,
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
                        '${state.globalUser?.email}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // trailing: IconButton(
                      //   onPressed: () async {
                      //     await context
                      //         .read<AuthenticationCubit>()
                      //         .signOut()
                      //         .then(
                      //       (value) {
                      //         Navigator.of(context).pushAndRemoveUntil(
                      //           MaterialPageRoute(
                      //             builder: (ctx) => const LoginPage(),
                      //           ),
                      //           (route) => false,
                      //         );
                      //       },
                      //     );
                      //   },
                      //   icon: const Icon(
                      //     Icons.logout_rounded,
                      //     color: ColourPallette.mountainMeadow,
                      //   ),
                      // ),
                      // trailing: trailingIcon,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // DASHBOARD WHERE ALL LINKS ARE STORED
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => CollectionStorePage(
                              collectionId: globalUser,
                              isRootCollection: true,
                              appBarLeadingIcon: const Icon(
                                Icons.apps_rounded,
                                color: ColourPallette.mountainMeadow,
                              ),
                            ),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // tileColor: ColourPallette.mountainMeadow.withOpacity(0.1),
                      leading: const Icon(
                        Icons.apps_rounded,
                        size: 24,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'Web-Apps',
                        style: sectionTextStyle,
                      ),
                      trailing: trailingIcon,
                    ),

                    // FAVOURITE COLLECTIONS STORE
                    // ListTile(
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (ctx) => FavouritesStorePage(
                    //           collectionId: '$globalUser$favourites',
                    //           isRootCollection: true,
                    //           appBarLeadingIcon: SvgPicture.asset(
                    //             MediaRes.favouriteSVG,
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   // tileColor: ColourPallette.mountainMeadow.withOpacity(0.1),
                    //   leading: SvgPicture.asset(
                    //     MediaRes.favouriteSVG,
                    //     height: 18,
                    //     width: 18,
                    //     color: ColourPallette.mountainMeadow,
                    //     // color: Colors.pink.shade600,
                    //   ),
                    //   title: const Text(
                    //     'Favourite',
                    //     style: sectionTextStyle,
                    //   ),
                    //   trailing: trailingIcon,
                    // ),

                    // BROWSE
                    ListTile(
                      onTap: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (ctx) => RecentsStorePage(
                        //       collectionId: '$globalUser$recents',
                        //       isRootCollection: true,
                        //       appBarLeadingIcon: SvgPicture.asset(
                        //         MediaRes.recentSVG,
                        //       ),
                        //     ),
                        //   ),
                        // );
                      },
                      leading: SvgPicture.asset(
                        MediaRes.networkSVG,
                        height: 24,
                        width: 24,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'Browse',
                        style: sectionTextStyle,
                      ),
                      // trailing: const Icon(
                      //   Icons.arrow_forward_ios_rounded,
                      //   color: ColourPallette.black,
                      // ),
                      trailing: SvgPicture.asset(
                        MediaRes.comingSoonSVG,
                        height: 16,
                        width: 16,
                        color: ColourPallette.mountainMeadow,
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
                      leading: const Icon(
                        Icons.rss_feed_rounded,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'My Feed',
                        style: sectionTextStyle,
                      ),
                      trailing: trailingIcon,
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
                      leading: const Icon(
                        Icons.filter_alt_rounded,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'Search',
                        style: sectionTextStyle,
                      ),
                      trailing: trailingIcon,
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
                      leading: const Icon(
                        Icons.person_3_rounded,
                        color: ColourPallette.mountainMeadow,
                        size: 24,
                      ),
                      title: const Text(
                        'Profile',
                        style: sectionTextStyle,
                      ),
                      trailing: trailingIcon,
                    ),

                    // GLOBAL SETTINGS
                    ListTile(
                      onTap: () {
                        // Navigator.of(context).push(
                        // MaterialPageRoute(
                        //   builder: (ctx) => RecentsStorePage(
                        //     collectionId: '$globalUser$recents',
                        //     isRootCollection: true,
                        //     appBarLeadingIcon: SvgPicture.asset(
                        //       MediaRes.recentSVG,
                        //     ),
                        //   ),
                        // ),
                        // );
                      },
                      leading: const Icon(
                        Icons.settings_rounded,
                        size: 24,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'Settings',
                        style: sectionTextStyle,
                      ),
                      // trailing: const Icon(
                      //   Icons.arrow_forward_ios_rounded,
                      //   color: ColourPallette.black,
                      // ),
                      trailing: SvgPicture.asset(
                        MediaRes.comingSoonSVG,
                        height: 16,
                        width: 16,
                        color: ColourPallette.mountainMeadow,
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
                      leading: const Icon(
                        Icons.support_rounded,
                        size: 24,
                        color: ColourPallette.mountainMeadow,
                      ),
                      title: const Text(
                        'Support Us',
                        style: sectionTextStyle,
                      ),
                      trailing: trailingIcon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
