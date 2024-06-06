import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../app_services/databases/hive_database.dart';
import '../app_models/link_tree_folder_model.dart';
import '../app_widgets/text_input.dart';
import '../constants.dart';

class UpdateUrlScreen extends StatefulWidget {
  final LinkTreeFolder rootFolder;
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
  bool _favourite = false;

  Future<void> saveFolder() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      // todo : update url

      Map<String, dynamic> url = widget.rootFolder.urls[widget.urlIndex];
      url['url'] = this.url;
      url['url_title'] = urlTitle;
      url['description'] = desc ?? '';
      url['is_favourite'] = _favourite;

      List<Map<String, dynamic>> listUrl = widget.rootFolder.urls;

      listUrl[widget.urlIndex] = url;

      LinkTreeFolder newLinkTree = LinkTreeFolder(
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
        await hs.addFavouriteLinks(url);
      }
    }
    Navigator.pop(context);
  }

  void deleteFolder(String id) {
    /// get folder
    LinkTreeFolder linkTree = hs.getTreeData(id)!;

    linkTree.urls.removeAt(widget.urlIndex);
    hs.update(linkTree);
  }

  _initialize() {
    url = widget.rootFolder.urls[widget.urlIndex]['url'];
    urlTitle = widget.rootFolder.urls[widget.urlIndex]['url_title'];
    desc = widget.rootFolder.urls[widget.urlIndex]['description'];
    _favourite =
        widget.rootFolder.urls[widget.urlIndex]['is_favourite'] ?? false;
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
          IconButton(
            onPressed: () async{
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
                const SizedBox(height: 20.0),
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
                const SizedBox(height: 20.0),
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
