import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:doutang/models/profile.dart';
import 'package:doutang/services/profile_storage_service.dart';

void main() {
  // Répertoire temporaire recréé pour chaque test.
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('doutang_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // ── SearchCriteria ─────────────────────────────────────────────────────────

  group('SearchCriteria.projectType', () {
    test('sérialisation → désérialisation conserve le projectType', () {
      final criteria = SearchCriteria(
        budgetMax: 1500,
        surfaceMin: 40,
        roomsMin: 2,
        projectType: 'location',
        zones: ['Paris 11', 'Montreuil'],
      );

      final restored = SearchCriteria.fromJson(criteria.toJson());
      expect(restored.projectType, equals('location'));
      expect(restored.budgetMax, equals(1500));
      expect(restored.zones, equals(['Paris 11', 'Montreuil']));
    });

    test('projectType est null par défaut', () {
      final criteria = SearchCriteria(budgetMax: 800);
      expect(criteria.projectType, isNull);
      final restored = SearchCriteria.fromJson(criteria.toJson());
      expect(restored.projectType, isNull);
    });

    test('projectType achat est conservé', () {
      final criteria = SearchCriteria(projectType: 'achat');
      final restored = SearchCriteria.fromJson(criteria.toJson());
      expect(restored.projectType, equals('achat'));
    });

    test('copyWith projectType remplace la valeur', () {
      final base = SearchCriteria(projectType: 'location');
      final updated = base.copyWith(projectType: 'achat');
      expect(updated.projectType, equals('achat'));
      expect(updated.budgetMax, isNull);
    });
  });

  // ── ProfileStorageService ──────────────────────────────────────────────────

  group('ProfileStorageService', () {
    test('load retourne null si le fichier n\'existe pas', () async {
      final result = await ProfileStorageService.load(
        basePath: tempDir.path,
      );
      expect(result, isNull);
    });

    test('save puis load restitue le profil à l\'identique', () async {
      final profile = UserProfile(
        owner: 'Alice',
        criteria: SearchCriteria(
          budgetMax: 1200,
          surfaceMin: 35,
          roomsMin: 2,
          projectType: 'location',
          zones: ['Paris 10', 'Paris 11'],
        ),
        weights: {
          'budget': 5,
          'surface': 3,
          'transports': 4,
          'luminosite': 5,
          'calme': 2,
          'etat': 3,
          'quartier': 4,
          'exterieur': 1,
        },
      );

      await ProfileStorageService.save(profile, basePath: tempDir.path);
      final restored = await ProfileStorageService.load(basePath: tempDir.path);

      expect(restored, isNotNull);
      expect(restored!.owner, equals('Alice'));
      expect(restored.criteria.budgetMax, equals(1200));
      expect(restored.criteria.surfaceMin, equals(35));
      expect(restored.criteria.roomsMin, equals(2));
      expect(restored.criteria.projectType, equals('location'));
      expect(restored.criteria.zones, equals(['Paris 10', 'Paris 11']));
      expect(restored.weights['budget'], equals(5));
      expect(restored.weights['luminosite'], equals(5));
      expect(restored.weights['exterieur'], equals(1));
    });

    test('save écrase le fichier existant', () async {
      final v1 = UserProfile(owner: 'V1');
      final v2 = UserProfile(owner: 'V2');

      await ProfileStorageService.save(v1, basePath: tempDir.path);
      await ProfileStorageService.save(v2, basePath: tempDir.path);
      final restored = await ProfileStorageService.load(basePath: tempDir.path);

      expect(restored!.owner, equals('V2'));
    });

    test('delete supprime le fichier — load retourne ensuite null', () async {
      final profile = UserProfile(owner: 'Temporaire');
      await ProfileStorageService.save(profile, basePath: tempDir.path);

      await ProfileStorageService.delete(basePath: tempDir.path);
      final result = await ProfileStorageService.load(basePath: tempDir.path);

      expect(result, isNull);
    });

    test('delete est sans effet si le fichier n\'existe pas', () async {
      // Ne doit pas lever d'exception.
      await expectLater(
        ProfileStorageService.delete(basePath: tempDir.path),
        completes,
      );
    });

    test('le fichier écrit est du JSON lisible (non corrompu)', () async {
      final profile = UserProfile(
        owner: 'Bob',
        criteria: SearchCriteria(projectType: 'achat', budgetMax: 250000),
      );

      await ProfileStorageService.save(profile, basePath: tempDir.path);

      final file = File('${tempDir.path}/profile.json');
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('"owner"'));
      expect(content, contains('"Bob"'));
      expect(content, contains('"project_type"'));
      expect(content, contains('"achat"'));
    });
  });
}
