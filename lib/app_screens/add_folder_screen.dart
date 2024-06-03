import 'package:flutter/material.dart';
import 'package:web_link_store/app_services/databases/hive_database.dart';
import 'package:web_link_store/app_models/link_tree_model.dart';
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

  void saveFolder() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      LinkTree linkTree = HiveService().getTreeData(widget.rootFolderKey)!;
      final HiveService hiveService = HiveService();
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      hiveService.add(
        LinkTree(
          id: time,
          folderName: title,
          subFolders: [],
          urls: [],
        ),
      );
      List<String> fold = linkTree.subFolders;
      fold.add(time);
      hiveService.update(
        LinkTree(
          id: widget.rootFolderKey,
          folderName: linkTree.folderName,
          subFolders: fold,
          urls: linkTree.urls,
        ),
      );
    }
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
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
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
