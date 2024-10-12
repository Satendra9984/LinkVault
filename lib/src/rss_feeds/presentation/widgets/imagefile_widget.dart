import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ImageFileWidget extends StatefulWidget {
  const ImageFileWidget({
    required this.child, required this.postFrameCallback, required this.initials, super.key,
  });

  final Widget child;
  final String initials;
  final void Function() postFrameCallback;

  @override
  State<ImageFileWidget> createState() => _ImageFileWidgetState();
}

class _ImageFileWidgetState extends State<ImageFileWidget> {
  final GlobalKey _childKey = GlobalKey();

  int _renderCount = 0;

  @override
  void initState() {
    // Call ensureLayoutComplete to check the layout after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLayoutComplete();
    });
    super.initState();
  }

  void _ensureLayoutComplete() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final renderBox =
            _childKey.currentContext?.findRenderObject() as RenderBox?;

        if (renderBox != null && renderBox.hasSize) {
          // Logger.printLog(
          //   '${widget.initials} child rendered: ${renderBox.size}',
          // );
          widget.postFrameCallback();
        } else if (_renderCount > 50) {
          widget.postFrameCallback();
          // Logger.printLog(
          //   '${widget.initials} child rendered: $_renderCount renderbox == null',
          // );
          return;
        } else {
          // If layout is not complete, call again in the next frame
          _renderCount++;
          // Logger.printLog(
          //   '${widget.initials} child rendered: $_renderCount renderbox == null',
          // );
          _ensureLayoutComplete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _childKey,
      child: widget.child,
    );
  }
}
