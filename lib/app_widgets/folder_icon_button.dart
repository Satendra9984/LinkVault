import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:web_link_store/app_models/link_tree_folder_model.dart';

class FolderIconButton extends StatefulWidget {
  final LinkTreeFolder folder;
  final void Function() onPress;
  final void Function() onLongPress;

  const FolderIconButton(
      {Key? key,
      required this.folder,
      required this.onPress,
      required this.onLongPress})
      : super(key: key);

  @override
  State<FolderIconButton> createState() => _FolderIconButtonState();
}

class _FolderIconButtonState extends State<FolderIconButton> {
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      onLongPress: widget.onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_rounded,
            size: 48.0,
            color: const Color(0xff3cac7c).withOpacity(0.85),
          ),
          Container(
            padding: const EdgeInsets.only(left: 4, right: 4),
            alignment: Alignment.center,
            child: Text(
              widget.folder.folderName.toString(),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.1,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
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
E/flutter (23234): #1      FetchPreviewDetails.fetch (package:web_link_store/app_models/fetch_preview_details.dart:23:55)*/
