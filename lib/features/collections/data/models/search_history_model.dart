import 'package:objectbox/objectbox.dart';

/// Stores a single user search query with a timestamp.
/// ObjectBox auto-generates a box for this entity via build_runner.
@Entity()
class SearchHistoryModel {
  @Id()
  int id = 0;

  String query;

  @Property(type: PropertyType.date)
  DateTime searchedAt;

  SearchHistoryModel({
    this.id = 0,
    required this.query,
    required this.searchedAt,
  });
}
