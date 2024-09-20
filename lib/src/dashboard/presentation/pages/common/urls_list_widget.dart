import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/app_tutorials.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/url_favicon_widget.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/dashboard/data/models/collection_fetch_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_fetch_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/add_url_page.dart';
import 'package:link_vault/src/dashboard/presentation/pages/common/update_url_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlsListWidget extends StatefulWidget {
  const UrlsListWidget({
    required this.title,
    required this.collectionFetchModel,
    required this.showAddCollectionButton,
    super.key,
  });

  final String title;
  final bool showAddCollectionButton;

  // final ScrollController scrollController;
  final CollectionFetchModel collectionFetchModel;

  @override
  State<UrlsListWidget> createState() => _UrlsListWidgetState();
}

class _UrlsListWidgetState extends State<UrlsListWidget> {
  late final ScrollController _scrollController;
  final _showAppBar = ValueNotifier(true);
  var _previousOffset = 0.0;
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
      // Logger.printLog('[scroll] Called on scroll in urlslist');
      _fetchMoreUrls();
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      floatingActionButton: widget.showAddCollectionButton == false
          ? null
          : BlocBuilder<SharedInputsCubit, SharedInputsState>(
              builder: (context, state) {
                if (widget.showAddCollectionButton == false) return Container();

                final urls = context.read<SharedInputsCubit>().getUrlsList();

                final url = urls.isNotEmpty ? urls[0] : null;

                return FloatingActionButton.extended(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: ColourPallette.salemgreen,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AddUrlPage(
                          parentCollection:
                              widget.collectionFetchModel.collection!,
                          url: url,
                        ),
                      ),
                    );
                  },
                  label: const Text(
                    'Add URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColourPallette.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_link_rounded,
                    color: ColourPallette.white,
                  ),
                );
              },
            ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<CollectionsCubit, CollectionsState>(
          listener: (context, state) {},
          builder: (context, state) {
            final availableUrls = state
                .collectionUrls[widget.collectionFetchModel.collection!.id];

            if (availableUrls == null || availableUrls.isEmpty) {
              _fetchMoreUrls();
              return Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      MediaRes.webSurf1SVG,
                      // MediaRes.pageUnderConstructionSVG,
                    ),
                    GestureDetector(
                      onTap: () async {
                        const howToAddlink =
                            AppLinks.howToAddURLVideoTutorialLink;
                        final uri = Uri.parse(howToAddlink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ColourPallette.error,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: ColourPallette.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Watch How to Add URL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  controller: _scrollController,
                  child: Column(
                    children: [
                      AlignedGridView.extent(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: availableUrls.length,
                        maxCrossAxisExtent: 80,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 20,
                        itemBuilder: (context, index) {
                          final url = availableUrls[index];

                          if (url.loadingStates == LoadingStates.loading) {
                            return Center(
                              child: Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            );
                          } else if (url.loadingStates ==
                              LoadingStates.errorLoading) {
                            return SizedBox(
                              height: 56,
                              width: 56,
                              child: IconButton(
                                onPressed: _fetchMoreUrls,
                                icon: const Icon(
                                  Icons.restore,
                                  color: ColourPallette.black,
                                ),
                              ),
                            );
                          }

                          // Logger.printLog(
                          //   StringUtils.getJsonFormat(
                          //     url.urlModel!.metaData?.toJson(),
                          //   ),
                          // );

                          return UrlFaviconLogoWidget(
                            onPress: () async {
                              final uri = Uri.parse(url.urlModel!.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            onDoubleTap: (urlMetaData) {
                              final urlc = url.urlModel!.copyWith(
                                metaData: urlMetaData,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => UpdateUrlPage(
                                    urlModel: urlc,
                                  ),
                                ),
                              );
                            },
                            urlModelData: url.urlModel!,
                          );
                        },
                      ),

                      // BOTTOM HEIGHT SO THAT ALL CONTENT IS VISIBLE
                      const SizedBox(height: 120),
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
              title: Text(
                '${widget.collectionFetchModel.collection?.name}',
                style: const TextStyle(
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
}
