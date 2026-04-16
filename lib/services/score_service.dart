import '../models/visit.dart';
import '../models/profile.dart';
import '../models/listing.dart';

class ScoreService {
  /// Calcule le score d'une visite individuelle basé sur les pondérations du profil.
  /// Retourne une valeur entre 0.0 et 5.0
  static double calculateVisitScore(Visit visit, UserProfile profile) {
    final answers = visit.answers.ratedAnswers;
    final weights = profile.weights;

    double weightedSum = 0;
    double totalWeight = 0;

    for (final entry in answers.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      final weight = (weights[key] ?? weights[_mapAnswerKeyToWeight(key)] ?? 3).toDouble();
      weightedSum += value * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return 0.0;

    return double.parse((weightedSum / totalWeight).toStringAsFixed(2));
  }

  /// Calcule le score couple en moyennant les scores individuels.
  /// Si un seul partenaire a visité, retourne son score directement.
  static double calculateCoupleScore(List<Visit> visitsForListing) {
    if (visitsForListing.isEmpty) return 0.0;

    final validScores = visitsForListing
        .where((v) => v.score > 0)
        .map((v) => v.score)
        .toList();

    if (validScores.isEmpty) return 0.0;

    final sum = validScores.reduce((a, b) => a + b);
    return double.parse((sum / validScores.length).toStringAsFixed(2));
  }

  /// Calcule le score de matching d'une annonce vs le profil AVANT visite.
  /// Retourne un pourcentage entre 0.0 et 1.0
  static double calculateMatchingScore(Listing listing, UserProfile profile) {
    final criteria = profile.criteria;
    double score = 0;
    int checks = 0;

    // Budget
    if (criteria.budgetMax != null && listing.price != null) {
      checks++;
      if (listing.price! <= criteria.budgetMax!) score++;
      else if (listing.price! <= criteria.budgetMax! * 1.1) score += 0.5;
    }

    // Surface
    if (criteria.surfaceMin != null && listing.surface != null) {
      checks++;
      if (listing.surface! >= criteria.surfaceMin!) score++;
      else if (listing.surface! >= criteria.surfaceMin! * 0.9) score += 0.5;
    }

    // Pièces
    if (criteria.roomsMin != null && listing.rooms != null) {
      checks++;
      if (listing.rooms! >= criteria.roomsMin!) score++;
    }

    if (checks == 0) return 0.5; // Pas assez d'infos — score neutre

    return double.parse((score / checks).toStringAsFixed(2));
  }

  /// Retourne un libellé pour un score donné
  static String scoreLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 3.5) return 'Très bien';
    if (score >= 2.5) return 'Bien';
    if (score >= 1.5) return 'Moyen';
    return 'Insuffisant';
  }

  /// Retourne les points forts d'une visite (notes >= 4)
  static List<String> strengths(Visit visit) {
    return visit.answers.ratedAnswers.entries
        .where((e) => e.value != null && e.value! >= 4)
        .map((e) => _labelForKey(e.key))
        .toList();
  }

  /// Retourne les points faibles d'une visite (notes <= 2)
  static List<String> weaknesses(Visit visit) {
    return visit.answers.ratedAnswers.entries
        .where((e) => e.value != null && e.value! <= 2)
        .map((e) => _labelForKey(e.key))
        .toList();
  }

  static String _mapAnswerKeyToWeight(String answerKey) {
    const mapping = {
      'etat_general': 'etat',
      'salle_de_bain': 'etat',
      'cuisine': 'etat',
      'rangements': 'etat',
      'chauffage': 'etat',
    };
    return mapping[answerKey] ?? answerKey;
  }

  static String _labelForKey(String key) {
    const labels = {
      'luminosite': 'Luminosité',
      'calme': 'Calme',
      'etat_general': 'État général',
      'cuisine': 'Cuisine',
      'salle_de_bain': 'Salle de bain',
      'rangements': 'Rangements',
      'chauffage': 'Chauffage',
      'quartier': 'Quartier',
    };
    return labels[key] ?? key;
  }
}
