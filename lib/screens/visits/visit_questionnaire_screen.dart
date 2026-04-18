import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/default_questions.dart';
import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/question_template.dart';
import '../../models/renovation_answers.dart';
import '../../models/visit.dart';
import '../../services/project_service.dart';
import '../../services/score_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
import '../../models/exterior_space.dart';
import '../../widgets/exterior_spaces_card.dart';
import '../../widgets/question_card.dart';
import '../../widgets/renovation_card.dart';

/// Écran de questionnaire de visite.
///
/// Reçoit via [settings.arguments] un `Map<String, dynamic>` avec :
/// - `'listing'`  : [Listing]
/// - `'profile'`  : [UserProfile]
///
/// Structure en 3 onglets :
/// - **Avant** — questions à poser avant d'entrer dans l'appartement.
/// - **Pendant** — questions posées sur place, groupées par section.
/// - **Après** — ressenti global, rénovation (achat uniquement), validation.
class VisitQuestionnaireScreen extends StatefulWidget {
  final Listing listing;
  final UserProfile profile;

  /// Visite existante à ré-éditer. Null = nouvelle visite.
  final Visit? existingVisit;

  /// Date/heure choisie dans [VisitStartScreen]. Null = maintenant.
  final DateTime? visitedAt;

  const VisitQuestionnaireScreen({
    super.key,
    required this.listing,
    required this.profile,
    this.existingVisit,
    this.visitedAt,
  });

  @override
  State<VisitQuestionnaireScreen> createState() =>
      _VisitQuestionnaireScreenState();
}

