import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';

class FolderIconButton extends StatelessWidget {
  const FolderIconButton({
    required this.collection,
    required this.onPress,
    required this.onLongPress,
    super.key,
  });
  final CollectionModel collection;
  final void Function() onPress;
  final void Function() onLongPress;

  @override
  Widget build(BuildContext context) {
    const folderColor = ColourPallette.freepikLoginImage;
    return GestureDetector(
      onTap: onPress,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              MediaRes.folderSVG,
              // MediaRes.folde,

              height: 60,
              width: 60,
              // color: folderColor,
            ),
          ),
          // ShaderMask(
          //   shaderCallback: (Rect bounds) {
          //     return LinearGradient(
          //       colors: [
          //         folderColor.withOpacity(0.25),
          //         folderColor.withOpacity(0.55),
          //         folderColor.withOpacity(0.75),
          //         folderColor.withOpacity(0.85),
          //         // Add more colors if needed
          //       ],
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //       stops: const [0.3, 0.5, 0.65, 1],
          //     ).createShader(bounds);
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.all(4),
          //     child: SvgPicture.asset(
          //       MediaRes.folderSVG,
          //       height: 60,
          //       width: 60,
          //       // color: folderColor,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 4),
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
