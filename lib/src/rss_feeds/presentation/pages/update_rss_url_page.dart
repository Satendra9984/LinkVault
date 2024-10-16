import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/common/widgets/custom_textfield.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/src/app_home/services/rss_service.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class UpdateRssFeedUrlPage extends StatefulWidget {
  const UpdateRssFeedUrlPage({
    required this.urlModel,
    super.key,
  });
  final UrlModel urlModel;

  @override
  State<UpdateRssFeedUrlPage> createState() => _UpdateRssFeedUrlPageState();
}

class _UpdateRssFeedUrlPageState extends State<UpdateRssFeedUrlPage> {
  final _formKey = GlobalKey<FormState>();
  final _rssFeedUrlAddressController = TextEditingController();
  final _websiteUrlAddressController = TextEditingController();

  final _rssFeedUrlErrorNotifier = ValueNotifier<String?>(null);

  final _urlTitleController = TextEditingController();
  final _urlDescriptionController = TextEditingController();
  final _isFavorite = ValueNotifier<bool>(false);
  // CATEGORIES RELATED DATA
  final _predefinedCategories = [...categories];
  final _selectedCategory = ValueNotifier<String>('');

  /// PREVIEW RELATED DATA
  final _previewMetaData = ValueNotifier<UrlMetaData?>(null);
  final _previewLoadingStates =
      ValueNotifier<LoadingStates>(LoadingStates.initial);
  final _previewError = ValueNotifier<Failure?>(null);

  Future<void> _updateUrl({required UrlCrudCubit urlCrudCubit}) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final isRssUrlValid = await RssXmlParsingService.isURLRssFeed(
        _rssFeedUrlAddressController.text,
      );

      if (isRssUrlValid == false) {
        _rssFeedUrlErrorNotifier.value = 'Invalid RSS Feed URL';
        return;
      } else {
        _rssFeedUrlErrorNotifier.value = null;
      }

      final urlMetaData = _previewMetaData.value != null
          ? _previewMetaData.value!
          : UrlMetaData.isEmpty(
              title: _urlTitleController.text,
            );

      final updatedAt = DateTime.now().toUtc();

      final urlModelData = UrlModel(
        firestoreId: widget.urlModel.firestoreId,
        collectionId: widget.urlModel.collectionId,
        url: _websiteUrlAddressController.text,
        title: _urlTitleController.text,
        tag: _selectedCategory.value,
        description: _urlDescriptionController.text,
        isFavourite: _isFavorite.value,
        isOffline: false,
        createdAt: widget.urlModel.createdAt,
        updatedAt: updatedAt,
        metaData: urlMetaData,
      );

