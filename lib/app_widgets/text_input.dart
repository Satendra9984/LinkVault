import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class TextInput extends StatelessWidget {
  final String label;
  final Widget formField;
  // final String hintText;
  const TextInput({
    Key? key,
    // required this.hintText,
    required this.formField,
    required this.label,
  }) : super(key: key);

  /// for container decoration
  final double blur = 6.0;
  final Offset distance = const Offset(3.5, 3.5);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            // TODO : APPLY FONTFAMILY
            // fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: blur,
                offset: distance,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey.shade600,
              ),
              BoxShadow(
                blurRadius: blur,
                offset: -distance,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.white,
              ),
            ],

            /// BoxShadow for neon glow
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(13.0),
            // border: Border.all(color: Colors.grey),
          ),
          child: formField,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
