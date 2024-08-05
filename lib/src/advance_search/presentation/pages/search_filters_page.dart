// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class AdvanceSearchFiltersPage extends StatefulWidget {
  const AdvanceSearchFiltersPage({super.key});

  @override
  State<AdvanceSearchFiltersPage> createState() =>
      _AdvanceSearchFiltersPageState();
}

class _AdvanceSearchFiltersPageState extends State<AdvanceSearchFiltersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Advance Search Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
