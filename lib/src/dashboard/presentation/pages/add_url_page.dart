import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collections_cubit/collections_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';
import 'package:link_vault/src/dashboard/presentation/enums/collection_loading_states.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/custom_textfield.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/url_preview_widget.dart';
import 'package:link_vault/src/dashboard/services/url_parsing_service.dart';

class AddUrlPage extends StatefulWidget {
  const AddUrlPage({
    required this.parentCollection,
    super.key,
  });
  final CollectionModel parentCollection;

  @override
  State<AddUrlPage> createState() => _AddUrlPageState();
}

class _AddUrlPageState extends State<AddUrlPage> {
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

  Future<void> _addUrl(
    CollectionsCubit collectionCubit, {
    required String userId,
  }) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {}
  }

  Future<void> _loadPreview() async {}

  @override
  void dispose() {
    _urlAddressController.dispose();
    _urlNameController.dispose();
    _descEditingController.dispose();
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
          'Add Url',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar: BlocConsumer<CollectionsCubit, CollectionsState>(
        listener: (context, state) {
          if (state.collectionLoadingStates ==
              CollectionLoadingStates.successAdding) {
            // PUSH REPLACE THIS SCREEN WITH COLLECTION PAGE
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final globalUserCubit = context.read<GlobalUserCubit>();
          final collectionCubit = context.read<CollectionsCubit>();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: CustomElevatedButton(
              onPressed: () async {
                // _addUrl(
                //   collectionCubit,
                //   userId: globalUserCubit.state.globalUser!.id,
                // );
              },
              text: 'Add Url',
              icon: state.collectionLoadingStates ==
                      CollectionLoadingStates.adding
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

                    if (previewMetaDataLoadingState == LoadingStates.loading) {
                      trailingWidgetList.add(
                        const CircularProgressIndicator(
                          backgroundColor: ColourPallette.black,
                        ),
                      );
                    } else if (previewMetaDataLoadingState ==
                        LoadingStates.errorLoading) {
                      return IconButton(
                        onPressed: _loadPreview,
                        icon: const Icon(Icons.preview_rounded),
                      );
                    } else {}

                    return Column(
                      children: [
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          enabled: false,
                          leading: Text(
                            'Preview and Autofill',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(Icons.preview_rounded),
                        ),
                        if (previewMetaDataLoadingState ==
                            LoadingStates.errorLoading)
                          Text(
                            'Something Went Wrong while fetching Preview. Try Again',
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
                  labelText: 'Description',
                  hintText: ' Add your important detail here. ',
                  maxLength: 300,
                  maxLines: 3,
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
                        }),
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
                          final isSelected = category == _selectedCategory;
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

                ValueListenableBuilder<UrlMetaData?>(
                  valueListenable: _previewMetaData,
                  builder: (context, previewMetaData, child) {
                    if (previewMetaData == null) {
                      return Container();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: UrlPreviewWidget(
                        urlMetaData: previewMetaData,
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
}
