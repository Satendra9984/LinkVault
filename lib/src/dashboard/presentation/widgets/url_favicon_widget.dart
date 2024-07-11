import 'dart:typed_data';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlFaviconLogoWidget extends StatelessWidget {
  const UrlFaviconLogoWidget({
    required this.onDoubleTap,
    required this.onPress,
    required this.urlModelData,
    super.key,
  });
  final UrlModel urlModelData;
  final void Function() onDoubleTap;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    final urlMetaData =
        urlModelData.metaData ?? UrlMetaData.isEmpty(title: urlModelData.title);

    return GestureDetector(
      onTap: onPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            padding: const EdgeInsets.all(8),
            child: _getLogoWidget(urlMetaData),
          ),
          const SizedBox(height: 4),
          Text(
            '${urlModelData.title}',
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

  Widget _getLogoWidget(UrlMetaData urlMetaData) {
    if (urlMetaData.favicon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          urlMetaData.favicon!,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) {
            try {
              final svgImage = SvgPicture.memory(
                urlMetaData.favicon!,
              );

              return svgImage;
            } catch (e) {
              return const Icon(Icons.web);
            }
          },
        ),
      );
    } else if (urlMetaData.faviconUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          urlMetaData.faviconUrl!,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) {
            try {
              final svgImage = SvgPicture.network(
                urlMetaData.faviconUrl!,
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
