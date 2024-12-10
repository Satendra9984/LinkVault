import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_preview_editor_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_launch_type.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/coll_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/services/rss_data_parsing_service.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/core/utils/validators.dart';
import 'package:link_vault/src/dashboard/presentation/pages/webview.dart';
import 'package:link_vault/src/rss_feeds/presentation/cubit/rss_feed_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class UpdateRssFeedUrlPage extends StatefulWidget {
  const UpdateRssFeedUrlPage({
    required this.urlModel,
    required this.isRootCollection,
    this.onDeleteURLCallback,
    this.onUpdateURLCallback,
    super.key,
  });
  final UrlModel urlModel;
  final bool isRootCollection;
  final void Function(UrlModel)? onDeleteURLCallback;
  final void Function(UrlModel)? onUpdateURLCallback;

  @override
  State<UpdateRssFeedUrlPage> createState() => _UpdateRssFeedUrlPageState();
}

class _UpdateRssFeedUrlPageState extends State<UpdateRssFeedUrlPage> {
  final _formKey = GlobalKey<FormState>();

  // RSS FEED URL BASEURL FROM USER
  final _rssFeedUrlAddressController = TextEditingController();
  final _rssFeedUrlErrorNotifier = ValueNotifier<String?>(null);

  // FOR WEBSITE BASEURL
  final _urlAddressController = TextEditingController();
  final _urlTitleController = TextEditingController();
  final _urlDescriptionController = TextEditingController();
  final _isFavorite = ValueNotifier<bool>(false);

  // CATEGORIES RELATED DATA
  final _showCategoryOptionsList = ValueNotifier(false);
  final _predefinedCategories = [...categories];
  final _selectedCategory = ValueNotifier<String>('');

  /// PREVIEW RELATED DATA
  final _showPreview = ValueNotifier<bool>(false);
  final _previewMetaData =
      ValueNotifier<UrlMetaData?>(UrlMetaData.isEmpty(title: ''));
  final _previewLoadingStates =
      ValueNotifier<LoadingStates>(LoadingStates.initial);
  final _previewError = ValueNotifier<String?>(null);
  final _allImagesUrlsList = ValueNotifier<List<String>>(<String>[]);

  // SETTINGS
  // OPEN IN
  final _urlLaunchType = ValueNotifier<UrlLaunchType>(UrlLaunchType.customTabs);
  final _feedUrlLaunchType =
      ValueNotifier<UrlLaunchType>(UrlLaunchType.separateBrowserWindow);

  Future<void> _updateUrl({required UrlCrudCubit urlCrudCubit}) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      // while (_previewLoadingStates.value == LoadingStates.loading) {}

      if (_previewMetaData.value == null) {
        // Logger.printLog('_previewametadatavalue is null');
        await _loadPreview();
      }

      if (_previewMetaData.value?.rssFeedUrl == null) return;

      final urlMetaData = _previewMetaData.value != null
          ? _previewMetaData.value!
          : widget.urlModel.metaData;

      // Logger.printLog('Previe meta data in updateurl');
      // Logger.printLog(StringUtils.getJsonFormat(urlMetaData?.toJson()));

      final updatedAt = DateTime.now().toUtc();
      final settings = <String, dynamic>{};
      settings[urlLaunchType] = _urlLaunchType.value.label;
      settings[feedUrlLaunchType] = _feedUrlLaunchType.value.label;

      final urlModelData = UrlModel(
        firestoreId: widget.urlModel.firestoreId,
        collectionId: widget.urlModel.collectionId,
        url: _urlAddressController.text,
        title: _urlTitleController.text,
        tag: _selectedCategory.value,
        description: _urlDescriptionController.text,
        isFavourite: _isFavorite.value,
        isOffline: false,
        createdAt: widget.urlModel.createdAt,
        updatedAt: updatedAt,
        metaData: urlMetaData,
        settings: settings,
      );

      // Logger.printLog(StringUtils.getJsonFormat(urlModelData.toJson()));

