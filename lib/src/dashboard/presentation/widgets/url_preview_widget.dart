import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlPreviewWidget extends StatefulWidget {
  const UrlPreviewWidget({
    required this.urlMetaData,
    this.outerScreenHorizontalDistance = 50,
    super.key,
  });

  final UrlMetaData urlMetaData;
  final double outerScreenHorizontalDistance;

  @override
  State<UrlPreviewWidget> createState() => _UrlPreviewWidgetState();
}

class _UrlPreviewWidgetState extends State<UrlPreviewWidget> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bannerImageDim = widget.urlMetaData.bannerImage != null
        ? ImageUtils.getImageDimFromUintData(widget.urlMetaData.bannerImage!) ??
            Size(size.width, 150)
        : Size(size.width, 150);

    final bannerImageAspectRatio = bannerImageDim.width / bannerImageDim.height;

    final isSideWaysBanner = bannerImageAspectRatio <= 1.75;

    // Logger.printLog(
    //   'banner image dim : ${bannerImageDim}, ratio: $bannerImageAspectRatio',
    // );

    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.urlMetaData.bannerImage != null && !isSideWaysBanner)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                widget.urlMetaData.bannerImage!,
                height: min(
                  bannerImageDim.height,
                  (size.width - widget.outerScreenHorizontalDistance) /
                      bannerImageAspectRatio, // 50 is outer screen padding
                ),
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) {
                  return SvgPicture.memory(
                    widget.urlMetaData.bannerImage!,
                    height: size.width / bannerImageAspectRatio,
                    // fit: BoxFit.contain,
                    // color: Colors.amber,
                  );
                },
              ),
            ),
          )
        else if (widget.urlMetaData.bannerImageUrl != null && !isSideWaysBanner)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.urlMetaData.bannerImageUrl!,
                height: min(
                  bannerImageDim.height,
                  (size.width - widget.outerScreenHorizontalDistance) /
                      bannerImageAspectRatio, // 50 is outer screen padding
                ),
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) {
                  return SvgPicture.network(
                    widget.urlMetaData.bannerImageUrl!,
                    height: size.width / bannerImageAspectRatio,
                    // fit: BoxFit.contain,
                    // color: Colors.amber,
                  );
                },
              ),
            ),
          ),

        /// Title and description and bannerImage?
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.urlMetaData.title}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                      TextSpan(
                        text: !_showFullDescription ? '  more' : '  less',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              _showFullDescription = !_showFullDescription;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 8),
            if (widget.urlMetaData.bannerImage != null && isSideWaysBanner)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    widget.urlMetaData.bannerImage!,
                    width: 100,
                    height: 100 / bannerImageAspectRatio,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    // color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
        if (widget.urlMetaData.description != null && _showFullDescription)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${!_showFullDescription ? widget.urlMetaData.description!.substring(0, min(150, widget.urlMetaData.description!.length)) : widget.urlMetaData.description}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      // overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        /// Website details and other option
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  if (widget.urlMetaData.favicon != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        widget.urlMetaData.favicon!,
                        height: 16,
                        width: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, _, __) {
                          try {
                            final svgImage = SvgPicture.memory(
                              widget.urlMetaData.favicon!,
                            );

                            return svgImage;
                          } catch (e) {
                            return const SizedBox(
                              height: 56,
                              width: 56,
                              child: Icon(Icons.web),
                            );
                          }
                        },
                      ),
                    )
                  else if (widget.urlMetaData.faviconUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.urlMetaData.faviconUrl!,
                        height: 16,
                        width: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, _, __) {
                          try {
                            final svgImage = SvgPicture.network(
                              widget.urlMetaData.faviconUrl!,
                            );

                            return svgImage;
                          } catch (e) {
                            return const SizedBox(
                              height: 56,
                              width: 56,
                              child: Icon(Icons.web),
                            );
                          }
                        },
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
                      '${widget.urlMetaData.websiteName}',
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
            const Row(
              children: [
                Icon(
                  Icons.share_rounded,
                  size: 20,
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.more_vert_rounded,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
