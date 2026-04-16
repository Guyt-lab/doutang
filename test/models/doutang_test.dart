import 'package:flutter_test/flutter_test.dart';
import 'package:doutang/models/project.dart';
import 'package:doutang/models/profile.dart';
import 'package:doutang/models/listing.dart';
import 'package:doutang/models/visit.dart';
import 'package:doutang/services/score_service.dart';
import 'package:doutang/services/merge_service.dart';

void main() {
  group('DoutangProject', () {
    test('sérialisation → désérialisation est idempotente', () {
      final project = DoutangProject(
        name: 'Test Project',
        type: ProjectType.location,
      );

      final json = project.toJson();
      final restored = DoutangProject.fromJson(json);

      expect(restored.id, equals(project.id));
      expect(restored.name, equals(project.name));
      expect(restored.type, equals(project.type));
    });

    test('toFileContent produit un JSON valide', () {
      final project = DoutangProject(
        name: 'Appart Paris 2026',
        type: ProjectType.location,
      );
      final content = project.toFileContent();
      final restored = DoutangProject.fromFileContent(content);
      expect(restored.name, equals('Appart Paris 2026'));
    });
  });

  group('UserProfile', () {
    test('les poids par défaut sont bien initialisés', () {
      final profile = UserProfile(owner: 'Moi');
      expect(profile.weights['budget'], equals(5));
      expect(profile.weights['luminosite'], equals(4));
    });

    test('sérialisation → désérialisation conserve les pondérations', () {
      final profile = UserProfile(
        owner: 'Elle',
        weights: {'budget': 5, 'calme': 2, 'luminosite': 5},
        criteria: SearchCriteria(budgetMax: 1500, surfaceMin: 40, roomsMin: 2),
      );

      final restored = UserProfile.fromJson(profile.toJson());
      expect(restored.owner, equals('Elle'));
      expect(restored.weights['calme'], equals(2));
      expect(restored.criteria.budgetMax, equals(1500));
    });
  });

  group('Listing', () {
    test('statut par défaut est aContacter', () {
      final listing = Listing(title: 'Bel appart', addedBy: 'Moi');
      expect(listing.status, equals(ListingStatus.aContacter));
    });

    test('sérialisation → désérialisation conserve le statut', () {
      final listing = Listing(
        title: 'Appart favori',
        price: 1200,
        surface: 45,
        addedBy: 'Moi',
        status: ListingStatus.visitee,
      );
      final restored = Listing.fromJson(listing.toJson());
      expect(restored.status, equals(ListingStatus.visitee));
      expect(restored.price, equals(1200));
    });
  });

  group('ScoreService', () {
    late UserProfile profile;

    setUp(() {
      profile = UserProfile(
        owner: 'Moi',
        weights: {
          'luminosite': 5,
          'calme': 4,
          'etat': 3,
          'quartier': 3,
          'transports': 3,
        },
      );
    });

    test('score calculé correctement avec réponses complètes', () {
      final visit = Visit(
        listingId: 'listing-1',
        owner: 'Moi',
        answers: VisitAnswers(
          luminosite: 5,
          calme: 4,
          etatGeneral: 3,
          quartier: 4,
        ),
        feeling: 4,
      );

      final score = ScoreService.calculateVisitScore(visit, profile);
      expect(score, greaterThan(0));
      expect(score, lessThanOrEqualTo(5));
    });

    test('score couple est la moyenne des scores individuels', () {
      final visit1 = Visit(
        listingId: 'listing-1',
        owner: 'Moi',
        score: 4.0,
      );
      final visit2 = Visit(
        listingId: 'listing-1',
        owner: 'Elle',
        score: 3.0,
      );

      final coupleScore = ScoreService.calculateCoupleScore([visit1, visit2]);
      expect(coupleScore, equals(3.5));
    });

    test('score couple avec un seul visiteur retourne son score', () {
      final visit = Visit(
        listingId: 'listing-1',
        owner: 'Moi',
        score: 4.2,
      );
      final coupleScore = ScoreService.calculateCoupleScore([visit]);
      expect(coupleScore, equals(4.2));
    });

    test('matching score dans les limites pour annonce compatible', () {
      final listing = Listing(
        title: 'Appart test',
        price: 1200,
        surface: 50,
        rooms: 2,
        addedBy: 'Moi',
      );
      final profileWithCriteria = profile.copyWith(
        criteria: SearchCriteria(
          budgetMax: 1500,
          surfaceMin: 40,
          roomsMin: 2,
        ),
      );
      final score = ScoreService.calculateMatchingScore(listing, profileWithCriteria);
      expect(score, equals(1.0));
    });
  });

  group('MergeService', () {
    late DoutangProject local;
    late DoutangProject incoming;

    setUp(() {
      local = DoutangProject(
        name: 'Recherche appart',
        type: ProjectType.location,
        profiles: [UserProfile(owner: 'Moi')],
        listings: [
          Listing(
            id: 'listing-1',
            title: 'Appart A',
            addedBy: 'Moi',
            updatedAt: DateTime(2026, 4, 1),
          ),
        ],
        visits: [
          Visit(listingId: 'listing-1', owner: 'Moi', score: 4.0),
        ],
      );

      incoming = DoutangProject(
        name: 'Recherche appart',
        type: ProjectType.location,
        profiles: [UserProfile(owner: 'Elle')],
        listings: [
          Listing(
            id: 'listing-2',
            title: 'Appart B',
            addedBy: 'Elle',
          ),
        ],
        visits: [
          Visit(listingId: 'listing-1', owner: 'Elle', score: 3.5),
        ],
      );
    });

    test('merge additionne les profils des deux owners', () {
      final merged = MergeService.merge(local, incoming);
      expect(merged.profiles.length, equals(2));
      expect(merged.profiles.map((p) => p.owner), containsAll(['Moi', 'Elle']));
    });

    test('merge additionne les annonces sans doublons', () {
      final merged = MergeService.merge(local, incoming);
      expect(merged.listings.length, equals(2));
    });

    test('merge fusionne les visites des deux owners', () {
      final merged = MergeService.merge(local, incoming);
      expect(merged.visits.length, equals(2));
    });

    test('listing plus récent écrase le plus ancien', () {
      final newerListing = Listing(
        id: 'listing-1',
        title: 'Appart A — mis à jour',
        addedBy: 'Moi',
        updatedAt: DateTime(2026, 4, 16),
      );
      final incomingWithUpdate = incoming.copyWith(
        listings: [newerListing],
      );

      final merged = MergeService.merge(local, incomingWithUpdate);
      final listing1 = merged.listings.firstWhere((l) => l.id == 'listing-1');
      expect(listing1.title, equals('Appart A — mis à jour'));
    });

    test('MergeSummary reflète les changements', () {
      final merged = MergeService.merge(local, incoming);
      final summary = MergeService.summarize(local, merged);
      expect(summary.newListings, equals(1));
      expect(summary.newVisits, equals(1));
      expect(summary.newProfiles, equals(1));
      expect(summary.hasChanges, isTrue);
    });
  });
}
