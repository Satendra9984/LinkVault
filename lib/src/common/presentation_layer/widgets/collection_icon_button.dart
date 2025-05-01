import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/src/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/core/utils/string_utils.dart';

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
    return GestureDetector(
      onTap: onPress,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              MediaRes.folderSVG,
              height: 56,
              width: 56,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            StringUtils.capitalizeEachWord(collection.name),
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColourPallette.black,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}
