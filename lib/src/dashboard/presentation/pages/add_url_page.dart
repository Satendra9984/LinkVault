import 'dart:convert';
import 'dart:math';

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
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _urlAddressController;
  late final TextEditingController _urlNameController;
  late final TextEditingController _descEditingController;
  late final List<String> _predefinedCategories;
  bool _favourite = false;
  String _selectedCategory = '';

  UrlMetaData? _previewMetaData;

  late LoadingStates _previewLoadingStates;

  Future<void> _addUrl(
    CollectionsCubit collectionCubit, {
    required String userId,
  }) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {}
  }

  void _initialize() {
    // INITITALIZING VARIABLES
    _formKey = GlobalKey<FormState>();
    _predefinedCategories = [...categories];
    _urlAddressController = TextEditingController();
    _urlNameController = TextEditingController();
    _descEditingController = TextEditingController();
    _selectedCategory = _predefinedCategories.first;
    _previewLoadingStates = LoadingStates.initial;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _urlAddressController.dispose();
    _urlNameController.dispose();
    _descEditingController.dispose();
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
                
                await UrlParsingService()
                    .getWebsiteMetaData(_urlAddressController.text)
                    .then((data) {
                  final (html, metadata) = data;
                  setState(() {
                    _previewMetaData = metadata;
                  });
                });
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

                if (_previewMetaData != null)
                  Column(
                    children: [
                      if (_previewMetaData!.bannerImage != null)
                        SizedBox(
                          child: Image.memory(
                            _previewMetaData!.bannerImage!,
                          ),
                        ),
                      if (_previewMetaData!.title != null)
                        Text(
                          _previewMetaData!.title!,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (_previewMetaData!.websiteName != null)
                        Text(
                          _previewMetaData!.websiteName!,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (_previewMetaData!.description != null)
                        Text(
                          _previewMetaData!.description!,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (_previewMetaData!.favicon != null)
                        SizedBox(
                          child: Image.memory(
                            _previewMetaData!.favicon!,
                          ),
                        ),
                    ],
                  ),

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
                    Switch.adaptive(
                      value: _favourite,
                      onChanged: (value) => setState(() {
                        _favourite = !_favourite;
                      }),
                      trackOutlineColor:
                          WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) => Colors.transparent,
                      ),
                      thumbColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) => Colors.transparent,
                      ),
                      activeTrackColor: ColourPallette.mountainMeadow,
                      inactiveTrackColor: ColourPallette.error,
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

                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: List.generate(
                    _predefinedCategories.length,
                    (index) {
                      final category = _predefinedCategories[index];
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategory = category;
                        }),
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
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
