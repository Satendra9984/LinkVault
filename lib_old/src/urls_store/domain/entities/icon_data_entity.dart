import 'package:equatable/equatable.dart';

// Icon representation as JSON (type and name)
import 'package:equatable/equatable.dart';

// Icon representation as JSON (type, name, and optionally color/pattern)
class IconDataModel extends Equatable {
  final String type;
  final String name;
  final String? color;
  final String? pattern;

  const IconDataModel({
    required this.type,
    required this.name,
    this.color,
    this.pattern,
  });

  @override
  List<Object?> get props => [type, name, color, pattern];

  factory IconDataModel.fromMap(Map<String, dynamic> map) {
    return IconDataModel(
      type: map['type'] as String,
      name: map['name'] as String,
      color: map['color'] as String?,
      pattern: map['pattern'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      if (color != null) 'color': color,
      if (pattern != null) 'pattern': pattern,
    };
  }
}
