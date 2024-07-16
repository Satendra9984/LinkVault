import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/data/enums/collection_loading_states.dart';
import 'package:link_vault/src/dashboard/presentation/pages/add_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/add_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/update_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/update_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/collections_list_widget.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/urls_list_widget.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/urls_preview_list.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderCollectionPage extends StatefulWidget {
  const FolderCollectionPage(
      {required this.collectionId, required this.isRootCollection, super.key});
  final String collectionId;
  final bool isRootCollection;

  @override
  State<FolderCollectionPage> createState() => _FolderCollectionPageState();
}

class _FolderCollectionPageState extends State<FolderCollectionPage> {
  late final ScrollController scrollController;
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    context.read<CollectionsCubit>().fetchCollection(
          collectionId: widget.collectionId,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourPallette.white,
      body: BlocConsumer<CollectionsCubit, CollectionsState>(
        listener: (context, state) {
          // [TODO]: implement listener
        },
        builder: (context, state) {
          // final size = MediaQuery.of(context).size;
          final collectionCubit = context.read<CollectionsCubit>();
          final globalUserCubit = context.read<GlobalUserCubit>();

          final fetchCollection = state.collections[widget.collectionId];

          if (fetchCollection == null) {
            return Container();
          }

          

              Logger.printLog('Updated collection store page');

              if (fetchCollection.collectionFetchingState ==
                  LoadingStates.loading) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: ColourPallette.white,
                  ),
                  body: Center(
                    child: Column(
                      children: [
                        LottieBuilder.asset(
                          MediaRes.loadingANIMATION,
                        ),
                        const Text(
                          'Loading Collection...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (fetchCollection.collectionFetchingState ==
                  LoadingStates.errorLoading) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: ColourPallette.white,
                  ),
                  body: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LottieBuilder.asset(
                          MediaRes.errorANIMATION,
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Oops !!!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Something went wrong while fetching the collection from the database.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomElevatedButton(
                          text: 'Try Again',
                          onPressed: () => collectionCubit.fetchCollection(
                            collectionId: widget.collectionId,
                            userId: globalUserCubit.state.globalUser!.id,
                            isRootCollection: widget.isRootCollection,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final collection = fetchCollection.collection;
              // Logger.printLog(
              //     StringUtils.getJsonFormat(collection.toJson().toString()));
              if (collection == null) {
                return Container();
              }

              return Scaffold(
                backgroundColor: ColourPallette.white,
                appBar: AppBar(
                  backgroundColor: ColourPallette.white,
                  surfaceTintColor: ColourPallette.mystic,
                  title: Text(
                    collection.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: ColourPallette.mystic.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 16,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _currentPage,
                    builder: (context, currentPage, _) {
                      return BottomNavigationBar(
                        currentIndex: _currentPage.value,
                        onTap: (currentIndex) {
                          _currentPage.value = currentIndex;
                          _pageController.jumpToPage(currentIndex);
                        },
                        enableFeedback: false,
                        backgroundColor: ColourPallette.white,
                        elevation: 0,
                        selectedItemColor: ColourPallette.black,
                        selectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        unselectedItemColor: ColourPallette.black,
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColourPallette.black,
                        ),
                        items: [
                          _bottomNavBarWidget(
                            label: 'Urls',
                            unSelectedIcon: Icons.link_outlined,
                            selectedIcon: Icons.link_rounded,
                            index: 0,
                          ),
                          _bottomNavBarWidget(
                            label: 'Collections',
                            unSelectedIcon: Icons.collections_bookmark_outlined,
                            selectedIcon: Icons.collections_bookmark_rounded,
                            index: 1,
                          ),
                          _bottomNavBarWidget(
                            unSelectedIcon: Icons.preview_outlined,
                            selectedIcon: Icons.preview_rounded,
                            index: 2,
                            label: 'Previews',
                          ),
                        ],
                      );
                    },
                  ),
                ),
                body: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    _currentPage.value = page;
                  },
                  children: [
                    UrlsListWidget(
                      // scrollController: scrollController,
                      title: 'Urls',
                      collectionFetchModelNotifier:
                          state.collections[widget.collectionId]!,
                      onAddUrlTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AddUrlPage(
                              parentCollection: collection,
                            ),
                          ),
                        );
                      },
                      onUrlTap: (url) async {
                        final uri = Uri.parse(url.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      onUrlDoubleTap: (url) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => UpdateUrlPage(
                              urlModel: url,
                            ),
                          ),
                        );
                      },
                    ),
                    CollectionsListWidget(
                      collectionFetchModelNotifier:
                          state.collections[widget.collectionId]!,
                      onAddFolderTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AddCollectionPage(
                              parentCollection: collection,
                            ),
                          ),
                        );
                      },
                      onFolderTap: (subCollection) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => FolderCollectionPage(
                              collectionId: subCollection.id,
                              isRootCollection: false,
                            ),
                          ),
                        );
                      },
                      onFolderDoubleTap: (subCollection) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => UpdateCollectionPage(
                              collection: subCollection,
                            ),
                          ),
                        );
                      },
                    ),
                    UrlsPreviewListWidget(
                      scrollController: scrollController,
                      title: 'Urls',
                      collectionFetchModelNotifier:
                          state.collections[widget.collectionId]!,
                      onAddUrlTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AddUrlPage(
                              parentCollection: collection,
                            ),
                          ),
                        );
                      },
                      onUrlTap: (url) async {
                        final uri = Uri.parse(url.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      onUrlDoubleTap: (url) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => UpdateUrlPage(
                              urlModel: url,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
          
          
        },
      ),
    );
  }

  BottomNavigationBarItem _bottomNavBarWidget({
    required int index,
    required IconData unSelectedIcon,
    required IconData selectedIcon,
    required String label,
  }) {
    final selected = _currentPage.value == index;
    return BottomNavigationBarItem(
      icon: Icon(
        unSelectedIcon,
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          // shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          color: selected ? ColourPallette.salemgreen.withOpacity(0.4) : null,
        ),
        child: Icon(
          selectedIcon,
          size: 24,
          color: ColourPallette.black,
        ),
      ),
      label: label,
    );
  }
}
