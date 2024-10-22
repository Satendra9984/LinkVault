import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/common/widgets/custom_textfield.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/shared_inputs_cubit/shared_inputs_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';

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
  final _urlNameController = TextEditingController();
  final _descEditingController = TextEditingController();
  final _isFavorite = ValueNotifier<bool>(false);
  // Categories related data
  final _predefinedCategories = [...categories];
  final _selectedCategory = ValueNotifier<String>('');

  /// PREVIEW RELATED DATA
  final _previewMetaData = ValueNotifier<UrlMetaData?>(null);
  final _previewLoadingStates =
      ValueNotifier<LoadingStates>(LoadingStates.initial);
  final _previewError = ValueNotifier<Failure?>(null);

  Future<void> _addUrl({required UrlCrudCubit urlCrudCubit}) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      while (_previewLoadingStates.value == LoadingStates.loading) {}

      if (_previewMetaData.value == null) {
        await _loadPreview();
      }

      final urlMetaData = _previewMetaData.value != null
          ? _previewMetaData.value!
          : UrlMetaData.isEmpty(
              title: _urlNameController.text,
            );

      // final urlMetaDataJson = urlMetaData.toJson();

      // urlMetaDataJson['banner_image'] = null;
      // urlMetaData = UrlMetaData.fromJson(urlMetaDataJson);

      final createdAt = DateTime.now().toUtc();

      final urlModelData = UrlModel(
        firestoreId: '',
        collectionId: widget.parentCollection.id,
        url: _urlAddressController.text,
        title: _urlNameController.text,
        description: _descEditingController.text,
        isFavourite: _isFavorite.value,
        tag: _selectedCategory.value,
        isOffline: false,
        createdAt: createdAt,
        updatedAt: createdAt,
        metaData: urlMetaData,
      );

      // Logger.printLog(StringUtils.getJsonFormat(urlModelData.toJson()));

      await urlCrudCubit.addUrl(
        urlData: urlModelData,
        isRootCollection: widget.isRootCollection,
      );
    }
  }

  Future<void> _loadPreview() async {
    if (_urlAddressController.text.isEmpty) {
      // // Logger.printLog('url address is empty');
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value =
          GeneralFailure(message: 'Url Address is empty', statusCode: '400');
      return;
    }

    // Fetching all details
    _previewLoadingStates.value = LoadingStates.loading;

    final (websiteHtmlContent, metaData) =
        await UrlParsingService.getWebsiteMetaData(_urlAddressController.text);

    // // Logger.printLog('htmlContentLen : ${websiteHtmlContent?.length}');

    if (metaData != null) {
      // // Logger.printLog('metadata size: ${metaData.toJson().toString().length}');
      _previewMetaData.value = metaData;
      _previewLoadingStates.value = LoadingStates.loaded;
      _previewError.value = null;

      // Initilializing default values
      if (_urlNameController.text.isEmpty && metaData.websiteName != null) {
        if (metaData.websiteName!.length < 30) {
          _urlNameController.text = metaData.websiteName!;
        } else {
          _urlNameController.text = metaData.websiteName!.substring(0, 30);
        }
      }
    } else {
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value = GeneralFailure(
        message: 'Something went wrong. Check your internet and try again.',
        statusCode: '400',
      );

      return;
    }
    // }
    // // Logger.printLog(
    //   'metadata size: ${_previewMetaData.value!.toJson().toString().length}',
    // );
    _previewLoadingStates.value = LoadingStates.loaded;
    await _showPreviewBottomSheet();
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
    _urlNameController.dispose();
    _descEditingController.dispose();
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
      onPopInvoked: (popInv) {
        if (widget.url != null) {
          context.read<SharedInputsCubit>().removeUrlInput(widget.url);
        }
      },
      child: Scaffold(
        backgroundColor: ColourPallette.white,
        appBar: AppBar(
          backgroundColor: ColourPallette.white,
          surfaceTintColor: ColourPallette.mystic.withOpacity(0.5),
          title: Text(
            'Add Url',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
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
                  CustomCollTextField(
                    controller: _urlAddressController,
                    labelText: 'Url Address',
                    hintText: ' eg. https://www.youtube.com ',
                    onTapOutside: (pointer) async {
                      if (_previewMetaData.value == null &&
                              _previewLoadingStates.value !=
                                  LoadingStates.loading ||
                          _previewLoadingStates.value != LoadingStates.loaded) {
                        await _loadPreview();
                      }
                    },
                    onSubmitted: (value) async {
                      if (_previewMetaData.value == null &&
                              _previewLoadingStates.value !=
                                  LoadingStates.loading ||
                          _previewLoadingStates.value != LoadingStates.loaded) {
                        await _loadPreview();
                      }
                    },
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
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
                            await _showPreviewBottomSheet();
                          } else {
                            await _loadPreview();
                          }
                        },
                        icon: const Icon(
                          Icons.preview_rounded,
                          color: ColourPallette.black,
                        ),
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
                        trailingWidgetList.add(previewButton);
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
                    controller: _urlNameController,
                    labelText: 'Title',
                    hintText: ' eg. google ',
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
                    controller: _descEditingController,
                    labelText: 'Notes',
                    hintText: ' Add your important detail here. ',
                    maxLength: 1000,
                    maxLines: 5,
                    validator: (value) {
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // IS fAVOURITE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Favourite',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isFavorite,
                        builder: (context, isFavorite, child) {
                          return Switch.adaptive(
                            value: isFavorite,
                            onChanged: (value) => _isFavorite.value = value,
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) => Colors.transparent,
                            ),
                            thumbColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) => Colors.transparent,
                            ),
                            activeTrackColor: ColourPallette.mountainMeadow,
                            inactiveTrackColor: ColourPallette.error,
                          );
                        },
                      ),
                    ],
                  ),

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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
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
                child: UrlPreviewWidget(
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
