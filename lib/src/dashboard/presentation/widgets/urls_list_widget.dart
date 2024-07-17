
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/add_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/update_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_favicon_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlsListWidget extends StatefulWidget {
  const UrlsListWidget({
    required this.title,
    required this.collectionFetchModel,
    // required this.scrollController,
    super.key,
  });

  final String title;
  // final ScrollController scrollController;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<UrlsListWidget> createState() => _UrlsListWidgetState();
}

class _UrlsListWidgetState extends State<UrlsListWidget> {
  // final _urlPreviewType = ValueNotifier(UrlPreviewType.icons);
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _scrollController;
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
    final fetchCollection = widget.collectionFetchModel;

    context.read<CollectionsCubit>().fetchMoreUrls(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColourPallette.white,
        surfaceTintColor: ColourPallette.mystic,
        title: Text(
          widget.collectionFetchModel.collection!.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColourPallette.salemgreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddUrlPage(
                parentCollection: widget.collectionFetchModel.collection!,
              ),
            ),
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 16 , vertical: 0),
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls = state
                .collectionUrls[widget.collectionFetchModel.collection!.id];

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  if (availableUrls == null || availableUrls.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/web_surf_1.svg',
                      ),
                    )
                  else
                    AlignedGridView.extent(
                      // controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: availableUrls.length,
                      maxCrossAxisExtent: 80,
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
                        } else if (url.loadingStates ==
                            LoadingStates.errorLoading) {
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
                          onPress: () async {
                            final uri = Uri.parse(url.urlModel!.url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          onDoubleTap: (urlMetaData) {
                            final urlc = url.urlModel!.copyWith(
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
                          urlModelData: url.urlModel!,
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
