import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/providers/global_user_cubit/global_user_cubit.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_button.dart';
import 'package:link_vault/core/common/presentation_layer/widgets/custom_textfield.dart';
import 'package:link_vault/core/common/repository_layer/models/collection_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/common/repository_layer/enums/collection_crud_loading_states.dart';
import 'package:link_vault/core/constants/coll_constants.dart';

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
  late final List<String> _predefinedCategories;
  final bool _favourite = false;
  String _selectedCategory = '';

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

      final subCollection = CollectionModel.isEmpty(
        userId: userId,
        name: _collectionNameController.text,
        parentCollection: widget.parentCollection.id,
        status: status,
        createdAt: createdAt,
        updatedAt: createdAt,
      ).copyWith(category: _selectedCategory);

      await collectionCubit.addCollection(collection: subCollection);
    }
  }

  void _initialize() {
    // INITITALIZING VARIABLES
    _formKey = GlobalKey<FormState>();
    _predefinedCategories = [...categories];
    _collectionNameController = TextEditingController();
    _descEditingController = TextEditingController();
    _selectedCategory = _predefinedCategories.first;
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
        backgroundColor: ColourPallette.white,
        surfaceTintColor: ColourPallette.mystic.withOpacity(0.5),
        title: Text(
          'Add Collection',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
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
                  maxLength: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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

                // Selected Category
                const Text(
                  'Categories',
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
                                  : ColourPallette.grey,
                            ),
                            borderRadius: BorderRadius.circular(16),
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
