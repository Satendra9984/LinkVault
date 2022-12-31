import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:web_link_store/app_models/fetch_preview_details.dart';
import 'package:web_link_store/app_widgets/preview_aspect.dart';
import 'package:web_link_store/app_widgets/preview_row.dart';

class Preview extends StatefulWidget {
  final Map<String, dynamic> webUrl;
  final void Function() onLongPress;
  final void Function() onPress;
  const Preview({
    Key? key,
    required this.onLongPress,
    required this.webUrl,
    required this.onPress,
  }) : super(key: key);

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  late FetchPreviewDetails _fetchPreviewDetails;

  bool isPressed = false;
  double sAspectRatio = 0.1;

  void setDimensions() {
    Map<String, dynamic> size =
        Map<String, dynamic>.from(widget.webUrl['size']);
    double height = size['height'];
    double width = size['width'];

    if (height != 0 && width != 0) {
      setState(() {
        sAspectRatio = width / height;
        // print('ration --> $sAspectRatio');
      });
    }
  }

  @override
  void initState() {
    _fetchPreviewDetails = FetchPreviewDetails();
    setDimensions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Offset distance =
        isPressed ? const Offset(2.5, 2.5) : const Offset(3.5, 3.5);
    double blur = isPressed ? 3.0 : 6.0;

    EdgeInsets _padding = const EdgeInsets.all(1);

    return GestureDetector(
      onTap: null,
      onLongPress: () {
        widget.onLongPress();
        setState(() {
          isPressed = !isPressed;
        });
      },
      child: sAspectRatio >= 1.5
          ? PreviewAspectRatio(
              onPress: widget.onPress,
              imageData: widget.webUrl,
            )
          : PreviewRowWidget(
              onPress: widget.onPress,
              imageData: widget.webUrl,
            ),
    );
  }
}
