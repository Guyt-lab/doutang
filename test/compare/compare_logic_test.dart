import 'package:flutter_test/flutter_test.dart';

import 'package:doutang/models/enums.dart';
import 'package:doutang/models/listing.dart';
import 'package:doutang/models/listing_facts.dart';
import 'package:doutang/models/profile.dart';
import 'package:doutang/models/question_template.dart';
import 'package:doutang/models/visit.dart';
import 'package:doutang/services/score_service.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Listing _listing({
  String id = 'l1',
  double? price,
  double? surface,
  String? dpe,
}) =>
    Listing(
      id: id,
      title: 'Bien $id',
      addedBy: 'test',
      price: price,
      surface: surface,
      facts: ListingFacts(dpe: dpe),
    );

Visit _visit({
  String listingId = 'l1',
  int luminosite = 4,
  int calme = 3,
  int feeling = 4,
  int? transportMinutes,
  bool? humidityDetected,
  int? phonicsScore,
}) =>
    Visit(
      listingId: listingId,
      owner: 'test',
      answers: VisitAnswers(
        luminosite: luminosite,
        calme: calme,
        etatGeneral: 3,
        cuisine: 3,
        salleDeBain: 3,
        rangements: 3,
        chauffage: 3,
        quartier: calme,
        transportMinutes: transportMinutes,
        humidityDetected: humidityDetected,
        phonicsScore: phonicsScore,
      ),
      feeling: feeling,
    );

UserProfile _profile({
  int transportMax = 30,
  bool humidityBlocker = true,
  int phonicsThreshold = 1,
}) =>
    UserProfile(
      owner: 'test',
      questionnaireConfig: QuestionnaireConfig(
        transportMaxMinutes: transportMax,
        humidityBlocker: humidityBlocker,
        phonicsBlockerThreshold: phonicsThreshold,
      ),
    );

