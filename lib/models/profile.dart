import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class UserProfile {
  final String id;
  final String owner;
  final SearchCriteria criteria;
  final Map<String, int> weights;
  final DateTime updatedAt;

  UserProfile({
    String? id,
    required this.owner,
    SearchCriteria? criteria,
    Map<String, int>? weights,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        criteria = criteria ?? SearchCriteria(),
        weights = weights ?? defaultWeights(),
        updatedAt = updatedAt ?? DateTime.now();

  static Map<String, int> defaultWeights() => {
        'budget': 5,
        'surface': 4,
        'transports': 3,
        'luminosite': 4,
        'calme': 4,
        'etat': 3,
        'quartier': 3,
        'exterieur': 2,
      };

  UserProfile copyWith({
    String? owner,
    SearchCriteria? criteria,
    Map<String, int>? weights,
  }) {
    return UserProfile(
      id: id,
      owner: owner ?? this.owner,
      criteria: criteria ?? this.criteria,
      weights: weights ?? this.weights,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner,
        'criteria': criteria.toJson(),
        'weights': weights,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        owner: json['owner'] as String,
        criteria: SearchCriteria.fromJson(
            json['criteria'] as Map<String, dynamic>),
        weights: Map<String, int>.from(
            (json['weights'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        )),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class SearchCriteria {
  final double? budgetMax;
  final double? surfaceMin;
  final int? roomsMin;
  final List<String> zones;
  final List<String> tags;

  SearchCriteria({
    this.budgetMax,
    this.surfaceMin,
    this.roomsMin,
    List<String>? zones,
    List<String>? tags,
  })  : zones = zones ?? [],
        tags = tags ?? [];

  SearchCriteria copyWith({
    double? budgetMax,
    double? surfaceMin,
    int? roomsMin,
    List<String>? zones,
    List<String>? tags,
  }) {
    return SearchCriteria(
      budgetMax: budgetMax ?? this.budgetMax,
      surfaceMin: surfaceMin ?? this.surfaceMin,
      roomsMin: roomsMin ?? this.roomsMin,
      zones: zones ?? this.zones,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'budget_max': budgetMax,
        'surface_min': surfaceMin,
        'rooms_min': roomsMin,
        'zones': zones,
        'tags': tags,
      };

  factory SearchCriteria.fromJson(Map<String, dynamic> json) => SearchCriteria(
        budgetMax: (json['budget_max'] as num?)?.toDouble(),
        surfaceMin: (json['surface_min'] as num?)?.toDouble(),
        roomsMin: (json['rooms_min'] as num?)?.toInt(),
        zones: List<String>.from(json['zones'] as List? ?? []),
        tags: List<String>.from(json['tags'] as List? ?? []),
      );
}
