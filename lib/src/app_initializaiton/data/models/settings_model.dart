// ignore_for_file: public_member_api_docs

import 'package:isar/isar.dart';

part 'settings_model.g.dart';

@Collection()
class IsarAppSettingsModel {
  IsarAppSettingsModel({
    this.seenOnboarding = false,
    this.theme,
  });

  Id id = 1; // single row, id=1
  final bool seenOnboarding;
  final String? theme; // store e.g. 'system'|'light'|'dark'
}