// Simule le tri du ranking (bloquants en bas, puis score décroissant).
List<
    ({
      Listing listing,
      Visit? visit,
      double finalScore,
      List<Blocker> blockers
    })> _sortedRanking(
  List<Listing> listings,
  List<Visit> visits,
  UserProfile profile,
) {
  final visitByListing = {for (final v in visits) v.listingId: v};
  final entries = listings.map((listing) {
    final visit = visitByListing[listing.id];
    final finalScore = ScoreService.calculateFinalScore(
        visit, listing.facts, profile, listing);
    final blockers = visit != null
        ? ScoreService.detectBlockers(visit, profile)
        : <Blocker>[];
    return (
      listing: listing,
      visit: visit,
      finalScore: finalScore,
      blockers: blockers,
    );
  }).toList();

  entries.sort((a, b) {
    final aBlocked = a.blockers.isNotEmpty;
    final bBlocked = b.blockers.isNotEmpty;
    if (aBlocked != bBlocked) return aBlocked ? 1 : -1;
    return b.finalScore.compareTo(a.finalScore);
  });
  return entries;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Ranking — tri', () {
    test('biens avec bloquant placés en bas', () {
      final profile = _profile(transportMax: 20);
      final l1 = _listing(id: 'l1');
      final l2 = _listing(id: 'l2');
      final v1 = _visit(listingId: 'l1', transportMinutes: 40); // bloquant
      final v2 = _visit(listingId: 'l2', transportMinutes: 10);

      final ranked = _sortedRanking([l1, l2], [v1, v2], profile);
      expect(ranked.first.listing.id, 'l2');
      expect(ranked.last.listing.id, 'l1');
      expect(ranked.last.blockers, isNotEmpty);
    });

    test('sans bloquants : trié par score décroissant', () {
      final profile = _profile();
      final l1 = _listing(id: 'l1', price: 200000, surface: 40);
      final l2 = _listing(id: 'l2', price: 100000, surface: 80);
      final v1 = _visit(listingId: 'l1', luminosite: 2, calme: 2, feeling: 2);
      final v2 = _visit(listingId: 'l2', luminosite: 5, calme: 5, feeling: 5);

      final ranked = _sortedRanking([l1, l2], [v1, v2], profile);
      expect(ranked.first.listing.id, 'l2');
      expect(ranked.first.finalScore, greaterThan(ranked.last.finalScore));
    });

    test('plusieurs bloquants conservent l\'ordre entre eux', () {
      final profile = _profile(transportMax: 20, humidityBlocker: true);
      final l1 = _listing(id: 'l1');
      final l2 = _listing(id: 'l2');
      final l3 = _listing(id: 'l3');
      final v1 = _visit(listingId: 'l1', transportMinutes: 50); // bloquant
      final v2 = _visit(listingId: 'l2', humidityDetected: true); // bloquant
      final v3 = _visit(listingId: 'l3', luminosite: 4, calme: 4, feeling: 5);

      final ranked = _sortedRanking([l1, l2, l3], [v1, v2, v3], profile);
      expect(ranked.first.listing.id, 'l3');
      expect(ranked.first.blockers, isEmpty);
      expect(ranked.sublist(1).every((e) => e.blockers.isNotEmpty), isTrue);
    });
  });

  group('Score final — avec et sans visite', () {
    test('sans visite : uniquement le score matching', () {
      final profile = _profile();
      final listing = _listing(id: 'l1', price: 300000, surface: 50);
      // critères par défaut (budgetMax null) → matching neutre 0.5 → 50
      final score = ScoreService.calculateFinalScore(
          null, listing.facts, profile, listing);
      expect(score, closeTo(50, 1));
    });

    test('avec visite : score composite > matching seul pour bonne visite', () {
      final profile = _profile();
      final listing = _listing(id: 'l1');
      final visit =
          _visit(listingId: 'l1', luminosite: 5, calme: 5, feeling: 5);
      final withVisit = ScoreService.calculateFinalScore(
          visit, listing.facts, profile, listing);
      final withoutVisit = ScoreService.calculateFinalScore(
          null, listing.facts, profile, listing);
      expect(withVisit, greaterThan(withoutVisit));
    });

    test('score final entre 0 et 100', () {
      final profile = _profile();
      final listing = _listing();
      final visit = _visit(luminosite: 1, calme: 1, feeling: 1);
      final score = ScoreService.calculateFinalScore(
          visit, listing.facts, profile, listing);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('matching respecte le budget', () {
      final profile = UserProfile(
        owner: 'test',
        criteria: SearchCriteria(budgetMax: 200000),
      );
      final listingOk = _listing(id: 'ok', price: 180000);
      final listingOver = _listing(id: 'over', price: 250000);

      final scoreOk = ScoreService.calculateMatchingScore(listingOk, profile);
      final scoreOver =
          ScoreService.calculateMatchingScore(listingOver, profile);
      expect(scoreOk, greaterThan(scoreOver));
    });
  });

  group('Détection des gagnants par critère (tableau)', () {
    test('le bien avec le meilleur score final est identifiable', () {
      final profile = _profile();
      final l1 = _listing(id: 'l1');
      final l2 = _listing(id: 'l2');
      final v1 = _visit(listingId: 'l1', luminosite: 2, calme: 2, feeling: 2);
      final v2 = _visit(listingId: 'l2', luminosite: 5, calme: 5, feeling: 5);

      final scores = {
        'l1': ScoreService.calculateFinalScore(v1, l1.facts, profile, l1),
        'l2': ScoreService.calculateFinalScore(v2, l2.facts, profile, l2),
      };
      final best = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
      expect(best.key, 'l2');
    });

    test('le prix le plus bas est le gagnant sur le critère prix', () {
      final prices = [300000.0, 180000.0, 250000.0];
      final bestIdx = prices.indexOf(prices.reduce((a, b) => a < b ? a : b));
      expect(bestIdx, 1);
    });

    test('le DPE le meilleur est A avant B', () {
      const order = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
      final dpes = ['C', 'A', 'B'];
      int? bestIdx;
      int? bestRank;
      for (int i = 0; i < dpes.length; i++) {
        final rank = order.indexOf(dpes[i]);
        if (bestRank == null || rank < bestRank) {
          bestRank = rank;
          bestIdx = i;
        }
      }
      expect(bestIdx, 1); // 'A'
    });

    test('pas de bloquant est préféré à bloquant', () {
      final profile = _profile(transportMax: 20);
      final v1 = _visit(listingId: 'l1', transportMinutes: 50);
      final v2 = _visit(listingId: 'l2', transportMinutes: 10);
      final b1 = ScoreService.detectBlockers(v1, profile);
      final b2 = ScoreService.detectBlockers(v2, profile);
      expect(b1, isNotEmpty);
      expect(b2, isEmpty);
    });
  });
}
