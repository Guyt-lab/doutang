import '../models/enums.dart';
import '../models/listing.dart';
import '../models/listing_facts.dart';
import '../models/profile.dart';
import '../models/question_template.dart';
import '../models/visit.dart';

class ScoreService {
  /// Calcule le score d'évaluation d'une visite (pondérations profil).
  ///
  /// [config] — si fourni, seules les questions dont l'id est dans
  /// [QuestionnaireConfig.enabledQuestionIds] contribuent au score.
  /// Si [enabledQuestionIds] est vide, toutes les réponses contribuent
  /// (comportement v1 inchangé).
  ///
  /// Retourne une valeur entre 0.0 et 5.0.
  static double calculateVisitScore(
    Visit visit,
    UserProfile profile, {
    QuestionnaireConfig? config,
  }) {
    final answers = visit.answers.ratedAnswers;
    final weights = profile.weights;
    final enabled = config?.enabledQuestionIds ?? {};

    double weightedSum = 0;
    double totalWeight = 0;

    for (final entry in answers.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      // Si une liste d'ids activés est définie, filtrer par clé de question.
      // La convention id = 'q_<key>' (ex: q_luminosite, q_calme…).
      if (enabled.isNotEmpty && !enabled.contains('q_$key')) continue;

      final weight =
          (weights[key] ?? weights[_mapAnswerKeyToWeight(key)] ?? 3).toDouble();
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

    final validScores =
        visitsForListing.where((v) => v.score > 0).map((v) => v.score).toList();

    if (validScores.isEmpty) return 0.0;

    final sum = validScores.reduce((a, b) => a + b);
    return double.parse((sum / validScores.length).toStringAsFixed(2));
  }

  /// Calcule le score de matching d'une annonce vs le profil AVANT visite.
  ///
  /// Utilise en priorité les champs [ListingFacts] (plus riches) puis les
  /// champs directs du [Listing] en fallback.
  ///
  /// Retourne un pourcentage entre 0.0 et 1.0.
  static double calculateMatchingScore(
    Listing listing,
    UserProfile profile, {
    ListingFacts? facts,
  }) {
    final criteria = profile.criteria;
    final f = facts ?? listing.facts;
    double score = 0;
    int checks = 0;

    // ── Budget ────────────────────────────────────────────────────────────
    final price = listing.price;
    if (criteria.budgetMax != null && price != null) {
      checks++;
      if (price <= criteria.budgetMax!) {
        score++;
      } else if (price <= criteria.budgetMax! * 1.1) {
        score += 0.5;
      }
    }

    // ── Surface ───────────────────────────────────────────────────────────
    final surface = f.surfaceTotal ?? listing.surface;
    if (criteria.surfaceMin != null && surface != null) {
      checks++;
      if (surface >= criteria.surfaceMin!) {
        score++;
      } else if (surface >= criteria.surfaceMin! * 0.9) {
        score += 0.5;
      }
    }

    // ── Pièces ────────────────────────────────────────────────────────────
    final rooms = f.rooms ?? listing.rooms;
    if (criteria.roomsMin != null && rooms != null) {
      checks++;
      if (rooms >= criteria.roomsMin!) score++;
    }

    // ── DPE (si les faits sont disponibles) ───────────────────────────────
    // Pour un projet achat, un DPE F ou G est pénalisant.
    if (f.dpe != null && criteria.projectType == 'achat') {
      checks++;
      const badDpe = {'F', 'G'};
      if (!badDpe.contains(f.dpe!.toUpperCase())) score++;
    }

    if (checks == 0) return 0.5; // Pas assez d'infos — score neutre

    return double.parse((score / checks).toStringAsFixed(2));
  }

  /// Détecte les bloqueurs d'une visite selon la configuration du profil.
  ///
  /// Un bloqueur signifie que le bien est éliminatoire sur ce critère.
  static List<Blocker> detectBlockers(
    Visit visit,
    UserProfile profile,
  ) {
    final answers = visit.answers;
    final config = profile.questionnaireConfig;
    final blockers = <Blocker>[];

    // ── Transport ─────────────────────────────────────────────────────────
    final minutes = answers.transportMinutes;
    if (minutes != null && minutes > config.transportMaxMinutes) {
      blockers.add(Blocker(
        type: BlockerType.transport,
        message: '${minutes} min (max ${config.transportMaxMinutes} min)',
      ));
    }

    // ── Humidité ──────────────────────────────────────────────────────────
    if (config.humidityBlocker && answers.humidityDetected == true) {
      blockers.add(const Blocker(
        type: BlockerType.humidity,
        message: 'Humidité détectée',
      ));
    }

    // ── Acoustique ────────────────────────────────────────────────────────
    final phonics = answers.phonicsScore;
    if (phonics != null && phonics <= config.phonicsBlockerThreshold) {
      blockers.add(Blocker(
        type: BlockerType.phonics,
        message: 'Score acoustique : $phonics/5',
      ));
    }

    return blockers;
  }

  /// Calcule le score final d'un bien (0–100).
  ///
  /// Combine trois composantes selon [QuestionnaireConfig.scoreWeights] :
  /// - `eval`     : score d'évaluation de visite, normalisé sur 100  (0 si pas de visite)
  /// - `matching` : score de matching annonce ↔ profil, normalisé sur 100
  /// - `feeling`  : ressenti global de la visite (1–5), normalisé sur 100 (0 si pas de visite)
  ///
  /// Si [visit] est null, seule la composante `matching` contribue (pondérée 1.0).
  static double calculateFinalScore(
    Visit? visit,
    ListingFacts facts,
    UserProfile profile,
    Listing listing,
  ) {
    final config = profile.questionnaireConfig;
    final weights = config.scoreWeights;

    final matchingRaw = calculateMatchingScore(listing, profile, facts: facts);
    final matchingScore = matchingRaw * 100;

    if (visit == null) {
      return double.parse(matchingScore.toStringAsFixed(1));
    }

    final evalRaw = calculateVisitScore(visit, profile, config: config);
    final evalScore = (evalRaw / 5.0) * 100;

    final feelingRaw = visit.feeling.clamp(1, 5);
    final feelingScore = ((feelingRaw - 1) / 4.0) * 100;

    final wEval = weights['eval'] ?? 0.5;
    final wMatching = weights['matching'] ?? 0.3;
    final wFeeling = weights['feeling'] ?? 0.2;

    final total =
        wEval * evalScore + wMatching * matchingScore + wFeeling * feelingScore;

    return double.parse(total.toStringAsFixed(1));
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
