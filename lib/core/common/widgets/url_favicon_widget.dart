import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/banner_image_builder_widget.dart';

class UrlFaviconLogoWidget extends StatelessWidget {
  const UrlFaviconLogoWidget({
    required this.onLongPress,
    required this.onTap,
    required this.urlModelData,
    super.key,
  });
  final UrlModel urlModelData;
  final void Function(UrlMetaData) onLongPress;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final urlMetaData =
        urlModelData.metaData ?? UrlMetaData.isEmpty(title: urlModelData.title);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => onLongPress(urlMetaData),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ColourPallette.white,
              // color: ColourPallette.mystic.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1), // Softer shadow
                  spreadRadius: 1, // Wider spread for a subtle shadow
                  offset: const Offset(0, 2),
                  blurRadius: 1, // Smoothens the shadow edges
                ),
                BoxShadow(
                  color: Colors.grey.withOpacity(0.06),
                  spreadRadius: 1,
                  offset: const Offset(0, 1), // Closer to the element
                  blurRadius: 1, // Less blur for this shadow
                ),
              ],
            ),
            child: _getLogoWidget(
              context: context,
              urlMetaData: urlMetaData,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            urlModelData.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColourPallette.black,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogoWidget({
    required BuildContext context,
    required UrlMetaData urlMetaData,
  }) {
    // // Logger.printLog(StringUtils.getJsonFormat(urlModelData.toJson()));

    var name = '';

    if (urlModelData.title.isNotEmpty) {
      name = urlModelData.title;
    } else if (urlMetaData.title != null && urlMetaData.title!.isNotEmpty) {
      name = urlMetaData.title!;
    } else if (urlMetaData.websiteName != null &&
        urlMetaData.websiteName!.isNotEmpty) {
      name = urlMetaData.websiteName!;
    }

    final placeHolder = Container(
      padding: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColourPallette.black,
        // color: Colors.deepPurple
      ),
      child: Text(
        name,
        maxLines: 1,
        textAlign: TextAlign.center,
        softWrap: true,
        overflow: TextOverflow.fade,
        style: const TextStyle(
          color: ColourPallette.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    if (urlMetaData.favicon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          urlMetaData.favicon!,
          fit: BoxFit.cover,
          errorBuilder: (ctx, _, __) {
            return placeHolder;
          },
        ),
      );
    } else if (urlMetaData.faviconUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: NetworkImageBuilderWidget(
            imageUrl: urlMetaData.faviconUrl!,
            compressImage: false,
            errorWidgetBuilder: () {
              return placeHolder;
            },
            successWidgetBuilder: (imageData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  imageData.imageBytesData!,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) {
                    return placeHolder;
                  },
                ),
              );
            },
          ),
        ),
      );
    } else {
      return placeHolder;
    }
  }
}
