import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class UpdateUrlScreen extends StatefulWidget {
  final LinkTree rootFolder;
  final int urlIndex;
  const UpdateUrlScreen({
    Key? key,
    required this.urlIndex,
    required this.rootFolder,
  }) : super(key: key);

  @override
  State<UpdateUrlScreen> createState() => _UpdateUrlScreenState();
}

class _UpdateUrlScreenState extends State<UpdateUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  HiveService hs = HiveService();
  String url = '', urlTitle = '';
  String? desc;

  void saveFolder() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      // todo : update url

      Map<String, dynamic> url = widget.rootFolder.urls[widget.urlIndex];
      url['url'] = this.url;
      url['url_title'] = urlTitle;
      url['description'] = desc ?? '';

      List<Map<String, dynamic>> listUrl = widget.rootFolder.urls;

      listUrl[widget.urlIndex] = url;

      LinkTree newLinkTree = LinkTree(
        id: widget.rootFolder.id,
        subFolders: widget.rootFolder.subFolders,
        urls: listUrl,
        folderName: widget.rootFolder.folderName,
      );

      hs.update(newLinkTree);
    }
    Navigator.pop(context);
  }

  void deleteFolder(String id) {
    /// get folder
    LinkTree linkTree = hs.getTreeData(id)!;

    linkTree.urls.removeAt(widget.urlIndex);
    hs.update(linkTree);
  }

  @override
  void initState() {
    super.initState();

    url = widget.rootFolder.urls[widget.urlIndex]['url'];
    urlTitle = widget.rootFolder.urls[widget.urlIndex]['url_title'];
    desc = widget.rootFolder.urls[widget.urlIndex]['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Url',
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
            onPressed: () async {
              if (url.isNotEmpty) {
                await Share.share(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Empty url'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              deleteFolder(widget.rootFolder.id);
              Navigator.of(context).pop();
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
                  label: 'URL',
                  formField: TextFormField(
                    initialValue: url,
                    onChanged: (value) {
                      url = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 2,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    decoration: kInputDecoration.copyWith(
                      hintText: 'url',
                      hintStyle: const TextStyle(
                          // color: Colors.grey.shade500,
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
                  label: 'URL Title',
                  formField: TextFormField(
                    initialValue: urlTitle,
                    onChanged: (value) {
                      urlTitle = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 2,
                    // maxLength: ,
                    cursorHeight: 30,
                    cursorWidth: 2.5,
                    decoration: kInputDecoration.copyWith(
                      hintText: 'url title',
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
