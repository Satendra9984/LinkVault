import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewRowWidget extends StatelessWidget {
  final Map<String, dynamic> imageData;
  final void Function() onPress;

  const PreviewRowWidget({
    Key? key,
    required this.imageData,
    required this.onPress,
  }) : super(key: key);

  // bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    Offset distance = const Offset(0.0, 4.5);
    double blur = 8.0;

    EdgeInsets _padding = const EdgeInsets.all(1);
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
              padding: _padding,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 2.5, right: 2.5, top: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: blur,
                    offset: distance,
                    color: Colors.white,
                  ),
                  BoxShadow(
                    blurRadius: blur,
                    offset: -distance,
                    color: const Color(0xFFA7A9AF),
                  ),
                ],
                color: const Color(0xFFEFEEEE),
                borderRadius: BorderRadius.circular(13.0),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.memory(
                  imageData['favicon'],
                  // height: 150,
                  // width: 200,
                  // loadingBuilder: (){},
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
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              // margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    imageData['image_title'],
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
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
                  // Text(
                  //   '$width\n$height\n aspect ration --> $sAspectRatio',
                  //   softWrap: true,
                  //   textAlign: TextAlign.start,
                  //   style: TextStyle(
                  //     fontSize: 13,
                  //     color: Colors.grey.shade400,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 64,
            width: 64,
            padding: _padding,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 2.5, right: 2.5, top: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              boxShadow: [
                BoxShadow(
                  blurRadius: blur,
                  offset: -distance,
                  color: Colors.white,
                  // inset: isPressed,
                ),
                BoxShadow(
                  blurRadius: blur,
                  offset: distance,
                  color: const Color(0xFFA7A9AF),
                  // inset: isPressed,
                ),
              ],
              color: const Color(0xFFEFEEEE),
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                imageUrl.toString(),
                // height: 150,
                // width: 200,
                // loadingBuilder: (){},
                errorBuilder: (context, object, stackTrace) {
                  return Image.asset(
                    'assets/images/click.png',
                    // height: 150,
                    // width: 200,
                  );
                },
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            // margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  description,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                // Text(
                //   '$width\n$height\n aspect ration --> $sAspectRatio',
                //   softWrap: true,
                //   textAlign: TextAlign.start,
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: Colors.grey.shade400,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    )
*/

// Column(
// children: [
//   Container(
//     height: 64,
//     width: 64,
//     // width: double.infinity,
//
//     // padding: const EdgeInsets.all(10),
//     alignment: Alignment.center,
//     margin:
//         const EdgeInsets.only(left: 2.5, right: 2.5, top: 5, bottom: 5),
//     decoration: BoxDecoration(
//       // color: Colors.transparent,
//       image: DecorationImage(
//         image: NetworkImage(
//           imageUrl,
//         ),
//         fit: BoxFit.contain,
//       ),
//     ),
//     // decoration: BoxDecoration(
//     //   border: Border.all(color: Colors.white30),
//     //   boxShadow: [
//     //     BoxShadow(
//     //       blurRadius: blur,
//     //       offset: -distance,
//     //       color: Colors.white,
//     //       inset: isPressed,
//     //     ),
//     //     BoxShadow(
//     //       blurRadius: blur,
//     //       offset: distance,
//     //       color: const Color(0xFFA7A9AF),
//     //       inset: isPressed,
//     //     ),
//     //   ],
//     //   color: const Color(0xFFEFEEEE),
//     //   borderRadius: BorderRadius.circular(13.0),
//     // ),
//     child: ClipRRect(
//       borderRadius: const BorderRadius.all(Radius.circular(10)),
//       child: Image.network(
//         imageUrl.toString(),
//         // height: 150,
//         // width: 200,
//         // loadingBuilder: (){},
//         errorBuilder: (context, object, stackTrace) {
//           print('i in ascpect --> $imageUrl');
//
//           return Image.asset(
//             'assets/images/icon3.png',
//             // height: 150,
//             // width: 200,
//           );
//         },
//         fit: BoxFit.cover,
//       ),
//     ),
//   ),
//   Text(
//     title,
//     softWrap: true,
//     textAlign: TextAlign.start,
//     style: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w500,
//       color: Colors.grey.shade800,
//     ),
//   ),
//   Text(
//     description,
//     softWrap: true,
//     textAlign: TextAlign.start,
//     style: TextStyle(
//       fontSize: 13,
//       color: Colors.grey.shade400,
//     ),
//   ),
// ],
