import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/banner_image_builder_widget.dart';

class UrlPreviewWidget extends StatelessWidget {
  UrlPreviewWidget({
    required this.urlMetaData,
    required this.onTap,
    required this.onDoubleTap,
    required this.onShareButtonTap,
    required this.onMoreVertButtontap,
    this.outerScreenHorizontalDistance = 50,
    super.key,
  });

  final UrlMetaData urlMetaData;
  final double outerScreenHorizontalDistance;
  final void Function() onTap;
  final void Function() onDoubleTap;
  final void Function() onShareButtonTap;
  final void Function() onMoreVertButtontap;

  final _showFullDescription = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // Logger.printLog(
    //   'website ${urlMetaData.websiteName}, url: ${urlMetaData.bannerImageUrl}',
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urlMetaData.bannerImageUrl != null)
          GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: NetworkImageBuilderWidget(
                imageUrl: urlMetaData.bannerImageUrl!,
                imageBytes: urlMetaData.bannerImage,
                compressImage: true,
              ),
            ),
          ),

        /// Title and description and bannerImage?
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: ValueListenableBuilder(
                    valueListenable: _showFullDescription,
                    builder: (context, showFullDescription, _) {
                      return RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${urlMetaData.title}',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                              ),
                            ),
                            TextSpan(
                              text: !showFullDescription ? '  more' : '  less',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _showFullDescription.value =
                                      !_showFullDescription.value;
                                },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 8),
            if (urlMetaData.bannerImageUrl != null)
              GestureDetector(
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                child: NetworkImageBuilderWidget(
                  imageUrl: urlMetaData.bannerImageUrl!,
                  isSideWayWidget: true,
                  compressImage: true,
                ),
              ),
          ],
        ),
        if (urlMetaData.description != null)
          ValueListenableBuilder(
            valueListenable: _showFullDescription,
            builder: (context, showFullDescription, _) {
              if (!showFullDescription) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${urlMetaData.description}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          // overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // const SizedBox(height: 8),

        /// Website details and other option
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: GestureDetector(
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                child: Row(
                  children: [
                    if (urlMetaData.favicon != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          urlMetaData.favicon!,
                          height: 16,
                          width: 16,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) {
                            try {
                              final svgImage = SvgPicture.memory(
                                urlMetaData.favicon!,
                              );

                              return svgImage;
                            } catch (e) {
                              return const SizedBox(
                                height: 16,
                                width: 16,
                                child: Icon(Icons.web),
                              );
                            }
                          },
                        ),
                      )
                    else if (urlMetaData.faviconUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: NetworkImageBuilderWidget(
                            imageUrl: urlMetaData.faviconUrl!,
                            compressImage: false,
                          ),
                        ),
                      )
                    // child: Image.network(
                    // urlMetaData.faviconUrl!,
                    // height: 16,
                    // width: 16,
                    // fit: BoxFit.contain,
                    // errorBuilder: (ctx, _, __) {
                    //   try {
                    //     final svgImage = SvgPicture.network(
                    //       urlMetaData.faviconUrl!,
                    //     );

                    //     return svgImage;
                    //   } catch (e) {
                    //     return const SizedBox(
                    //       height: 16,
                    //       width: 16,
                    //       child: Icon(Icons.web),
                    //     );
                    //   }
                    // },
                    // ),

                    else
                      const SizedBox(
                        height: 56,
                        width: 56,
                        child: Icon(Icons.web),
                      ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${urlMetaData.websiteName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onShareButtonTap,
                  icon: const Icon(
                    Icons.share_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onMoreVertButtontap,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
