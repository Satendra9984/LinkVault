import 'package:flutter/material.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/src/dashboard/data/models/collection_model.dart';
import 'package:link_vault/src/dashboard/presentation/widgets/custom_textfield.dart';

class AddCollectionPage extends StatefulWidget {
  const AddCollectionPage({
    required this.parentCollection,
    super.key,
  });
  final CollectionModel parentCollection;

  @override
  State<AddCollectionPage> createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends State<AddCollectionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _collectionNameController;
  late final TextEditingController _descEditingController;

  bool _favourite = false;
  String _selectedCategory = '';

  final List<String> _predefinedCategories = [
    'Work',
    'Personal',
    'News',
    'Social Media',
    'Entertainment',
    'Shopping',
    'Education',
    'Finance',
    'Health',
    'Travel',
    'Recipes',
    'Technology',
    'Sports',
    'Music',
    'Books',
    'Research',
    'Projects',
    'Blogs',
    'Tutorials',
    'Utilities',
  ];

  Future<void> saveFolder() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {}
  }

  @override
  void initState() {
    _selectedCategory = _predefinedCategories.first;
    _collectionNameController = TextEditingController();
    _descEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Collection',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await saveFolder();
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
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
                  hintText: ' Exam Resources ',
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
                  children:
                      List.generate(_predefinedCategories.length, (index) {
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
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// font-family: 'Montserrat', sans-serif;
// letter-spacing: -0.2px;
// font-size: $ruler;
