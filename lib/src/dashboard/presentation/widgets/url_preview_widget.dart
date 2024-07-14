import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';
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
                            successWidgetBuilder: (imageBytes) {
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
      successWidgetBuilder: (imageBytes) {
        final bannerImageDim = ImageUtils.getImageDimFromUintData(
              imageBytes,
            ) ??
            const Size(600, 150);

        final bannerImageAspectRatio =
            bannerImageDim.height / bannerImageDim.width;

        final isSideWaysBanner = bannerImageAspectRatio >= 1.5;
        var width = bannerImageDim.width;
        var height = bannerImageDim.height;

        if (isSideWaysBanner) {
          return Row(
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
              // const SizedBox(width: 8),
              SizedBox(
                width: 120,
                height: 120 * min(bannerImageAspectRatio, 1.5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
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
              ),
            ],
          );
        }

        if (bannerImageAspectRatio > 1 && bannerImageAspectRatio < 1.5) {
          // height is greater
          width = min(size.width - 50, bannerImageDim.width);
          height = min(width * bannerImageAspectRatio, bannerImageDim.height);

          final averageBrightNess = ImageUtils.averageBrightness(
            ImageUtils.extractLowerHalf(imageBytes, fractionLowerHeight: 3 / 4),
          );

          final gradientColor =
              averageBrightNess < 128 ? Colors.black : Colors.white;

          final linearGradient = LinearGradient(
            colors: [
              gradientColor.withOpacity(0.75),
              gradientColor.withOpacity(0.65),
              gradientColor.withOpacity(0.55),
              gradientColor.withOpacity(0.5),
              gradientColor.withOpacity(0.35),
              gradientColor.withOpacity(0.15),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            stops: const [0.3, 0.5, 0.65, 0.75, 0.8, 1],
            // tileMode: TileMode.decal,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // Banner Image
                  SizedBox(
                    // height: height,
                    // width: width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes,
                        height: height,
                        width: width,
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
                    height: height * 0.5,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: linearGradient,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                            children: [
                              if (urlMetaData.faviconUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 56,
                                    width: 56,
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
                                      successWidgetBuilder: (imageBytes) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.memory(
                                            imageBytes,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, _, __) {
                                              try {
                                                final svgImage =
                                                    SvgPicture.memory(
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
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${urlMetaData.title}',
                                      style: TextStyle(
                                        color: averageBrightNess > 128
                                            ? Colors.grey.shade900
                                            : ColourPallette.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
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
                child: Image.memory(
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
                    padding: const EdgeInsets.only(top: 8),
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
