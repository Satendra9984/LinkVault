
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:link_vault/app_services/url_parsing/fetch_preview_details.dart';
import 'package:link_vault/app_widgets/preview_aspect.dart';
import 'package:link_vault/app_widgets/preview_row.dart';

class Preview extends StatefulWidget {
  const Preview({
    required this.onDoubleTap, required this.webUrl, required this.onPress, super.key,
  });
  final Map<String, dynamic> webUrl;
  final void Function() onDoubleTap;
  final void Function() onPress;

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  late FetchPreviewDetails _fetchPreviewDetails;

  bool isPressed = false;
  double sAspectRatio = 0.1;

  void setDimensions() {
    final size =
        Map<String, dynamic>.from(widget.webUrl['size'] as Map);
    final height = size['height'] as double;
    final width = size['width'] as double;

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
    return GestureDetector(
      onDoubleTap: () {
        widget.onDoubleTap();
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
