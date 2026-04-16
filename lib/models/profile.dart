import 'package:uuid/uuid.dart';

import 'question_template.dart';

const _uuid = Uuid();

class UserProfile {
  final String id;
  final String owner;
  final SearchCriteria criteria;
  final Map<String, int> weights;
  final QuestionnaireConfig questionnaireConfig;
  final DateTime updatedAt;

  UserProfile({
    String? id,
    required this.owner,
    SearchCriteria? criteria,
    Map<String, int>? weights,
    QuestionnaireConfig? questionnaireConfig,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        criteria = criteria ?? SearchCriteria(),
        weights = weights ?? defaultWeights(),
        questionnaireConfig =
            questionnaireConfig ?? QuestionnaireConfig.defaults,
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
    QuestionnaireConfig? questionnaireConfig,
  }) {
    return UserProfile(
      id: id,
      owner: owner ?? this.owner,
      criteria: criteria ?? this.criteria,
      weights: weights ?? this.weights,
      questionnaireConfig: questionnaireConfig ?? this.questionnaireConfig,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner,
        'criteria': criteria.toJson(),
        'weights': weights,
        'questionnaire_config': questionnaireConfig.toJson(),
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
        questionnaireConfig: json['questionnaire_config'] != null
            ? QuestionnaireConfig.fromJson(
                json['questionnaire_config'] as Map<String, dynamic>)
            : QuestionnaireConfig.defaults,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class SearchCriteria {
  final double? budgetMax;
  final double? surfaceMin;
  final int? roomsMin;

  /// 'location' ou 'achat'
  final String? projectType;
  final List<String> zones;
  final List<String> tags;

  SearchCriteria({
    this.budgetMax,
    this.surfaceMin,
    this.roomsMin,
    this.projectType,
    List<String>? zones,
    List<String>? tags,
  })  : zones = zones ?? [],
        tags = tags ?? [];

  SearchCriteria copyWith({
    double? budgetMax,
    double? surfaceMin,
    int? roomsMin,
    String? projectType,
    List<String>? zones,
    List<String>? tags,
  }) {
    return SearchCriteria(
      budgetMax: budgetMax ?? this.budgetMax,
      surfaceMin: surfaceMin ?? this.surfaceMin,
      roomsMin: roomsMin ?? this.roomsMin,
      projectType: projectType ?? this.projectType,
      zones: zones ?? this.zones,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'budget_max': budgetMax,
        'surface_min': surfaceMin,
        'rooms_min': roomsMin,
        'project_type': projectType,
        'zones': zones,
        'tags': tags,
      };

  factory SearchCriteria.fromJson(Map<String, dynamic> json) => SearchCriteria(
        budgetMax: (json['budget_max'] as num?)?.toDouble(),
        surfaceMin: (json['surface_min'] as num?)?.toDouble(),
        roomsMin: (json['rooms_min'] as num?)?.toInt(),
        projectType: json['project_type'] as String?,
        zones: List<String>.from(json['zones'] as List? ?? []),
        tags: List<String>.from(json['tags'] as List? ?? []),
      );
}
