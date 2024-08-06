// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';

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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SvgPicture.asset(
                MediaRes.pageUnderConstructionSVG,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await context.read<AdvanceSearchCubit>().migrateData();
              },
              child: const Text(
                'Migrate dAta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async {
               await context.read<AdvanceSearchCubit>().searchLocalDatabase();
              },
              child: const Text(
                'Advance Search Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}
