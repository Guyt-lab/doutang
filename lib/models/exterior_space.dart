/// Un espace extérieur associé à un bien (balcon, terrasse, jardin, cour).
class ExteriorSpace {
  final String type;
  final double? surface;

  const ExteriorSpace({required this.type, this.surface});

  ExteriorSpace copyWith({double? surface}) =>
      ExteriorSpace(type: type, surface: surface ?? this.surface);

  Map<String, dynamic> toJson() => {'type': type, 'surface': surface};

  factory ExteriorSpace.fromJson(Map<String, dynamic> j) => ExteriorSpace(
        type: j['type'] as String,
        surface: (j['surface'] as num?)?.toDouble(),
      );
}
