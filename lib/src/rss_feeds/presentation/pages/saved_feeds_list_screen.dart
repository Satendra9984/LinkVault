// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/src/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/src/common/presentation_layer/pages/url_preview_list_template_screen.dart';
import 'package:link_vault/src/common/presentation_layer/providers/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/bottom_sheet_option_widget.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/src/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/src/common/repository_layer/models/url_fetch_model.dart';
import 'package:link_vault/src/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:lottie/lottie.dart';

class SavedFeedsPreviewListScreen extends StatefulWidget {
  const SavedFeedsPreviewListScreen({
    required this.showBottomBar,
    required this.isRootCollection,
    required this.collectionId,
    required this.appBarLeadingIcon,
    super.key,
  });

  final ValueNotifier<bool> showBottomBar;
  final bool isRootCollection;
  final String collectionId;
  final Widget appBarLeadingIcon;

  @override
  State<SavedFeedsPreviewListScreen> createState() =>
      _SavedFeedsPreviewListScreenState();
}

class _SavedFeedsPreviewListScreenState
    extends State<SavedFeedsPreviewListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    context.read<CollectionsCubit>().fetchCollection(
          collectionId: widget.collectionId,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: widget.isRootCollection,
          collectionName: 'My Feeds',
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<CollectionsCubit, CollectionsState>(
      listener: (ctx, state) {},
      builder: (context, state) {
        // final size = MediaQuery.of(context).size;
        final collectionCubit = context.read<CollectionsCubit>();
        final globalUserCubit = context.read<GlobalUserCubit>();

        final fetchCollection = state.collections[widget.collectionId];

        if (fetchCollection == null) {
          collectionCubit.fetchCollection(
            collectionId: widget.collectionId,
            userId: globalUserCubit.state.globalUser!.id,
            isRootCollection: widget.isRootCollection,
            collectionName: 'My Feeds',
          );
        }

        if (fetchCollection == null ||
            fetchCollection.collectionFetchingState == LoadingStates.loading) {
          return _showLoadingWidget();
        }

        if (fetchCollection.collectionFetchingState ==
                LoadingStates.errorLoading ||
            fetchCollection.collection == null) {
          return _showErrorLoadingWidget(
            () => collectionCubit.fetchCollection(
              collectionId: widget.collectionId,
              userId: globalUserCubit.state.globalUser!.id,
              isRootCollection: widget.isRootCollection,
              collectionName: 'My Feeds',
            ),
          );
        }

        return UrlPreviewListTemplateScreen(
          isRootCollection: widget.isRootCollection,
          collectionModel: fetchCollection.collection!,
          showAddUrlButton: false,
          onAddUrlPressed: ({String? url}) {},
          onLongPress: (
            urlModel, {
            required List<Widget> urlOptions,
          }) async {
            await showUrlOptionsBottomSheet(
              context,
              urlModel: urlModel,
              urlOptions: urlOptions,
            );
          },
          urlsEmptyWidget: _urlsEmptyWidget(),
          showBottomNavBar: widget.showBottomBar,
          appBar: ({
            required ValueNotifier<List<ValueNotifier<UrlFetchStateModel>>>
                list,
            required List<Widget> actions,
          }) {
            return AppBar(
              clipBehavior: Clip.none,
              surfaceTintColor: ColourPallette.mystic,
              title: Row(
                children: [
                  // SizedBox(
                  //   height: 20,
                  //   width: 20,
                  //   child: widget.appBarLeadingIcon,
                  // ),
                  // const SizedBox(width: 8),
                  Text(
                    fetchCollection.collection!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                ...actions,
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showUrlOptionsBottomSheet(
    BuildContext context, {
    required UrlModel urlModel,
    required List<Widget> urlOptions,
  }) async {
    final size = MediaQuery.of(context).size;
    const titleTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    onPop() async {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      Navigator.pop(context);
    }

    final showLastUpdated = ValueNotifier(false);
    urlOptions
      ..insert(
        0,
        // UPDATE URL
        BottomSheetOption(
          leadingIcon: Icons.replay_circle_filled_outlined,
          title: const Text('Update', style: titleTextStyle),
          trailing: ValueListenableBuilder(
            valueListenable: showLastUpdated,
            builder: (ctx, showLastUpdatedVal, _) {
              if (!showLastUpdatedVal) {
                return GestureDetector(
                  onTap: () => showLastUpdated.value = !showLastUpdated.value,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                  ),
                );
              }

              final updatedAt = urlModel.updatedAt;
              // Format to get hour with am/pm notation
              final formattedTime = DateFormat('h:mma').format(updatedAt);
              // Combine with the date
              final lastSynced =
                  'Last ($formattedTime, ${updatedAt.day}/${updatedAt.month}/${updatedAt.year})';

              return GestureDetector(
                onTap: () => showLastUpdated.value = !showLastUpdated.value,
                child: Text(
                  lastSynced,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColourPallette.salemgreen.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => UpdateUrlTemplateScreen(
                  urlModel: urlModel,
                  isRootCollection: widget.isRootCollection,
                  onDeleteURLCallback: (urlModel) async {
                    final cubit = context.read<RssFeedCubit>();

                    var collectionId =
                        'hzx1SlJoeyRcnEvTx0U1OdkXMEQ2Rss_Feedsaved_feeds';

                    // Check if the string contains 'saved_feeds'
                    if (collectionId.contains('saved_feeds')) {
                      // Remove 'saved_feeds' from the string
                      collectionId = collectionId.replaceAll('saved_feeds', '');
                    }

                    final forRssFeedUpdate = urlModel.copyWith(
                      isOffline: false,
                      collectionId: collectionId,
                    );

                    await cubit.updateRSSFeed(feedUrlModel: forRssFeedUpdate);
                  },
                ),
              ),
            ).then(
              (_) {
                Navigator.pop(context);
              },
            );
          },
        ),
      )
      ..insert(
        2,
        // ADD TO FAVOURITES
        BottomSheetOption(
          leadingIcon: Icons.bookmark_add_rounded,
          title: const Text('Favourites', style: titleTextStyle),
          trailing: Builder(
            builder: (ctx) {
              if (urlModel.isFavourite == false) {
                return const SizedBox.shrink();
              }

              return Icon(
                Icons.check_circle_rounded,
                color: ColourPallette.salemgreen.withOpacity(0.5),
              );
            },
          ),
          onTap: () async {
            // if (urlModel.isFavourite) return;

            final urlCrudCubit = context.read<UrlCrudCubit>();
            final globalUser =
                context.read<GlobalUserCubit>().getGlobalUser()!.id;

            await Future.wait(
              [
                urlCrudCubit.addUrl(
                  isRootCollection: true,
                  urlData: urlModel.copyWith(
                    parentUrlModelFirestoreId: urlModel.firestoreId,
                    collectionId: '$globalUser$favourites',
                    isFavourite: true,
                  ),
                ),
                urlCrudCubit.updateUrl(
                  urlData: urlModel.copyWith(
                    isFavourite: true,
                  ),
                ),
                Future(() => Navigator.pop(context)),
              ],
            );
          },
        ),
      );
    await showModalBottomSheet<Widget>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints.loose(
        Size(size.width, size.height * 0.45),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            const EdgeInsets.only(top: 20, bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: ColourPallette.mystic.withOpacity(0.25),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final urlModelData = urlModel;
                          final urlMetaData = urlModel.metaData!;

                          var name = '';

                          if (urlModelData.title.isNotEmpty) {
                            name = urlModelData.title;
                          } else if (urlMetaData.title != null &&
                              urlMetaData.title!.isNotEmpty) {
                            name = urlMetaData.title!;
                          } else if (urlMetaData.websiteName != null &&
                              urlMetaData.websiteName!.isNotEmpty) {
                            name = urlMetaData.websiteName!;
                          }

                          final placeHolder = Container(
                            padding: const EdgeInsets.all(2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: ColourPallette.black,
                              // color: Colors.deepPurple
                            ),
                            child: Text(
                              _websiteName(name, 5),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                color: ColourPallette.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                              ),
                            ),
                          );

                          if (urlModel.metaData?.faviconUrl == null) {
                            return placeHolder;
                          }
                          final metaData = urlModel.metaData;

                          if (metaData?.faviconUrl != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: NetworkImageBuilderWidget(
                                    imageUrl: urlMetaData.faviconUrl!,
                                    compressImage: false,
                                    errorWidgetBuilder: () {
                                      return placeHolder;
                                    },
                                    successWidgetBuilder: (imageData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Builder(
                                          builder: (ctx) {
                                            final memoryImage = Image.memory(
                                              imageData.imageBytesData!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (ctx, _, __) {
                                                return placeHolder;
                                              },
                                            );
                                            // Check if the URL ends with ".svg" to use SvgPicture or Image accordingly
                                            if (urlMetaData.faviconUrl!
                                                .toLowerCase()
                                                .endsWith('.svg')) {
                                              // Try loading the SVG and handle errors
                                              return FutureBuilder(
                                                future: _loadSvgBytes(
                                                  imageData.imageBytesData!,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return memoryImage;
                                                  } else {
                                                    return snapshot.data!;
                                                  }
                                                },
                                              );
                                            } else {
                                              return memoryImage;
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return placeHolder;
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        StringUtils.capitalizeEachWord(
                          urlModel.metaData?.websiteName ??
                              urlModel.metaData?.title ??
                              urlModel.title,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ...urlOptions,

              // DELETE URL
              BottomSheetOption(
                leadingIcon: Icons.delete_rounded,
                title: const Text('Delete', style: titleTextStyle),
                onTap: () async {
                  final urlcrudcubit = context.read<UrlCrudCubit>();
                  final cubit = context.read<RssFeedCubit>();
                  final navigator = Navigator.of(context);

                  await showDeleteConfirmationDialog(context, urlModel,
                      () async {
                    await urlcrudcubit.deleteUrl(
                      urlData: urlModel,
                      isRootCollection: widget.isRootCollection,
                    );

                    var collectionId =
                        'hzx1SlJoeyRcnEvTx0U1OdkXMEQ2Rss_Feedsaved_feeds';

                    // Check if the string contains 'saved_feeds'
                    if (collectionId.contains('saved_feeds')) {
                      // Remove 'saved_feeds' from the string
                      collectionId = collectionId.replaceAll('saved_feeds', '');
                    }

                    final forRssFeedUpdate = urlModel.copyWith(
                      isOffline: false,
                      collectionId: collectionId,
                    );

                    await cubit.updateRSSFeed(feedUrlModel: forRssFeedUpdate);
                  }).then(
                    (_) {
                      navigator.maybePop();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(
      () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(
    BuildContext context,
    UrlModel urlModel,
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
              const Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${urlModel.title}"?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _urlsEmptyWidget() {
    return Center(
      child: SvgPicture.asset(
        MediaRes.webSurf3SVG,
      ),
    );
  }

  Widget _showErrorLoadingWidget(
    void Function() onPress,
  ) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              'Something went wrong while fetching the collection from server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              text: 'Try Again',
              onPressed: () => onPress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showLoadingWidget() {
    return Scaffold(
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

  Future<Widget> _loadSvgBytes(Uint8List svgImageBytes) async {
    try {
      return SvgPicture.memory(
        svgImageBytes,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  String _websiteName(String websiteName, int allowedLength) {
    // Logger.printLog('WebsiteName: $websiteName');
    if (websiteName.length < allowedLength) {
      return websiteName;
    }

    final spaced = websiteName.trim().split(' ');
    final initials = StringBuffer();

    for (final ele in spaced) {
      if (ele.isNotEmpty) {
        initials.write(ele[0]);
      }
    }

    return initials.toString();
  }

  @override
  bool get wantKeepAlive => true;
}