      await urlCrudCubit
          .updateUrl(
        urlData: urlModelData,
      )
          .then(
        (_) {
          if (widget.onUpdateURLCallback == null) return;
          widget.onUpdateURLCallback!(urlModelData);
        },
      );
    }
  }

  Future<void> _loadPreview() async {
    try {
      _formKey.currentState?.validate();

      if (_rssFeedUrlAddressController.text.trim().trim().isEmpty) {
        _rssFeedUrlErrorNotifier.value = 'RSS Link Not Verified. Try Again';
        _previewLoadingStates.value = LoadingStates.errorLoading;
        _previewError.value = 'Could Not Fetch Preview Data. Try Again';
        return;
      }

      _rssFeedUrlAddressController.text =
          Validator.formatUrl(_rssFeedUrlAddressController.text.trim());

      _urlAddressController.text = _rssFeedUrlAddressController.text;

      _previewMetaData.value =
          (_previewMetaData.value ?? UrlMetaData.isEmpty(title: '')).copyWith(
        rssFeedUrl: _rssFeedUrlAddressController.text.trim(),
      );
      // Fetching all details

      try {
        _rssFeedUrlErrorNotifier.value = null;
        _previewLoadingStates.value = LoadingStates.loading;

        final rssData = await RssXmlParsingService.fetchRssFeed(
          _rssFeedUrlAddressController.text,
        );

        // We need to extract Base URL
        if (rssData == null) {
          _rssFeedUrlErrorNotifier.value = 'RSS Link Not Verified. Try Again';
          _previewLoadingStates.value = LoadingStates.errorLoading;
          _previewError.value = 'Could Not Fetch Preview Data. Try Again';
          return;
        }
        // Extract the main channel/ feed element
        final channel = rssData.findAllElements('rdf:RDF').firstOrNull ??
            rssData.findAllElements('channel').firstOrNull ??
            rssData.findAllElements('feed').firstOrNull;

        // Logger.printLog('channel is ${channel == null}');
        if (channel == null) {
          _rssFeedUrlErrorNotifier.value = 'RSS Link Not Verified. Try Again';
          _previewLoadingStates.value = LoadingStates.errorLoading;
          _previewError.value = 'Could Not Fetch Preview Data. Try Again';
          return;
        }

        final baseUrl = RssXmlParsingService.getBaseUrlFromRssData(channel);
        // Logger.printLog('AddRSS: $baseUrl');

        if (baseUrl == null || baseUrl.isEmpty) {
          _previewLoadingStates.value = LoadingStates.errorLoading;
          _previewError.value = 'Could Not Fetch Preview Data. Try Again';
          _rssFeedUrlErrorNotifier.value = 'RSS Link Not Verified. Try Again';
          return;
        }

        _urlAddressController.text = baseUrl;

        final (websiteHtmlContent, metaData) =
            await UrlParsingService.getWebsiteMetaData(baseUrl);

        final allImageUrls = UrlParsingService.getAllImageUrlsAvailable(
          null,
          baseUrl,
          webHtmlContent: websiteHtmlContent,
        );

        _allImagesUrlsList.value = allImageUrls;

        if (metaData != null) {
          _previewMetaData.value = metaData.copyWith(
            rssFeedUrl: _rssFeedUrlAddressController.text.trim(),
            faviconUrl: widget.urlModel.metaData?.faviconUrl,
            bannerImageUrl: widget.urlModel.metaData?.bannerImageUrl,
          );
          // Initilializing default values
          if (_urlTitleController.text.isEmpty &&
              metaData.websiteName != null) {
            _urlTitleController.text = metaData.websiteName!;
          }
          _showPreview.value = true;
          _previewLoadingStates.value = LoadingStates.loaded;
          _previewError.value = null;
        } else {
          _previewLoadingStates.value = LoadingStates.errorLoading;
          _previewError.value = 'Could Not Fetch Preview Data. Try Again';
          _rssFeedUrlErrorNotifier.value = 'RSS Link Not Verified. Try Again';
          return;
        }
      } on HttpException catch (e) {
        _rssFeedUrlErrorNotifier.value = e.message;
        _previewLoadingStates.value = LoadingStates.errorLoading;
        _previewError.value = 'Could Not Fetch Preview Data. Try Again';
      } catch (e) {
        _rssFeedUrlErrorNotifier.value = 'Something Went Wrong';
        _previewLoadingStates.value = LoadingStates.errorLoading;
        _previewError.value = 'Could Not Fetch Preview Data. Try Again';
      }
    } catch (e) {}
  }

  @override
  void initState() {
    context.read<UrlCrudCubit>().cleanUp();
    _rssFeedUrlAddressController.text =
        widget.urlModel.metaData!.rssFeedUrl ?? '';
    _urlAddressController.text = widget.urlModel.url;
    _urlTitleController.text = widget.urlModel.title;
    _urlDescriptionController.text = widget.urlModel.description ?? '';
    _isFavorite.value = widget.urlModel.isFavourite;
    _selectedCategory.value = widget.urlModel.tag;
    _previewMetaData.value = widget.urlModel.metaData;
    _previewLoadingStates.value = LoadingStates.loaded;

    // Logger.printLog(
    //   '[rss] : update ${StringUtils.getJsonFormat(widget.urlModel.metaData?.toJson())}',
    // );

    _initializeSettingsOption();
    _loadPreview();
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );
  }

  void _initializeSettingsOption() {
    final settings = widget.urlModel.settings ?? {};

    if (settings.containsKey(urlLaunchType)) {
      _urlLaunchType.value =
          UrlLaunchType.fromString(settings[urlLaunchType] as String);
    }
    if (settings.containsKey(feedUrlLaunchType)) {
      _feedUrlLaunchType.value =
          UrlLaunchType.fromString(settings[feedUrlLaunchType] as String);
    }
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
    _urlLaunchType.dispose();
    _allImagesUrlsList.dispose();
    _feedUrlLaunchType.dispose();
    _showCategoryOptionsList.dispose();
    _showPreview.dispose();
    _rssFeedUrlErrorNotifier.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourPallette.white,
      appBar: AppBar(
      clipBehavior: Clip.none,

        backgroundColor: ColourPallette.white,
        surfaceTintColor: ColourPallette.mystic.withOpacity(0.5),
        title: Row(
          children: [
            Icon(
              Icons.rss_feed_rounded,
              color: Colors.deepOrange.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Update RSS Link',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
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
                    isRootCollection: widget.isRootCollection,
                  )
                  .then((_) {
                cubit.refreshCollectionFeed(
                  collectionId: collectionId,
                );

                if (widget.onDeleteURLCallback != null) {
                  widget.onDeleteURLCallback!(widget.urlModel);
                }
              });
            },
            icon: const Icon(
              Icons.delete_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              final urlAddress =
                  _rssFeedUrlAddressController.text.trim().trim();
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
                      hintText: 'https://www.thehindu.com/feeder/default.rss',
                      errorText: errorText,
                      isRequired: true,
                      keyboardType: TextInputType.url,
                      labelTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ColourPallette.black,
                      ),
                      onTapOutside: (pointer) async {
                        if (_previewMetaData.value == null &&
                                _previewLoadingStates.value !=
                                    LoadingStates.loading ||
                            _previewLoadingStates.value !=
                                LoadingStates.loaded) {
                          await _loadPreview();
                        }
                      },
                      onSubmitted: (value) async {
                        if (_previewMetaData.value == null &&
                                _previewLoadingStates.value !=
                                    LoadingStates.loading ||
                            _previewLoadingStates.value !=
                                LoadingStates.loaded) {
                          await _loadPreview();
                        }
                      },
                      validator: (value) {
                        try {
                          // Validate the URL
                          final validationResult =
                              Validator.validateUrl(value ?? '');

                          if (validationResult != null) {
                            return validationResult;
                          }

                          return null;
                        } catch (e) {
                          // Logger.printLog(e.toString());
                          return 'Could not validate Link. Something Went Wrong';
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // TITILE TEXTFIELD
                CustomCollTextField(
                  controller: _urlTitleController,
                  labelText: 'Title',
                  hintText: ' eg. google ',
                  keyboardType: TextInputType.name,
                  isRequired: true,
                  labelTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColourPallette.black,
                  ),
                  maxLength: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PREVIEW AND AUTOFILLL OPTION
                ValueListenableBuilder<LoadingStates?>(
                  valueListenable: _previewLoadingStates,
                  builder: (context, previewMetaDataLoadingState, _) {
                    final trailingWidgetList = <Widget>[];

                    final previewButton = ValueListenableBuilder(
                      valueListenable: _showPreview,
                      builder: (ctx, showPreview, _) {
                        return IconButton(
                          onPressed: () async {
                            if (previewMetaDataLoadingState ==
                                LoadingStates.loaded) {
                              _showPreview.value = !_showPreview.value;
                            } else {
                              await _loadPreview();
                            }
                          },
                          icon: Icon(
                            !showPreview
                                ? Icons.image_rounded
                                : Icons.hide_image_rounded,
                            color: ColourPallette.mountainMeadow,
                          ),
                        );
                      },
                    );

                    final loadAgain = IconButton(
                      onPressed: _loadPreview,
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
                                fontWeight: FontWeight.w400,
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
                            '${_previewError.value}',
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

                ValueListenableBuilder(
                  valueListenable: _allImagesUrlsList,
                  builder: (ctx, allImagesUrlsList, _) {
                    return ValueListenableBuilder(
                      valueListenable: _showPreview,
                      builder: (ctx, showPreview, _) {
                        if (!showPreview) {
                          return const SizedBox.shrink();
                        }
                        return ValueListenableBuilder(
                          valueListenable: _previewMetaData,
                          builder: (ctx, urlMetaData, _) {
                            if (urlMetaData == null) {
                              return const SizedBox.shrink();
                            }
                            final date = DateTime.now().toUtc();
                            final urlModelData = UrlModel(
                              firestoreId: widget.urlModel.firestoreId,
                              collectionId: widget.urlModel.collectionId,
                              url: _urlAddressController.text.trim(),
                              title: _urlTitleController.text.trim(),
                              description:
                                  _urlDescriptionController.text.trim(),
                              isFavourite: _showPreview.value,
                              tag: _selectedCategory.value,
                              isOffline: false,
                              createdAt: widget.urlModel.createdAt,
                              updatedAt: date,
                              metaData: urlMetaData,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColourPallette.white,
                                // color: ColourPallette.mystic.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ColourPallette.mystic.withOpacity(0.2),
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4, // Smoothens the shadow edges
                                  ),
                                  BoxShadow(
                                    color:
                                        ColourPallette.mystic.withOpacity(0.4),
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: URLPreviewEditorWidget(
                                urlModel: urlModelData,
                                metaDataNotifier: _previewMetaData,
                                allImageUrls: allImagesUrlsList,
                                urlPreloadMethod: UrlPreloadMethods.httpGet,
                                onTap: () async {
                                  switch (_urlLaunchType.value) {
                                    case UrlLaunchType.customTabs:
                                      {
                                        final theme = Theme.of(context);
                                        await CustomTabsService.launchUrl(
                                          url: urlModelData.url,
                                          theme: theme,
                                        ).then(
                                          (_) async {
                                            // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                            // JUST LIKE APPS IN BACKGROUND TYPE
                                          },
                                        );
                                        break;
                                      }
                                    case UrlLaunchType.webView:
                                      {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => DashboardWebView(
                                              url: urlModelData.url,
                                            ),
                                          ),
                                        );

                                        break;
                                      }
                                    case UrlLaunchType.readingMode:
                                      {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => DashboardWebView(
                                              url: urlModelData.url,
                                            ),
                                          ),
                                        );

                                        break;
                                      }
                                    case UrlLaunchType.separateBrowserWindow:
                                      {
                                        final theme = Theme.of(context);
                                        await CustomTabsService.launchUrl(
                                          url: urlModelData.url,
                                          theme: theme,
                                        ).then(
                                          (_) async {
                                            // STORE IT IN RECENTS - NEED TO DISPLAY SOME PAGE-LIKE INTERFACE
                                            // JUST LIKE APPS IN BACKGROUND TYPE
                                          },
                                        );
                                        break;
                                      }
                                  }
                                },
                                onLongPress: () {},
                                onShareButtonTap: () {
                                  final urlAddress = _urlAddressController.text;
                                  final urlTitle = _urlTitleController.text;
                                  final urlDescription =
                                      _urlDescriptionController.text;

                                  Share.share(
                                    '$urlAddress\n$urlTitle\n$urlDescription',
                                  );
                                },
                                onLayoutOptionsButtontap: () {},
                                updateBannerImage: () {},
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // SELECT CATEGORY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _showCategoryOptionsList,
                      builder: (ctx, showCategoryOptionsList, _) {
                        if (showCategoryOptionsList) {
                          return IconButton(
                            onPressed: () => _showCategoryOptionsList.value =
                                !_showCategoryOptionsList.value,
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                            ),
                          );
                        }
                        return IconButton(
                          onPressed: () => _showCategoryOptionsList.value =
                              !_showCategoryOptionsList.value,
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                ValueListenableBuilder(
                  valueListenable: _showCategoryOptionsList,
                  builder: (ctx, showCategoryOptionsList, _) {
                    if (!showCategoryOptionsList) {
                      return const SizedBox.shrink();
                    }
                    return ValueListenableBuilder<String>(
                      valueListenable: _selectedCategory,
                      builder: (context, selectedCategory, child) {
                        return Wrap(
                          spacing: 8,
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
                                    horizontal: 4,
                                    vertical: 2,
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // SETTINGS
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                const SizedBox(height: 16),

                // ALWAYS OPEN-IN SETTINGS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Open Url In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // DROPDOWN OF BROWSER, WEBVIEW
                    ValueListenableBuilder(
                      valueListenable: _urlLaunchType,
                      builder: (ctx, urlLaunchType, _) {
                        return DropdownButton<UrlLaunchType>(
                          value: urlLaunchType,
                          onChanged: (urlLaunchType) {
                            if (urlLaunchType == null) return;
                            _urlLaunchType.value = urlLaunchType;
                          },
                          isDense: true,
                          iconEnabledColor: ColourPallette.black,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          underline: const SizedBox.shrink(),
                          dropdownColor: ColourPallette.mystic,
                          items: [
                            DropdownMenuItem(
                              value: UrlLaunchType.customTabs,
                              child: Text(
                                StringUtils.capitalize(
                                  'Browser', // UrlLaunchType.customTabs.label,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: UrlLaunchType.webView,
                              child: Text(
                                StringUtils.capitalize(
                                  UrlLaunchType.webView.label,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ALWAYS RSS FEED URL OPEN-IN SETTINGS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Open RSS Feed In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // DROPDOWN OF BROWSER, WEBVIEW
                    ValueListenableBuilder(
                      valueListenable: _feedUrlLaunchType,
                      builder: (ctx, feedUrlLaunchType, _) {
                        return DropdownButton<UrlLaunchType>(
                          value: _feedUrlLaunchType.value,
                          onChanged: (feedUrlLaunchType) {
                            if (feedUrlLaunchType == null) return;
                            _feedUrlLaunchType.value = feedUrlLaunchType;
                          },
                          isDense: true,
                          iconEnabledColor: ColourPallette.black,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          underline: const SizedBox.shrink(),
                          dropdownColor: ColourPallette.mystic,
                          items: [
                            ...UrlLaunchType.values.map(
                              (urlLaunchType) => DropdownMenuItem(
                                value: urlLaunchType,
                                child: Text(
                                  StringUtils.capitalize(
                                    urlLaunchType ==
                                            UrlLaunchType.separateBrowserWindow
                                        ? 'Browser'
                                        : urlLaunchType
                                            .label, // UrlLaunchType.customTabs.label,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ADDITONAL OPTIONS
                const Text(
                  'Additional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColourPallette.salemgreen,
                  ),
                ),

                const SizedBox(height: 16),

                CustomCollTextField(
                  controller: _urlDescriptionController,
                  labelText: 'Notes',
                  hintText: ' Add your important detail here. ',
                  maxLength: 1000,
                  maxLines: 5,
                  labelTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColourPallette.black,
                  ),
                  validator: (value) {
                    return null;
                  },
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
