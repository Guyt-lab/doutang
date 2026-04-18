import 'package:flutter_test/flutter_test.dart';

import 'package:doutang/data/default_questions.dart';
import 'package:doutang/models/enums.dart';
import 'package:doutang/models/question_template.dart';
import 'package:doutang/models/visit.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Simule le filtrage appliqué dans visit_questionnaire_screen.dart.
List<QuestionTemplate> filterQuestions({
  required String projectType, // 'location' ou 'achat'
  required ListingPropertyKind? propertyKind,
  QuestionnaireConfig? config,
}) {
  final cfg = config ?? QuestionnaireConfig.defaults;

  List<ProjectFilter> effectiveTags(QuestionTemplate q) =>
      cfg.questionTagOverrides[q.id] ?? q.appliesTo;

  final isAchat = projectType == 'achat';
  final txFilter = isAchat ? ProjectFilter.achat : ProjectFilter.location;

  bool applies(QuestionTemplate q) {
    if (cfg.disabledQuestionIds.contains(q.id)) return false;
    final tags = effectiveTags(q);
    if (tags.isEmpty) return true;

    final hasTxTag =
        tags.any((f) => f == ProjectFilter.achat || f == ProjectFilter.location);
    if (hasTxTag && !tags.contains(txFilter)) return false;

    final hasPropTag = tags.any(
        (f) => f == ProjectFilter.appartement || f == ProjectFilter.maison);
    if (hasPropTag) {
      final propFilter = propertyKind == ListingPropertyKind.maison
          ? ProjectFilter.maison
          : ProjectFilter.appartement;
      if (!tags.contains(propFilter)) return false;
    }
    return true;
  }

  return [...kDefaultQuestions, ...cfg.customQuestions]
      .where(applies)
      .toList();
}

List<QuestionTemplate> _avant(List<QuestionTemplate> all) =>
    all.where((q) => q.timing == QuestionTiming.avant).toList();

List<QuestionTemplate> _pendant(List<QuestionTemplate> all) =>
    all.where((q) =>
        q.timing == QuestionTiming.pendant ||
        q.timing == QuestionTiming.flexible).toList();

List<QuestionTemplate> _apres(List<QuestionTemplate> all) =>
    all.where((q) => q.timing == QuestionTiming.apres).toList();

