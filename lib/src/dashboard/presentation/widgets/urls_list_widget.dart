import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/enums/url_preview_type.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_favicon_widget.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';

class UrlsListWidget extends StatelessWidget {
  UrlsListWidget({
    required this.title,
    required this.urlList,
    required this.onAddUrlTap,
    required this.onUrlTap,
    required this.onUrlDoubleTap,
    super.key,
  });

  final String title;
  final List<UrlModel> urlList;
  final void Function() onAddUrlTap;
  final void Function(UrlModel url) onUrlTap;
  final void Function(UrlModel url) onUrlDoubleTap;

  final _urlPreviewType = ValueNotifier(UrlPreviewType.previewMeta);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Urls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuButton<UrlPreviewType>(
              color: ColourPallette.white,
              surfaceTintColor: ColourPallette.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: ColourPallette.mountainMeadow,
                  width: 1.1,
                ),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: Colors.grey.shade900,
              ),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: UrlPreviewType.icons,
                    child: Text(
                      'Icons only',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: UrlPreviewType.previewMeta,
                    child: Text(
                      'Preview only',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                _urlPreviewType.value = value;
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder(
          valueListenable: _urlPreviewType,
          builder: (context, urlPreviewType, _) {
            if (urlPreviewType == UrlPreviewType.previewMeta) {
              return _previewMetaWidget(context);
            }

            return _previewIconsWidget(context);
          },
        ),
      ],
    );
  }

  Widget _previewMetaWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: Colors.grey.shade100,
        // ),
        borderRadius: BorderRadius.circular(12),
        // color: ColourPallette.mystic.withOpacity(0.5),
      ),
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: urlList.length,
        itemBuilder: (ctx, index) {
          final url = urlList[index];
          final urlMetaData =
              url.metaData ?? UrlMetaData.isEmpty(title: url.title);

          return Column(
            children: [
              UrlPreviewWidget(
                urlMetaData: urlMetaData,
                onTap: () => onUrlTap(url),
                onDoubleTap: () => onUrlDoubleTap(url),
                onShareButtonTap: () {},
                onMoreVertButtontap: () {},
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _previewIconsWidget(BuildContext context) {
    const collectionIconWidth = 80.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: Colors.grey.shade100,
        // ),
        borderRadius: BorderRadius.circular(12),
        // color: ColourPallette.mystic.withOpacity(0.5),
      ),
      alignment: Alignment.centerLeft,
      child: AlignedGridView.extent(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: urlList.length + 1,
        maxCrossAxisExtent: collectionIconWidth,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: onAddUrlTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                // color: Colors.amber,
                child: Column(
                  children: [
                    Icon(
                      Icons.add_link_rounded,
                      size: 38,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          index = index - 1;
          final url = urlList[index];

          return UrlFaviconLogoWidget(
            onPress: () => onUrlTap(url),
            onDoubleTap: () => onUrlDoubleTap(url),
            urlModelData: url,
          );
        },
      ),
    );
  }
}
