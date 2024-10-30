// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_image_painter.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';

class UrlPreviewBytesWidget extends StatelessWidget {
  UrlPreviewBytesWidget({
    required this.urlMetaData,
    required this.onTap,
    required this.onLongPress,
    required this.onShareButtonTap,
    required this.onMoreVertButtontap,
    this.outerScreenHorizontalDistance = 50,
    super.key,
  });

  final UrlMetaData urlMetaData;
  final double outerScreenHorizontalDistance;
  final void Function() onTap;
  final void Function() onLongPress;
  final void Function() onShareButtonTap;
  final void Function() onMoreVertButtontap;

  final _showFullDescription = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urlMetaData.bannerImageUrl != null &&
            urlMetaData.bannerImageUrl!.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _bannerImageBuilder(
                context: context,
                size: size,
              ),
            ),
          )
        else if (urlMetaData.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _getTitle()),
                if (urlMetaData.faviconUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 56,
                      width: 56,
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
                          final imageBytes = imageData.imageBytesData!;
                          // Logger.printLog(
                          //   '[img]: faviconUrl urlpre: ${urlMetaData.faviconUrl!}',
                          // );

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
                  ),
              ],
            ),
          ),

        if (urlMetaData.description != null)
          ValueListenableBuilder(
            valueListenable: _showFullDescription,
            builder: (context, showFullDescription, _) {
              if (!showFullDescription && urlMetaData.title != null) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.only(),
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
                onLongPress: onLongPress,
                child: Row(
                  children: [
                    if (urlMetaData.faviconUrl != null)
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
                              // Logger.printLog(
                              //   '[img]: faviconUrl urlpre: ${urlMetaData.faviconUrl!}',
                              // );
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
                ValueListenableBuilder(
                  valueListenable: _showFullDescription,
                  builder: (context, showFullDescription, _) {
                    return IconButton(
                      onPressed: () => _showFullDescription.value =
                          !_showFullDescription.value,
                      icon: Icon(
                        showFullDescription
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: onShareButtonTap,
                  icon: const Icon(
                    Icons.share_rounded,
                    size: 16,
                  ),
                ),
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
            (bannerImageAspectRatio <= 1.3 && bannerImageAspectRatio > 0.65);
        var width = bannerImageDim.width;
        var height = bannerImageDim.height;

        // // Logger.printLog(
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
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _getTitle(),
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

        if (bannerImageAspectRatio > 1.3 && bannerImageAspectRatio < 1.5) {
          // height is greater
          width = min(size.width - 32, bannerImageDim.width);
          height = min(width * bannerImageAspectRatio, bannerImageDim.height);

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

          return Stack(
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
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: _getTitle(
                    titleTextStyle: TextStyle(
                      color: averageBrightNess > 128
                          ? Colors.grey.shade900
                          : ColourPallette.white,
                      fontWeight: FontWeight.w600,
                      fontSize: bannerImageAspectRatio < 0.8 ? 17 : 20,
                    ),
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _getTitle(),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _getTitle({TextStyle? titleTextStyle}) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ValueListenableBuilder(
        valueListenable: _showFullDescription,
        builder: (context, showFullDescription, _) {
          return Text(
            '${urlMetaData.title}',
            style: titleTextStyle ??
                TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
          );
        },
      ),
    );
  }
}