class _VisitQuestionnaireScreenState extends State<VisitQuestionnaireScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  /// Réponses courantes : id de question → valeur (int?, bool? ou String?).
  final Map<String, dynamic> _answers = {};

  /// Ressenti global : 1 (très négatif) → 5 (coup de cœur).
  int _feeling = 3;

  /// Évaluation travaux (projet achat uniquement).
  RenovationAnswers _renovation = const RenovationAnswers();

  /// Espaces extérieurs saisis dans l'onglet Avant.
  List<ExteriorSpace> _exteriorSpaces = [];

  bool _isSaving = false;

  // Questions filtrées par onglet
  late final List<QuestionTemplate> _questionsAvant;
  late final List<QuestionTemplate> _questionsPendant;
  late final List<QuestionTemplate> _questionsApres;

  bool get _isAchat =>
      widget.profile.criteria.projectType == 'achat';

  // ── Cycle de vie ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filterQuestions();
    if (widget.existingVisit != null) {
      _prefillFromExistingVisit(widget.existingVisit!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Filtrage des questions ─────────────────────────────────────────────────

  void _filterQuestions() {
    final config = widget.profile.questionnaireConfig;

    // Effective appliesTo for a question: override if present, else template default.
    List<ProjectFilter> effectiveTags(QuestionTemplate q) =>
        config.questionTagOverrides[q.id] ?? q.appliesTo;

    bool applies(QuestionTemplate q) {
      if (config.disabledQuestionIds.contains(q.id)) return false;

      final tags = effectiveTags(q);
      if (tags.isNotEmpty) {
        final txFilter = _isAchat ? ProjectFilter.achat : ProjectFilter.location;
        final propKind = widget.listing.propertyKind;

        final hasTxTag = tags.any(
            (f) => f == ProjectFilter.achat || f == ProjectFilter.location);
        if (hasTxTag && !tags.contains(txFilter)) return false;

        final hasPropTag = tags.any(
            (f) => f == ProjectFilter.appartement || f == ProjectFilter.maison);
        if (hasPropTag) {
          final propFilter = propKind == ListingPropertyKind.maison
              ? ProjectFilter.maison
              : ProjectFilter.appartement;
          if (!tags.contains(propFilter)) return false;
        }
      }
      return true;
    }

    final allQuestions = [
      ...kDefaultQuestions,
      ...config.customQuestions,
    ];
    final active = allQuestions.where(applies).toList();

    _questionsAvant =
        active.where((q) => q.timing == QuestionTiming.avant).toList();
    _questionsPendant = active
        .where((q) =>
            q.timing == QuestionTiming.pendant ||
            q.timing == QuestionTiming.flexible)
        .toList();
    _questionsApres =
        active.where((q) => q.timing == QuestionTiming.apres).toList();
  }

  // ── Pré-remplissage depuis une visite existante ────────────────────────────

  void _prefillFromExistingVisit(Visit v) {
    final a = v.answers;

    void put(String key, dynamic val) {
      if (val != null) _answers[key] = val;
    }

    void putStr(String key, String? val) {
      if (val != null && val.isNotEmpty) _answers[key] = val;
    }

    // s1
    put(kQTransportMinutes, a.transportScore);
    _answers[kQTransportType] = _decodeMultiChoice(a.transportType);
    _answers[kQMobilityServices] = _decodeMultiChoice(a.mobilityService);
    put(kQNoiseStreet, a.noiseScore ?? a.calme);
    put(kQNeighborhoodVibe, a.neighborhoodScore ?? a.quartier);
    put(kQSafetyFeeling, a.safetyScore);
    put(kQGreenSpaces, a.greenScore);
    // s2
    put(kQCommonAreas, a.commonAreasScore);
    put(kQBuildingCondition, a.commonAreasScore);
    put(kQElevatorOk, a.elevatorOk ?? a.ascenseur);
    put(kQElevatorPresent, a.elevatorOk ?? a.ascenseur);
    put(kQCave, a.caveOk ?? a.cave);
    put(kQBikeStorage, a.bikeStorage);
    put(kQSecureDoor, a.secureDoorOk ?? a.digicode);
    put(kQParking, a.parking);
    put(kQBuildingConcierge, a.buildingConcierge);
    put(kQCaveAccess, a.caveAccess);
    put(kQCaveDoor, a.caveDoor);
    put(kQCaveDry, a.caveDry);
    put(kQBikeStorageSecured, a.bikeStorageSecured);
    put(kQBikeStorageSpace, a.bikeStorageSpace);
    put(kQTrashAccess, a.trashAccess);
    put(kQDisabledAccess, a.disabledAccess);
    // s3
    put(kQLuminosityLiving, a.luminosityScore ?? a.luminosite);
    putStr(kQVisitTime, a.visitTime);
    put(kQVisAVis, a.visAVisScore);
    put(kQDoubleGlazing, a.doubleVitrage);
    // s4
    put(kQPhonicsFloors, a.phonicsScore);
    put(kQPhonicsNeighbors, a.phonicsScore);
    put(kQPhonicsStreet, a.phonicsScore);
    put(kQHumidityDetected, a.humidityDetected);
    put(kQHeatingDistribution, a.heatingDistributionScore ?? a.chauffage);
    put(kQThermalInsulation, a.thermalInsulationScore);
    // s_living
    put(kQRadiatorLiving, a.radiatorLiving);
    // s_bathroom
    put(kQRadiatorBathroom, a.radiatorBathroom);
    // s_bedrooms
    put(kQRadiatorBedroom, a.radiatorBedroom);
    // s_heating
    putStr(kQHeatingSystem, a.heatingSystem);
    // s2 elevator size
    _answers[kQElevatorSize] = _decodeMultiChoice(a.elevatorSize);
    // s5
    put(kQGeneralState, a.etatGeneral);
    put(kQElectricPanel, a.electricPanelOk);
    put(kQEarthGround, a.earthGroundOk);
    put(kQOutlets, a.outletsScore);
    put(kQWaterPressure, a.waterPressureOk);
    put(kQWaterQuality, a.waterQualityScore);
    put(kQMobileSignal, a.mobileSignalOk);
    put(kQVmc, a.vmcOk);
    // s6
    put(kQKitchenLayout, a.cuisine);
    put(kQKitchenWorktop, a.kitchenWorktopScore);
    put(kQKitchenHood, a.hoodOk);
    put(kQWashingMachineSpace, a.washingMachineSpace);
    put(kQFridgeSpace, a.fridgeSpaceOk);
    put(kQDishwasherSpace, a.dishwasherSpace);
    put(kQTrashSpace, a.trashSpace);
    put(kQVmcKitchen, a.vmcKitchen);
    _answers[kQKitchenOpenClosed] = _decodeMultiChoice(a.kitchenOpenClosed);
    put(kQBathroomSize, a.salleDeBain);
    put(kQTowelRadiator, a.towelRadiatorSdb);
    _answers[kQBathroomFeatures] = _decodeMultiChoice(a.bathroomFeatures);
    // s7
    put(kQStorageSpace, a.rangements);
    putStr(kQOutdoorSurface, a.outdoorSurface);
    put(kQOutdoorNeighborExposure, a.outdoorNeighborExposure);
    put(kQOutdoorSunExposure, a.outdoorSunExposure);
    put(kQOutdoorViewQuality, a.outdoorViewQuality);
    // s8
    putStr(kQDepartureReason, a.departureReason);
    putStr(kQChargesAmount, a.chargesAmount);
    putStr(kQCoupDeCoeur, a.coupDeCoeur);
    putStr(kQPointRedhibitoire, a.pointRedhibitoire);

    // v3 — transport conditionnel
    putStr(kQTransportStations, a.transportStations);
    // v3 — admin
    putStr(kQTaxeHabitation, a.taxeHabitation);
    put(kQCoproprietieMaison, a.coproprieteMaison);
    // v3 — extérieur structure maison
    put(kQFacadeFissures, a.facadeFissures);
    put(kQSolAffaissement, a.solAffaissement);
    put(kQMursDeformation, a.mursDeformation);
    put(kQHumiditeExterieure, a.humiditeExterieure);
    // v3 — toiture
    put(kQToitureTuiles, a.toitureTuiles);
    put(kQGoutieres, a.goutieres);
    put(kQCharpente, a.charpente);
    put(kQIsolationToiture, a.isolationToiture);
    put(kQToitureRenovation, a.toitureRenovation);
    // v3 — drainage
    put(kQTerrainPente, a.terrainPente);
    put(kQEauStagnante, a.eauStagnante);
    put(kQDrains, a.drains);
    put(kQTracesInondation, a.tracesInondation);
    // v3 — terrain
    put(kQTerrainVoisinsProximite, a.terrainVoisinsProximite);
    put(kQIncidentsVoisins, a.incidentsVoisins);
    put(kQArbresProches, a.arbresProches);
    putStr(kQOrientationTerrain, a.orientationTerrain);
    put(kQNuisancesTerrain, a.nuisancesTerrain);
    // v3 — raccordements
    put(kQRaccordementEauElecGaz, a.raccordementEauElecGaz);
    putStr(kQToutALegout, a.toutALegout);
    put(kQFibreMaison, a.fibreMaison);
    put(kQBranchementsEtat, a.branchementsEtat);
    // v3 — façade ext
    put(kQCrepiEtat, a.crepiEtat);
    put(kQFacadeHumidite, a.facadeHumidite);
    put(kQIte, a.ite);
    // v3 — accès
    put(kQAccesRoute, a.accesRoute);
    put(kQStationnementMaison, a.stationnementMaison);
    put(kQServitudes, a.servitudes);
    // v3 — urbanisme
    put(kQProjetsConstruction, a.projetsConstruction);
    put(kQPlu, a.plu);
    put(kQTerrainsConstructibles, a.terrainsConstructibles);
    // v3 — risques
    put(kQErpConsulte, a.erpConsulte);
    put(kQRisqueInondation, a.risqueInondation);
    put(kQRisqueGlissement, a.risqueGlissement);
    put(kQPollutionSols, a.pollutionSols);
    put(kQNuisancesEnvironnement, a.nuisancesEnvironnement);
    // v3 — diagnostics
    putStr(kQRavelementDate, a.ravelementDate);
    put(kQTravauxVotes, a.travauxVotes);
    put(kQProceduresCopro, a.proceduresCopro);
    put(kQEvacuationsCommunes, a.evacuationsCommunes);
    put(kQFibreImmeuble, a.fibreImmeuble);
    putStr(kQDpeNiveau, a.dpeNiveau);
    put(kQElecAge, a.elecAge);
    putStr(kQDiagElec, a.diagElec);
    put(kQGazAge, a.gazAge);
    putStr(kQDiagGaz, a.diagGaz);
    putStr(kQDateConstruction, a.dateConstruction);
    putStr(kQDiagAmiante, a.diagAmiante);
    putStr(kQDiagPlomb, a.diagPlomb);

    _feeling = v.feeling;
    if (a.renovation != null) _renovation = a.renovation!;
    if (a.exteriorSpaces != null) {
      try {
        final decoded = jsonDecode(a.exteriorSpaces!) as List;
        _exteriorSpaces = decoded
            .map((e) => ExteriorSpace.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static const _sectionLabels = <String, String>{
    's1': 'Transports & Quartier',
    's2': 'Immeuble & Parties communes',
    's3': 'Luminosité & Vue',
    's4': 'Acoustique & Isolation',
    's5': 'État général',
    's_living': 'Pièce à vivre / Salon',
    's_kitchen': 'Cuisine',
    's_bathroom': 'Salle de bain',
    's_bedrooms': 'Chambres',
    's_elec': 'Électricité',
    's_heating': 'Chauffage',
    's_water': 'Eau',
    's7': 'Espaces extérieurs',
    // Maison — pendant
    's_facade': 'Extérieur & Structure',
    's_toiture': 'Toiture',
    's_drainage': 'Drainage & Eau',
    's_terrain': 'Terrain & Environnement',
    's_raccordements': 'Raccordements',
    's_facade_ext': 'Façade & Isolation extérieure',
    's_acces': 'Accès & Stationnement',
    // Maison — après
    's_urbanisme': 'Urbanisme',
    's_risques': 'Risques naturels',
    // Achat + appartement — après
    's_diagnostics': 'Diagnostics techniques',
    // Toujours en dernier dans Avant
    's8': 'Aspects pratiques',
  };

  static const _sectionIcons = <String, IconData>{
    's1': Icons.directions_transit_outlined,
    's2': Icons.apartment_outlined,
    's3': Icons.wb_sunny_outlined,
    's4': Icons.hearing_outlined,
    's5': Icons.build_outlined,
    's_living': Icons.weekend_outlined,
    's_kitchen': Icons.kitchen_outlined,
    's_bathroom': Icons.bathtub_outlined,
    's_bedrooms': Icons.bed_outlined,
    's_elec': Icons.electrical_services_outlined,
    's_heating': Icons.thermostat_outlined,
    's_water': Icons.water_drop_outlined,
    's7': Icons.yard_outlined,
    's_facade': Icons.foundation_outlined,
    's_toiture': Icons.roofing,
    's_drainage': Icons.water_outlined,
    's_terrain': Icons.terrain_outlined,
    's_raccordements': Icons.plumbing_outlined,
    's_facade_ext': Icons.format_paint_outlined,
    's_acces': Icons.directions_car_outlined,
    's_urbanisme': Icons.location_city_outlined,
    's_risques': Icons.warning_amber_outlined,
    's_diagnostics': Icons.assignment_outlined,
    's8': Icons.receipt_long_outlined,
  };

  // Template inline pour le champ conditionnel "stations" (non dans kDefaultQuestions)
  static const _kTransportStationsQ = QuestionTemplate(
    id: kQTransportStations,
    section: 's1',
    text: 'Noms des stations/arrêts les plus proches',
    level: QuestionLevel.important,
    type: QuestionType.text,
    timing: QuestionTiming.avant,
  );

  /// Groupe les questions par clé de section, en préservant l'ordre.
  Map<String, List<QuestionTemplate>> _groupBySection(
    List<QuestionTemplate> questions,
  ) {
    final groups = <String, List<QuestionTemplate>>{};
    for (final q in questions) {
      groups.putIfAbsent(q.section, () => []).add(q);
    }
    return groups;
  }

  int _answeredIn(List<QuestionTemplate> questions) =>
      questions.where((q) {
        final v = _answers[q.id];
        if (v == null) return false;
        if (v is List) return v.isNotEmpty;
        return true;
      }).length;

  void _setAnswer(String id, dynamic value) =>
      setState(() => _answers[id] = value);

  /// Décode un champ multiChoice depuis sa représentation JSON string.
  /// Rétrocompat : si la valeur n'est pas du JSON valide, la traite comme texte brut.
  static List<String>? _decodeMultiChoice(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return List<String>.from(decoded);
    } catch (_) {}
    return [json];
  }

  /// Retourne l'heure de visite au format "HH:mm" depuis [widget.visitedAt]
  /// ou la valeur texte saisie manuellement (rétrocompat).
  String? _visitTimeString() {
    final dt = widget.visitedAt ?? widget.existingVisit?.visitedAt;
    if (dt != null) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  /// Encode une valeur multiChoice (List) en JSON string pour stockage.
  String? _encodeMultiChoice(String key) {
    final v = _answers[key];
    if (v == null) return null;
    if (v is List<String>) return jsonEncode(v);
    if (v is String) return v;
    return null;
  }

  Widget _buildTransportStationsCard() {
    final v = _answers[kQTransportType];
    final hasSelection = v is List && v.isNotEmpty;
    if (!hasSelection) return const SizedBox.shrink();
    return QuestionCard(
      key: const ValueKey(kQTransportStations),
      question: _kTransportStationsQ,
      value: _answers[kQTransportStations],
      onChanged: (val) => _setAnswer(kQTransportStations, val),
    );
  }

  // ── Construction du VisitAnswers ───────────────────────────────────────────

  VisitAnswers _buildVisitAnswers() {
    int? intQ(String key) => _answers[key] as int?;
    bool? boolQ(String key) => _answers[key] as bool?;
    String? strQ(String key) {
      final v = _answers[key] as String?;
      return (v != null && v.isNotEmpty) ? v : null;
    }

    // Score phonique = min des 3 questions acoustiques (cas le pire).
    int? phonicsScore() {
      final vals = [kQPhonicsFloors, kQPhonicsNeighbors, kQPhonicsStreet]
          .map(intQ)
          .whereType<int>()
          .toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a < b ? a : b);
    }

    double? parseAmount(String? text) {
      if (text == null || text.isEmpty) return null;
      final cleaned =
          text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
      return double.tryParse(cleaned);
    }

    return VisitAnswers(
      // ── v1 : champs de score legacy ──
      luminosite: intQ(kQLuminosityLiving),
      calme: intQ(kQNoiseStreet),
      etatGeneral: intQ(kQGeneralState),
      cuisine: intQ(kQKitchenLayout),
      salleDeBain: intQ(kQBathroomSize),
      rangements: intQ(kQStorageSpace),
      chauffage: intQ(kQHeatingDistribution),
      quartier: intQ(kQNeighborhoodVibe),
      // ── v1 : booléens legacy ──
      doubleVitrage: boolQ(kQDoubleGlazing),
      cave: boolQ(kQCave),
      balconOuTerrasse: boolQ(kQBalconyTerrace),
      ascenseur: boolQ(kQElevatorPresent),
      digicode: boolQ(kQSecureDoor),
      // ── v1 : textes legacy ──
      coupDeCoeur: strQ(kQCoupDeCoeur),
      pointRedhibitoire: strQ(kQPointRedhibitoire),
      // ── v2 : Transports ──
      transportScore: intQ(kQTransportMinutes),
      transportType: _encodeMultiChoice(kQTransportType),
      mobilityService: _encodeMultiChoice(kQMobilityServices),
      // ── v2 : Quartier ──
      noiseScore: intQ(kQNoiseStreet),
      neighborhoodScore: intQ(kQNeighborhoodVibe),
      safetyScore: intQ(kQSafetyFeeling),
      greenScore: intQ(kQGreenSpaces),
      // ── v2 : Immeuble ──
      commonAreasScore: intQ(kQCommonAreas) ?? intQ(kQBuildingCondition),
      elevatorOk: boolQ(kQElevatorOk) ?? boolQ(kQElevatorPresent),
      caveOk: boolQ(kQCave),
      secureDoorOk: boolQ(kQSecureDoor),
      bikeStorage: boolQ(kQBikeStorage),
      parking: boolQ(kQParking),
      buildingConcierge: boolQ(kQBuildingConcierge),
      elevatorSize: _encodeMultiChoice(kQElevatorSize),
      caveAccess: boolQ(kQCaveAccess),
      caveDoor: boolQ(kQCaveDoor),
      caveDry: boolQ(kQCaveDry),
      bikeStorageSecured: boolQ(kQBikeStorageSecured),
      bikeStorageSpace: boolQ(kQBikeStorageSpace),
      trashAccess: intQ(kQTrashAccess),
      disabledAccess: boolQ(kQDisabledAccess),
      // ── v2 : Luminosité ──
      luminosityScore: intQ(kQLuminosityLiving),
      visitTime: _visitTimeString(),
      visAVisScore: intQ(kQVisAVis),
      // ── v2 : Acoustique ──
      phonicsScore: phonicsScore(),
      humidityDetected: boolQ(kQHumidityDetected),
      heatingDistributionScore: intQ(kQHeatingDistribution),
      thermalInsulationScore: intQ(kQThermalInsulation),
      // ── v2 : Équipements ──
      waterPressureOk: boolQ(kQWaterPressure),
      waterQualityScore: intQ(kQWaterQuality),
      electricPanelOk: boolQ(kQElectricPanel),
      earthGroundOk: boolQ(kQEarthGround),
      outletsScore: intQ(kQOutlets),
      mobileSignalOk: boolQ(kQMobileSignal),
      vmcOk: boolQ(kQVmc),
      // ── v2 : Cuisine ──
      kitchenWorktopScore: intQ(kQKitchenWorktop),
      fridgeSpaceOk: boolQ(kQFridgeSpace),
      hoodOk: boolQ(kQKitchenHood),
      washingMachineSpace: boolQ(kQWashingMachineSpace),
      dishwasherSpace: boolQ(kQDishwasherSpace),
      trashSpace: boolQ(kQTrashSpace),
      kitchenOpenClosed: _encodeMultiChoice(kQKitchenOpenClosed),
      vmcKitchen: boolQ(kQVmcKitchen),
      towelRadiatorSdb: boolQ(kQTowelRadiator),
      bathroomFeatures: _encodeMultiChoice(kQBathroomFeatures),
      // ── v2 : Radiateurs & Chauffage ──
      radiatorLiving: boolQ(kQRadiatorLiving),
      radiatorBathroom: boolQ(kQRadiatorBathroom),
      radiatorBedroom: boolQ(kQRadiatorBedroom),
      heatingSystem: strQ(kQHeatingSystem),
      // ── v2 : Admin ──
      departureReason: strQ(kQDepartureReason),
      agencyFees: parseAmount(strQ(kQAgencyFees)),
      guaranteeDeposit: parseAmount(strQ(kQDeposit)),
      landTax: parseAmount(strQ(kQLandTax)),
      chargesAmount: strQ(kQChargesAmount),
      // ── v2 : Rénovation (achat uniquement) ──
      renovation: _isAchat ? _renovation : null,
      // ── v2 : Espaces extérieurs (visite) ──
      outdoorSurface: strQ(kQOutdoorSurface),
      outdoorNeighborExposure: intQ(kQOutdoorNeighborExposure),
      outdoorSunExposure: intQ(kQOutdoorSunExposure),
      outdoorViewQuality: intQ(kQOutdoorViewQuality),
      // ── v2 : Espaces extérieurs (avant) ──
      exteriorSpaces: _exteriorSpaces.isEmpty
          ? null
          : jsonEncode(_exteriorSpaces.map((e) => e.toJson()).toList()),
      // ── v3 : Transport conditionnel ──
      transportStations: strQ(kQTransportStations),
      // ── v3 : Admin ──
      taxeHabitation: strQ(kQTaxeHabitation),
      coproprieteMaison: boolQ(kQCoproprietieMaison),
      // ── v3 : Extérieur structure maison ──
      facadeFissures: boolQ(kQFacadeFissures),
      solAffaissement: boolQ(kQSolAffaissement),
      mursDeformation: boolQ(kQMursDeformation),
      humiditeExterieure: boolQ(kQHumiditeExterieure),
      // ── v3 : Toiture ──
      toitureTuiles: intQ(kQToitureTuiles),
      goutieres: boolQ(kQGoutieres),
      charpente: boolQ(kQCharpente),
      isolationToiture: boolQ(kQIsolationToiture),
      toitureRenovation: boolQ(kQToitureRenovation),
      // ── v3 : Drainage ──
      terrainPente: boolQ(kQTerrainPente),
      eauStagnante: boolQ(kQEauStagnante),
      drains: boolQ(kQDrains),
      tracesInondation: boolQ(kQTracesInondation),
      // ── v3 : Terrain ──
      terrainVoisinsProximite: intQ(kQTerrainVoisinsProximite),
      incidentsVoisins: boolQ(kQIncidentsVoisins),
      arbresProches: boolQ(kQArbresProches),
      orientationTerrain: strQ(kQOrientationTerrain),
      nuisancesTerrain: intQ(kQNuisancesTerrain),
      // ── v3 : Raccordements ──
      raccordementEauElecGaz: boolQ(kQRaccordementEauElecGaz),
      toutALegout: strQ(kQToutALegout),
      fibreMaison: boolQ(kQFibreMaison),
      branchementsEtat: intQ(kQBranchementsEtat),
      // ── v3 : Façade ext ──
      crepiEtat: intQ(kQCrepiEtat),
      facadeHumidite: boolQ(kQFacadeHumidite),
      ite: boolQ(kQIte),
      // ── v3 : Accès ──
      accesRoute: intQ(kQAccesRoute),
      stationnementMaison: boolQ(kQStationnementMaison),
      servitudes: boolQ(kQServitudes),
      // ── v3 : Urbanisme ──
      projetsConstruction: boolQ(kQProjetsConstruction),
      plu: boolQ(kQPlu),
      terrainsConstructibles: boolQ(kQTerrainsConstructibles),
      // ── v3 : Risques ──
      erpConsulte: boolQ(kQErpConsulte),
      risqueInondation: boolQ(kQRisqueInondation),
      risqueGlissement: boolQ(kQRisqueGlissement),
      pollutionSols: boolQ(kQPollutionSols),
      nuisancesEnvironnement: boolQ(kQNuisancesEnvironnement),
      // ── v3 : Diagnostics ──
      ravelementDate: strQ(kQRavelementDate),
      travauxVotes: boolQ(kQTravauxVotes),
      proceduresCopro: boolQ(kQProceduresCopro),
      evacuationsCommunes: boolQ(kQEvacuationsCommunes),
      fibreImmeuble: boolQ(kQFibreImmeuble),
      dpeNiveau: strQ(kQDpeNiveau),
      elecAge: boolQ(kQElecAge),
      diagElec: strQ(kQDiagElec),
      gazAge: boolQ(kQGazAge),
      diagGaz: strQ(kQDiagGaz),
      dateConstruction: strQ(kQDateConstruction),
      diagAmiante: strQ(kQDiagAmiante),
      diagPlomb: strQ(kQDiagPlomb),
    );
  }

  // ── Action : terminer la visite ────────────────────────────────────────────

  Future<void> _finishVisit() async {
    setState(() => _isSaving = true);
    try {
      final answers = _buildVisitAnswers();
      final visit = Visit(
        listingId: widget.listing.id,
        owner: widget.profile.owner,
        answers: answers,
        feeling: _feeling,
        visitedAt: widget.visitedAt ?? widget.existingVisit?.visitedAt,
      );

      final score = ScoreService.calculateFinalScore(
        visit,
        widget.listing.facts,
        widget.profile,
        widget.listing,
      );
      final visitWithScore = visit.copyWith(score: score);

      if (!mounted) return;

      if (widget.existingVisit != null) {
        final projectId = await ProjectService.getActiveId() ?? '';
        await VisitStorageService.add(visitWithScore, projectId: projectId);
        if (mounted) Navigator.pop(context);
      } else {
        final blockers = ScoreService.detectBlockers(visitWithScore, widget.profile);
        await Navigator.pushReplacementNamed(
          context,
          AppRoutes.visitSummary,
          arguments: {
            'visit': visitWithScore,
            'listing': widget.listing,
            'blockers': blockers,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build principal ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final titleText = widget.listing.title.length > 28
        ? '${widget.listing.title.substring(0, 26)}…'
        : widget.listing.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [
              Tab(
                text:
                    'Avant  ${_answeredIn(_questionsAvant)}/${_questionsAvant.length}',
              ),
              Tab(
                text:
                    'Visite  ${_answeredIn(_questionsPendant)}/${_questionsPendant.length}',
              ),
              const Tab(text: 'Après'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionsTab(_questionsAvant, tabKey: 'avant'),
          _buildQuestionsTab(_questionsPendant, tabKey: 'visite'),
          _buildApresTab(),
        ],
      ),
    );
  }

  // ── Onglet questions (Avant / Pendant) ─────────────────────────────────────

  Widget _buildQuestionsTab(
    List<QuestionTemplate> questions, {
    required String tabKey,
  }) {
    if (questions.isEmpty) {
      return const Center(
        child: Text(
          'Aucune question pour cette phase.',
          style: TextStyle(color: DoutangTheme.textSecondary),
        ),
      );
    }

    final grouped = _groupBySection(questions);
    return ListView(
      padding: const EdgeInsets.only(top: DSpacing.xs, bottom: DSpacing.xxl),
      children: [
        for (final entry in grouped.entries) ...[
          ExpansionTile(
            key: ValueKey('${tabKey}_${entry.key}'),
            initiallyExpanded: false,
            leading: Icon(
              _sectionIcons[entry.key] ?? Icons.help_outline,
              size: 18,
              color: DoutangTheme.primary,
            ),
            title: Text(
              (_sectionLabels[entry.key] ?? entry.key).toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DoutangTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            trailing: _AnsweredBadge(
              answered: _answeredIn(entry.value),
              total: entry.value.length,
            ),
            children: [
              for (final q in entry.value) ...[
                QuestionCard(
                  key: ValueKey(q.id),
                  question: q,
                  value: _answers[q.id],
                  onChanged: (v) => _setAnswer(q.id, v),
                ),
                // Champ conditionnel : stations de transport si un mode TC sélectionné
                if (q.id == kQTransportType) _buildTransportStationsCard(),
              ],
              const SizedBox(height: DSpacing.sm),
            ],
          ),
        ],
        if (tabKey == 'avant')
          ExpansionTile(
            key: const ValueKey('avant_exterior'),
            initiallyExpanded: false,
            leading: const Icon(
              Icons.yard_outlined,
              size: 18,
              color: DoutangTheme.primary,
            ),
            title: const Text(
              'ESPACES EXTÉRIEURS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DoutangTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            trailing: _AnsweredBadge(
              answered: _exteriorSpaces.isNotEmpty ? 1 : 0,
              total: 1,
            ),
            children: [
              ExteriorSpacesCard(
                key: const ValueKey('exterior_spaces_card'),
                value: _exteriorSpaces,
                onChanged: (spaces) =>
                    setState(() => _exteriorSpaces = spaces),
              ),
              const SizedBox(height: DSpacing.sm),
            ],
          ),
      ],
    );
  }

  // ── Onglet Après ──────────────────────────────────────────────────────────

  Widget _buildApresTab() {
    final grouped = _groupBySection(_questionsApres);
    return ListView(
      padding: const EdgeInsets.only(top: DSpacing.xs, bottom: DSpacing.xxl),
      children: [
        // Questions "après" groupées par section
        for (final entry in grouped.entries)
          ExpansionTile(
            key: ValueKey('apres_${entry.key}'),
            initiallyExpanded: false,
            leading: Icon(
              _sectionIcons[entry.key] ?? Icons.help_outline,
              size: 18,
              color: DoutangTheme.primary,
            ),
            title: Text(
              (_sectionLabels[entry.key] ?? entry.key).toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DoutangTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            trailing: _AnsweredBadge(
              answered: _answeredIn(entry.value),
              total: entry.value.length,
            ),
            children: [
              for (final q in entry.value)
                QuestionCard(
                  key: ValueKey(q.id),
                  question: q,
                  value: _answers[q.id],
                  onChanged: (v) => _setAnswer(q.id, v),
                ),
              const SizedBox(height: DSpacing.sm),
            ],
          ),

        // Ressenti global
        const SizedBox(height: DSpacing.lg),
        _buildFeelingPicker(),

        // Rénovation (achat uniquement)
        if (_isAchat) ...[
          const SizedBox(height: DSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSpacing.md),
            child: Text(
              'Évaluation des travaux',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DoutangTheme.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: DSpacing.sm),
          RenovationCard(
            answers: _renovation,
            onChanged: (r) => setState(() => _renovation = r),
          ),
        ],

        // Bouton de validation
        const SizedBox(height: DSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSpacing.md),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _finishVisit,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Terminer la visite'),
          ),
        ),
        const SizedBox(height: DSpacing.md),
      ],
    );
  }

  // ── Picker de ressenti ────────────────────────────────────────────────────

  static const _feelings = <(int, String, String)>[
    (1, '😟', 'Pas du tout'),
    (2, '😕', 'Peu enthousiaste'),
    (3, '😐', 'Mitigé'),
    (4, '😊', 'Enthousiaste'),
    (5, '😍', 'Coup de cœur !'),
  ];

  Widget _buildFeelingPicker() {
    final label =
        _feelings.firstWhere((f) => f.$1 == _feeling, orElse: () => _feelings[2]).$3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSpacing.md),
      padding: const EdgeInsets.all(DSpacing.md),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ressenti global',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: DSpacing.sm),
              Text(
                '— $label',
                style: const TextStyle(
                  fontSize: 13,
                  color: DoutangTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _feelings.map((f) {
              final isSelected = _feeling == f.$1;
              return GestureDetector(
                onTap: () => setState(() => _feeling = f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DoutangTheme.primarySurface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? DoutangTheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: TextStyle(fontSize: isSelected ? 36 : 28),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Widget interne : badge réponses ───────────────────────────────────────

class _AnsweredBadge extends StatelessWidget {
  final int answered;
  final int total;

  const _AnsweredBadge({required this.answered, required this.total});

  @override
  Widget build(BuildContext context) {
    final complete = answered == total;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: complete ? DoutangTheme.primarySurface : DoutangTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: complete ? DoutangTheme.primary : DoutangTheme.border,
        ),
      ),
      child: Text(
        '$answered/$total',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: complete ? DoutangTheme.primary : DoutangTheme.textSecondary,
        ),
      ),
    );
  }
}

