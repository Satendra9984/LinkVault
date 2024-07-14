import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    required this.scrollController,
    super.key,
  });

  final String title;
  final ScrollController scrollController;
  final ValueNotifier<CollectionFetchModel> collectionFetchModelNotifier;
  final void Function() onAddUrlTap;
  final void Function(UrlModel url) onUrlTap;
  final void Function(UrlModel url) onUrlDoubleTap;

  @override
  State<UrlsListWidget> createState() => _UrlsListWidgetState();
}

class _UrlsListWidgetState extends State<UrlsListWidget> {
  final _urlPreviewType = ValueNotifier(UrlPreviewType.icons);
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController..addListener(_onScroll);
    _fetchMoreUrls();
  }

  void _onScroll() {
    // Logger.printLog(
    //   '[scroll] pixels: ${_scrollController.position.pixels}, maxExtent: ${_scrollController.position.maxScrollExtent}',
    // );

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
    final fetchMore = _urlPreviewType.value == UrlPreviewType.icons ? 20 : 5;
    final end = min(
      fetchCollection.urlList.length - 1 + fetchMore,
      fetchCollection.collection!.urls.length - 1,
    );

    Logger.printLog(
      '${fetchCollection.collection?.urls.length}, start: $start, end: $end',
    );

    final urlIds = <String>[];
    if (start > -1 && end >= start) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Urls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuButton<UrlPreviewType>(
              color: ColourPallette.white,
              surfaceTintColor: ColourPallette.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: ColourPallette.mountainMeadow,
                  width: 1.1,
                ),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: Colors.grey.shade900,
              ),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: UrlPreviewType.icons,
                    child: Text(
                      'Logos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: UrlPreviewType.previewMeta,
                    child: Text(
                      'Previews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                _urlPreviewType.value = value;
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder(
          valueListenable: _urlPreviewType,
          builder: (context, urlPreviewType, _) {
            if (urlPreviewType == UrlPreviewType.previewMeta) {
              return _previewMetaWidget(context);
            }

            return _previewIconsWidget(context);
          },
        ),
      ],
    );
  }

  Widget _previewMetaWidget(BuildContext context) {
    final availableUrls = widget.collectionFetchModelNotifier.value.urlList;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: availableUrls.length,
        itemBuilder: (ctx, index) {
          final url = availableUrls[index];

          if (url.loadingStates == LoadingStates.loading) {
            return const SizedBox(
              height: 56,
              width: 56,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: ColourPallette.black,
                ),
              ),
            );
          } else if (url.loadingStates == LoadingStates.errorLoading) {
            return IconButton(
              onPressed: _fetchMoreUrls,
              icon: const Icon(
                Icons.restore,
                color: ColourPallette.black,
              ),
            );
          }
          final urlMetaData = url.urlModel!.metaData ??
              UrlMetaData.isEmpty(
                title: url.urlModel!.title,
              );

          return Column(
            children: [
              UrlPreviewWidget(
                urlMetaData: urlMetaData,
                onTap: () => widget.onUrlTap(url.urlModel!),
                onDoubleTap: () => widget.onUrlDoubleTap(url.urlModel!),
                onShareButtonTap: () {},
                onMoreVertButtontap: () {},
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _previewIconsWidget(BuildContext context) {
    const collectionIconWidth = 80.0;
    final availableUrls = widget.collectionFetchModelNotifier.value.urlList;

    if (widget.collectionFetchModelNotifier.value.urlFetchMoreState ==
        LoadingStates.loading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(8),
          height: 56,
          width: 56,
          child: const CircularProgressIndicator(
            backgroundColor: ColourPallette.grey,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: AlignedGridView.extent(
        // controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: availableUrls.length + 1,
        maxCrossAxisExtent: collectionIconWidth,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: widget.onAddUrlTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                // color: Colors.amber,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_link_rounded,
                      size: 38,
                      color: Colors.grey.shade800,
                    ),
                  ],
                ),
              ),
            );
          }

          index = index - 1;
          final url = availableUrls[index];

          if (url.loadingStates == LoadingStates.loading) {
            return Container(
              padding: EdgeInsets.all(8),
              height: 56,
              width: 56,
              child: const CircularProgressIndicator(
                backgroundColor: ColourPallette.grey,
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
            onDoubleTap: () => widget.onUrlDoubleTap(url.urlModel!),
            urlModelData: url.urlModel!,
          );
        },
      ),
    );
  }
}
