import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/collection_icon_button.dart';

class CollectionsListWidget extends StatelessWidget {
  const CollectionsListWidget({
    required this.subCollections,
    required this.onAddFolderTap,
    required this.onFolderTap,
    required this.onFolderDoubleTap,
    super.key,
  });

  final List<CollectionModel> subCollections;
  final void Function() onAddFolderTap;
  final void Function() onFolderTap;
  final void Function() onFolderDoubleTap;

  @override
  Widget build(BuildContext context) {
    const collectionIconWidth = 80.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      alignment: Alignment.centerLeft,
      child: AlignedGridView.extent(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: subCollections.length + 10,
        // crossAxisCount: _getCount(),
        maxCrossAxisExtent: collectionIconWidth,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          if (index == index) {
            return GestureDetector(
              onTap: onAddFolderTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                // color: Colors.amber,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.create_new_folder_outlined,
                      size: 38,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add ${index == 4 ? 'Collectionssssssssss' : ''}',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          index = index - 1;
          return Text(
            'Add Folder',
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade500
                  : Colors.grey.shade800,
            ),
          );
          // return FolderIconButton(
          //   folder: subCollections[index],
          //   onDoubleTap: () async {
          // Navigator.of(context)
          //     .push(
          //   CupertinoPageRoute(
          //     builder: (context) => UpdateFolder(
          //       currentFolder: _getLinkTree(subCollections[index].id),
          //     ),
          //   ),
          // )
          //     .then(
          //   (value) async {
          //     _initializeLinkTreeList();
          //     await HiveService().addRecentFolder(subCollections[index].id);
          //     debugPrint('[log] : added recent folder');
          //   },
          // );
          // },
          // onPress: () {
          // Navigator.of(context)
          //     .push(
          //   CupertinoPageRoute(
          //     builder: (context) => StorePage(
          //       parentFolderId: subCollections[index].id,
          //     ),
          //   ),
          // )
          //     .then(
          //   (value) async {
          //     _initializeLinkTreeList();
          //     await HiveService().addRecentFolder(subCollections[index].id);
          //     debugPrint('[log] : added recent folder');
          // },
          // );
          // },
          // );
        },
      ),
    );
  }
}
