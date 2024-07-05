import 'package:flutter/material.dart';

class FolderCollectionPage extends StatefulWidget {
  const FolderCollectionPage({super.key});

  @override
  State<FolderCollectionPage> createState() => _FolderCollectionPageState();
}

class _FolderCollectionPageState extends State<FolderCollectionPage> {


  @override
  void initState() {
    super.initState();

    // [TODO] : Call initiliaize for this foldercollection id


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard page'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: Text('LogOut'),
        ),
      ),
    );
  }
}
