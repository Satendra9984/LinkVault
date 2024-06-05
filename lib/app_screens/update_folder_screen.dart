import 'package:flutter/material.dart';

import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class UpdateFolder extends StatefulWidget {
  final LinkTreeFolder rootFolder;
  final int subFolderIndex;
  const UpdateFolder({
    Key? key,
    required this.subFolderIndex,
    required this.rootFolder,
  }) : super(key: key);

  @override
  State<UpdateFolder> createState() => _UpdateFolderState();
}

class _UpdateFolderState extends State<UpdateFolder> {
  final _formKey = GlobalKey<FormState>();
  HiveService hs = HiveService();
  String title = '', desc = '';

  void saveFolder() {
    final isValid = _formKey.currentState!.validate();
    final HiveService hiveService = HiveService();
    LinkTreeFolder linkTree = hiveService
        .getTreeData(widget.rootFolder.subFolders[widget.subFolderIndex])!;

    if (isValid) {
      _formKey.currentState!.save();

      hiveService.update(
        LinkTreeFolder(
          id: widget.rootFolder.subFolders[widget.subFolderIndex],
          folderName: title,
          subFolders: widget.rootFolder.subFolders,
          urls: widget.rootFolder.urls,
        ),
      );
    }
    debugPrint('linkTree id --> ${linkTree.id}\n${linkTree.folderName}\n');
    Navigator.pop(context);
  }

  void deleteFolder(String id) {
    /// get folder
    LinkTreeFolder? linkTree = hs.getTreeData(id);

    if (linkTree != null) {
      List<String> keys = linkTree.subFolders;

      if (keys.isEmpty) {
        return;
      }
      for (String key in keys) {
        /// deleting subfolders
        deleteFolder(key);
        hs.delete(key);
      }

      /// update folder list of root folder
      hs.delete(id);
    }
  }

  /// update root folder list
  void updateRootFolderList() {
    List<String> fold = widget.rootFolder.subFolders;
    fold.removeAt(widget.subFolderIndex);

    LinkTreeFolder rTree = LinkTreeFolder(
      id: widget.rootFolder.id,
      subFolders: fold,
      folderName: widget.rootFolder.folderName,
      urls: widget.rootFolder.urls,
    );

    hs.update(rTree);
  }

  @override
  void initState() {
    super.initState();

    title = hs
            .getTreeData(widget.rootFolder.subFolders[widget.subFolderIndex])
            ?.folderName ??
        '';
    // desc = widget.rootFolder.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Folder',
          style: TextStyle(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                saveFolder();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saving'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
          ),
          IconButton(
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                deleteFolder(
                    widget.rootFolder.subFolders[widget.subFolderIndex]);

                /// update current folder list
                updateRootFolderList();
              }).then(
                (value) => Navigator.of(context).pop(),
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
        // elevation: 0,
        // backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  label: 'Folder Name',
                  formField: TextFormField(
                    initialValue: title,
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
                TextInput(
                  label: 'Description',
                  formField: TextFormField(
                    initialValue: desc.toString(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
