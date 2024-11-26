// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_preload_manager_cubit/url_preload_manager_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/filter_popup_menu_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/list_filter_pop_up_menu_item.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_image_cache_service.dart';
import 'package:link_vault/core/services/custom_tabs_client_service.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/rss_feeds/presentation/widgets/imagefile_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RssFeedPreviewWidget extends StatefulWidget {
  const RssFeedPreviewWidget({
    required this.urlModel,
    required this.onTap,
    required this.onLongPress,
    required this.onShareButtonTap,
    required this.onLayoutOptionsButtontap,
    required this.updateBannerImage,
    required this.urlPreloadMethod,
    this.onBookmarkButtonTap,
    this.showDescription = false,
    this.showBannerImage = true,
    this.isSidewaysLayout = false,
    super.key,
  });

  final UrlModel urlModel;
  final bool showDescription;
  final bool showBannerImage;
  final UrlPreloadMethods urlPreloadMethod;

  final bool isSidewaysLayout;
  final void Function() onTap;
  final void Function() updateBannerImage;
  final void Function() onLongPress;
  final void Function() onShareButtonTap;
  final void Function()? onBookmarkButtonTap;
  final void Function() onLayoutOptionsButtontap;

  @override
  State<RssFeedPreviewWidget> createState() => _RssFeedPreviewWidgetState();
}

class _RssFeedPreviewWidgetState extends State<RssFeedPreviewWidget> {
  String initials = '';

  // keys for widgets like Title, Image that changes on Filter
  final GlobalKey _mainWidgetKey = GlobalKey();
  GlobalKey _urlTitleKey = GlobalKey();
  GlobalKey _bannerImageKey = GlobalKey();
  var _preloadUrl = false;

  // Widget Layout Informations for description upper calculations
  final ValueNotifier<Size?> _urlTitleSize = ValueNotifier<Size?>(null);
  final ValueNotifier<Size?> _bannerImageSize = ValueNotifier<Size?>(null);

  // For Managing Local and Parent Filters state
  final _showFullDescription = ValueNotifier(false);
  final _showBannerImage = ValueNotifier(true);

  final _isSideWayLayout = ValueNotifier(false);
  final _upperDescriptionIndex = ValueNotifier(0);

  final upperDescTextStyle = TextStyle(
    color: Colors.grey.shade900,
    fontSize: 14,
  );

  final titleTextStyle = TextStyle(
    color: Colors.grey.shade900,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  @override
  void initState() {
    _showFullDescription.value = widget.showDescription;
    _isSideWayLayout.value = widget.isSidewaysLayout;
    _showBannerImage.value = widget.showBannerImage;
    final description = widget.urlModel.metaData?.title ?? '';

    initials = description.length > 7
        ? description.substring(0, 8)
        : description.substring(0, description.length);
    _updateFeedBannerImageUrl();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RssFeedPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBannerImage != oldWidget.showBannerImage) {
      _showBannerImage.value = widget.showBannerImage;
    }

    // // Logger.printLog('$initials didUpdateWidget');
    if (widget.isSidewaysLayout != oldWidget.isSidewaysLayout ||
        widget.showDescription != oldWidget.showDescription) {
      // Detach the widgets to mark them for layout
      _detachWidget(_mainWidgetKey);
      _detachWidget(_bannerImageKey);
      _detachWidget(_urlTitleKey);

      // Reassign keys to force rebuild
      _bannerImageKey = GlobalKey();
      _urlTitleKey = GlobalKey();

      // Update other states
      _urlTitleSize.value = null;
      _bannerImageSize.value = null;
      _upperDescriptionIndex.value = 0;
      _showFullDescription.value = widget.showDescription;
      _isSideWayLayout.value = widget.isSidewaysLayout;
      _showBannerImage.value = widget.showBannerImage;
    }
  }

  @override
  void dispose() {
    _urlTitleSize.dispose();
    _bannerImageSize.dispose();
    _isSideWayLayout.dispose();
    _showFullDescription.dispose();
    _upperDescriptionIndex.dispose();

    super.dispose();
  }

  Future<void> _updateFeedBannerImageUrl() async {
    // // Logger.printLog(
    //   '$initials ${StringUtils.getJsonFormat(widget.urlModel.metaData)}',
    // );

    if (widget.urlModel.metaData != null &&
        widget.urlModel.metaData!.rssFeedUrl != null &&
        widget.urlModel.metaData!.bannerImageUrl == null) {
      // // Logger.printLog('[rss] : _updateBannerImageUrl');
      widget.updateBannerImage();
    }
  }

