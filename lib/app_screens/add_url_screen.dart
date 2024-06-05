import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_link_store/app_services/url_parsing/fetch_preview_details.dart';
import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class AddUrlScreen extends StatefulWidget {
  final String rootFolderKey;
  final String? sharedUrl;
  const AddUrlScreen({
    Key? key,
    required this.rootFolderKey,
    this.sharedUrl,
  }) : super(key: key);

  @override
  State<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String url = '', urlTitle = '';
  String? desc = '';

  Future<void> saveUrl() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      LinkTreeFolder linkTree =
          HiveService().getTreeData(widget.rootFolderKey)!;
      final HiveService hiveService = HiveService();
      final FetchPreviewDetails fetchPreviewDetails = FetchPreviewDetails();
      Map<String, dynamic> idata = await fetchPreviewDetails.fetch(url);
      idata['url_title'] = urlTitle;
      idata['user_note'] = desc ?? '';
      idata['url'] = url;
      /*
      {
      'url' : url,
      'favicon': faviconUint,
      'image': imageUint,
      'image_title': title ?? 'No title available',
      'description': description ?? 'No description available',
      'size': {
        'height': desc['height'] ?? 0,
        'width': desc['width'] ?? 0,
      },
    };
    */
      /// get list of url
      List<Map<String, dynamic>> listUrl = linkTree.urls;

      /// add idata to the list
      listUrl.insert(listUrl.length, idata);

      /// update linktree
      hiveService.update(
        LinkTreeFolder(
            id: linkTree.id,
            subFolders: linkTree.subFolders,
            urls: listUrl,
            folderName: linkTree.folderName),
      );
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.sharedUrl != null) {
      url = widget.sharedUrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Url',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isSaving = true;
                });
                await saveUrl();
                setState(() {
                  _isSaving = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
        // elevation: 0,
        // backgroundColor: Colors.transparent,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                            hintText: 'https://google.com',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a url';
                            }
                            return null;
                          },
                        ),
                      ),
                      TextInput(
                        label: 'TITLE',
                        formField: TextFormField(
                          onChanged: (value) {
                            urlTitle = value;
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 2,
                          cursorHeight: 30,
                          cursorWidth: 2.5,
                          decoration: kInputDecoration.copyWith(
                            hintText: 'title',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                      ),
                      TextInput(
                        label: 'Add Note',
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

                      /// todo : add preview
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          'TODO: Add url name\nTODO: Add insert at variable field\n todo : add preview show\n'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
