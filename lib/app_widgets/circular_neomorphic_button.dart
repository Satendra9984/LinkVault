import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RoundedNeomorphicButton extends StatelessWidget {
  final Function() onPressed;
  final Widget child;
  const RoundedNeomorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);
  final Offset distance = const Offset(2.5, 2.5);
  final double blur = 6.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey.shade800, Colors.black]
                : [Colors.white, Colors.grey.shade200],
          ),
          shape: BoxShape.circle,
          border: Border.all(style: BorderStyle.none),
          boxShadow: [
            BoxShadow(
              blurRadius: blur,
              offset: -distance,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.white,
              // inset: isPressed,
            ),
            BoxShadow(
              blurRadius: blur,
              offset: distance,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey.shade400,
              // inset: isPressed,
            ),
          ],
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white,
        ),
        child: child,
      ),
    );
  }
}
