/// Enums partagés à travers toute l'application Doutang.
///
/// Convention JSON : [enumFromJson] / [e.name] pour la sérialisation.
/// Tous les enums utilisent `.name` (Dart 2.15+) pour les valeurs JSON.

// ── Helpers de sérialisation ──────────────────────────────────────────────

/// Désérialise un enum depuis une chaîne JSON nullable.
/// Retourne null si [json] est null ou inconnu.
T? enumFromJson<T extends Enum>(List<T> values, String? json) {
  if (json == null) return null;
  for (final v in values) {
    if (v.name == json) return v;
  }
  return null;
}

/// Sérialise un enum (retourne [e.name] ou null).
String? enumToJson(Enum? e) => e?.name;

// ── Modèle de bien ────────────────────────────────────────────────────────

/// Style architectural du bâtiment.
enum BuildingStyle {
  haussmannien,
  moderne,
  contemporain,
  ancien,
  brique,
  immeuble,
  villa,
  maisondeville,
  autre,
}

/// Type de chauffage.
enum HeatingType {
  gaz,
  electrique,
  fioul,
  pompeAChaleur,
  bois,
  climReversible,
  autre,
}

/// Mode de contrôle du chauffage.
enum HeatingControl { individuel, collectif, mitige }

/// Type de vitrage.
enum GlazingType { simple, doubleVitrage, tripleVitrage }

/// Matériau/type de revêtement de sol.
enum FloorType {
  parquet,
  parquetFlottant,
  carrelage,
  betonCire,
  moquette,
  stratifie,
  tomette,
  autre,
}

/// Configuration de la cuisine.
enum KitchenType { ouverte, semiOuverte, fermee, americaine }

/// Énergie de la cuisine.
enum KitchenEnergy { gaz, electrique, induction }

/// Niveau de luminosité naturelle.
enum LightingType { excellente, bonne, moyenne, sombre }

/// Qualité de l'eau (calcaire, etc.).
enum WaterQuality { calcaire, normale, douce }

/// Taille de la salle de bain.
enum BathroomSize { petite, moyenne, grande }

/// Proximité spatiale entre deux espaces.
enum Proximity { direct, proche, eloigne }

// ── Rénovation ────────────────────────────────────────────────────────────

/// Niveau de rénovation requis pour un poste.
enum RenovationLevel { none, cosmetic, important, structural }

/// Fourchette budgétaire estimée pour des travaux.
enum BudgetRange { none, under5k, between5and20k, above20k }

// ── Questionnaire ─────────────────────────────────────────────────────────

/// Importance d'une question dans le questionnaire.
enum QuestionLevel { critical, important, nice }

/// Type de réponse attendue.
enum QuestionType {
  /// Note de 1 à 5.
  score,

  /// Réponse oui / non.
  yesNo,

  /// Saisie texte libre.
  text,

  /// Photo attachée.
  photo,
}

/// Moment optimal pour poser la question.
enum QuestionTiming { avant, pendant, apres, flexible }

/// Filtre de projet : à qui cette question s'applique.
enum ProjectFilter { location, achat, appartement, maison }

// ── Score & bloqueurs ─────────────────────────────────────────────────────

/// Type de bloqueur détecté lors d'une visite.
enum BlockerType { transport, humidity, phonics, budget, surface, rooms }

/// Un bloqueur identifié sur un bien visité.
class Blocker {
  final BlockerType type;
  final String message;

  const Blocker({required this.type, required this.message});

  @override
  String toString() => 'Blocker(${type.name}: $message)';
}
