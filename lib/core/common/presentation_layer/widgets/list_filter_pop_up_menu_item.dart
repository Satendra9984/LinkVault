import 'package:flutter/material.dart';
import 'package:link_vault/core/res/colours.dart';

class ListFilterPopupMenuItem extends PopupMenuItem<dynamic> {
  ListFilterPopupMenuItem({
    required this.title,
    required this.notifier,
    required this.onPress,
    super.key,
  }) : super(
          onTap: onPress,
          value: notifier,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColourPallette.black,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: notifier,
                builder: (context, isFavorite, child) {
                  if (isFavorite) {
                    return const Icon(
                      Icons.check_box_rounded,
                      color: ColourPallette.salemgreen,
                    );
                  }

                  return const Icon(
                    Icons.check_box_outline_blank_outlined,
                    // color: ColourPallette.salemgreen,
                  );
                },
              ),
            ],
          ),
        );
  final String title;
  final ValueNotifier<bool> notifier;
  final void Function() onPress;
}
