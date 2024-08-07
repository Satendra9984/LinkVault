import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/collection_icon_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/add_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard/collection_store_page.dart';

class SearchedCollectionsListWidget extends StatefulWidget {
  const SearchedCollectionsListWidget({
    super.key,
  });

  @override
  State<SearchedCollectionsListWidget> createState() =>
      _SearchedCollectionsListWidgetState();
}

class _SearchedCollectionsListWidgetState
    extends State<SearchedCollectionsListWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);

    super.initState();
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCollections();
    }
  }

  void _fetchMoreCollections() {
    context.read<AdvanceSearchCubit>().searchLocalDatabaseCollections();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
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
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,
        child: BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
          listener: (context, state) {},
          builder: (context, state) {
            // final fetchCollection = state.collections;

            // if (fetchCollection == null) {
            //   // _fetchMoreCollections();

            //   return Center(
            //     child: SvgPicture.asset(
            //       MediaRes.collectionSVG,
            //     ),
            //   );
            // }

            final availableSubCollections = state.collections;
            const collectionIconWidth = 96.0;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              controller: _scrollController,
              child: Column(
                children: [
                  if (availableSubCollections.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        MediaRes.collectionSVG,
                      ),
                    )
                  else
                    AlignedGridView.extent(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableSubCollections.length,
                      maxCrossAxisExtent: 80,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 20,
                      itemBuilder: (context, index) {
                        // final fetchCollectionCubit = context.read<CollectionsCubit>();
                        final subCollection = availableSubCollections[index];

                        // if (subCollection.collectionFetchingState ==
                        //     LoadingStates.loading) {
                        //   return Column(
                        //     children: [
                        //       Container(
                        //         width: 72,
                        //         height: 72,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(12),
                        //           color: Colors.grey.shade200,
                        //         ),
                        //       ),
                        //       Container(
                        //         margin: const EdgeInsets.symmetric(
                        //           horizontal: 8,
                        //           vertical: 8,
                        //         ),
                        //         width: 72,
                        //         height: 8,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(16),
                        //           color: Colors.grey.shade300,
                        //         ),
                        //       ),
                        //     ],
                        //   );
                        // } else if (subCollection.collectionFetchingState ==
                        //     LoadingStates.errorLoading) {
                        //   return const Icon(
                        //     Icons.error,
                        //     color: Colors.red,
                        //   );
                        // }

                        return FolderIconButton(
                          collection: subCollection,
                          onDoubleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => UpdateCollectionPage(
                                  collection: subCollection,
                                ),
                              ),
                            );
                          },
                          onPress: () {
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

  // @override
  // bool get wantKeepAlive => true;
}
