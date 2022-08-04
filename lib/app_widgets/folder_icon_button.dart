// import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:web_link_store/app_services/databases/link_tree_model.dart';

import '../app_screens/update_folder_screen.dart';

class FolderIconButton extends StatefulWidget {
  final LinkTree folder;
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
    if (kDebugMode) {
      print('linktree folder --> ${widget.folder.folderName}\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    Offset distance =
        isPressed ? const Offset(3.5, 3.5) : const Offset(2.5, 2.5);
    double blur = isPressed ? 2.0 : 3.0;

    EdgeInsets _padding =
        isPressed ? const EdgeInsets.all(5) : const EdgeInsets.all(1.99);

    return Listener(
      onPointerUp: (_) {
        setState(() {
          isPressed = !isPressed;
        });
      },
      onPointerDown: (_) {
        setState(() {
          isPressed = !isPressed;
        });
      },
      child: GestureDetector(
        onTap: widget.onPress,
        onLongPress: () {
          widget.onLongPress();
          setState(() {
            isPressed = !isPressed;
          });
        },
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              height: 60,
              width: 60,
              duration: const Duration(milliseconds: 30),
              padding: _padding,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/click.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: blur,
                    offset: distance,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey.shade500,
                    inset: isPressed,
                  ),
                  BoxShadow(
                    blurRadius: blur,
                    offset: -distance,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    inset: isPressed,
                  ),
                ],
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                borderRadius: BorderRadius.circular(13.0),
              ),
              child: Image.asset(
                'assets/images/icon3.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),

              alignment: Alignment.center,
              // fit: FlexFit.loose,
              child: Text(
                widget.folder.folderName.toString(),
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  // overflow: TextOverflow.visible,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// todo : solve error
/*E/flutter (23234): [ERROR:flutter/lib/ui/ui_dart_state.cc(198)] Unhandled Exception: RangeError (index): Invalid value: Valid value range is empty: 0
E/flutter (23234): #0      List.[] (dart:core-patch/growable_array.dart:264:36)
E/flutter (23234): #1      FetchPreviewDetails.fetch (package:web_link_store/app_models/fetch_preview_details.dart:23:55)*/