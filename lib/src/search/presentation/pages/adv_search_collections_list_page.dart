import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/collection_list_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_collection_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/collection_icon_button.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_fetch_model.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/dashboard/presentation/pages/dashboard_store_screen.dart';
import 'package:link_vault/src/search/presentation/advance_search_cubit/search_cubit.dart';

class SearchedCollectionsListWidget extends StatefulWidget {
  const SearchedCollectionsListWidget({
    super.key,
  });

  @override
  State<SearchedCollectionsListWidget> createState() =>
      _SearchedCollectionsListWidgetState();
}

class _SearchedCollectionsListWidgetState
    extends State<SearchedCollectionsListWidget>
    with AutomaticKeepAliveClientMixin {
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  Future<void> _onScroll() async {
    if (_scrollController.offset > _previousOffset) {
      _showAppBar.value = false;
      // widget.showBottomBar.value = false;
    } else if (_scrollController.offset < _previousOffset) {
      _showAppBar.value = true;
      // widget.showBottomBar.value = true;
    }
    _previousOffset = _scrollController.offset;

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
    super.build(context);

    return CollectionsListScreenTemplate(
      isRootCollection: false,
      collectionModel: CollectionModel.isEmpty(
        userId: context.read<GlobalUserCubit>().getGlobalUser()?.id ?? 'user',
        name: 'Advance Search',
        parentCollection: 'Advance Search',
        status: {
          'status': 'active',
        },
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      showAddCollectionButton: false,
      onAddCollectionPressed: () {},
      onCollectionItemFetchedWidget: null,
      appBar: _getAppBar,
      body: _getBody,
    );
  }

  Widget _getBody({
    required ValueNotifier<List<CollectionFetchModel>> list,
    required VoidCallback filterList,
  }) {
    return BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
      listener: (context, state) {},
      builder: (context, state) {
        final searchCubit = context.read<AdvanceSearchCubit>();

        if (state.collections.isEmpty) {
          return Center(
            child: SvgPicture.asset(
              MediaRes.collectionSVG,
            ),
          );
        }
        filterList();
        final localList = <CollectionFetchModel>[];

        for (var i = 0; i < localList.length; i++) {
          localList.add(
            CollectionFetchModel(
              collectionFetchingState: LoadingStates.loaded,
              subCollectionFetchedIndex: i,
              collection: state.collections[i],
            ),
          );
        }
        list.value = localList;

        return ValueListenableBuilder(
          valueListenable: list,
          builder: (context, availableSubCollectionsFetch, _) {
            final availableSubCollections = availableSubCollectionsFetch
                .map((ele) => ele.collection)
                .toList();

            if (availableSubCollections.isEmpty) {
              Center(
                child: SvgPicture.asset(
                  MediaRes.collectionSVG,
                ),
              );
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
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
                        if (subCollection == null) {
                          return const SizedBox.shrink();
                        }
                        return FolderIconButton(
                          collection: subCollection,
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    UpdateCollectionTemplateScreen(
                                  collection: subCollection,
                                ),
                              ),
                            );
                          },
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => CollectionStorePage(
                                  collectionId: subCollection.id,
                                  isRootCollection: false,
                                  appBarLeadingIcon: SvgPicture.asset(
                                    MediaRes.searchSVG,
                                    height: 16,
                                    width: 16,
                                  ),
                                ),
                              ),
                            ).then(
                              (value) {
                                searchCubit.searchDB();
                              },
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
        );
      },
    );
  }

  Widget _getAppBar({
    required List<Widget> actions,
    required ValueNotifier<List<CollectionFetchModel>> list,
    required List<Widget> collectionOptions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: const Text(
        'Advance Search',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        ...actions,
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
