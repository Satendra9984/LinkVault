// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/banner_image_builder_widget.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/custom_painter.dart';

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
    //   'website ${urlMetaData.faviconUrl} ${urlMetaData.websiteName}, url: ${urlMetaData.bannerImageUrl}',
    // );
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urlMetaData.bannerImageUrl != null &&
            urlMetaData.bannerImageUrl!.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _bannerImageBuilder(
                context: context,
                size: size,
              ),
            ),
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

        /// Website details and other option
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: GestureDetector(
                onTap: onTap,
                // onDoubleTap: onDoubleTap,
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
                            // bool isSvg = false;
                            // try {
                            //   final svgImage = SvgPicture.memory(
                            //     urlMetaData.favicon!,
                            //   );

                            //   isSvg = true;
                            // } catch (e) {
                            // Logger.printLog('[SVG] $e');
                            return const SizedBox(
                              height: 16,
                              width: 16,
                              child: Icon(Icons.web),
                            );
                            // }
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
                            errorWidgetBuilder: () {
                              return IconButton(
                                onPressed: () => context
                                    .read<NetworkImageCacheCubit>()
                                    .addImage(
                                      urlMetaData.faviconUrl!,
                                      compressImage: false,
                                    ),
                                icon: const Icon(Icons.circle),
                                color: ColourPallette.black,
                              );
                            },
                            successWidgetBuilder: (imageData) {
                              final imageBytes = imageData.imageBytesData!;

                              if (imageData.uiImage != null) {
                                return CustomPaint(
                                  size: const Size(16, 16),
                                  painter: ImagePainter(
                                    imageData.uiImage!,
                                  ),
                                );
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  imageBytes,
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
                            },
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.web,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
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
                // const SizedBox(width: 8),
                // IconButton(
                //   onPressed: onMoreVertButtontap,
                //   icon: const Icon(
                //     Icons.more_vert_rounded,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _bannerImageBuilder({
    required BuildContext context,
    required Size size,
    bool isSideWays = false,
  }) {
    return NetworkImageBuilderWidget(
      imageUrl: urlMetaData.bannerImageUrl!,
      imageBytes: urlMetaData.bannerImage,
      compressImage: true,
      errorWidgetBuilder: () {
        if (isSideWays) {
          return Container();
        }

        return SizedBox(
          height: 150,
          width: 600,
          child: Center(
            child: IconButton(
              onPressed: () => context.read<NetworkImageCacheCubit>().addImage(
                    urlMetaData.bannerImageUrl!,
                    compressImage: true,
                  ),
              icon: const Icon(Icons.restore_rounded),
            ),
          ),
        );
      },
      loadingWidgetBuilder: () {
        if (isSideWays) {
          return Container();
        }
        return const SizedBox(
          height: 150,
          width: 600,
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: ColourPallette.grey,
              color: ColourPallette.white,
            ),
          ),
        );
      },
      successWidgetBuilder: (imageData) {
        final imageBytes = imageData.imageBytesData!;

        final bannerImageDim = ImageUtils.getImageDimFromUintData(
              imageBytes,
            ) ??
            const Size(600, 150);

        final bannerImageAspectRatio =
            bannerImageDim.height / bannerImageDim.width;

        final isSideWaysBanner = bannerImageAspectRatio >= 1.5 ||
            (bannerImageAspectRatio < 1 && bannerImageAspectRatio > 0.65);
        var width = bannerImageDim.width;
        var height = bannerImageDim.height;

        // Logger.printLog(
        //   '[bannerimage] : ${imageData.imageUrl.substring(0, 32)}, ${bannerImageAspectRatio}, screen: $size, ui.Image: ${imageData.uiImage != null}',
        // );

        if (bannerImageAspectRatio >= 1.5) {
          width = 100;
          height = min(80, width * bannerImageAspectRatio);
        } else {
          width = 100;
          height = width * bannerImageAspectRatio;
        }

        if (isSideWaysBanner) {
          // Logger.printLog(
          //   '[bannerimage] : imagesize: ${width}, $height',
          // );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  onDoubleTap: onDoubleTap,
                  child: Container(
                    alignment: Alignment.topLeft,
                    // color: Colors.amber,
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
                                text:
                                    !showFullDescription ? '  more' : '  less',
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
              const SizedBox(width: 4),
              SizedBox(
                // color: Colors.amber,
                width: width,
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (imageData.uiImage != null)
                      ? CustomPaint(
                          size: Size(width, height),
                          painter: ImagePainter(
                            imageData.uiImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) {
                            return SvgPicture.memory(
                              imageBytes,
                              placeholderBuilder: (context) {
                                return const SizedBox(
                                  height: 150,
                                  width: 600,
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }

        // Logger.printLog(
        //   '[bannerimage] : ${imageData.imageUrl}, ${bannerImageAspectRatio}, screen: $size',
        // );

        if (bannerImageAspectRatio >= 0.65 && bannerImageAspectRatio < 1.5) {
          // height is greater
          width = min(size.width - 32, bannerImageDim.width);
          height = min(width * bannerImageAspectRatio, bannerImageDim.height);

          // Logger.printLog(
          //   '[bannerimage] : imagesize: ${width}, $height',
          // );

          final averageBrightNess = ImageUtils.averageBrightness(
            ImageUtils.extractLowerHalf(imageBytes, fractionLowerHeight: 3 / 4),
          );

          final gradientColor =
              averageBrightNess < 128 ? Colors.black : Colors.white;

          final colors = averageBrightNess < 128
              ? [
                  gradientColor.withOpacity(0.60),
                  gradientColor.withOpacity(0.55),
                  gradientColor.withOpacity(0.50),
                  gradientColor.withOpacity(0.45),
                  gradientColor.withOpacity(0.40),
                  gradientColor.withOpacity(0.05),
                ]
              : [
                  gradientColor.withOpacity(0.9),
                  gradientColor.withOpacity(0.68),
                  gradientColor.withOpacity(0.50),
                  gradientColor.withOpacity(0.45),
                  gradientColor.withOpacity(0.35),
                  gradientColor.withOpacity(0.05),
                ];

          final linearGradient = LinearGradient(
            colors: colors,

            begin: Alignment.bottomCenter,
            end: Alignment.center,
            stops: const [0.40, 0.6, 0.65, 0.7, 0.75, 1],
            // tileMode: TileMode.decal,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // Banner Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: (imageData.uiImage != null)
                          ? CustomPaint(
                              size: Size(width, height),
                              painter: ImagePainter(
                                imageData.uiImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.memory(
                              imageBytes,
                              height: height,
                              width: width,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, _, __) {
                                return SvgPicture.memory(
                                  imageBytes,
                                  placeholderBuilder: (context) {
                                    return const SizedBox(
                                      height: 150,
                                      width: 600,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                  // title
                  Container(
                    height: height * 0.75,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: linearGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: onTap,
                      onDoubleTap: onDoubleTap,
                      child: ValueListenableBuilder(
                        valueListenable: _showFullDescription,
                        builder: (context, showFullDescription, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (urlMetaData.faviconUrl != null)
                              //   ClipRRect(
                              //     borderRadius: BorderRadius.circular(4),
                              //     child: SizedBox(
                              //       height: 56,
                              //       width: 56,
                              //       child: NetworkImageBuilderWidget(
                              //         imageUrl: urlMetaData.faviconUrl!,
                              //         compressImage: false,
                              //         errorWidgetBuilder: () {
                              //           return IconButton(
                              //             onPressed: () => context
                              //                 .read<NetworkImageCacheCubit>()
                              //                 .addImage(
                              //                   urlMetaData.faviconUrl!,
                              //                   compressImage: false,
                              //                 ),
                              //             icon: const Icon(Icons.circle),
                              //             color: ColourPallette.black,
                              //           );
                              //         },
                              //         successWidgetBuilder: (imageBytes) {
                              //           if (imageData.uiImage != null) {
                              //             return CustomPaint(
                              //               size: const Size(16, 16),
                              //               painter: ImagePainter(
                              //                 imageData.uiImage!,
                              //               ),
                              //             );
                              //           }
                              //           return ClipRRect(
                              //             borderRadius:
                              //                 BorderRadius.circular(4),
                              //             child: Image.memory(
                              //               imageBytes.imageBytesData!,
                              //               fit: BoxFit.contain,
                              //               errorBuilder: (ctx, _, __) {
                              //                 try {
                              //                   final svgImage =
                              //                       SvgPicture.memory(
                              //                     urlMetaData.favicon!,
                              //                   );

                              //                   return svgImage;
                              //                 } catch (e) {
                              //                   return const Icon(Icons.web);
                              //                 }
                              //               },
                              //             ),
                              //           );
                              //         },
                              //       ),
                              //     ),
                              //   ),

                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${urlMetaData.title}',
                                      style: TextStyle(
                                        color: averageBrightNess > 128
                                            ? Colors.grey.shade900
                                            : ColourPallette.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: bannerImageAspectRatio < 0.8
                                            ? 17
                                            : 20,
                                      ),
                                    ),
                                    TextSpan(
                                      text: !showFullDescription
                                          ? '  more'
                                          : '  less',
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
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // title
                ],
              ),
            ],
          );
        } else {
          // width is greater
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (imageData.uiImage != null)
                    ? CustomPaint(
                        size: Size(width, height),
                        painter: ImagePainter(
                          imageData.uiImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.memory(
                        imageBytes,
                        errorBuilder: (ctx, _, __) {
                          return SvgPicture.memory(
                            imageBytes,
                            placeholderBuilder: (context) {
                              return const SizedBox(
                                height: 150,
                                width: 600,
                              );
                            },
                          );
                        },
                      ),
              ),
              if (urlMetaData.title != null)
                GestureDetector(
                  onTap: onTap,
                  onDoubleTap: onDoubleTap,
                  child: Container(
                    padding: const EdgeInsets.only(top: 4),
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
                                text:
                                    !showFullDescription ? '  more' : '  less',
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
            ],
          );
        }
      },
    );
  }
}
