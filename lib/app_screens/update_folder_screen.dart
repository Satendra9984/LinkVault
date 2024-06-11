import 'package:flutter/material.dart';

import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class UpdateFolder extends StatefulWidget {
  final LinkTreeFolder currentFolder;
  const UpdateFolder({
    Key? key,
    required this.currentFolder,
  }) : super(key: key);

  @override
  State<UpdateFolder> createState() => _UpdateFolderState();
}

class _UpdateFolderState extends State<UpdateFolder> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _desc = '';
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

  Future<void> saveFolder() async {
    final isValid = _formKey.currentState!.validate();
    final HiveService hiveService = HiveService();

    if (isValid) {
      _formKey.currentState!.save();

      LinkTreeFolder updatedFolder = LinkTreeFolder(
        id: widget.currentFolder.id,
        folderName: _title,
        parentFolderId: widget.currentFolder.parentFolderId,
        subFolders: widget.currentFolder.subFolders,
        urls: widget.currentFolder.urls,
        description: _desc,
        isFavourite: _favourite,
        category: _selectedCategory,
      );

      hiveService.update(updatedFolder);
      if (_favourite && widget.currentFolder.isFavourite == false) {
        await hiveService.addFavouriteFolder(updatedFolder.id);
      }
    }

    Navigator.pop(context);
  }

  Future<void> deleteSubFolders(String id) async {
    /// get folder
    HiveService hs = HiveService();
    LinkTreeFolder? linkTree = hs.getTreeData(id);

    if (linkTree != null) {
      List<String> keys = linkTree.subFolders;

      if (keys.isEmpty) {
        return;
      }
      for (String key in keys) {
        deleteSubFolders(key);
        // hs.delete(key);
      }

      /// update folder list of root folder
      hs.delete(id);
    }
  }

  Future<void> deleteFromFavouriteAndRecent(String id) async {
    /// DELETE FROM FAVOURITE AND RECENT FOLDERS LIST
    HiveService hs = HiveService();
    await hs.removeFavouriteFolder(id);
    await hs.removeRecentFolder(id);
  }

  /// update root folder list
  void updateParentFolderList() {
    HiveService hs = HiveService();

    LinkTreeFolder parentFolder =
        hs.getTreeData(widget.currentFolder.parentFolderId)!;
    List<String> fold = parentFolder.subFolders;
    fold.removeWhere((element) => element == widget.currentFolder.id);

    LinkTreeFolder rTree = LinkTreeFolder(
      id: parentFolder.id,
      parentFolderId: parentFolder.parentFolderId,
      subFolders: fold,
      folderName: parentFolder.folderName,
      urls: parentFolder.urls,
      description: parentFolder.description,
      isFavourite: parentFolder.isFavourite,
      category: parentFolder.category,
    );

    hs.update(rTree);
  }

  void _initializeData() {
    HiveService hs = HiveService();
    LinkTreeFolder currentFolder = hs.getTreeData(widget.currentFolder.id)!;

    // debugPrint(
    //     '[log] : ${currentFolder.folderName} ${currentFolder.description} ${currentFolder.category} ${currentFolder.isFavourite}');
    _title = currentFolder.folderName;
    _desc = currentFolder.description;
    _favourite = currentFolder.isFavourite;
    _selectedCategory = currentFolder.category ?? "Default";

    // setState(() {});
  }

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Folder',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              deleteSubFolders(widget.currentFolder.id);
              await deleteFromFavouriteAndRecent(widget.currentFolder.id);
              updateParentFolderList();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.remove_circle_rounded,
              color: Colors.red.shade400,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await saveFolder();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saving'),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.check_circle,
              color: Color(0xff3cac7c),
            ),
          ),
        ],

        // elevation: 0,
        // backgroundColor: Colors.transparent,
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
                    initialValue: _title,
                    onChanged: (value) {
                      _title = value;
                    },
                    keyboardType: TextInputType.text,
                    maxLength: 30,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    cursorColor: const Color(0xff3cac7c),
                    decoration: kInputDecoration.copyWith(
                      hintText: 'folder',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter _title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                TextInput(
                  label: 'Description',
                  formField: TextFormField(
                    initialValue: _desc,
                    onChanged: (value) {
                      _desc = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    cursorColor: const Color(0xff3cac7c),
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
