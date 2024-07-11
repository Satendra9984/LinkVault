import 'dart:typed_data';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlFaviconLogoWidget extends StatefulWidget {
  const UrlFaviconLogoWidget({
    required this.onDoubleTap,
    required this.onPress,
    required this.urlMetaData,
    super.key,
  });
  final UrlMetaData urlMetaData;
  final void Function() onDoubleTap;
  final void Function() onPress;

  @override
  State<UrlFaviconLogoWidget> createState() => _UrlFaviconLogoWidgetState();
}

class _UrlFaviconLogoWidgetState extends State<UrlFaviconLogoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      onDoubleTap: widget.onDoubleTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            padding: const EdgeInsets.all(8),
            child: _getLogoWidget(),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.urlMetaData.websiteName}',
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogoWidget() {
    if (widget.urlMetaData.favicon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          widget.urlMetaData.favicon!,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) {
            try {
              final svgImage = SvgPicture.memory(
                widget.urlMetaData.favicon!,
              );

              return svgImage;
            } catch (e) {
              return const Icon(Icons.web);
            }
          },
        ),
      );
    } else if (widget.urlMetaData.faviconUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          widget.urlMetaData.faviconUrl!,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) {
            try {
              final svgImage = SvgPicture.network(
                widget.urlMetaData.faviconUrl!,
              );

              return svgImage;
            } catch (e) {
              return const Icon(Icons.web);
            }
          },
        ),
      );
    } else {
      return const Icon(Icons.web);
    }
  }
}
