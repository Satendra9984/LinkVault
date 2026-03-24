

import 'package:equatable/equatable.dart';

class CollectionIcon extends Equatable {
  final String type; // 'emoji', 'icon', 'image'
  final String value;
  final String color;

  const CollectionIcon({
    required this.type,
    required this.value,
    required this.color,
  });

  factory CollectionIcon.emoji(String emoji, [String color = '#6B7280']) {
    return CollectionIcon(type: 'emoji', value: emoji, color: color);
  }

  factory CollectionIcon.fromJson(Map<String, dynamic> json) {
    return CollectionIcon(
      type: json['type'] ?? 'emoji',
      value: json['value'] ?? '📁',
      color: json['color'] ?? '#6B7280',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'color': color,
      };

  @override
  List<Object> get props => [type, value, color];
}