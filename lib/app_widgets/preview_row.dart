import 'dart:typed_data';

import 'package:flutter/material.dart';

class PreviewRowWidget extends StatelessWidget {

  const PreviewRowWidget({
    required this.imageData, required this.onPress, super.key,
  });
  final Map<String, dynamic> imageData;
  final void Function() onPress;

  // bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    const distance = Offset(0, 0);
    const blur = 0.0;

    const padding = EdgeInsets.all(5);
    return GestureDetector(
      onTap: onPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 64,
              width: 64,
              padding: padding,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 2.5, right: 2.5, top: 5),
              decoration: BoxDecoration(
                // border: Border.all(),
                boxShadow: [
                  BoxShadow(
                    blurRadius: blur,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey.shade600,
                    // inset: isPressed,
                  ),
                  BoxShadow(
                    blurRadius: blur,
                    offset: -distance,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    // inset: isPressed,
                  ),
                ],
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.memory(
                  imageData['favicon'] as Uint8List,
                  errorBuilder: (context, object, stackTrace) {
                    try {
                      return Image.memory(imageData['favicon'] as Uint8List);
                    } catch (e) {
                      return Image.asset(
                        'assets/images/icon3.png',
                      );
                    }
                  },
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    imageData['image_title'].toString(),
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    imageData['description'].toString(),
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade600
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