      await urlCrudCubit.updateUrl(
        urlData: urlModelData,
      );
    }
  }

  Future<void> _loadPreview() async {
    if (_rssFeedUrlAddressController.text.isEmpty) {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value =
          GeneralFailure(message: 'Url Address is empty', statusCode: '400');
      return;
    }

    // Fetching all details
    _previewLoadingStates.value = LoadingStates.loading;

    final rssData = await RssXmlParsingService.fetchRssFeed(
      _rssFeedUrlAddressController.text,
    );

    // We need to extract Base URL
    if (rssData == null) {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value = GeneralFailure(
        message: 'Something went wrong. Check your internet and try again.',
        statusCode: '400',
      );
      // Logger.printLog('[rss]: error rssData is null');

      return;
    }
    // final channel = rssData.findAllElements('channel').first;
    // Extract the main channel/ feed element
    final channel = rssData.findAllElements('rdf:RDF').firstOrNull ??
        rssData.findAllElements('channel').firstOrNull ??
        rssData.findAllElements('feed').firstOrNull;

    // Logger.printLog('channel is ${channel == null}');
    if (channel == null) {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      return;
    }

    final baseUrl = RssXmlParsingService.getBaseUrlFromRssData(channel);
    // Logger.printLog('AddRSS: $baseUrl');

    if (baseUrl == null || baseUrl.isEmpty) {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      return;
    }

    _websiteUrlAddressController.text = baseUrl;
    final (websiteHtmlContent, metaData) =
        await UrlParsingService.getWebsiteMetaData(baseUrl);

    if (metaData != null) {
      _previewMetaData.value = metaData.copyWith(
        rssFeedUrl: _rssFeedUrlAddressController.text,
      );
      _previewLoadingStates.value = LoadingStates.loaded;
      _previewError.value = null;

      // Initilializing default values
      if (_urlTitleController.text.isEmpty && metaData.websiteName != null) {
        _urlTitleController.text = metaData.websiteName!;
      }
    } else {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value = GeneralFailure(
        message: 'Something went wrong. Check your internet and try again.',
        statusCode: '400',
      );

      return;
    }
    _previewLoadingStates.value = LoadingStates.loaded;
  }

  @override
  void initState() {
    context.read<UrlCrudCubit>().cleanUp();
    _rssFeedUrlAddressController.text =
        widget.urlModel.metaData!.rssFeedUrl ?? '';
    _websiteUrlAddressController.text = widget.urlModel.url;
    _urlTitleController.text = widget.urlModel.title;
    _urlDescriptionController.text = widget.urlModel.description ?? '';
    _isFavorite.value = widget.urlModel.isFavourite;
    _selectedCategory.value = widget.urlModel.tag;
    _previewMetaData.value = widget.urlModel.metaData;
    _previewLoadingStates.value = LoadingStates.loaded;
    super.initState();
  }

  @override
  void dispose() {
    _rssFeedUrlAddressController.dispose();
    _urlTitleController.dispose();
    _urlDescriptionController.dispose();
    _isFavorite.dispose();
    _selectedCategory.dispose();
    _previewMetaData.dispose();
    _previewLoadingStates.dispose();
    _previewError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourPallette.white,
      appBar: AppBar(
        backgroundColor: ColourPallette.white,
        surfaceTintColor: ColourPallette.mystic.withOpacity(0.5),
        title: Text(
          'Update RSS Feed Url',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final cubit = context.read<RssFeedCubit>();
              final collectionId = widget.urlModel.collectionId;

              await context
                  .read<UrlCrudCubit>()
                  .deleteUrl(
                    urlData: widget.urlModel,
                  )
                  .then((_) {
                cubit.refreshCollectionFeed(
                  collectionId: collectionId,
                );
              });
            },
            icon: const Icon(
              Icons.delete_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              final urlAddress = _rssFeedUrlAddressController.text;
              final urlTitle = _urlTitleController.text;
              final urlDescription = _urlDescriptionController.text;

              Share.share(
                '$urlAddress\n$urlTitle\n$urlDescription',
              );
            },
            icon: const Icon(
              Icons.share_rounded,
              size: 20,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BlocConsumer<UrlCrudCubit, UrlCrudCubitState>(
          listener: (context, state) {
            if (state.urlCrudLoadingStates ==
                    UrlCrudLoadingStates.updatedSuccessfully ||
                state.urlCrudLoadingStates ==
                    UrlCrudLoadingStates.deletedSuccessfully) {
              // PUSH REPLACE THIS SCREEN WITH COLLECTION PAGE
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            // final globalUserCubit = context.read<GlobalUserCubit>();
            final urlCrudCubit = context.read<UrlCrudCubit>();

            final isSomeOperationHappenning =
                state.urlCrudLoadingStates == UrlCrudLoadingStates.updating ||
                    state.urlCrudLoadingStates == UrlCrudLoadingStates.deleting;

            final buttonText = switch (state.urlCrudLoadingStates) {
              UrlCrudLoadingStates.updating => 'Updating Url',
              UrlCrudLoadingStates.deleting => 'Deleting Url',
              _ => 'Update Url'
            };

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CustomElevatedButton(
                onPressed: () {
                  if (isSomeOperationHappenning) {
                    return;
                  }
                  _updateUrl(urlCrudCubit: urlCrudCubit);
                },
                text: buttonText,
                icon: isSomeOperationHappenning
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: ColourPallette.bitterlemon,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: _rssFeedUrlErrorNotifier,
                  builder: (context, errorText, _) {
                    return CustomCollTextField(
                      controller: _rssFeedUrlAddressController,
                      labelText: 'RSS Feed URL',
                      hintText:
                          ' eg. https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml ',
                      errorText: errorText,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                ValueListenableBuilder<LoadingStates?>(
                  valueListenable: _previewLoadingStates,
                  builder: (context, previewMetaDataLoadingState, _) {
                    final trailingWidgetList = <Widget>[];

                    final previewButton = IconButton(
                      onPressed: () async {
                        if (_previewMetaData.value != null) {
                          await _showPreviewBottomSheet(context);
                        } else {
                          await _loadPreview().then(
                            (_) async => _showPreviewBottomSheet(context),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.preview_rounded,
                        color: ColourPallette.black,
                      ),
                    );

                    final loadAgain = IconButton(
                      onPressed: () async => _loadPreview().then(
                        (_) async => _showPreviewBottomSheet(context),
                      ),
                      icon: const Icon(
                        Icons.restore_rounded,
                        color: ColourPallette.black,
                      ),
                    );

                    if (previewMetaDataLoadingState == LoadingStates.loading) {
                      trailingWidgetList.add(
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: ColourPallette.black,
                            color: ColourPallette.white,
                          ),
                        ),
                      );
                    } else if (previewMetaDataLoadingState ==
                        LoadingStates.loaded) {
                      trailingWidgetList.addAll(
                        [loadAgain, previewButton],
                      );
                    } else {
                      trailingWidgetList.addAll(
                        [loadAgain, previewButton],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Preview and Autofill',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColourPallette.black,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: trailingWidgetList,
                            ),
                          ],
                        ),
                        if (previewMetaDataLoadingState ==
                            LoadingStates.errorLoading)
                          Text(
                            '${_previewError.value?.message}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColourPallette.error,
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                CustomCollTextField(
                  controller: _urlTitleController,
                  labelText: 'Title',
                  hintText: ' eg. The Hindustan Times ',
                  keyboardType: TextInputType.name,
                  maxLength: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomCollTextField(
                  controller: _urlDescriptionController,
                  labelText: 'Notes',
                  hintText: ' Add your important detailS here. ',
                  maxLength: 1000,
                  maxLines: 5,
                  validator: (value) {
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // IS fAVOURITE
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text(
                //       'Favourite',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     ValueListenableBuilder<bool>(
                //       valueListenable: _isFavorite,
                //       builder: (context, isFavorite, child) {
                //         return Switch.adaptive(
                //           value: isFavorite,
                //           onChanged: (value) => _isFavorite.value = value,
                //           trackOutlineColor:
                //               WidgetStateProperty.resolveWith<Color?>(
                //             (Set<WidgetState> states) => Colors.transparent,
                //           ),
                //           thumbColor: WidgetStateProperty.resolveWith<Color?>(
                //             (Set<WidgetState> states) => Colors.transparent,
                //           ),
                //           activeTrackColor: ColourPallette.mountainMeadow,
                //           inactiveTrackColor: ColourPallette.error,
                //         );
                //       },
                //     ),
                //   ],
                // ),

                const SizedBox(height: 20),

                // Selected Category
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                ValueListenableBuilder<String>(
                  valueListenable: _selectedCategory,
                  builder: (context, selectedCategory, child) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(
                        _predefinedCategories.length,
                        (index) {
                          final category = _predefinedCategories[index];
                          final isSelected =
                              category == _selectedCategory.value;
                          return GestureDetector(
                            onTap: () => _selectedCategory.value = category,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ColourPallette.mountainMeadow
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? ColourPallette.mountainMeadow
                                      : ColourPallette.grey,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPreviewBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColourPallette.mystic,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: UrlPreviewWidget(
                  urlMetaData: _previewMetaData.value!,
                  onTap: () => {},
                  onLongPress: () => {},
                  onShareButtonTap: () {},
                  onMoreVertButtontap: () {},
                ),
              );
            },
          ),
        );
      },
    );
  }
}
