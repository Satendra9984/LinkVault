import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_preload_manager_cubit/url_preload_manager_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/network_image_builder_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_client_service.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UrlFaviconLogoWidget extends StatefulWidget {
  const UrlFaviconLogoWidget({
    required this.onLongPress,
    required this.onTap,
    required this.urlModelData,
    required this.urlPreloadMethod,
    super.key,
  });
  final UrlModel urlModelData;
  final void Function(UrlMetaData) onLongPress;
  final void Function() onTap;
  final UrlPreloadMethods urlPreloadMethod;

  @override
  State<UrlFaviconLogoWidget> createState() => _UrlFaviconLogoWidgetState();
}

class _UrlFaviconLogoWidgetState extends State<UrlFaviconLogoWidget> {
  var _preloadUrl = false;

  @override
  Widget build(BuildContext context) {
    final urlMetaData = widget.urlModelData.metaData ??
        UrlMetaData.isEmpty(title: widget.urlModelData.title);

    return VisibilityDetector(
      key: Key(
        widget.urlModelData.firestoreId + widget.urlModelData.collectionId,
      ),
      onVisibilityChanged: (visibleInfo) async {
        if (widget.urlPreloadMethod != UrlPreloadMethods.none &&
            visibleInfo.visibleFraction > 0 &&
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
                    widget.urlModelData.url,
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
        } else {
          // Logger.printLog(
          //   '[customtabs] : not calling mayLaunchUrl FaviconWidget ${widget.urlModelData.url}',
          // );
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => widget.onLongPress(urlMetaData),
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
              StringUtils.capitalizeEachWord(widget.urlModelData.title),
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
      ),
    );
  }

  Widget _getLogoWidget({
    required BuildContext context,
    required UrlMetaData urlMetaData,
  }) {
    // Logger.printLog(StringUtils.getJsonFormat(urlModelData.toJson()));

    var name = '';

    if (widget.urlModelData.title.isNotEmpty) {
      name = widget.urlModelData.title;
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

    if (urlMetaData.faviconUrl != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: NetworkImageBuilderWidget(
            imageUrl: urlMetaData.faviconUrl!,
            compressImage: false,
            errorWidgetBuilder: () {
              return placeHolder;
            },
            successWidgetBuilder: (imageData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Builder(
                  builder: (ctx) {
                    // Check if the URL ends with ".svg" to use SvgPicture or Image accordingly
                    if (urlMetaData.faviconUrl!
                        .toLowerCase()
                        .endsWith('.svg')) {
                      // Try loading the SVG and handle errors
                      return FutureBuilder(
                        future: _loadSvg(imageData.imageBytesData!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show a loading indicator while loading the SVG
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // Fallback if SVG fails to load
                            return placeHolder;
                          } else {
                            // Return the successfully loaded SVG
                            return snapshot.data!;
                          }
                        },
                      );
                    } else {
                      return Image.memory(
                        imageData.imageBytesData!,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, _, __) {
                          return placeHolder;
                        },
                      );
                    }
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

  Future<Widget> _loadSvg(Uint8List svgImageBytes) async {
    try {
      return SvgPicture.memory(
        svgImageBytes,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }
}
