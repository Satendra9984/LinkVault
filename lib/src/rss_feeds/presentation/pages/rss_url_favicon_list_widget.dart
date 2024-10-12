import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/res/app_tutorials.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/url_favicon_widget.dart';
import 'package:link_vault/src/app_home/presentation/pages/common/url_favicon_list_template_screen.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/add_rss_feed_url_screen.dart';
import 'package:link_vault/src/rss_feeds/presentation/pages/update_rss_url_page.dart';
import 'package:url_launcher/url_launcher.dart';

class RssFeedUrlsListWidget extends StatefulWidget {
  const RssFeedUrlsListWidget({
    required this.collectionFetchModel,
    required this.isRootCollection,
    super.key,
  });

  // final String title;
  final bool isRootCollection;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<RssFeedUrlsListWidget> createState() => _RssFeedUrlsListWidgetState();
}

class _RssFeedUrlsListWidgetState extends State<RssFeedUrlsListWidget>
    with AutomaticKeepAliveClientMixin {
  void _onAddUrlPressed({String? url}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddRssFeedUrlPage(
          parentCollection: widget.collectionFetchModel.collection!,
          url: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return UrlFaviconListTemplateScreen(
      collectionFetchModel: widget.collectionFetchModel,
      showAddUrlButton: true,
      onAddUrlPressed: _onAddUrlPressed,
      appBar: _appBarBuilder,
      urlsEmptyWidget: _urlsEmptyWidget(context),
      onUrlModelItemFetchedWidget: _urlItemBuilder,
    );
  }

  Widget _urlItemBuilder({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required int index,
  }) {
    final url = list.value[index].urlModel!;

    return UrlFaviconLogoWidget(
      // [TODO] : THIS IS DYNAMIC FIELD
      onTap: () async {
        final uri = Uri.parse(url.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      // [TODO] : THIS IS DYNAMIC FIELD
      onDoubleTap: (urlMetaData) {
        final urlc = url.copyWith(metaData: urlMetaData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateRssFeedUrlPage(urlModel: urlc),
          ),
        );
      },
      urlModelData: url,
    );
  }

  Widget _appBarBuilder({
    required ValueNotifier<List<UrlFetchStateModel>> list,
    required List<Widget> actions,
  }) {
    return AppBar(
      surfaceTintColor: ColourPallette.mystic,
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            MediaRes.compassSVG,
            height: 18,
            width: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.isRootCollection ? 'My Feeds' : widget.collectionFetchModel.collection?.name}(Preview)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
      ],
    );
  }

  Widget _urlsEmptyWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            MediaRes.rssFeedSVG,
            width: size.width,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 24),
          const Text(
            '“ The Feed Curated for You, by You. ”',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _linkTextWidget(
                  onTap: () async {
                    const howToAddlink = AppLinks.whatIsRSSFeed;
                    final uri = Uri.parse(howToAddlink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: ColourPallette.white,
                    size: 12,
                  ),
                  text: const Text(
                    'What is a RSS Feed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {
                    const howToAddlink = AppLinks.howToAddRSSFeedLinkOfWebsite;
                    final uri = Uri.parse(howToAddlink);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: ColourPallette.white,
                    size: 12,
                  ),
                  text: const Text(
                    'How To Use It',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Best Practices and Directions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 16),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Text(
                    'Use Collections for different topics.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Expanded(
                    child: Text(
                      'Add only optimal number of URLs (<30*) for more efficient use and readability.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _linkTextWidget(
                  onTap: () async {},
                  leading: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  iconColor: ColourPallette.white,
                  text: const Expanded(
                    child: Text(
                      'Each feed will refresh at 8 Hours interval for productive usage.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 'Give FeedBack And Suggestions:',
                const Text(
                  'Give FeedBack And Suggestions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 16,
                  spacing: 20,
                  children: [
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.linkVaultDiscord;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.discord,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: Colors.deepPurple,
                      text: const Text(
                        'Discord',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.linkVaultRedditCommunity;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.reddit_rounded,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: Colors.orange.shade800,
                      text: const Text(
                        'Reddit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _linkTextWidget(
                      onTap: () async {
                        const howToAddlink = AppLinks.twitterSatendraPal;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(
                        Icons.close,
                        color: ColourPallette.white,
                        size: 12,
                      ),
                      iconColor: ColourPallette.black,
                      text: const Text(
                        'Twitter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTextWidget({
    required VoidCallback onTap,
    required Widget leading,
    required Widget text,
    Color? iconColor,
  }) {
    iconColor ??= ColourPallette.error;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: iconColor,
            ),
            child: leading,
          ),
          const SizedBox(width: 8),
          text,
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
