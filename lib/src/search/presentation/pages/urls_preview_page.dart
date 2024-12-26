// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/presentation_layer/pages/update_url_template_screen.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_previewbytes_widget.dart';
import 'package:link_vault/core/common/repository_layer/models/url_meta_data.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/res/media.dart';
import 'package:link_vault/src/search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchedUrlsPreviewListWidget extends StatefulWidget {
  const SearchedUrlsPreviewListWidget({
    super.key,
  });

  @override
  State<SearchedUrlsPreviewListWidget> createState() =>
      _SearchedUrlsPreviewListWidgetState();
}

class _SearchedUrlsPreviewListWidgetState
    extends State<SearchedUrlsPreviewListWidget>
    with AutomaticKeepAliveClientMixin {
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;

  late final ScrollController _scrollController;
  // ADDITIONAL VIEW-HELPER FILTERS
  final _atozFilter = ValueNotifier(false);
  final _ztoaFilter = ValueNotifier(false);
  final _createdAtLatestFilter = ValueNotifier(false);
  final _createdAtOldestFilter = ValueNotifier(false);
  final _updatedAtLatestFilter = ValueNotifier(false);
  final _updatedAtOldestFilter = ValueNotifier(false);

  final _list = ValueNotifier<List<UrlModel>>(<UrlModel>[]);

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.offset > _previousOffset) {
      _showAppBar.value = false;
      // widget.showBottomBar.value = false;
    } else if (_scrollController.offset < _previousOffset) {
      _showAppBar.value = true;
      // widget.showBottomBar.value = true;
    }
    _previousOffset = _scrollController.offset;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _fetchMoreUrls();
    }
  }

  void _fetchMoreUrls() {
    context.read<AdvanceSearchCubit>().searchLocalDatabaseURLs();
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
          return a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              );
        },
      );
  }

  void _filterZtoA() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          return b.title.toLowerCase().compareTo(
                a.title.toLowerCase(),
              );
        },
      );
  }

  void _filterCreateLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          return b.createdAt.compareTo(a.createdAt);
        },
      );
  }

  void _filterCreateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          return a.createdAt.compareTo(b.createdAt);
        },
      );
  }

  void _filterUpdatedLatest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          return b.updatedAt.compareTo(a.updatedAt);
        },
      );
  }

  void _filterUpdateOldest() {
    _list.value = [..._list.value]..sort(
        (a, b) {
          return a.updatedAt.compareTo(b.updatedAt);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColourPallette.white,
      appBar: _getAppBar(),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
          listener: (context, state) {},
          builder: (context, state) {
            final searchCubit = context.read<AdvanceSearchCubit>();
            _list.value = state.urls;

            _filterList();

            return ValueListenableBuilder(
              valueListenable: _list,
              builder: (context, availableUrls, _) {
                if (availableUrls.isEmpty) {
                  return Center(
                    child: SvgPicture.asset(
                      MediaRes.webSurf3SVG,
                      // MediaRes.pageUnderConstructionSVG,
                    ),
                  );
                }
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      if (availableUrls.isEmpty)
                        Center(
                          child: SvgPicture.asset(
                            MediaRes.webSurf3SVG,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: availableUrls.length,
                          itemBuilder: (ctx, index) {
                            final url = availableUrls[index];

                            final urlMetaData = url.metaData ??
                                UrlMetaData.isEmpty(
                                  title: url.title,
                                );

                            return Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: UrlPreviewBytesWidget(
                                    urlMetaData: urlMetaData,
                                    onTap: () async {
                                      final uri = Uri.parse(url.url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    onLongPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              UpdateUrlTemplateScreen(
                                            urlModel: url,
                                            isRootCollection: false,
                                          ),
                                        ),
                                      ).then(
                                        (value) {
                                          searchCubit.searchDB();
                                        },
                                      );
                                    },
                                    onShareButtonTap: () {
                                      Share.share(
                                        '${url.url}\n${urlMetaData.title}\n${urlMetaData.description}',
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
      clipBehavior: Clip.none,

              surfaceTintColor: ColourPallette.mystic,
              title: const Text(
                'Advance Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                _filterOptions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterOptions() {
    return PopupMenuButton(
      color: ColourPallette.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.filter_list,
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
