import 'dart:typed_data';

import 'package:flutter/material.dart';

class PreviewAspectRatio extends StatelessWidget {

  const PreviewAspectRatio({
    required this.imageData, required this.onPress, super.key,
  });
  final Map<String, dynamic> imageData;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    const distance = Offset(0, 0);
    const blur = 0.0;

    const padding = EdgeInsets.all(1);
    return GestureDetector(
      onTap: onPress,
      child: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            padding: const EdgeInsets.all(3.5),
            alignment: Alignment.center,
            margin:
                const EdgeInsets.only(left: 2.5, right: 2.5, top: 5, bottom: 5),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: blur,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
                BoxShadow(
                  blurRadius: blur,
                  offset: -distance,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
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
                imageData['image']as Uint8List,
                errorBuilder: (context, object, stackTrace) {
                  try {
                    return Image.memory(imageData['favicon'] as Uint8List);
                  } catch (e) {
                    return Image.asset(
                      'assets/images/icon3.png',
                    );
                  }
                },
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Text(
                  imageData['image_title'].toString(),
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}
// https://dev.to/social_previews/article/430257.png
// https://res.cloudinary.com/practicaldev/image/fetch/s--E8ak4Hr1--/c_limit,f_auto,fl_progressive,q_auto,w_32/https://dev-to.s3.us-east-2.amazonaws.com/favicon.ico
