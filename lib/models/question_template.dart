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

  /// Options pour les questions de type [QuestionType.multiChoice].
  final List<String> options;

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
    this.options = const [],
  });

  QuestionTemplate copyWith({
    String? section,
    String? text,
    String? hint,
    QuestionLevel? level,
    QuestionType? type,
    QuestionTiming? timing,
    List<ProjectFilter>? appliesTo,
    bool? withPhoto,
    bool? isEnabled,
    List<String>? options,
  }) =>
      QuestionTemplate(
        id: id,
        section: section ?? this.section,
        text: text ?? this.text,
        hint: hint ?? this.hint,
        level: level ?? this.level,
        type: type ?? this.type,
        timing: timing ?? this.timing,
        appliesTo: appliesTo ?? this.appliesTo,
        withPhoto: withPhoto ?? this.withPhoto,
        isCustom: isCustom,
        isEnabled: isEnabled ?? this.isEnabled,
        options: options ?? this.options,
      );

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
        'options': options,
      };

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) =>
      QuestionTemplate(
        id: json['id'] as String,
        section: json['section'] as String,
        text: json['text'] as String,
        hint: json['hint'] as String?,
        level: enumFromJson(QuestionLevel.values, json['level'] as String?) ??
            QuestionLevel.nice,
        type: enumFromJson(QuestionType.values, json['type'] as String?) ??
            QuestionType.score,
        timing:
            enumFromJson(QuestionTiming.values, json['timing'] as String?) ??
                QuestionTiming.flexible,
        appliesTo: (json['applies_to'] as List? ?? [])
            .map((e) =>
                enumFromJson(ProjectFilter.values, e as String?) ??
                ProjectFilter.location)
            .toList(),
        withPhoto: json['with_photo'] as bool? ?? false,
        isCustom: json['is_custom'] as bool? ?? false,
        isEnabled: json['is_enabled'] as bool? ?? true,
        options: List<String>.from(json['options'] as List? ?? []),
      );
}

/// Configuration personnalisée du questionnaire pour un [UserProfile].
class QuestionnaireConfig {
  /// IDs des questions désactivées (liste noire). Vide = tout activé.
  final Set<String> disabledQuestionIds;

  /// Questions personnalisées créées par l'utilisateur.
  final List<QuestionTemplate> customQuestions;

  /// Surcharge des tags [ProjectFilter] par question (ID → liste de filtres).
  /// Permet de changer maison/appartement/achat/location sur n'importe quelle question.
  final Map<String, List<ProjectFilter>> questionTagOverrides;

  /// Poids de chaque composante dans le score final (doit sommer à 1.0).
  /// Clés : 'eval', 'matching', 'feeling'.
  final Map<String, double> scoreWeights;

  /// Durée de trajet en minutes au-delà de laquelle un bloqueur est levé.
  final int transportMaxMinutes;

  /// Si true, la présence d'humidité déclenche un bloqueur.
  final bool humidityBlocker;

  /// Score acoustique ≤ ce seuil déclenche un bloqueur (1-5).
  final int phonicsBlockerThreshold;

  // Conservé pour rétrocompat lecture (ignoré à l'écriture).
  final Set<String> enabledQuestionIds;

  const QuestionnaireConfig({
    this.disabledQuestionIds = const {},
    this.customQuestions = const [],
    this.questionTagOverrides = const {},
    this.scoreWeights = const {
      'eval': 0.5,
      'matching': 0.3,
      'feeling': 0.2,
    },
    this.transportMaxMinutes = 15,
    this.humidityBlocker = true,
    this.phonicsBlockerThreshold = 1,
    this.enabledQuestionIds = const {},
  });

  /// Configuration par défaut (toutes questions actives, poids standards).
  static const QuestionnaireConfig defaults = QuestionnaireConfig();

  QuestionnaireConfig copyWith({
    Set<String>? disabledQuestionIds,
    List<QuestionTemplate>? customQuestions,
    Map<String, List<ProjectFilter>>? questionTagOverrides,
    Map<String, double>? scoreWeights,
    int? transportMaxMinutes,
    bool? humidityBlocker,
    int? phonicsBlockerThreshold,
  }) =>
      QuestionnaireConfig(
        disabledQuestionIds: disabledQuestionIds ?? this.disabledQuestionIds,
        customQuestions: customQuestions ?? this.customQuestions,
        questionTagOverrides: questionTagOverrides ?? this.questionTagOverrides,
        scoreWeights: scoreWeights ?? this.scoreWeights,
        transportMaxMinutes: transportMaxMinutes ?? this.transportMaxMinutes,
        humidityBlocker: humidityBlocker ?? this.humidityBlocker,
        phonicsBlockerThreshold:
            phonicsBlockerThreshold ?? this.phonicsBlockerThreshold,
        enabledQuestionIds: enabledQuestionIds,
      );

  Map<String, dynamic> toJson() => {
        'disabled_question_ids': disabledQuestionIds.toList(),
        'custom_questions': customQuestions.map((q) => q.toJson()).toList(),
        'question_tag_overrides': questionTagOverrides.map(
          (id, filters) => MapEntry(id, filters.map((f) => f.name).toList()),
        ),
        'score_weights': scoreWeights,
        'transport_max_minutes': transportMaxMinutes,
        'humidity_blocker': humidityBlocker,
        'phonics_blocker_threshold': phonicsBlockerThreshold,
      };

  factory QuestionnaireConfig.fromJson(Map<String, dynamic> json) =>
      QuestionnaireConfig(
        disabledQuestionIds: Set<String>.from(
          json['disabled_question_ids'] as List? ?? [],
        ),
        enabledQuestionIds: Set<String>.from(
          json['enabled_question_ids'] as List? ?? [],
        ),
        customQuestions: (json['custom_questions'] as List? ?? [])
            .map((e) => QuestionTemplate.fromJson(e as Map<String, dynamic>))
            .toList(),
        questionTagOverrides: (json['question_tag_overrides']
                    as Map<String, dynamic>? ??
                {})
            .map((id, tags) => MapEntry(
                  id,
                  (tags as List)
                      .map((t) =>
                          enumFromJson(ProjectFilter.values, t as String?) ??
                          ProjectFilter.location)
                      .toList(),
                )),
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
