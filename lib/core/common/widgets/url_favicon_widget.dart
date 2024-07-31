
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/banner_image_builder_widget.dart';
import 'package:link_vault/core/common/widgets/custom_image_painter.dart';

class UrlFaviconLogoWidget extends StatelessWidget {
  const UrlFaviconLogoWidget({
    required this.onDoubleTap,
    required this.onPress,
    required this.urlModelData,
    super.key,
  });
  final UrlModel urlModelData;
  final void Function(UrlMetaData) onDoubleTap;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    final urlMetaData =
        urlModelData.metaData ?? UrlMetaData.isEmpty(title: urlModelData.title);

    return GestureDetector(
      onTap: onPress,
      onLongPress: () {
        if (urlMetaData.faviconUrl != null) {
          final favicon = context
              .read<NetworkImageCacheCubit>()
              .getImageData(urlMetaData.faviconUrl!);

          if (favicon != null) {
            onDoubleTap(
              urlMetaData.copyWith(
                favicon: favicon.value.imageBytesData,
              ),
            );
          } else {
            onDoubleTap(urlMetaData);
          }
        } else {
          onDoubleTap(urlMetaData);
        }
      },
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // color: ColourPallette.mystic.withOpacity(0.15),
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
    if (urlMetaData.favicon != null) {
      // Logger.printLog(
      //   '[favicon]: ${urlMetaData.faviconUrl}, size: ${urlMetaData.favicon?.length}',
      // );
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          urlMetaData.favicon!,
          fit: BoxFit.cover,
          
          errorBuilder: (ctx, _, __) {
            // try {
            //   final svgImage = SvgPicture.memory(
            //     urlMetaData.favicon!,
            //   );

            //   return svgImage;
            // } catch (e) {
            return const Icon(Icons.web);
            // }
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
              return IconButton(
                onPressed: () =>
                    context.read<NetworkImageCacheCubit>().addImage(
                          urlMetaData.faviconUrl!,
                          compressImage: false,
                        ),
                icon: const Icon(Icons.circle),
                color: ColourPallette.black,
              );
            },
            successWidgetBuilder: (imageData) {
              if (imageData.uiImage != null) {
                return CustomPaint(
                  size: const Size(56, 56),
                  painter: ImagePainter(
                    imageData.uiImage!,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  imageData.imageBytesData!,
                  fit: BoxFit.cover,
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
            },
          ),
        ),
      );
    } else {
      return const Icon(Icons.web);
    }
  }
}
