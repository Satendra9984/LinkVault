import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/src/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/src/common/repository_layer/enums/collection_crud_loading_states.dart';
import 'package:link_vault/src/common/repository_layer/enums/url_view_type.dart';
import 'package:link_vault/src/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/constants/coll_constants.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/utils/string_utils.dart';

class AddCollectionTemplateScreen extends StatefulWidget {
  const AddCollectionTemplateScreen({
    required this.parentCollection,
    super.key,
  });
  final CollectionModel parentCollection;

  @override
  State<AddCollectionTemplateScreen> createState() =>
      _AddCollectionTemplateScreenState();
}

class _AddCollectionTemplateScreenState
    extends State<AddCollectionTemplateScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _collectionNameController;
  late final TextEditingController _descEditingController;
  // CATEGORIES RELATED DATA
  final _showCategoryOptionsList = ValueNotifier(false);
  final _predefinedCategories = [...categories];
  final _selectedCategory = ValueNotifier<String>('');
  final bool _favourite = false;
  // SETTINGS RELATED
  final _urlsViewType = ValueNotifier(UrlViewType.favicons);

  Future<void> addCollection(
    CollectionCrudCubit collectionCubit, {
    required String userId,
  }) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final createdAt = DateTime.now().toUtc();
      final status = <String, dynamic>{
        'is_favourite': _favourite,
      };

      final settings = <String, dynamic>{};
      settings[urlsViewType] = _urlsViewType.value.label;

      final subCollection = CollectionModel.isEmpty(
        userId: userId,
        name: _collectionNameController.text,
        parentCollection: widget.parentCollection.id,
        status: status,
        createdAt: createdAt,
        updatedAt: createdAt,
      ).copyWith(
        category: _selectedCategory.value,
        settings: settings,
      );

      // Logger.printLog(StringUtils.getJsonFormat(subCollection));

      await collectionCubit.addCollection(collection: subCollection);
    }
  }

  void _initialize() {
    // INITITALIZING VARIABLES
    _formKey = GlobalKey<FormState>();
    _collectionNameController = TextEditingController();
    _descEditingController = TextEditingController();
    _selectedCategory.value = _predefinedCategories.first;
  }

  @override
  void initState() {
    context.read<CollectionCrudCubit>().cleanUp();

    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    _initialize();
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    _descEditingController.dispose();

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
            const Icon(
              Icons.create_new_folder_rounded,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Collection',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          BlocConsumer<CollectionCrudCubit, CollectionCrudCubitState>(
        listener: (context, state) {
          if (state.collectionCrudLoadingStates ==
              CollectionCrudLoadingStates.addedSuccessfully) {
            // [TODO] : PUSH REPLACE THIS SCREEN WITH COLLECTION PAGE
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final globalUserCubit = context.read<GlobalUserCubit>();
          final collectionCubit = context.read<CollectionCrudCubit>();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: CustomElevatedButton(
              onPressed: () => addCollection(
                collectionCubit,
                userId: globalUserCubit.state.globalUser!.id,
              ),
              text: 'Add Collection',
              icon: state.collectionCrudLoadingStates ==
                      CollectionCrudLoadingStates.adding
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
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCollTextField(
                  controller: _collectionNameController,
                  labelText: 'Collection Name',
                  hintText: ' eg. Exam Resources ',
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

                const SizedBox(height: 20),

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
                        'URLs View Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // DROPDOWN OF BROWSER, WEBVIEW
                    ValueListenableBuilder(
                      valueListenable: _urlsViewType,
                      builder: (ctx, urlsViewType, _) {
                        return DropdownButton<UrlViewType>(
                          value: urlsViewType,
                          onChanged: (urlsViewType) {
                            if (urlsViewType == null) return;
                            _urlsViewType.value = urlsViewType;
                          },
                          isDense: true,
                          iconEnabledColor: ColourPallette.black,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          underline: const SizedBox.shrink(),
                          dropdownColor: ColourPallette.mystic,
                          items: [
                            DropdownMenuItem(
                              value: UrlViewType.favicons,
                              child: Text(
                                StringUtils.capitalize(
                                  UrlViewType.favicons.label,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: UrlViewType.previews,
                              child: Text(
                                StringUtils.capitalize(
                                  UrlViewType.previews.label,
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
                //     Switch.adaptive(
                //       value: _favourite,
                //       onChanged: (value) => setState(() {
                //         _favourite = !_favourite;
                //       }),
                //       trackOutlineColor:
                //           WidgetStateProperty.resolveWith<Color?>(
                //         (Set<WidgetState> states) => Colors.transparent,
                //       ),
                //       thumbColor: WidgetStateProperty.resolveWith<Color?>(
                //         (Set<WidgetState> states) => Colors.transparent,
                //       ),
                //       activeTrackColor: ColourPallette.mountainMeadow,
                //       inactiveTrackColor: ColourPallette.error,
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
