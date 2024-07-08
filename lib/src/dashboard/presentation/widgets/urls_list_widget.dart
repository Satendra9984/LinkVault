import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlsListWidget extends StatelessWidget {
  const UrlsListWidget({
    required this.urlList,
    required this.onAddUrlTap,
    required this.onUrlTap,
    required this.onUrlDoubleTap,
    super.key,
  });

  final List<UrlModel> urlList;
  final void Function() onAddUrlTap;
  final void Function(UrlModel url) onUrlTap;
  final void Function(UrlModel url) onUrlDoubleTap;

  @override
  Widget build(BuildContext context) {
    const collectionIconWidth = 80.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        borderRadius: BorderRadius.circular(12),
        color: ColourPallette.mystic.withOpacity(0.5),
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
          return Text(url.title);
        },
      ),
    );
  }
}
