import 'package:flutter/material.dart';
import 'package:link_vault/src/auth/data/data_sources/auth_remote_data_sources.dart';
import 'package:link_vault/src/auth/data/repositories/auth_repo_impl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard page'),
      ),

      body: Center(
        child: TextButton(
          onPressed: () {
            
          },
          
          child: Text('LogOut'),),
      ),
    );
  }
}
