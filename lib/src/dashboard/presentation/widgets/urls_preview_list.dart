import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/add_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/update_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlsPreviewListWidget extends StatefulWidget {
  const UrlsPreviewListWidget({
    required this.title,
    required this.collectionFetchModel,
    required this.scrollController,
    super.key,
  });

  final String title;
  final ScrollController scrollController;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<UrlsPreviewListWidget> createState() => _UrlsPreviewListWidgetState();
}

class _UrlsPreviewListWidgetState extends State<UrlsPreviewListWidget> {
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMoreUrls();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > _previousOffset) {
      _showAppBar.value = false;
    } else if (_scrollController.offset < _previousOffset) {
      _showAppBar.value = true;
    }
    _previousOffset = _scrollController.offset;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
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
  void dispose() {
    _scrollController.dispose();
    _showAppBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: _showAppBar,
          builder: (context, isVisible, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              height: isVisible ? kToolbarHeight + 16 : 24.0,
              child: AppBar(
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
            );
          },
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
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
                        'assets/images/web_surf_3.svg',
                      ),
                    )
                  else
                    ListView.builder(
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
                        } else if (url.loadingStates ==
                            LoadingStates.errorLoading) {
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
                              onTap: () async {
                                final uri = Uri.parse(url.urlModel!.url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              onDoubleTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => UpdateUrlPage(
                                      urlModel: url.urlModel!,
                                    ),
                                  ),
                                );
                              },
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
