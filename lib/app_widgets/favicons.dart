import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;

class FaviconsGrid extends StatefulWidget {
  final Map imageUrl;
  final void Function() onLongPress;
  final void Function() onPress;

  const FaviconsGrid({
    Key? key,
    required this.onLongPress,
    required this.onPress,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<FaviconsGrid> createState() => _FaviconsGridState();
}

class _FaviconsGridState extends State<FaviconsGrid> {
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Offset distance =
    //     isPressed ? const Offset(0.5, 0.5) : const Offset(1.0, 1.0);
    // double blur = isPressed ? 2.0 : 1.0;

    EdgeInsets _padding =
        isPressed ? const EdgeInsets.all(8) : const EdgeInsets.all(5);

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
          children: [
            AnimatedContainer(
              height: 60,
              width: 60,
              duration: const Duration(milliseconds: 30),
              padding: _padding,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
              // decoration: BoxDecoration(
              //   image: const DecorationImage(
              //     image: AssetImage('assets/images/click.png'),
              //     fit: BoxFit.contain,
              //     alignment: Alignment.center,
              //   ),
              //   boxShadow: [
              //     BoxShadow(
              //       blurRadius: blur,
              //       offset: distance,
              //       color: Theme.of(context).brightness == Brightness.dark
              //           ? Colors.black
              //           : Colors.grey.shade600,
              //       inset: isPressed,
              //     ),
              //     BoxShadow(
              //       blurRadius: blur,
              //       offset: -distance,
              //       color: Theme.of(context).brightness == Brightness.dark
              //           ? Colors.grey.shade800
              //           : Colors.grey.shade100,
              //       inset: isPressed,
              //     ),
              //   ],
              //   color: Theme.of(context).brightness == Brightness.dark
              //       ? Colors.grey.shade900
              //       : Colors.white,
              //   borderRadius: BorderRadius.circular(8.0),
              // ),
             
             
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.memory(
                  widget.imageUrl['favicon'],
                  errorBuilder: (context, object, stackTrace) {
                    return Image.asset('assets/images/click.png');
                  },
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              // margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              padding:
                  const EdgeInsets.only(left: 4, right: 4),
              alignment: Alignment.center,
              child: Text(
                widget.imageUrl['url_title'],
                softWrap: true,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  height: 1.1,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade500
                      : Colors.grey.shade700,

                      
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
