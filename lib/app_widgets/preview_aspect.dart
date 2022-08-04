// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewAspectRatio extends StatelessWidget {
  final Map<String, dynamic> imageData;
  final void Function() onPress;

  PreviewAspectRatio({
    Key? key,
    required this.imageData,
    required this.onPress,
  }) : super(key: key);

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    Offset distance = const Offset(0.0, 4.5);
    double blur = 8.0;

    EdgeInsets _padding = const EdgeInsets.all(1);
    return GestureDetector(
      onTap: onPress,
      child: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            // padding: const EdgeInsets.all(2.5),
            alignment: Alignment.center,
            margin:
                const EdgeInsets.only(left: 2.5, right: 2.5, top: 5, bottom: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              boxShadow: [
                BoxShadow(
                  blurRadius: blur,
                  offset: distance,
                  color: Colors.white,
                  // inset: isPressed,
                ),
                BoxShadow(
                  blurRadius: blur,
                  offset: -distance,
                  color: const Color(0xFFA7A9AF),
                  // inset: isPressed,
                ),
              ],
              color: const Color(0xFFEFEEEE),
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.memory(
                imageData['image'],
                errorBuilder: (context, object, stackTrace) {
                  try {
                    return Image.memory(imageData['favicon']);
                  } catch (e) {
                    // print('i in ascpect --> $imageData');
                    return Image.asset(
                      'assets/images/icon3.png',
                      // height: 150,
                      // width: 200,
                    );
                  }
                },
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            imageData['image_title'],
            softWrap: true,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            imageData['description'],
            softWrap: true,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
// https://dev.to/social_previews/article/430257.png
// https://res.cloudinary.com/practicaldev/image/fetch/s--E8ak4Hr1--/c_limit,f_auto,fl_progressive,q_auto,w_32/https://dev-to.s3.us-east-2.amazonaws.com/favicon.ico
