// ignore_for_file: public_member_api_docs

import 'package:isar/isar.dart';

part 'global_user_model.g.dart';

@collection
class GlobalUser {
  Id? isarId; // Isar internal ID

  @Index(unique: true)
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime creditExpiryDate;

  GlobalUser({
    this.isarId,
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.creditExpiryDate,
  });

  // Convert from JSON (for remote data)
  factory GlobalUser.fromJson(Map<String, dynamic> json) {
    return GlobalUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      creditExpiryDate: DateTime.parse(
        json['creditExpiryDate'] as String,
      ),
    );
  }

  // Convert to JSON (for remote data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'creditExpiryDate': creditExpiryDate.toIso8601String(),
    };
  }

  // Copy method
  GlobalUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? creditExpiryDate,
  }) {
    return GlobalUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      creditExpiryDate: creditExpiryDate ?? this.creditExpiryDate,
    );
  }
}

// class GlobalUser {
//   const GlobalUser({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.createdAt,
//     required this.creditExpiryDate,
//   });
//   factory GlobalUser.fromJson(Map<String, dynamic> json) {
//     return GlobalUser(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       email: json['email'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       creditExpiryDate: DateTime.parse(json['creditExpiryDate'] as String),
//     );
//   }
  
//   final String id;
//   final String name;
//   final String email;
//   final DateTime createdAt;
//   final DateTime creditExpiryDate;

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'createdAt': createdAt.toIso8601String(),
//       'creditExpiryDate': creditExpiryDate.toIso8601String(),
//     };
//   }

//   GlobalUser copyWith({
//     String? id,
//     String? name,
//     String? email,
//     DateTime? createdAt,
//     DateTime? creditExpiryDate,
//   }) {
//     return GlobalUser(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       createdAt: createdAt ?? this.createdAt,
//       creditExpiryDate: creditExpiryDate ?? this.creditExpiryDate,
//     );
//   }
// }
