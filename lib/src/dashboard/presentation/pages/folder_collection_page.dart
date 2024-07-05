import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/collection_loading_states.dart';

class FolderCollectionPage extends StatefulWidget {
  const FolderCollectionPage(
      {required this.collectionId, required this.isRootCollection, super.key});
  final String collectionId;
  final bool isRootCollection;

  @override
  State<FolderCollectionPage> createState() => _FolderCollectionPageState();
}

class _FolderCollectionPageState extends State<FolderCollectionPage> {
  @override
  void initState() {
    super.initState();
    // [TODO] : Call initiliaize for this foldercollection id

    context.read<CollectionsCubit>().fetchCollection(
          collectionId: widget.collectionId,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
          isRootCollection: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CollectionsCubit, CollectionsState>(
        listener: (context, state) {
          // [TODO]: implement listener
        },
        builder: (context, state) {
          final isCurrentStateCollection =
              widget.collectionId == state.currentCollection;

          if (isCurrentStateCollection &&
              state.collectionLoadingStates ==
                  CollectionLoadingStates.fetching) {
            return Text(state.collectionLoadingStates.toString());
          }

          if (isCurrentStateCollection &&
              state.collectionLoadingStates ==
                  CollectionLoadingStates.errorLoading) {
            return Text(state.collectionLoadingStates.toString());
          }

          final collection = state.collections[widget.collectionId]!;

          final inJson = collection.toJson();
          final stringForm = const JsonEncoder.withIndent('  ').convert(inJson);
          final stringFormUrls =
              const JsonEncoder.withIndent('  ').convert(state.collectionUrls);

          return Scaffold(
            backgroundColor: ColourPallette.white,
            appBar: AppBar(
              backgroundColor: ColourPallette.white,
              title: const Text('Collection page'),
            ),
            body: Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('LogOut'),
                  ),
                  Text(state.collectionLoadingStates.toString()),
                  Text(stringForm),
                  Text(
                    stringFormUrls,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
