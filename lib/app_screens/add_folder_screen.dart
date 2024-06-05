import 'package:flutter/material.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import 'package:web_link_store/app_models/link_tree_folder_model.dart';
import 'package:web_link_store/constants.dart';

import '../app_widgets/text_input.dart';

class AddFolderScreen extends StatefulWidget {
  final String rootFolderKey;
  const AddFolderScreen({
    Key? key,
    required this.rootFolderKey,
  }) : super(key: key);

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', desc = '';
  bool _favourite = false;
  String _selectedCategory = "";
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
    'Utilities'
  ];

  void saveFolder() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      LinkTreeFolder linkTree =
          HiveService().getTreeData(widget.rootFolderKey)!;
      final HiveService hiveService = HiveService();
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      hiveService.add(
        LinkTreeFolder(
          id: time,
          folderName: title,
          subFolders: [],
          urls: [],
        ),
      );
      List<String> fold = linkTree.subFolders;
      fold.add(time);
      hiveService.update(
        LinkTreeFolder(
          id: widget.rootFolderKey,
          folderName: linkTree.folderName,
          subFolders: fold,
          urls: linkTree.urls,
        ),
      );
    }
  }

  @override
  void initState() {
    _selectedCategory = _predefinedCategories.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Folder',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                saveFolder();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Saving',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
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
                TextInput(
                  label: 'Folder Name',
                  formField: TextFormField(
                    onChanged: (value) {
                      title = value;
                    },
                    keyboardType: TextInputType.text,
                    maxLength: 30,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    decoration: kInputDecoration.copyWith(
                      hintText: 'folder',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  label: 'Description',
                  formField: TextFormField(
                    onChanged: (value) {
                      desc = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    decoration: kInputDecoration.copyWith(
                      hintText: 'save your important details here',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

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
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Selected Category
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12.0),

                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children:
                      List.generate(_predefinedCategories.length, (index) {
                    var category = _predefinedCategories[index];
                    bool isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = category;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
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
