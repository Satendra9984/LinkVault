import 'dart:math';

import 'package:flutter/material.dart';
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

class UrlsPreviewListWidget extends StatefulWidget {
  UrlsPreviewListWidget({
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
  State<UrlsPreviewListWidget> createState() => _UrlsPreviewListWidgetState();
}

class _UrlsPreviewListWidgetState extends State<UrlsPreviewListWidget> {
  // final _urlPreviewType = ValueNotifier(UrlPreviewType.previewMeta);
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMoreUrls();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    final fetchCollection = widget.collectionFetchModelNotifier.value;

    if (fetchCollection.urlFetchMoreState == LoadingStates.loading) {
      return;
    }

    final start = fetchCollection.urlList.length;
    const fetchMore = 5;
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

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _previewMetaWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewMetaWidget(BuildContext context) {
    final availableUrls = widget.collectionFetchModelNotifier.value.urlList;

    final collection = widget.collectionFetchModelNotifier.value.collection;

    if (collection != null && collection.urls.isEmpty) {
      return Center(
        child: SvgPicture.asset(
          'assets/images/web_surf_3.svg',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.topLeft,
      child: ListView.builder(
        shrinkWrap: true,
        // physics: const BScrollableScrollPhysics(),
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
}
