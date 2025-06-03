import 'package:equatable/equatable.dart';

class CollectionBackground extends Equatable {
  final String color;
  final String pattern;
  final double opacity;

  const CollectionBackground({
    required this.color,
    required this.pattern,
    required this.opacity,
  });

  factory CollectionBackground.fromJson(Map<String, dynamic> json) {
    return CollectionBackground(
      color: json['color'] ?? '#F9FAFB',
      pattern: json['pattern'] ?? 'none',
      opacity: (json['opacity'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'color': color,
        'pattern': pattern,
        'opacity': opacity,
      };

  @override
  List<Object> get props => [color, pattern, opacity];
}