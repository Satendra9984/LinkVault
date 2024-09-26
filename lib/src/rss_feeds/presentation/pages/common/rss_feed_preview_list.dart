// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlsPreviewListWidget extends StatefulWidget {
  const UrlsPreviewListWidget({
    required this.title,
    required this.collectionFetchModel,
    required this.showBottomBar,
    super.key,
  });

  final String title;
  final ValueNotifier<bool> showBottomBar;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<UrlsPreviewListWidget> createState() => _UrlsPreviewListWidgetState();
}

class _UrlsPreviewListWidgetState extends State<UrlsPreviewListWidget>
    with AutomaticKeepAliveClientMixin {
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  // ADDITIONAL VIEW-HELPER FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);
  final _createdAtLatestFilter = ValueNotifier(false);
  final _createdAtOldestFilter = ValueNotifier(false);
  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);
  final _list = ValueNotifier<List<UrlFetchStateModel>>(<UrlFetchStateModel>[]);

  @override
  void initState() {
    // _scrollController.addListener(_onScroll);
    _getAllUrlsForFeeds();
    super.initState();
  }

  void _getAllUrlsForFeeds() {
    final urls = widget.collectionFetchModel.collection!.urls;

    final callTimes = urls.length ~/ 23;

    for (int i = 1; i <= callTimes; i++) {
      _fetchMoreUrls();
    }
  }

  // void _onScroll() {
  // if (_scrollController.offset > _previousOffset) {
  //   _showAppBar.value = false;
  //   widget.showBottomBar.value = false;
  // } else if (_scrollController.offset < _previousOffset) {
  //   _showAppBar.value = true;
  //   widget.showBottomBar.value = true;
  // }
  // _previousOffset = _scrollController.offset;
  // if (_scrollController.position.pixels >=
  //     _scrollController.position.maxScrollExtent) {
  //   _fetchMoreUrls();
  // }
  // }

  void _fetchMoreUrls() {
    final fetchCollection = widget.collectionFetchModel;

    context.read<CollectionsCubit>().fetchMoreUrls(
          collectionId: fetchCollection.collection!.id,
          userId: context.read<GlobalUserCubit>().state.globalUser!.id,
        );
  }

  void _filterList() {
    // FILTER BY TITLE
    if (_atozFilter.value) {
      _filterAtoZ();
    } else if (_ztoaFilter.value) {
      _filterZtoA();
    }

    // FILTER BY CREATED AT
    if (_createdAtLatestFilter.value) {
      _filterCreateLatest();
    } else if (_createdAtOldestFilter.value) {
      _filterCreateOldest();
    }

    // FILTER BY UPDATED AT
    if (_updatedAtLatestFilter.value) {
      _filterUpdatedLatest();
    } else if (_updatedAtOldestFilter.value) {
      _filterUpdateOldest();
    }
  }

  void _filterAtoZ() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return a.urlModel!.title.toLowerCase().compareTo(
                b.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterZtoA() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return b.urlModel!.title.toLowerCase().compareTo(
                a.urlModel!.title.toLowerCase(),
              );
        },
      );
  }

  void _filterCreateLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return b.urlModel!.createdAt.compareTo(a.urlModel!.createdAt);
        },
      );
  }

  void _filterCreateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return a.urlModel!.createdAt.compareTo(b.urlModel!.createdAt);
        },
      );
  }

  void _filterUpdatedLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return b.urlModel!.updatedAt.compareTo(a.urlModel!.updatedAt);
        },
      );
  }

  void _filterUpdateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          if (a.urlModel == null || b.urlModel == null) {
            return -1;
          }
          return a.urlModel!.updatedAt.compareTo(b.urlModel!.updatedAt);
        },
      );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showAppBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _getAppBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls = state
                .collectionUrls[widget.collectionFetchModel.collection!.id];

            if (availableUrls == null || availableUrls.isEmpty) {
              // _fetchMoreUrls();
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              );
            }

            bool isAllUrlsNotFetched = availableUrls.length !=
                    widget.collectionFetchModel.collection!.urls.length ||
                availableUrls[availableUrls.length - 1].loadingStates ==
                    LoadingStates.loading;

            if (isAllUrlsNotFetched) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      MediaRes.loadingANIMATION,
                      width: size.width,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '“Loading The Latest Feed Curated for You, by You. ”',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            _list.value = availableUrls;

            _filterList();
            return ValueListenableBuilder(
              valueListenable: _list,
              builder: (context, availableUrls, _) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableUrls.length,
                        itemBuilder: (ctx, index) {
                          final url = availableUrls[index];

                          if (url.loadingStates == LoadingStates.loading) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: size.width * 0.75,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                const Divider(),
                                // const SizedBox(height: 8),
                              ],
                            );
                          } else if (url.loadingStates ==
                              LoadingStates.errorLoading) {
                            return IconButton(
                              onPressed: _fetchMoreUrls,
                              icon: const Icon(
                                Icons.restore,
                                color: ColourPallette.black,
                              ),
                            );
                          }
                          final urlMetaData = url.urlModel!.metaData ??
                              UrlMetaData.isEmpty(
                                title: url.urlModel!.title,
                              );

                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: UrlPreviewWidget(
                                  urlMetaData: urlMetaData,
                                  onTap: () async {
                                    final uri = Uri.parse(url.urlModel!.url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  onLongPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => UpdateUrlPage(
                                          urlModel: url.urlModel!,
                                        ),
                                      ),
                                    );
                                  },
                                  onShareButtonTap: () {
                                    Share.share(
                                      '${url.urlModel?.url}\n${urlMetaData.title}\n${urlMetaData.description}',
                                    );
                                  },
                                  onMoreVertButtontap: () {},
                                ),
                              ),
                              // const SizedBox(height: 4),
                              Divider(
                                color: Colors.grey.shade200,
                              ),
                              // const SizedBox(height: 4),
                            ],
                          );
                        },
                      ),

                      // BOTTOM HEIGHT SO THAT ALL CONTENT IS VISIBLE
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSize _getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showAppBar,
        builder: (context, isVisible, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible ? kToolbarHeight + 16 : 24.0,
            child: AppBar(
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
                  const Text(
                    'Feeds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                _refreshFeedButton(),
                _filterOptions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _refreshFeedButton() {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.refresh_rounded),
    );
  }

  Widget _filterOptions() {
    return PopupMenuButton(
      color: ColourPallette.white,
      padding: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.filter_alt_rounded,
      ),
      itemBuilder: (ctx) {
        return [
          _listFilterPopUpMenyItem(
            title: 'A to Z',
            notifier: _atozFilter,
            onPress: () {
              if (_atozFilter.value) {
                _ztoaFilter.value = false;
              }
              _filterAtoZ();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Z to A',
            notifier: _ztoaFilter,
            onPress: () {
              if (_ztoaFilter.value) {
                _atozFilter.value = false;
              }
              _filterZtoA();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Latest Created First',
            notifier: _createdAtLatestFilter,
            onPress: () {
              if (_createdAtLatestFilter.value) {
                _createdAtOldestFilter.value = false;
              }
              _filterCreateLatest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Oldest Created First',
            notifier: _createdAtOldestFilter,
            onPress: () {
              if (_createdAtOldestFilter.value) {
                _createdAtLatestFilter.value = false;
              }
              _filterCreateOldest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Latest Updated First',
            notifier: _updatedAtLatestFilter,
            onPress: () {
              if (_updatedAtLatestFilter.value) {
                _updatedAtOldestFilter.value = false;
              }

              _filterUpdatedLatest();
            },
          ),
          _listFilterPopUpMenyItem(
            title: 'Oldest Updated First',
            notifier: _updatedAtOldestFilter,
            onPress: () {
              if (_updatedAtOldestFilter.value) {
                _updatedAtLatestFilter.value = false;
              }
              _filterUpdateOldest();
            },
          ),
        ];
      },
    );
  }

  PopupMenuItem<bool> _listFilterPopUpMenyItem({
    required String title,
    required ValueNotifier<bool> notifier,
    required void Function() onPress,
  }) {
    return PopupMenuItem(
      value: notifier.value,
      onTap: () {},
      enabled: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColourPallette.black,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, isFavorite, child) {
              return Checkbox.adaptive(
                value: isFavorite,
                onChanged: (_) {
                  notifier.value = !notifier.value;
                  onPress();
                },
                activeColor: ColourPallette.salemgreen,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
