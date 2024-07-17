import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/providers/global_user_provider/global_user_cubit.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/widgets/custom_button.dart';
import 'package:link_vault/src/dashboard/data/enums/collection_crud_loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/collection_crud_cubit/collections_crud_cubit_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/custom_textfield.dart';

class UpdateCollectionPage extends StatefulWidget {
  const UpdateCollectionPage({
    required this.collection,
    super.key,
  });
  final CollectionModel collection;

  @override
  State<UpdateCollectionPage> createState() => _UpdateCollectionPageState();
}

class _UpdateCollectionPageState extends State<UpdateCollectionPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _collectionNameController;
  late final TextEditingController _descEditingController;
  late final List<String> _predefinedCategories;
  bool _favourite = false;
  String _selectedCategory = '';

  Future<void> _updateCollection(CollectionCrudCubit collectionCubit) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final updatedAt = DateTime.now().toUtc();
      final status = widget.collection.status ?? {};

      status['is_favourite'] = _favourite;

      final updatedCollection = widget.collection.copyWith(
        name: _collectionNameController.text,
        description: _descEditingController.text,
        status: status,
        updatedAt: updatedAt,
        category: _selectedCategory,
      );

      await collectionCubit.updateCollection(
        collection: updatedCollection,
      );
    }
  }

  void _initialize() {
    // INITITALIZING VARIABLES
    _formKey = GlobalKey<FormState>();
    _predefinedCategories = [...categories];
    _collectionNameController = TextEditingController();
    _descEditingController = TextEditingController();
    _selectedCategory = _predefinedCategories.first;

    // INITITALIZING VALUES
    _collectionNameController.text = widget.collection.name;
    _descEditingController.text = widget.collection.description ?? '';
    _selectedCategory = widget.collection.category;
    _favourite = (widget.collection.status?['is_favourite'] as bool?) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
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
          'Update Collection',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<CollectionCrudCubit>().deleteCollection(
                      collection: widget.collection,
                    ),
            icon: const Icon(
              Icons.delete_rounded,
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          BlocConsumer<CollectionCrudCubit, CollectionCrudCubitState>(
        listener: (context, state) {
          if (state.collectionCrudLoadingStates ==
                  CollectionCrudLoadingStates.updatedSuccessfully ||
              state.collectionCrudLoadingStates ==
                  CollectionCrudLoadingStates.deletedSuccessfully) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final globalUserCubit = context.read<GlobalUserCubit>();
          final collectionCubit = context.read<CollectionCrudCubit>();

          final isSomeOperationHappenning = state.collectionCrudLoadingStates ==
                  CollectionCrudLoadingStates.updating ||
              state.collectionCrudLoadingStates ==
                  CollectionCrudLoadingStates.deleting;

          final buttonText = switch (state.collectionCrudLoadingStates) {
            CollectionCrudLoadingStates.updating => 'Updating Collection',
            CollectionCrudLoadingStates.deleting => 'Deleting Collection',
            _ => 'Update Collection'
          };

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: CustomElevatedButton(
              onPressed: () {
                if (isSomeOperationHappenning) {
                  return;
                }
                _updateCollection(collectionCubit);
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
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) => Colors.transparent,
                      ),
                      thumbColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) => Colors.transparent,
                      ),
                      activeTrackColor: ColourPallette.mountainMeadow,
                      inactiveTrackColor: ColourPallette.error,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
