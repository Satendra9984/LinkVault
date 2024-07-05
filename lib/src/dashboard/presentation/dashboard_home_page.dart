import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';
import 'package:link_vault/src/dashboard/presentation/pages/folder_collection_page.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // [TODO] : Create the collections cubit for managing global list of all collections

        // [TODO] : Create a CRUD cubit for managing crud operation a single collection

        // [TODO] : We can further add more cubits like Offlineview editor, webpage reader, openai summariser etc.
      ],
      child: MaterialApp(
        home: FolderCollectionPage(),
      ),
    );
  }
}
