import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_preview_editor_widget.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/url_previewbytes_widget.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_crud_loading_states.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_launch_type.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/common/repository_layer/models/url_meta_data.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';
import 'package:link_vault/core/constants/coll_constants.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/services/url_parsing_service.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/core/utils/validators.dart';
import 'package:link_vault/src/dashboard/presentation/pages/webview.dart';
import 'package:share_plus/share_plus.dart';

// https://youtu.be/jMi-VwEBJ70

class AddUrlTemplateScreen extends StatefulWidget {
  const AddUrlTemplateScreen({
    required this.parentCollection,
    required this.isRootCollection,
    this.url,
    super.key,
  });
  final CollectionModel parentCollection;
  final String? url;
  final bool isRootCollection;

  @override
  State<AddUrlTemplateScreen> createState() => _AddUrlTemplateScreenState();
}

class _AddUrlTemplateScreenState extends State<AddUrlTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlAddressController = TextEditingController();
  final _urlTitleController = TextEditingController();
  final _urlDescriptionController = TextEditingController();
  final _isFavorite = ValueNotifier<bool>(false);
  // CATEGORIES RELATED DATA
  final _showCategoryOptionsList = ValueNotifier(false);
  final _predefinedCategories = [...categories];
  final _selectedCategory = ValueNotifier<String>('');

  // SETTINGS
  // OPEN IN
  final _urlLaunchType = ValueNotifier<UrlLaunchType>(UrlLaunchType.webView);

  /// PREVIEW RELATED DATA
  final _showPreview = ValueNotifier<bool>(false);
  final _previewMetaData = ValueNotifier<UrlMetaData?>(null);
  final _previewLoadingStates =
      ValueNotifier<LoadingStates>(LoadingStates.initial);
  final _previewError = ValueNotifier<Failure?>(null);
  final _allImagesUrlsList = ValueNotifier<List<String>>(<String>[]);

  Future<void> _addUrl({required UrlCrudCubit urlCrudCubit}) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _urlAddressController.text =
          Validator.formatUrl(_urlAddressController.text);
      // while (_previewLoadingStates.value == LoadingStates.loading) {}

      if (_previewMetaData.value == null) {
        await _loadPreview();
      }

      final urlMetaData = _previewMetaData.value != null
          ? _previewMetaData.value!
          : UrlMetaData.isEmpty(
              title: _urlTitleController.text,
            );

      final settings = <String, dynamic>{};

      settings[urlLaunchType] = _urlLaunchType.value.label;

      final createdAt = DateTime.now().toUtc();

      final urlModelData = UrlModel(
        firestoreId: '',
        collectionId: widget.parentCollection.id,
        url: _urlAddressController.text,
        title: _urlTitleController.text,
        description: _urlDescriptionController.text,
        isFavourite: _isFavorite.value,
        tag: _selectedCategory.value,
        isOffline: false,
        createdAt: createdAt,
        updatedAt: createdAt,
        metaData: urlMetaData,
        settings: settings,
      );

      // Logger.printLog(StringUtils.getJsonFormat(urlModelData.toJson()));

      await urlCrudCubit.addUrl(
        urlData: urlModelData,
        isRootCollection: widget.isRootCollection,
      );
    }
  }

  Future<void> _loadPreview() async {
    try {
      _formKey.currentState?.validate();

      if (_urlAddressController.text.isEmpty) {
        _previewLoadingStates.value = LoadingStates.errorLoading;
        _previewError.value =
            GeneralFailure(message: 'Link Address is empty', statusCode: '400');
        return;
      }

      // Fetching all details
      _urlAddressController.text =
          Validator.formatUrl(_urlAddressController.text);

      _previewLoadingStates.value = LoadingStates.loading;
      _previewError.value = null;

      final (websiteHtmlContent, metaData) =
          await UrlParsingService.getWebsiteMetaData(
        _urlAddressController.text,
      );

      // Logger.printLog('htmlContentLen : ${websiteHtmlContent?.length}');
      final allImageUrls = UrlParsingService.getAllImageUrlsAvailable(
        null,
        _urlAddressController.text,
        webHtmlContent: websiteHtmlContent,
      );

      _allImagesUrlsList.value = allImageUrls;

      if (metaData != null) {
        // Logger.printLog('metadata size: ${metaData.toJson().toString().length}');
        _previewMetaData.value = metaData;
        _previewLoadingStates.value = LoadingStates.loaded;
        _previewError.value = null;

        // Initilializing default values
        if (_urlTitleController.text.isEmpty && metaData.websiteName != null) {
          if (metaData.websiteName!.length < 30) {
            _urlTitleController.text = metaData.websiteName!;
          } else {
            _urlTitleController.text = metaData.websiteName!.substring(0, 30);
          }
        }

        _previewLoadingStates.value = LoadingStates.loaded;
        _showPreview.value = true;
        _previewError.value = null;
      } else {
        _previewLoadingStates.value = LoadingStates.errorLoading;
        _previewError.value = GeneralFailure(
          message: 'Something went wrong. Check your internet and try again.',
          statusCode: '400',
        );
      }
    } catch (e) {}
  }

  @override
  void initState() {
    context.read<UrlCrudCubit>().cleanUp();

    _urlAddressController.text = widget.url ?? '';
    // context.read<SharedInputsCubit>().removeInput();
    _selectedCategory.value = _predefinedCategories.first;
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );
  }

  @override
  void dispose() {
    _urlAddressController.dispose();
    _urlTitleController.dispose();
    _urlDescriptionController.dispose();
    _isFavorite.dispose();
    _selectedCategory.dispose();
    _previewMetaData.dispose();
    _previewLoadingStates.dispose();
    // if (widget.url != null) {
    //   context.read<SharedInputsCubit>().removeUrlInput();
    // }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (popInv, _) {
        if (widget.url != null) {
          context.read<SharedInputsCubit>().removeUrlInput(widget.url);
        }
      },
      child: Scaffold(
        backgroundColor: ColourPallette.white,
        appBar: AppBar(
      clipBehavior: Clip.none,

          backgroundColor: ColourPallette.white,
          surfaceTintColor: ColourPallette.mystic.withOpacity(0.5),
          title: Row(
            children: [
              const Icon(
                Icons.add_link_rounded,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Link',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocConsumer<UrlCrudCubit, UrlCrudCubitState>(
          listener: (context, state) {
            if (state.urlCrudLoadingStates ==
                UrlCrudLoadingStates.addedSuccessfully) {
              // PUSH REPLACE THIS SCREEN WITH COLLECTION PAGE
              if (widget.url != null) {
                context.read<SharedInputsCubit>().removeUrlInput(widget.url);
              }
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            // final globalUserCubit = context.read<GlobalUserCubit>();
            final urlCrudCubit = context.read<UrlCrudCubit>();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CustomElevatedButton(
                onPressed: () async {
                  await _addUrl(
                    urlCrudCubit: urlCrudCubit,
                  );
                },
                text: 'Add Url',
                icon: state.urlCrudLoadingStates == UrlCrudLoadingStates.adding
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // URL-ADDRESS TEXTFIELD
                  CustomCollTextField(
                    controller: _urlAddressController,
                    labelText: 'Link Address',
                    hintText: 'e.g., https://www.youtube.com',
                    keyboardType: TextInputType.url,
                    isRequired: true,
                    labelTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColourPallette.black,
                    ),
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
                    onEditingCompleted: () {
                      _urlAddressController.text =
                          Validator.formatUrl(_urlAddressController.text);
                    },
                    onSubmitted: (value) {
                      // Format the URL and update the controller
                      _urlAddressController.text = Validator.formatUrl(value);
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

                      if (previewMetaDataLoadingState ==
                          LoadingStates.loading) {
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
                                firestoreId: '',
                                collectionId: '',
                                url: _urlAddressController.text.trim(),
                                title: _urlTitleController.text.trim(),
                                description:
                                    _urlDescriptionController.text.trim(),
                                isFavourite: _showPreview.value,
                                tag: _selectedCategory.value,
                                isOffline: false,
                                createdAt: date,
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
                                      color: ColourPallette.mystic
                                          .withOpacity(0.2),
                                      spreadRadius: 2,
                                      offset: const Offset(0, 2),
                                      blurRadius:
                                          4, // Smoothens the shadow edges
                                    ),
                                    BoxShadow(
                                      color: ColourPallette.mystic
                                          .withOpacity(0.4),
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
                                              builder: (ctx) =>
                                                  DashboardWebView(
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
                                              builder: (ctx) =>
                                                  DashboardWebView(
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
                                    final urlAddress =
                                        _urlAddressController.text;
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
                                  onTap: () =>
                                      _selectedCategory.value = category,
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
                          'Always Open In',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPreviewBottomSheet() async {
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
                child: UrlPreviewBytesWidget(
                  urlMetaData: _previewMetaData.value!,
                  onTap: () {},
                  onLongPress: () {},
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
