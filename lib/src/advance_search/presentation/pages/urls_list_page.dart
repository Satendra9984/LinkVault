import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_url_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchedUrlsListWidget extends StatefulWidget {
  const SearchedUrlsListWidget({
    required this.title,
    required this.showAddCollectionButton,
    super.key,
  });

  final String title;
  final bool showAddCollectionButton;

  @override
  State<SearchedUrlsListWidget> createState() => _SearchedUrlsListWidgetState();
}

class _SearchedUrlsListWidgetState extends State<SearchedUrlsListWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // Logger.printLog('[scroll] Called on scroll in urlslist');
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    // final fetchCollection = widget.collectionFetchModel;

    // context.read<CollectionsCubit>().fetchMoreUrls(
    //       collectionId: fetchCollection.collection!.id,
    //       userId: context.read<GlobalUserCubit>().state.globalUser!.id,
    //     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls = state.urls;

            // if (availableUrls == null) {
            //   _fetchMoreUrls();
            // }

            // return Center(
            //   child: SvgPicture.asset(
            //     // MediaRes.webSurf1SVG,
            //     MediaRes.pageUnderConstructionSVG,
            //   ),
            // );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              controller: _scrollController,
              child: Column(
                children: [
                  if (availableUrls == null || availableUrls.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        // MediaRes.webSurf1SVG,
                        MediaRes.comingSoonSVG,
                      ),
                    )
                  else
                    AlignedGridView.extent(
                      // controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: availableUrls.length,
                      maxCrossAxisExtent: 80,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 20,
                      itemBuilder: (context, index) {
                        final url = availableUrls[index];

                        
                        return UrlFaviconLogoWidget(
                          onPress: () async {
                            final uri = Uri.parse(url.url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          onDoubleTap: (urlMetaData) {
                            final urlc = url.copyWith(
                              metaData: urlMetaData,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => UpdateUrlPage(
                                  urlModel: urlc,
                                ),
                              ),
                            );
                          },
                          urlModelData: url,
                        );
                      },
                    ),

                  // BOTTOM HEIGHT SO THAT ALL CONTENT IS VISIBLE
                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
