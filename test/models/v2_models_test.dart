import 'package:flutter_test/flutter_test.dart';

import 'package:doutang/models/enums.dart';
import 'package:doutang/models/listing.dart';
import 'package:doutang/models/listing_facts.dart';
import 'package:doutang/models/profile.dart';
import 'package:doutang/models/question_template.dart';
import 'package:doutang/models/renovation_answers.dart';
import 'package:doutang/models/visit.dart';
import 'package:doutang/services/score_service.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  // RenovationAnswers.computedBudgetRange
  // ────────────────────────────────────────────────────────────────────────────
  group('RenovationAnswers.computedBudgetRange', () {
    test('aucun travaux → none', () {
      const r = RenovationAnswers();
      expect(r.computedBudgetRange, BudgetRange.none);
    });

    test('1 cosmétique → under5k', () {
      const r = RenovationAnswers(floors: RenovationLevel.cosmetic);
      expect(r.computedBudgetRange, BudgetRange.under5k);
    });

    test('3 cosmétiques → between5and20k', () {
      const r = RenovationAnswers(
        floors: RenovationLevel.cosmetic,
        walls: RenovationLevel.cosmetic,
        bathroom: RenovationLevel.cosmetic,
      );
      expect(r.computedBudgetRange, BudgetRange.between5and20k);
    });

    test('1 important → between5and20k', () {
      const r = RenovationAnswers(electric: RenovationLevel.important);
      expect(r.computedBudgetRange, BudgetRange.between5and20k);
    });

    test('3 importants → above20k', () {
      const r = RenovationAnswers(
        electric: RenovationLevel.important,
        plumbing: RenovationLevel.important,
        windows: RenovationLevel.important,
      );
      expect(r.computedBudgetRange, BudgetRange.above20k);
    });

    test('1 structurel → above20k', () {
      const r = RenovationAnswers(heating: RenovationLevel.structural);
      expect(r.computedBudgetRange, BudgetRange.above20k);
    });

    test('mix structurel + cosmétiques → above20k (structurel domine)', () {
      const r = RenovationAnswers(
        floors: RenovationLevel.cosmetic,
        walls: RenovationLevel.cosmetic,
        heating: RenovationLevel.structural,
      );
      expect(r.computedBudgetRange, BudgetRange.above20k);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // ScoreService.detectBlockers
  // ────────────────────────────────────────────────────────────────────────────
  group('ScoreService.detectBlockers', () {
    late UserProfile profile;

    setUp(() {
      profile = UserProfile(owner: 'test');
      // Defaults : transportMaxMinutes=15, humidityBlocker=true, phonicsBlockerThreshold=1
    });

    Visit _visitWith({
      int? transportMinutes,
      bool? humidityDetected,
      int? phonicsScore,
    }) {
      return Visit(
        listingId: 'l1',
        owner: 'test',
        answers: VisitAnswers(
          transportMinutes: transportMinutes,
          humidityDetected: humidityDetected,
          phonicsScore: phonicsScore,
        ),
      );
    }

    test('aucun bloqueur si tout est OK', () {
      final visit = _visitWith(
        transportMinutes: 10,
        humidityDetected: false,
        phonicsScore: 3,
      );
      expect(ScoreService.detectBlockers(visit, profile), isEmpty);
    });

    test('bloqueur transport si trajet > 15 min', () {
      final visit = _visitWith(transportMinutes: 20);
      final blockers = ScoreService.detectBlockers(visit, profile);
      expect(blockers.length, 1);
      expect(blockers.first.type, BlockerType.transport);
    });

    test('pas de bloqueur transport si exactement 15 min', () {
      final visit = _visitWith(transportMinutes: 15);
      expect(ScoreService.detectBlockers(visit, profile), isEmpty);
    });

    test('bloqueur humidité si humidité détectée', () {
      final visit = _visitWith(humidityDetected: true);
      final blockers = ScoreService.detectBlockers(visit, profile);
      expect(blockers.any((b) => b.type == BlockerType.humidity), isTrue);
    });

    test('pas de bloqueur humidité si humidityBlocker désactivé', () {
      final customProfile = profile.copyWith(
        questionnaireConfig: const QuestionnaireConfig(humidityBlocker: false),
      );
      final visit = _visitWith(humidityDetected: true);
      expect(ScoreService.detectBlockers(visit, customProfile), isEmpty);
    });

    test('bloqueur phonics si score ≤ seuil (1 par défaut)', () {
      final visit = _visitWith(phonicsScore: 1);
      final blockers = ScoreService.detectBlockers(visit, profile);
      expect(blockers.any((b) => b.type == BlockerType.phonics), isTrue);
    });

    test('pas de bloqueur phonics si score > seuil', () {
      final visit = _visitWith(phonicsScore: 2);
      expect(ScoreService.detectBlockers(visit, profile), isEmpty);
    });

    test('multiple bloqueurs détectés simultanément', () {
      final visit = _visitWith(
        transportMinutes: 30,
        humidityDetected: true,
        phonicsScore: 1,
      );
      final blockers = ScoreService.detectBlockers(visit, profile);
      expect(blockers.length, 3);
    });

    test('aucun bloqueur si champs absents (null)', () {
      final visit = _visitWith();
      expect(ScoreService.detectBlockers(visit, profile), isEmpty);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // ScoreService.calculateFinalScore
  // ────────────────────────────────────────────────────────────────────────────
  group('ScoreService.calculateFinalScore', () {
    late UserProfile profile;
    late Listing listing;

    setUp(() {
      profile = UserProfile(
        owner: 'test',
        criteria: SearchCriteria(budgetMax: 300000),
      );
      listing = Listing(
        title: 'Test',
        price: 250000,
        addedBy: 'test',
      );
    });

    test('sans visite → retourne le score de matching normalisé', () {
      final score = ScoreService.calculateFinalScore(
        null,
        const ListingFacts(),
        profile,
        listing,
      );
      // Budget OK (250k ≤ 300k) → matching = 1.0 → score = 100
      expect(score, closeTo(100.0, 0.1));
    });

    test('avec visite parfaite → score élevé', () {
      final visit = Visit(
        listingId: listing.id,
        owner: 'test',
        answers: VisitAnswers(
          luminosite: 5,
          calme: 5,
          etatGeneral: 5,
          cuisine: 5,
          salleDeBain: 5,
          rangements: 5,
          chauffage: 5,
          quartier: 5,
        ),
        feeling: 5,
      );
      final score = ScoreService.calculateFinalScore(
        visit,
        const ListingFacts(),
        profile,
        listing,
      );
      expect(score, greaterThan(80.0));
    });

    test('avec visite médiocre + budget hors critères → score bas', () {
      final expensiveListing = listing.copyWith(price: 500000);
      final visit = Visit(
        listingId: expensiveListing.id,
        owner: 'test',
        answers: VisitAnswers(
          luminosite: 1,
          calme: 1,
          etatGeneral: 1,
          cuisine: 1,
          salleDeBain: 1,
          rangements: 1,
          chauffage: 1,
          quartier: 1,
        ),
        feeling: 1,
      );
      final score = ScoreService.calculateFinalScore(
        visit,
        const ListingFacts(),
        profile,
        expensiveListing,
      );
      expect(score, lessThan(40.0));
    });

    test('score compris entre 0 et 100', () {
      final visit = Visit(
        listingId: listing.id,
        owner: 'test',
        answers: VisitAnswers(luminosite: 3, calme: 3),
        feeling: 3,
      );
      final score = ScoreService.calculateFinalScore(
        visit,
        const ListingFacts(),
        profile,
        listing,
      );
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // ListingFacts.complement
  // ────────────────────────────────────────────────────────────────────────────
  group('ListingFacts.complement', () {
    test('les champs non-null de this ne sont pas écrasés', () {
      const a = ListingFacts(surfaceTotal: 60, rooms: 3);
      const b = ListingFacts(surfaceTotal: 55, rooms: 2, dpe: 'C');
      final result = a.complement(b);
      expect(result.surfaceTotal, 60); // a gagne
      expect(result.rooms, 3); // a gagne
      expect(result.dpe, 'C'); // b complète
    });

    test('les champs null de this sont remplis par other', () {
      const a = ListingFacts(surfaceTotal: 60);
      const b = ListingFacts(rooms: 4, dpe: 'B');
      final result = a.complement(b);
      expect(result.surfaceTotal, 60);
      expect(result.rooms, 4);
      expect(result.dpe, 'B');
    });

    test('complement avec other vide retourne this inchangé', () {
      const a = ListingFacts(surfaceTotal: 70, rooms: 3, dpe: 'A');
      final result = a.complement(const ListingFacts());
      expect(result.surfaceTotal, 70);
      expect(result.rooms, 3);
      expect(result.dpe, 'A');
    });
  });
}
