import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/url_preview_type.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_favicon_widget.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';

class UrlsListWidget extends StatefulWidget {
  UrlsListWidget({
    required this.title,
    required this.collectionFetchModelNotifier,
    required this.onAddUrlTap,
    required this.onUrlTap,
    required this.onUrlDoubleTap,
    // required this.scrollController,
    super.key,
  });

  final String title;
  // final ScrollController scrollController;
  final ValueNotifier<CollectionFetchModel> collectionFetchModelNotifier;
  final void Function() onAddUrlTap;
  final void Function(UrlModel url) onUrlTap;
  final void Function(UrlModel url) onUrlDoubleTap;

  @override
  State<UrlsListWidget> createState() => _UrlsListWidgetState();
}

class _UrlsListWidgetState extends State<UrlsListWidget> {
  // final _urlPreviewType = ValueNotifier(UrlPreviewType.icons);
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController = ScrollController()..addListener(_onScroll);
      _fetchMoreUrls();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // Logger.printLog('[scroll] Called on scroll in urlslist');
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    final fetchCollection = widget.collectionFetchModelNotifier.value;

    if (fetchCollection.urlFetchMoreState == LoadingStates.loading) {
      return;
    }

    final start = fetchCollection.urlList.length;
    const fetchMore = 20;
    var end = start + fetchMore;

    if (fetchCollection.collection != null &&
        fetchCollection.collection!.urls.isNotEmpty) {
      end = min(end, fetchCollection.collection!.urls.length);
    } else if (fetchCollection.collection != null &&
        fetchCollection.collection!.urls.isEmpty) {
      end = 0;
    } else {
      end = 0;
    }

    Logger.printLog(
      '${fetchCollection.collection?.urls.length}, start: $start, end: $end',
    );

    final urlIds = <String>[];
    if (start > -1 && end > start) {
      urlIds.addAll(
        fetchCollection.collection!.urls.sublist(start, end),
      );
    }

    context.read<CollectionsCubit>().fetchMoreUrls(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          end: end,
          urlIds: urlIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColourPallette.salemgreen,
        onPressed: widget.onAddUrlTap,
        label: const Text(
          'Add URL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColourPallette.white,
          ),
        ),
        icon: const Icon(
          Icons.add_link_rounded,
          color: ColourPallette.white,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // margin: const EdgeInsets.only(bottom: 120),
        child: _previewIconsWidget(context),
      ),
    );
  }

  Widget _previewIconsWidget(BuildContext context) {
    const collectionIconWidth = 80.0;
    final availableUrls = widget.collectionFetchModelNotifier.value.urlList;

    // if (widget.collectionFetchModelNotifier.value.urlFetchMoreState ==
    //     LoadingStates.loading) {
    //   return Center(
    //     child: Container(
    //       padding: EdgeInsets.all(8),
    //       height: 56,
    //       width: 56,
    //       child: const CircularProgressIndicator(
    //         backgroundColor: ColourPallette.grey,
    //       ),
    //     ),
    //   );
    // }

    final collection = widget.collectionFetchModelNotifier.value.collection;

    if (collection != null && collection.urls.isEmpty) {
      return Center(
        child: SvgPicture.asset(
          'assets/images/web_surf_1.svg',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.topLeft,
      child: AlignedGridView.extent(
        // controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: availableUrls.length,
        maxCrossAxisExtent: collectionIconWidth,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          final url = availableUrls[index];

          if (url.loadingStates == LoadingStates.loading) {
            return const Center(
              child: SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(
                  backgroundColor: ColourPallette.grey,
                  color: ColourPallette.white,
                ),
              ),
            );
          } else if (url.loadingStates == LoadingStates.errorLoading) {
            return SizedBox(
              height: 56,
              width: 56,
              child: IconButton(
                onPressed: _fetchMoreUrls,
                icon: const Icon(
                  Icons.restore,
                  color: ColourPallette.black,
                ),
              ),
            );
          }

          return UrlFaviconLogoWidget(
            onPress: () => widget.onUrlTap(url.urlModel!),
            onDoubleTap: (urlMetaData) => widget.onUrlDoubleTap(
              url.urlModel!.copyWith(
                metaData: urlMetaData,
              ),
            ),
            urlModelData: url.urlModel!,
          );
        },
      ),
    );
  }
}
