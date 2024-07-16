import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/errors/failure.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/enums/url_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/url_crud_cubit/url_crud_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';
import 'package:link_vault/src/dashboard/data/enums/collection_loading_states.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:link_vault/src/dashboard/services/url_parsing_service.dart';
import 'package:path/path.dart';

class UpdateUrlPage extends StatefulWidget {
  const UpdateUrlPage({
    required this.urlModel,
    super.key,
  });
  final UrlModel urlModel;

  @override
  State<UpdateUrlPage> createState() => _UpdateUrlPageState();
}

class _UpdateUrlPageState extends State<UpdateUrlPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlAddressController = TextEditingController();
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
      final urlMetaData = _previewMetaData.value != null
          ? _previewMetaData.value!
          : UrlMetaData.isEmpty(
              title: _urlTitleController.text,
            );

      // final urlMetaDataJson = urlMetaData.toJson();

      // urlMetaDataJson['banner_image'] = null;
      // urlMetaData = UrlMetaData.fromJson(urlMetaDataJson);

      final createdAt = DateTime.now().toUtc();

      final urlModelData = UrlModel(
        id: widget.urlModel.id,
        collectionId: widget.urlModel.collectionId,
        url: _urlAddressController.text,
        title: _urlTitleController.text,
        tag: _selectedCategory.value,
        description: _urlDescriptionController.text,
        isFavourite: _isFavorite.value,
        isOffline: false,
        createdAt: createdAt,
        updatedAt: createdAt,
        metaData: urlMetaData,
      );

      urlCrudCubit.updateUrl(
        urlData: urlModelData,
      );
    }
  }

  Future<void> _loadPreview() async {
    if (_urlAddressController.text.isEmpty) {
      Logger.printLog('url address is empty');
      _previewLoadingStates.value = LoadingStates.errorLoading;
      _previewError.value =
          GeneralFailure(message: 'Url Address is empty', statusCode: '400');
      return;
    }

    // Fetching all details
    _previewLoadingStates.value = LoadingStates.loading;

    final (websiteHtmlContent, metaData) =
        await UrlParsingService.getWebsiteMetaData(_urlAddressController.text);

    // Logger.printLog('htmlContentLen : ${websiteHtmlContent?.length}');

    if (metaData != null) {
      // Logger.printLog('metadata size: ${metaData.toJson().toString().length}');
      _previewMetaData.value = metaData;
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
    // }
    Logger.printLog(
      'metadata size: ${_previewMetaData.value!.toJson().toString().length}',
    );
    _previewLoadingStates.value = LoadingStates.loaded;
    await _showPreviewBottomSheet(this.context);
  }

  @override
  void initState() {
    _urlAddressController.text = widget.urlModel.url;
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
    _urlAddressController.dispose();
    _urlTitleController.dispose();
    _urlDescriptionController.dispose();
    _isFavorite.dispose();
    _selectedCategory.dispose();
    _previewMetaData.dispose();
    _previewLoadingStates.dispose();
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
          'Update Url',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<UrlCrudCubit>().deleteUrl(
                  urlData: widget.urlModel,
                ),
            icon: const Icon(
              Icons.delete_rounded,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocConsumer<UrlCrudCubit, UrlCrudCubitState>(
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
                          await _showPreviewBottomSheet(context);
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
                  controller: _urlDescriptionController,
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
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) => Colors.transparent,
                          ),
                          thumbColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) => Colors.transparent,
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
                                      : Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(6),
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
                  onDoubleTap: () => {},
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