bool _hasId(List<QuestionTemplate> list, String id) =>
    list.any((q) => q.id == id);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Tagging des nouvelles questions', () {
    test('sections maison uniquement taguées [maison]', () {
      final maisonIds = [
        kQFacadeFissures, kQSolAffaissement, kQMursDeformation,
        kQToitureTuiles, kQGoutieres, kQCharpente,
        kQTerrainPente, kQEauStagnante, kQTracesInondation,
        kQRaccordementEauElecGaz, kQToutALegout, kQFibreMaison,
        kQAccesRoute, kQStationnementMaison,
        kQErpConsulte, kQRisqueInondation, kQPlu,
      ];
      for (final id in maisonIds) {
        final q = kDefaultQuestions.firstWhere((q) => q.id == id,
            orElse: () => throw StateError('$id introuvable'));
        expect(q.appliesTo, contains(ProjectFilter.maison),
            reason: '$id devrait être tagué maison');
        expect(q.appliesTo, isNot(contains(ProjectFilter.appartement)),
            reason: '$id ne devrait pas être tagué appartement');
      }
    });

    test('diagnostics taguées [achat, appartement]', () {
      final diagIds = [
        kQTravauxVotes, kQProceduresCopro, kQDpeNiveau,
        kQElecAge, kQDiagElec, kQDiagAmiante, kQDiagPlomb,
      ];
      for (final id in diagIds) {
        final q = kDefaultQuestions.firstWhere((q) => q.id == id);
        expect(q.appliesTo, containsAll([ProjectFilter.achat, ProjectFilter.appartement]),
            reason: '$id devrait être tagué achat+appartement');
        expect(q.appliesTo, isNot(contains(ProjectFilter.maison)),
            reason: '$id ne devrait pas être tagué maison');
      }
    });

    test('kQTaxeHabitation est location uniquement, timing avant', () {
      final q = kDefaultQuestions.firstWhere((q) => q.id == kQTaxeHabitation);
      expect(q.appliesTo, equals([ProjectFilter.location]));
      expect(q.timing, equals(QuestionTiming.avant));
    });

    test('kQCoproprietieMaison est achat+maison, timing avant', () {
      final q =
          kDefaultQuestions.firstWhere((q) => q.id == kQCoproprietieMaison);
      expect(q.appliesTo, containsAll([ProjectFilter.achat, ProjectFilter.maison]));
      expect(q.timing, equals(QuestionTiming.avant));
    });

    test('sections maison pendant sont bien timing pendant', () {
      final pendantIds = [
        kQFacadeFissures, kQToitureTuiles, kQTerrainPente,
        kQRaccordementEauElecGaz, kQAccesRoute, kQCrepiEtat,
      ];
      for (final id in pendantIds) {
        final q = kDefaultQuestions.firstWhere((q) => q.id == id);
        expect(q.timing, equals(QuestionTiming.pendant),
            reason: '$id devrait être timing pendant');
      }
    });

    test('sections maison après sont bien timing apres', () {
      final apresIds = [
        kQProjetsConstruction, kQPlu, kQTerrainsConstructibles,
        kQErpConsulte, kQRisqueInondation, kQRisqueGlissement,
      ];
      for (final id in apresIds) {
        final q = kDefaultQuestions.firstWhere((q) => q.id == id);
        expect(q.timing, equals(QuestionTiming.apres),
            reason: '$id devrait être timing apres');
      }
    });

    test('diagnostics techniques sont bien timing apres', () {
      final apresIds = [
        kQTravauxVotes, kQDpeNiveau, kQDiagElec, kQDiagAmiante,
      ];
      for (final id in apresIds) {
        final q = kDefaultQuestions.firstWhere((q) => q.id == id);
        expect(q.timing, equals(QuestionTiming.apres));
      }
    });
  });

  group('Filtrage — appartement location', () {
    late List<QuestionTemplate> all;

    setUpAll(() {
      all = filterQuestions(
        projectType: 'location',
        propertyKind: ListingPropertyKind.appartement,
      );
    });

    test('questions universelles présentes', () {
      expect(_hasId(all, kQTransportMinutes), isTrue);
      expect(_hasId(all, kQLuminosityLiving), isTrue);
      expect(_hasId(all, kQGeneralState), isTrue);
    });

    test('sections maison absentes', () {
      expect(_hasId(all, kQFacadeFissures), isFalse);
      expect(_hasId(all, kQToitureTuiles), isFalse);
      expect(_hasId(all, kQTerrainPente), isFalse);
      expect(_hasId(all, kQErpConsulte), isFalse);
      expect(_hasId(all, kQPlu), isFalse);
    });

    test('diagnostics achat+appartement présents (avant tab)', () {
      expect(_hasId(_apres(all), kQTravauxVotes), isTrue);
      expect(_hasId(_apres(all), kQDpeNiveau), isTrue);
    });

    test('questions achat absentes', () {
      expect(_hasId(all, kQLandTax), isFalse);
    });

    test('taxe habitation présente (location)', () {
      expect(_hasId(_avant(all), kQTaxeHabitation), isTrue);
    });

    test('copropriété maison absente (appartement location)', () {
      // Tagué [achat, maison] : absent pour location
      expect(_hasId(all, kQCoproprietieMaison), isFalse);
    });
  });

  group('Filtrage — maison achat', () {
    late List<QuestionTemplate> all;

    setUpAll(() {
      all = filterQuestions(
        projectType: 'achat',
        propertyKind: ListingPropertyKind.maison,
      );
    });

    test('sections maison pendant présentes', () {
      expect(_hasId(_pendant(all), kQFacadeFissures), isTrue);
      expect(_hasId(_pendant(all), kQToitureTuiles), isTrue);
      expect(_hasId(_pendant(all), kQTerrainPente), isTrue);
      expect(_hasId(_pendant(all), kQRaccordementEauElecGaz), isTrue);
      expect(_hasId(_pendant(all), kQAccesRoute), isTrue);
    });

    test('sections maison apres présentes', () {
      expect(_hasId(_apres(all), kQErpConsulte), isTrue);
      expect(_hasId(_apres(all), kQPlu), isTrue);
      expect(_hasId(_apres(all), kQRisqueInondation), isTrue);
    });

    test('diagnostics achat+appartement présents', () {
      expect(_hasId(_apres(all), kQTravauxVotes), isTrue);
      expect(_hasId(_apres(all), kQDiagAmiante), isTrue);
    });

    test('questions appartement-only absentes', () {
      // kQElevatorPresent appliesTo [appartement]
      expect(_hasId(all, kQElevatorPresent), isFalse);
    });

    test('taxe habitation absente (achat)', () {
      expect(_hasId(all, kQTaxeHabitation), isFalse);
    });

    test('copropriété maison présente (achat + maison)', () {
      expect(_hasId(_avant(all), kQCoproprietieMaison), isTrue);
    });

    test('taxe foncière présente (achat)', () {
      expect(_hasId(_avant(all), kQLandTax), isTrue);
    });
  });

  group('Filtrage — appartement achat', () {
    late List<QuestionTemplate> all;

    setUpAll(() {
      all = filterQuestions(
        projectType: 'achat',
        propertyKind: ListingPropertyKind.appartement,
      );
    });

    test('sections maison absentes', () {
      expect(_hasId(all, kQFacadeFissures), isFalse);
      expect(_hasId(all, kQToitureTuiles), isFalse);
      expect(_hasId(all, kQPlu), isFalse);
    });

    test('diagnostics achat+appartement présents', () {
      expect(_hasId(_apres(all), kQDpeNiveau), isTrue);
      expect(_hasId(_apres(all), kQElecAge), isTrue);
      expect(_hasId(_apres(all), kQDiagPlomb), isTrue);
    });
  });

  group('Filtrage — désactivation via QuestionnaireConfig', () {
    test('question désactivée n\'apparaît pas', () {
      final config = QuestionnaireConfig(
        disabledQuestionIds: {kQFacadeFissures, kQToitureTuiles},
      );
      final all = filterQuestions(
        projectType: 'achat',
        propertyKind: ListingPropertyKind.maison,
        config: config,
      );
      expect(_hasId(all, kQFacadeFissures), isFalse);
      expect(_hasId(all, kQToitureTuiles), isFalse);
      // autres questions maison toujours présentes
      expect(_hasId(all, kQTerrainPente), isTrue);
    });
  });

  group('Rétrocompatibilité VisitAnswers', () {
    test('désérialisation depuis JSON v1 (sans champs v3) ne lève pas', () {
      final json = <String, dynamic>{
        'luminosite': 4,
        'calme': 3,
        'etat_general': 4,
        'cuisine': 3,
        'salle_de_bain': 4,
        'rangements': 2,
        'chauffage': 3,
        'quartier': 4,
        'double_vitrage': true,
        'gardien': false,
        'cave': null,
        'balcon_ou_terrasse': true,
        'ascenseur': false,
        'digicode': true,
        'coup_de_coeur': 'Luminosité',
        'point_redhibitoire': null,
      };
      // Ne doit pas lever d'exception — tous les nouveaux champs sont null
      final answers = VisitAnswers.fromJson(json);
      expect(answers.luminosite, equals(4));
      expect(answers.facadeFissures, isNull);
      expect(answers.diagAmiante, isNull);
      expect(answers.transportStations, isNull);
    });
  });
}
