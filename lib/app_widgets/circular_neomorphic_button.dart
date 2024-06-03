import 'package:flutter/material.dart';

class RoundedNeomorphicButton extends StatelessWidget {
  final Function() onPressed;
  final Widget child;
  const RoundedNeomorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);
  final Offset distance = const Offset(1.5, 1.5);
  final double blur = 3.0;

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
