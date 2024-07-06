import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
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
    return GestureDetector(
      onTap: onPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        children: [
          const Icon(
            Icons.folder_rounded,
            size: 56,
            color: ColourPallette.mountainMeadow,
          ),
          // const SizedBox(height: 0.4),
          Text(
            collection.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              // fontSize: 14,
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

// todo : solve error
/*E/flutter (23234): [ERROR:flutter/lib/ui/ui_dart_state.cc(198)] Unhandled Exception: RangeError (index): Invalid value: Valid value range is empty: 0
E/flutter (23234): #0      List.[] (dart:core-patch/growable_array.dart:264:36)
E/flutter (23234): #1      FetchPreviewDetails.fetch (package:link_vault/app_models/fetch_preview_details.dart:23:55)*/
