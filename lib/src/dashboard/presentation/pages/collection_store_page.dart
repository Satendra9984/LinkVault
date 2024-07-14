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
  @override
  void initState() {
    super.initState();
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

          final fetchCollectionV = state.collections[widget.collectionId];

          if (fetchCollectionV == null) {
            return Container();
          }

          return ValueListenableBuilder<CollectionFetchModel?>(
            valueListenable: state.collections[widget.collectionId]!,
            builder: (ctx, fetchCollection, _) {
              if (fetchCollection == null) {
                return Container();
              }

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
              // Logger.printLog(
              //   'Ui updated after fetching subcollection: ${fetchCollection.subCollectionFetchedIndex}, ${state.collections.keys}',
              // );
              final subCollections = <CollectionFetchModel>[];
              if (fetchCollection.subCollectionFetchedIndex >= 0 &&
                  fetchCollection.subCollectionFetchedIndex <
                      collection.subcollections.length) {
                for (int i = 0;
                    i <= fetchCollection.subCollectionFetchedIndex;
                    i++) {
                  final subCollId = collection.subcollections[i];
                  final subCollectionFetch = state.collections[subCollId];

                  if (subCollectionFetch == null) {
                    continue;
                  }

                  subCollections.add(subCollectionFetch.value);
                }
              }
              // Logger.printLog(subCollections.length.toString());

              final urlList = <UrlModel>[];

              for (final urlId in collection.urls) {
                // final url = state.collectionUrls[urlId];

                // if (url == null) continue;

                // urlList.add(url);
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
                body: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ListView(
                    children: [
                      const Text(
                        'Collections',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CollectionsListWidget(
                        subCollections: subCollections,
                        onAddFolderTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => AddCollectionPage(
                                parentCollection: collection,
                              ),
                            ),
                          );

                          // int start =
                          //     fetchCollection.subCollectionFetchedIndex + 1;

                          // int end = min(
                          //   fetchCollection.subCollectionFetchedIndex + 5,
                          //   collection.subcollections.length - 1,
                          // );

                          // Logger.printLog(
                          //   '${fetchCollection.subCollectionFetchedIndex}, start: $start, end: $end',
                          // );

                          // final subCollectionIds = <String>[];
                          // if (start > -1 &&
                          //     end < collection.subcollections.length &&
                          //     end >= start) {
                          //   subCollectionIds.addAll(
                          //     collection.subcollections.sublist(start, end),
                          //   );
                          // }

                          // collectionCubit.fetchMoreSubCollections(
                          //   collectionId: collection.id,
                          //   userId: globalUserCubit.state.globalUser!.id,
                          //   isRootCollection: widget.isRootCollection,
                          //   end: end,
                          //   subCollectionIds: subCollectionIds,
                          // );
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
                      const SizedBox(height: 32),
                      UrlsListWidget(
                        title: 'Urls',
                        urlList: urlList,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
