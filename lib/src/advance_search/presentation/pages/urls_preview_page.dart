// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchedUrlsPreviewListWidget extends StatefulWidget {
  const SearchedUrlsPreviewListWidget({
    super.key,
  });

  @override
  State<SearchedUrlsPreviewListWidget> createState() =>
      _SearchedUrlsPreviewListWidgetState();
}

class _SearchedUrlsPreviewListWidgetState
    extends State<SearchedUrlsPreviewListWidget>
    with AutomaticKeepAliveClientMixin {
  final _showAppBar = ValueNotifier(true);
  // var _previousOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  void _onScroll() {
    // if (_scrollController.offset > _previousOffset) {
    //   _showAppBar.value = false;
    //   widget.showBottomBar.value = false;
    // } else if (_scrollController.offset < _previousOffset) {
    //   _showAppBar.value = true;
    //   widget.showBottomBar.value = true;
    // }
    // _previousOffset = _scrollController.offset;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    // final fetchCollection = widget.collectionFetchModel;

    context.read<AdvanceSearchCubit>().searchLocalDatabaseURLs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showAppBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              MediaRes.searchSVG,
              height: 18,
              width: 18,
            ),
            const SizedBox(width: 12),
            const Text(
              'Advance Search',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AdvanceSearchCubit>().searchDB();
            },
            icon: const Icon(
              Icons.filter_list,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
        child: BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls = state.urls;

            // if (availableUrls == null) {
            //   _fetchMoreUrls();
            // }

            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  if (availableUrls.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        MediaRes.webSurf3SVG,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableUrls.length,
                      itemBuilder: (ctx, index) {
                        final url = availableUrls[index];

                        final urlMetaData = url.metaData ??
                            UrlMetaData.isEmpty(
                              title: url.title,
                            );

                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: UrlPreviewWidget(
                                urlMetaData: urlMetaData,
                                onTap: () async {
                                  final uri = Uri.parse(url.url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                                onLongPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => UpdateUrlPage(
                                        urlModel: url,
                                      ),
                                    ),
                                  );
                                },
                                onShareButtonTap: () {
                                  Share.share(
                                    '${url.url}\n${urlMetaData.title}\n${urlMetaData.description}',
                                  );
                                },
                                onMoreVertButtontap: () {},
                              ),
                            ),
                            // const SizedBox(height: 4),
                            Divider(
                              color: Colors.grey.shade200,
                            ),
                            // const SizedBox(height: 4),
                          ],
                        );
                      },
                    ),

                  // BOTTOM HEIGHT SO THAT ALL CONTENT IS VISIBLE
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