  void _getDescriptionContainerSize({
    required TextStyle textStyle,
    required TextStyle titleTextStyle,
    required BuildContext context,
  }) {
    _updateSize(_urlTitleKey, _urlTitleSize);
    _updateSize(_bannerImageKey, _bannerImageSize);

    if (_urlTitleSize.value == null ||
        _bannerImageSize.value == null ||
        _bannerImageSize.value!.width == 0 ||
        _bannerImageSize.value!.height == 0) {
      return;
    }

    final remainingHeightForDescription =
        _bannerImageSize.value!.height - _urlTitleSize.value!.height;

    if (remainingHeightForDescription <= 0) {
      _upperDescriptionIndex.value = 0;
      _bannerImageSize.value = null;

      return;
    }

    final remainingWidthForDescription = _urlTitleSize.value!.width;

    if (_bannerImageSize.value!.height > _bannerImageSize.value!.width * 1.1) {
      _isSideWayLayout.value = true;
    }

    // // Logger.printLog('[size] ${_bannerImageSize.value}');
    _splitDescription(
      description: widget.urlModel.metaData?.description?.trim() ?? '',
      containerWidth: remainingWidthForDescription,
      containerHeight: remainingHeightForDescription,
      targettTextStyle: textStyle,
    );
  }

  String? _splitDescription({
    required String description,
    required double containerWidth,
    required double containerHeight,
    required TextStyle targettTextStyle,
  }) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    )
      ..maxLines = 1
      ..text = TextSpan(text: 'description', style: targettTextStyle)
      ..layout(maxWidth: containerWidth);

    // Create a TextPainter for line height calculation
    int? maxLines = (containerHeight / textPainter.height).round();
    maxLines = maxLines > 0 ? maxLines : null;

    if (maxLines == null) return null;

    final words = description.split(' ');

    final part1 = StringBuffer();
    var currentLineCount = 0;
    var totolPart1Length = 0;
    var wordIndex = 0;

    // Iterate over the available number of lines
    while (currentLineCount < maxLines && wordIndex < words.length) {
      final currentLine = StringBuffer();
      // Add words to the current line until it exceeds or matches the container width
      while (wordIndex < words.length) {
        final nextWord = words[wordIndex];

        // Create a new text span with the current line + the next word
        textPainter
          ..text = TextSpan(
            text:
                '$currentLine $nextWord', // Use .toString() to get the current line's text
            style: targettTextStyle,
          )
          ..layout(
            maxWidth: containerWidth * 1.5,
          ); // Measure the width without constraints

        final textPainterWidth = textPainter.width;
        // Case 1: When the text width exactly matches the container width
        if (textPainterWidth <= containerWidth) {
          currentLine.write(' $nextWord');
          wordIndex++;
        }
        // Case 3: When the text width exceeds the container width
        else {
          break; // Break the loop as the line is overfilled
        }
      }

      // Write the completed line to the final result and increment the line count
      final newlineContent = currentLine.toString();
      totolPart1Length += newlineContent.length;
      part1.write(newlineContent);
      currentLineCount++;
    }

    final part1t = part1.toString().trim();

    final index = totolPart1Length > 0 ? totolPart1Length - 1 : 0;
    // Use truncatedDescription in the UI
    _upperDescriptionIndex.value = index;
    return part1t; // Return the truncated description part
  }

  void _updateSize(GlobalKey key, ValueNotifier<Size?> notifier) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      notifier.value = renderBox.size;
    }
  }

  void _detachWidget(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      // renderBox.detach();
      renderBox.markNeedsLayout();
      // renderBox.reassemble();
      // Logger.printLog('$initials detaching $key');
    }
  }

  String _getTimeDifferenceOfFeed() {
    final feedTime = widget.urlModel.createdAt;
    final currentDate = DateTime.now().toUtc();

    final difference = currentDate.difference(feedTime);
    // Check if the time difference is in days, hours, or minutes
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} sec';
    } else if (difference.inMilliseconds > 0) {
      return '${0} sec';
    }

    // If it's less than a minute
    return '--';
  }

  String _websiteName(String websiteName, int allowedLength) {
    // // Logger.printLog('WebsiteName: $websiteName');
    if (websiteName.length < allowedLength) {
      return websiteName;
    }

    final spaced = websiteName.trim().split(' ');
    final initials = StringBuffer();

    for (final ele in spaced) {
      if (ele.isNotEmpty) {
        initials.write(ele[0]);
      }
    }

    return initials.toString();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final descriptionAvailable =
        widget.urlModel.metaData?.description != null &&
            widget.urlModel.metaData!.description!.isNotEmpty;

    FutureBuilder<FileInfo?>? imageBuilder;

    if (widget.urlModel.metaData?.bannerImageUrl != null &&
        widget.urlModel.metaData!.bannerImageUrl!.isNotEmpty) {
      imageBuilder = FutureBuilder<FileInfo?>(
        future: CustomImagesCacheManager.instance.getImageFile(
          widget.urlModel.metaData!.bannerImageUrl!,
          widget.urlModel.collectionId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return const SizedBox.shrink(); // Show a placeholder while loading
          }

          final fileInfo = snapshot.data;

          if (fileInfo != null) {
            // Check if the file is an SVG
            if (widget.urlModel.metaData!.bannerImageUrl!
                .toLowerCase()
                .endsWith('.svg')) {
              // Use the _loadSvgFile function for SVG files
              return FutureBuilder<Widget>(
                future: _loadSvgFile(fileInfo.file),
                builder: (context, svgSnapshot) {
                  if (svgSnapshot.connectionState == ConnectionState.waiting ||
                      svgSnapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  return svgSnapshot.data!;
                },
              );
            }

            // Standard image loading for non-SVG files
            return RepaintBoundary(
              child: Image.file(
                fileInfo.file,
                width: size.width,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) =>
                    Container(), // Fallback in case of error
                frameBuilder: (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (frame == null) {
                    return Container(); // Placeholder while the image is loading
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColourPallette.mystic.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ImageFileWidget(
                        initials: initials,
                        child: child,
                        postFrameCallback: () {
                          if (_bannerImageSize.value == null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                                _getDescriptionContainerSize(
                                  context: context,
                                  textStyle: upperDescTextStyle,
                                  titleTextStyle: titleTextStyle,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Container(); // Return an empty container if no image is available
        },
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: VisibilityDetector(
        key: _mainWidgetKey,
        onVisibilityChanged: (VisibilityInfo info) async {
          // Logger.printLog('$initials ${info.visibleFraction}');
          if (info.visibleFraction > 0) {
            // Widget is at least partially visible
            if (_showBannerImage.value &&
                (_bannerImageSize.value == null ||
                    _bannerImageSize.value!.width < 1.0 ||
                    _bannerImageSize.value!.height < 1.0)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _getDescriptionContainerSize(
                  context: context,
                  textStyle: upperDescTextStyle,
                  titleTextStyle: titleTextStyle,
                );
              });
            }

            if (widget.urlPreloadMethod != UrlPreloadMethods.none &&
                _preloadUrl == false) {
              // Logger.printLog(
              //   '[customtabs] : calling mayLaunchUrl FaviconWidget ${widget.urlModelData.url}',
              // );
              final urlPreloadCubit = context.read<UrlPreloadManagerCubit>();
              // CALL CUBIT FOR THIS REQUEST
              await Future.wait(
                [
                  Future(
                    () {
                      urlPreloadCubit.preloadUrl(
                        widget.urlModel.metaData?.rssFeedUrl ??
                            widget.urlModel.url,
                        urlPreloadMethod: widget.urlPreloadMethod,
                      );
                    },
                  ),
                  Future(
                    CustomTabsClientService.warmUp,
                  ),
                ],
              );

              _preloadUrl = true;
            }
          } else {
            // Widget is not visible
            // Logger.printLog('RssFeedPreviewWidget is not visible: ${initials}');
          }
        },
        child: ValueListenableBuilder(
          valueListenable: _isSideWayLayout,
          builder: (context, isSideWays, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP BANNERIMAGE WHEN NOT IN SIDEWAYS
                if (imageBuilder != null && !isSideWays)
                  ValueListenableBuilder(
                    valueListenable: _bannerImageSize,
                    builder: (context, bannerImageSize, _) {
                      final bannerImageHeight =
                          bannerImageSize?.height != null &&
                                  bannerImageSize!.height > 1.0
                              ? min(
                                  bannerImageSize.height,
                                  size.width,
                                )
                              : null;

                      return ValueListenableBuilder(
                        valueListenable: _showBannerImage,
                        builder: (context, showBannerImage, _) {
                          if (!showBannerImage) return const SizedBox.shrink();

                          return bannerImageHeight == null
                              ? SizedBox(
                                  key: _bannerImageKey,
                                  width: size.width,
                                  child: imageBuilder,
                                )
                              : SizedBox(
                                  key: _bannerImageKey,
                                  width: size.width,
                                  height: bannerImageHeight,
                                  child: imageBuilder,
                                );
                        },
                      );
                    },
                  ),
                if (imageBuilder != null && !isSideWays)
                  const SizedBox(height: 8),

                // TITLE, SIDEWAY UPPER DESCRIPTION, BANNERIMAGE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE AND UPPERDESCRIPTION
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.urlModel.metaData?.title?.trim()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isSideWays ? 16 : 18,
                            ),
                            key: _urlTitleKey,
                          ),
                          if (descriptionAvailable && isSideWays)
                            ValueListenableBuilder(
                              valueListenable: _showFullDescription,
                              builder: (context, showFullDescription, _) {
                                if (!showFullDescription) {
                                  return Container();
                                }
                                return ValueListenableBuilder(
                                  valueListenable: _upperDescriptionIndex,
                                  builder: (context, upperDescriptionIndex, _) {
                                    // final imageSize = _bannerImageSize.value;
                                    if (upperDescriptionIndex < 1) {
                                      return Container();
                                    }

                                    var upperDescWidth = 0.0;
                                    var upperDescHeigthht = 0.0;

                                    if (_bannerImageSize.value != null &&
                                        _urlTitleSize.value != null) {
                                      upperDescWidth =
                                          _urlTitleSize.value!.width;

                                      final bannerImageHeight = min(
                                        _bannerImageSize.value!.height,
                                        size.width * 0.35,
                                      );

                                      upperDescHeigthht = bannerImageHeight -
                                          _urlTitleSize.value!.height;
                                    }

                                    final textPainter = TextPainter(
                                      textDirection: TextDirection.ltr,
                                    )
                                      ..maxLines = 1
                                      ..text = TextSpan(
                                        text: 'M',
                                        style: upperDescTextStyle,
                                      )
                                      ..layout(maxWidth: upperDescWidth);

                                    int? maxLines =
                                        (upperDescHeigthht / textPainter.height)
                                            .round();
                                    maxLines = maxLines > 0 ? maxLines : null;

                                    if (maxLines == null) {
                                      return Container();
                                    }

                                    return Text(
                                      widget.urlModel.metaData!.description!,
                                      style: upperDescTextStyle,
                                      maxLines: maxLines,
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    if (imageBuilder != null && isSideWays)
                      const SizedBox(width: 8),

                    // SIDEWAYS BANNERIMAGE
                    if (imageBuilder != null && isSideWays)
                      ValueListenableBuilder(
                        valueListenable: _bannerImageSize,
                        builder: (context, bannerImageSize, _) {
                          var bannerWidth = size.width * 0.35;

                          if (bannerImageSize?.width != null) {
                            bannerWidth =
                                min(bannerWidth, bannerImageSize!.width);
                          }

                          // Logger.printLog(
                          //   '$initials mgwidth: ${bannerImageSize?.width}, screenwidth: ${size.width * 0.35}, final $bannerWidth',
                          // );

                          final bannerImageHeight =
                              bannerImageSize?.height != null &&
                                      bannerImageSize!.height > 1.0
                                  ? min(
                                      bannerImageSize.height,
                                      size.width * 0.35,
                                    )
                                  : null;
                          return ValueListenableBuilder(
                            valueListenable: _showBannerImage,
                            builder: (context, showBannerImage, _) {
                              if (!showBannerImage) {
                                return const SizedBox.shrink();
                              }
                              return bannerImageHeight == null
                                  ? SizedBox(
                                      key: _bannerImageKey,
                                      width: bannerWidth,
                                      child: imageBuilder,
                                    )
                                  : SizedBox(
                                      key: _bannerImageKey,
                                      width: bannerWidth,
                                      height: bannerImageHeight,
                                      child: imageBuilder,
                                    );
                            },
                          );
                        },
                      ),
                  ],
                ),

                if (descriptionAvailable)
                  ValueListenableBuilder(
                    valueListenable: _showFullDescription,
                    builder: (context, showFullDescription, _) {
                      if (!showFullDescription) {
                        return Container();
                      }

                      return ValueListenableBuilder(
                        valueListenable: _upperDescriptionIndex,
                        builder: (context, upperDescriptionIndex, _) {
                          var description =
                              widget.urlModel.metaData!.description!.trim();

                          final start = min(
                            !isSideWays ? 0 : upperDescriptionIndex,
                            description.length,
                          );
                          final endIndex = description.length;

                          description = description
                              .substring(
                                start,
                                endIndex,
                              )
                              .trim();
                          if (description.isEmpty) {
                            return Container();
                          }
                          return Text(
                            description,
                            style: upperDescTextStyle,
                          );
                        },
                      );
                    },
                  ),

                /// Website details and other option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // LAUNCH IN CUSTOM TAB
                              final uri = Uri.parse(widget.urlModel.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            child: Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    final urlModelData = widget.urlModel;
                                    final urlMetaData =
                                        widget.urlModel.metaData!;

                                    var name = '';

                                    if (urlModelData.title.isNotEmpty) {
                                      name = urlModelData.title;
                                    } else if (urlMetaData.title != null &&
                                        urlMetaData.title!.isNotEmpty) {
                                      name = urlMetaData.title!;
                                    } else if (urlMetaData.websiteName !=
                                            null &&
                                        urlMetaData.websiteName!.isNotEmpty) {
                                      name = urlMetaData.websiteName!;
                                    }

                                    final placeHolder = Container(
                                      padding: const EdgeInsets.all(2),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColourPallette.black,
                                        // color: Colors.deepPurple
                                      ),
                                      child: Text(
                                        _websiteName(name, 5),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                          color: ColourPallette.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 8,
                                        ),
                                      ),
                                    );

                                    if (widget.urlModel.metaData?.faviconUrl ==
                                        null) {
                                      return placeHolder;
                                    }
                                    final metaData = widget.urlModel.metaData;

                                    if (metaData?.faviconUrl != null) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: NetworkImageBuilderWidget(
                                              imageUrl: urlMetaData.faviconUrl!,
                                              compressImage: false,
                                              errorWidgetBuilder: () {
                                                return placeHolder;
                                              },
                                              successWidgetBuilder:
                                                  (imageData) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Builder(
                                                    builder: (ctx) {
                                                      final memoryImage =
                                                          Image.memory(
                                                        imageData
                                                            .imageBytesData!,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (ctx, _, __) {
                                                          return placeHolder;
                                                        },
                                                      );
                                                      // Check if the URL ends with ".svg" to use SvgPicture or Image accordingly
                                                      if (urlMetaData
                                                          .faviconUrl!
                                                          .toLowerCase()
                                                          .endsWith('.svg')) {
                                                        // Try loading the SVG and handle errors
                                                        return FutureBuilder(
                                                          future: _loadSvgBytes(
                                                            imageData
                                                                .imageBytesData!,
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const CircularProgressIndicator();
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return memoryImage;
                                                            } else {
                                                              return snapshot
                                                                  .data!;
                                                            }
                                                          },
                                                        );
                                                      } else {
                                                        return memoryImage;
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return placeHolder;
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  StringUtils.capitalizeEachWord(
                                    _websiteName(
                                      widget.urlModel.metaData?.websiteName ??
                                          widget.urlModel.title,
                                      15,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTimeDifferenceOfFeed(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.onBookmarkButtonTap != null)
                          IconButton(
                            onPressed: widget.onBookmarkButtonTap,
                            icon: Icon(
                              widget.urlModel.isOffline
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                              color: widget.urlModel.isOffline
                                  ? ColourPallette.salemgreen
                                  : Colors.grey.shade700,
                            ),
                          ),
                        _layoutFilterOptions(),
                        IconButton(
                          onPressed: widget.onShareButtonTap,
                          icon: Icon(
                            Icons.share_rounded,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Widget> _loadSvgBytes(Uint8List svgImageBytes) async {
    try {
      return SvgPicture.memory(
        svgImageBytes,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  // Function to load SVG from a local file
  Future<Widget> _loadSvgFile(File file) async {
    try {
      // Load the SVG file
      return SvgPicture.file(
        file,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    } catch (e) {
      // Handle errors during loading
      throw Exception('Failed to load SVG from file: $e');
    }
  }

  Widget _layoutFilterOptions() {
    return FilterPopupMenuButton(
      icon: Icon(
        Icons.format_shapes_rounded,
        // Icons.more_vert_rounded,
        color: Colors.grey.shade700,
        size: 16,
      ),
      menuItems: [
        if (widget.urlModel.metaData?.description != null)
          ListFilterPopupMenuItem(
            title: 'Full Description',
            notifier: _showFullDescription,
            onPress: () =>
                _showFullDescription.value = !_showFullDescription.value,
          ),
        ListFilterPopupMenuItem(
          title: 'Show Images',
          notifier: _showBannerImage,
          onPress: () => _showBannerImage.value = !_showBannerImage.value,
        ),
      ],
    );
  }
}
