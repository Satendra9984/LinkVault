import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
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
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchMoreCollections();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCollections();
    }
  }

  void _fetchMoreCollections() {
    final fetchCollection = widget.collectionFetchModel;

    context.read<CollectionsCubit>().fetchMoreSubCollections(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    const collectionIconWidth = 120.0;
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.topLeft,
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final fetchCollection =
                state.collections[widget.collectionFetchModel.collection!.id]!;

            if (fetchCollection.collection!.subcollections.isEmpty ||
                fetchCollection.subCollectionFetchedIndex < 0) {
              return Center(
                child: SvgPicture.asset(
                  'assets/images/collections.svg',
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

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  if (availableSubCollections.isEmpty)
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/collections.svg',
                      ),
                    )
                  else
                    AlignedGridView.extent(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableSubCollections.length,
                      maxCrossAxisExtent: collectionIconWidth,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
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
}
