// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';
import 'package:link_vault/core/common/widgets/custom_textfield.dart';
import 'package:link_vault/src/advance_search/presentation/advance_search_cubit/search_cubit.dart';
import 'package:link_vault/src/dashboard/presentation/enums/coll_constants.dart';

class AdvanceSearchFiltersPage extends StatefulWidget {
  const AdvanceSearchFiltersPage({super.key});

  @override
  State<AdvanceSearchFiltersPage> createState() =>
      _AdvanceSearchFiltersPageState();
}

class _AdvanceSearchFiltersPageState extends State<AdvanceSearchFiltersPage>
    with AutomaticKeepAliveClientMixin {
  final _showCategoriesOptions = ValueNotifier(true);
  final _predefinedCategories = [...categories];
  // final _selectedCategory = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();

    final searchCubit = context.read<AdvanceSearchCubit>();

    searchCubit.createStartDate.value = DateTime(2024, 7);
    searchCubit.createEndDate.value = DateTime.now();
    searchCubit.updatedStartDate.value = DateTime(2024, 7);
    searchCubit.updatedEndDate.value = DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: BlocConsumer<AdvanceSearchCubit, AdvanceSearchState>(
            listener: (context, state) {},
            builder: (context, state) {
              final searchCubit = context.read<AdvanceSearchCubit>();

              return Form(
                key: searchCubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCollTextField(
                      controller: searchCubit.nameSearch,
                      labelText: 'Search',
                      hintText: ' title, name etc., ',
                      onTapOutside: (pointer) async {},
                      onSubmitted: (value) async {},
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // CREATED AT RANGE
                    FormField<DateTime>(
                      validator: (dateTime) {
                        if (searchCubit.createEndDate.value == null &&
                            searchCubit.createEndDate.value == null) {
                          return null;
                        }

                        if (searchCubit.createEndDate.value!
                                .compareTo(searchCubit.createStartDate.value!) <
                            0) {
                          return 'End Date Should be greater than Start Date';
                        }
                      },
                      builder: (formSate) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: Text(
                                'Created Time Range',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                // border: Border.all(color: ColourPallette.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: ColourPallette.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable:
                                            searchCubit.createStartDate,
                                        builder:
                                            (context, createdStartDate, _) {
                                          final dateString =
                                              '${createdStartDate?.day ?? 'dd'}/${createdStartDate?.month ?? 'mm'}/${createdStartDate?.year ?? 'yyyy'}';

                                          return Text(
                                            dateString,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: createdStartDate == null
                                                  ? ColourPallette.grey
                                                  : ColourPallette.black,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2024, 7),
                                            lastDate: DateTime.now(),
                                          ).then(
                                            (date) {
                                              if (date == null) return;

                                              searchCubit
                                                  .createStartDate.value = date;
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: ColourPallette.darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                // border: Border.all(color: ColourPallette.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: ColourPallette.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable:
                                            searchCubit.createEndDate,
                                        builder: (context, createdEndDate, _) {
                                          final dateString =
                                              '${createdEndDate?.day ?? 'dd'}/${createdEndDate?.month ?? 'mm'}/${createdEndDate?.year ?? 'yyyy'}';

                                          return Text(
                                            dateString,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: createdEndDate == null
                                                  ? ColourPallette.grey
                                                  : ColourPallette.black,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2024, 7),
                                            lastDate: DateTime.now(),
                                          ).then(
                                            (date) {
                                              if (date == null) return;

                                              searchCubit.createEndDate.value =
                                                  date;
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: ColourPallette.darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (formSate.hasError)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${formSate.errorText}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: ColourPallette.error,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // UPDATED AT RANGE
                    FormField<DateTime>(
                      validator: (dateTime) {
                        if (searchCubit.updatedEndDate.value == null &&
                            searchCubit.updatedEndDate.value == null)
                          return null;

                        if (searchCubit.updatedEndDate.value!.compareTo(
                                searchCubit.updatedStartDate.value!) <
                            0) {
                          return 'End Date Should be greater than Start Date';
                        }
                      },
                      builder: (formSate) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: Text(
                                'Updated Time Range',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                // border: Border.all(color: ColourPallette.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: ColourPallette.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable:
                                            searchCubit.updatedStartDate,
                                        builder:
                                            (context, createdStartDate, _) {
                                          final dateString =
                                              '${createdStartDate?.day ?? 'dd'}/${createdStartDate?.month ?? 'mm'}/${createdStartDate?.year ?? 'yyyy'}';

                                          return Text(
                                            dateString,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: createdStartDate == null
                                                  ? ColourPallette.grey
                                                  : ColourPallette.black,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2024, 7),
                                            lastDate: DateTime.now(),
                                          ).then(
                                            (date) {
                                              if (date == null) return;

                                              searchCubit.updatedStartDate
                                                  .value = date;
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: ColourPallette.darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                // border: Border.all(color: ColourPallette.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: ColourPallette.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable:
                                            searchCubit.updatedEndDate,
                                        builder: (context, createdEndDate, _) {
                                          final dateString =
                                              '${createdEndDate?.day ?? 'dd'}/${createdEndDate?.month ?? 'mm'}/${createdEndDate?.year ?? 'yyyy'}';

                                          return Text(
                                            dateString,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: createdEndDate == null
                                                  ? ColourPallette.grey
                                                  : ColourPallette.black,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2024, 7),
                                            lastDate: DateTime.now(),
                                          ).then(
                                            (date) {
                                              if (date == null) return;

                                              searchCubit.updatedEndDate.value =
                                                  date;
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: ColourPallette.darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (formSate.hasError)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${formSate.errorText}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: ColourPallette.error,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // CATEGORIES
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showCategoriesOptions.value =
                                    !_showCategoriesOptions.value;
                              },
                              icon: ValueListenableBuilder(
                                valueListenable: _showCategoriesOptions,
                                builder: (context, showCategories, _) {
                                  return Icon(
                                    showCategories
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: _showCategoriesOptions,
                          builder: (context, showCategories, _) {
                            if (!showCategories) {
                              return Container();
                            }

                            return ValueListenableBuilder<List<String>>(
                              valueListenable: searchCubit.categories,
                              builder: (context, selectedCategory, child) {
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: List.generate(
                                    _predefinedCategories.length,
                                    (index) {
                                      final category =
                                          _predefinedCategories[index];
                                      final isSelected =
                                          selectedCategory.contains(category);
                                      return GestureDetector(
                                        onTap: () {
                                          final newList = [...selectedCategory];
                                          if (isSelected) {
                                            newList.remove(category);
                                            searchCubit.categories.value =
                                                newList;
                                          } else {
                                            newList.add(category);
                                            searchCubit.categories.value =
                                                newList;
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? ColourPallette.mountainMeadow
                                                : Colors.white,
                                            border: Border.all(
                                              color: isSelected
                                                  ? ColourPallette
                                                      .mountainMeadow
                                                  : ColourPallette.grey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // IS fAVOURITE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Favourite',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: searchCubit.isFavourite,
                            builder: (context, isFavorite, child) {
                              return Switch.adaptive(
                                value: isFavorite,
                                onChanged: (value) =>
                                    searchCubit.isFavourite.value = value,
                                trackOutlineColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) =>
                                      Colors.transparent,
                                ),
                                thumbColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) =>
                                      Colors.transparent,
                                ),
                                activeTrackColor: ColourPallette.mountainMeadow,
                                inactiveTrackColor: ColourPallette.error,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
