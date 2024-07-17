import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart';
// import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';

class FolderIconButton extends StatelessWidget {
  const FolderIconButton({
    required this.collection,
    required this.onPress,
    required this.onDoubleTap,
    super.key,
  });
  final CollectionModel collection;
  final void Function() onPress;
  final void Function() onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final folderColor = Colors.green.shade500;
    return GestureDetector(
      onTap: onPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  folderColor .withOpacity(0.25),
                  folderColor.withOpacity(0.5),
                  folderColor.withOpacity(0.75),
                  folderColor.withOpacity(0.95),
                  // Add more colors if needed
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.3, 0.5, 1],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.folder ,
              size: 72,
              color: Colors.white, // This color will be masked by the gradient
            ),
          ),
          Text(
            collection.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
