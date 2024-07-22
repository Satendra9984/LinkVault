import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/add_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/collection_store_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/update_collection_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/collection_icon_button.dart';

class CollectionsListWidget extends StatefulWidget {
  const CollectionsListWidget({
    required this.collectionFetchModel,
    super.key,
  });

  final CollectionFetchModel collectionFetchModel;

  @override
  State<CollectionsListWidget> createState() => _CollectionsListWidgetState();
}

class _CollectionsListWidgetState extends State<CollectionsListWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // _scrollController;
    _fetchMoreCollections();
    // });
    super.initState();
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      await _fetchMoreCollections();
    }
  }

  Future<void> _fetchMoreCollections() async {
    final fetchCollection = widget.collectionFetchModel;

    await context.read<CollectionsCubit>().fetchMoreSubCollections(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: '${widget.collectionFetchModel.hashCode}',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: ColourPallette.salemgreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddCollectionPage(
                parentCollection: widget.collectionFetchModel.collection!,
              ),
            ),
          );
        },
        label: const Text(
          'Add Collection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColourPallette.white,
          ),
        ),
        icon: const Icon(
          Icons.create_new_folder_rounded,
          color: ColourPallette.white,
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final fetchCollection =
                state.collections[widget.collectionFetchModel.collection!.id];

            if (fetchCollection == null) {
              // _fetchMoreCollections();

              return Center(
                child: SvgPicture.asset(
                  MediaRes.collectionSVG,
                ),
              );
            }

            final availableSubCollections = <CollectionFetchModel>[];

            for (var i = 0;
                i <= fetchCollection.subCollectionFetchedIndex;
                i++) {
              final subCollId = fetchCollection.collection!.subcollections[i];
              final subCollection = state.collections[subCollId];

              if (subCollection == null) continue;

              availableSubCollections.add(subCollection);
            }

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

                        if (subCollection.collectionFetchingState ==
                            LoadingStates.loading) {
                          return Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                width: 72,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          );
                        } else if (subCollection.collectionFetchingState ==
                            LoadingStates.errorLoading) {
                          return const Icon(
                            Icons.error,
                            color: Colors.red,
                          );
                        }

                        return FolderIconButton(
                          collection: subCollection.collection!,
                          onDoubleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => UpdateCollectionPage(
                                  collection: subCollection.collection!,
                                ),
                              ),
                            );
                          },
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => FolderCollectionPage(
                                  collectionId: subCollection.collection!.id,
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
