import 'enums.dart';

/// Modèle d'une question du questionnaire de visite.
class QuestionTemplate {
  final String id;
  final String section;
  final String text;
  final String? hint;
  final QuestionLevel level;
  final QuestionType type;
  final QuestionTiming timing;

  /// Filtres de projet auxquels cette question s'applique.
  /// Liste vide = s'applique à tous.
  final List<ProjectFilter> appliesTo;

  final bool withPhoto;
  final bool isCustom;
  final bool isEnabled;

  const QuestionTemplate({
    required this.id,
    required this.section,
    required this.text,
    this.hint,
    required this.level,
    required this.type,
    required this.timing,
    this.appliesTo = const [],
    this.withPhoto = false,
    this.isCustom = false,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section,
        'text': text,
        'hint': hint,
        'level': level.name,
        'type': type.name,
        'timing': timing.name,
        'applies_to': appliesTo.map((e) => e.name).toList(),
        'with_photo': withPhoto,
        'is_custom': isCustom,
        'is_enabled': isEnabled,
      };

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) =>
      QuestionTemplate(
        id: json['id'] as String,
        section: json['section'] as String,
        text: json['text'] as String,
        hint: json['hint'] as String?,
        level: enumFromJson(
                QuestionLevel.values, json['level'] as String?) ??
            QuestionLevel.nice,
        type: enumFromJson(
                QuestionType.values, json['type'] as String?) ??
            QuestionType.score,
        timing: enumFromJson(
                QuestionTiming.values, json['timing'] as String?) ??
            QuestionTiming.flexible,
        appliesTo: (json['applies_to'] as List? ?? [])
            .map((e) =>
                enumFromJson(ProjectFilter.values, e as String?) ??
                ProjectFilter.location)
            .toList(),
        withPhoto: json['with_photo'] as bool? ?? false,
        isCustom: json['is_custom'] as bool? ?? false,
        isEnabled: json['is_enabled'] as bool? ?? true,
      );
}

/// Configuration personnalisée du questionnaire pour un [UserProfile].
class QuestionnaireConfig {
  /// IDs des questions activées. Si vide → toutes les questions sont activées.
  final Set<String> enabledQuestionIds;

  /// Poids de chaque composante dans le score final (doit sommer à 1.0).
  /// Clés : 'eval', 'matching', 'feeling'.
  final Map<String, double> scoreWeights;

  /// Durée de trajet en minutes au-delà de laquelle un bloqueur est levé.
  final int transportMaxMinutes;

  /// Si true, la présence d'humidité déclenche un bloqueur.
  final bool humidityBlocker;

  /// Score acoustique ≤ ce seuil déclenche un bloqueur (1-5).
  final int phonicsBlockerThreshold;

  const QuestionnaireConfig({
    this.enabledQuestionIds = const {},
    this.scoreWeights = const {
      'eval': 0.5,
      'matching': 0.3,
      'feeling': 0.2,
    },
    this.transportMaxMinutes = 15,
    this.humidityBlocker = true,
    this.phonicsBlockerThreshold = 1,
  });

  /// Configuration par défaut (toutes questions actives, poids standards).
  static const QuestionnaireConfig defaults = QuestionnaireConfig();

  QuestionnaireConfig copyWith({
    Set<String>? enabledQuestionIds,
    Map<String, double>? scoreWeights,
    int? transportMaxMinutes,
    bool? humidityBlocker,
    int? phonicsBlockerThreshold,
  }) =>
      QuestionnaireConfig(
        enabledQuestionIds: enabledQuestionIds ?? this.enabledQuestionIds,
        scoreWeights: scoreWeights ?? this.scoreWeights,
        transportMaxMinutes:
            transportMaxMinutes ?? this.transportMaxMinutes,
        humidityBlocker: humidityBlocker ?? this.humidityBlocker,
        phonicsBlockerThreshold:
            phonicsBlockerThreshold ?? this.phonicsBlockerThreshold,
      );

  Map<String, dynamic> toJson() => {
        'enabled_question_ids': enabledQuestionIds.toList(),
        'score_weights': scoreWeights,
        'transport_max_minutes': transportMaxMinutes,
        'humidity_blocker': humidityBlocker,
        'phonics_blocker_threshold': phonicsBlockerThreshold,
      };

  factory QuestionnaireConfig.fromJson(Map<String, dynamic> json) =>
      QuestionnaireConfig(
        enabledQuestionIds: Set<String>.from(
          json['enabled_question_ids'] as List? ?? [],
        ),
        scoreWeights: Map<String, double>.from(
          (json['score_weights'] as Map<String, dynamic>? ??
                  {'eval': 0.5, 'matching': 0.3, 'feeling': 0.2})
              .map((k, v) => MapEntry(k, (v as num).toDouble())),
        ),
        transportMaxMinutes:
            (json['transport_max_minutes'] as num?)?.toInt() ?? 15,
        humidityBlocker: json['humidity_blocker'] as bool? ?? true,
        phonicsBlockerThreshold:
            (json['phonics_blocker_threshold'] as num?)?.toInt() ?? 1,
      );
}
