import 'package:flutter/material.dart';
import 'package:link_vault/app_models/link_tree_folder_model.dart';
import 'package:link_vault/app_services/databases/hive_database.dart';
import 'package:link_vault/app_services/url_parsing/fetch_preview_details.dart';
import 'package:link_vault/app_widgets/text_input.dart';
import 'package:link_vault/constants.dart';
import 'package:share_plus/share_plus.dart';

class UpdateUrlScreen extends StatefulWidget {
  const UpdateUrlScreen({
    required this.urlIndex, required this.rootFolder, super.key,
  });
  final LinkTreeFolder rootFolder;
  final int urlIndex;

  @override
  State<UpdateUrlScreen> createState() => _UpdateUrlScreenState();
}

class _UpdateUrlScreenState extends State<UpdateUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  HiveService hs = HiveService();
  String url = '';
  String urlTitle = '';
  String? desc;
  bool _favourite = false;
  bool _isSaving = false;

  Future<void> saveUrl() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      // todo : update url
      final fetchPreviewDetails = FetchPreviewDetails();
      final idata = await fetchPreviewDetails.fetch(url);

      // Map<String, dynamic> url = widget.rootFolder.urls[widget.urlIndex];
      idata['url'] = url;
      idata['url_title'] = urlTitle;
      idata['description'] = desc ?? '';
      idata['is_favourite'] = _favourite;

      final listUrl = widget.rootFolder.urls;

      listUrl[widget.urlIndex] = idata;

      final newLinkTree = LinkTreeFolder(
        id: widget.rootFolder.id,
        subFolders: widget.rootFolder.subFolders,
        urls: listUrl,
        folderName: widget.rootFolder.folderName,
        parentFolderId: widget.rootFolder.parentFolderId,
        description: widget.rootFolder.description,
        isFavourite: widget.rootFolder.isFavourite,
        category: widget.rootFolder.category,
      );

      hs.update(newLinkTree);

      if (_favourite) {
        await hs.addFavouriteLinks(idata);
      }
    }
    Navigator.pop(context);
  }

  void deleteFolder(String id) {
    /// get folder
    final linkTree = hs.getTreeData(id)!;

    linkTree.urls.removeAt(widget.urlIndex);
    hs.update(linkTree);
  }

  _initialize() {
    url = widget.rootFolder.urls[widget.urlIndex]['url'].toString();
    urlTitle = widget.rootFolder.urls[widget.urlIndex]['url_title'].toString();
    desc = widget.rootFolder.urls[widget.urlIndex]['description'].toString();
    _favourite =
        (widget.rootFolder.urls[widget.urlIndex]['is_favourite'] as bool?) ??
            false;
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Url',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              deleteFolder(widget.rootFolder.id);
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.remove_circle_rounded,
              color: Colors.red.shade800,
            ),
          ),
          if (_isSaving) Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.green.shade800,
                  ),
                ) else IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isSaving = true;
                      });

                      try {
                        await saveUrl();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Center(child: Text('Saved')),
                          ),
                        );
                      } catch (e) {
                        debugPrint('[log][error] : $e');
                        setState(() {
                          _isSaving = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Center(
                              child: Text(
                                'Something Went wrong.',
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    color: Color(0xff3cac7c),
                  ),
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
                    cursorColor: const Color(0xff3cac7c),
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
                const SizedBox(height: 20),
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
                    cursorColor: const Color(0xff3cac7c),

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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                    cursorColor: const Color(0xff3cac7c),
                    showCursor: true,
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
