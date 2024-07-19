import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
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
    final folderColor = ColourPallette.freepikLoginImage;
    return GestureDetector(
      onTap: onPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  folderColor.withOpacity(0.25),
                  folderColor.withOpacity(0.55),
                  folderColor.withOpacity(0.75),
                  folderColor.withOpacity(0.85),
                  // Add more colors if needed
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.5, 0.65, 1],
              ).createShader(bounds);
            },
            // child: Icon(
            //   Icons.folder,
            //   size: 80,
            //   color: folderColor, // This color will be masked by the gradient
            // ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/images/folder_6.svg',
                height: 56,
                width: 56,
                // color: folderColor,
              ),
            ),
          ),

          // Icon(
          //   Icons.folder,
          //   size: 72,
          //   color: folderColor.withOpacity(1), // This color will be masked by the gradient
          // ),

          // Padding(
          //   padding: const EdgeInsets.all(4),
          //   child: SvgPicture.asset(
          //     'assets/images/folder_6.svg',
          //     height: 56,
          //     width: 56,
          //     // color: folderColor,
          //   ),
          // ),
          Text(
            collection.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
