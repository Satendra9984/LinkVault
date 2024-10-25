// import 'package:flutter/material.dart';

// class ListFilterPopUpMenyItem {
//   const ListFilterPopUpMenyItem({
//     required this.title,
//     required this.notifier,
//     required this.onPress,
//     // super.key,
//   });

//   final String title;
//   final ValueNotifier<bool> notifier;
//   final Function onPress;

  
//   PopupMenuItem<bool> build(BuildContext context) {
//     return PopupMenuItem(
//       value: _atozFilter.value,
//       onTap: () => _atozFilter.value = !_atozFilter.value,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           ValueListenableBuilder<bool>(
//             valueListenable: notifier,
//             builder: (context, isFavorite, child) {
//               return Checkbox.adaptive(
//                 value: isFavorite,
//                 onChanged: (_) => notifier.value = !notifier.value,
//                 activeColor: ColourPallette.salemgreen,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
