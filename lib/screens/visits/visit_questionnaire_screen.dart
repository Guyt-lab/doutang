import 'package:flutter/material.dart';

import '../../data/default_questions.dart';
import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/question_template.dart';
import '../../models/renovation_answers.dart';
import '../../models/visit.dart';
import '../../services/score_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
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

  const VisitQuestionnaireScreen({
    super.key,
    required this.listing,
    required this.profile,
    this.existingVisit,
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
    final enabledIds =
        widget.profile.questionnaireConfig.enabledQuestionIds;

    bool applies(QuestionTemplate q) {
      if (q.appliesTo.isNotEmpty) {
        final needed =
            _isAchat ? ProjectFilter.achat : ProjectFilter.location;
        if (!q.appliesTo.contains(needed)) return false;
      }
      if (enabledIds.isNotEmpty && !enabledIds.contains(q.id)) return false;
      return true;
    }

    final active = kDefaultQuestions.where(applies).toList();

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
    putStr(kQTransportType, a.transportType);
    putStr(kQMobilityServices, a.mobilityService);
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
    put(kQBathroomSize, a.salleDeBain);
    put(kQTowelRadiator, a.towelRadiatorSdb);
    // s7
    put(kQStorageSpace, a.rangements);
    put(kQBalconyTerrace, a.balconOuTerrasse);
    // s8
    putStr(kQDepartureReason, a.departureReason);
    putStr(kQCoupDeCoeur, a.coupDeCoeur);
    putStr(kQPointRedhibitoire, a.pointRedhibitoire);

    _feeling = v.feeling;
    if (a.renovation != null) _renovation = a.renovation!;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static const _sectionLabels = <String, String>{
    's1': 'Transports & Quartier',
    's2': 'Immeuble & Parties communes',
    's3': 'Luminosité & Vue',
    's4': 'Acoustique & Isolation',
    's5': 'État général & Équipements',
    's6': 'Cuisine & Salle de bain',
    's7': 'Chambres & Espaces de vie',
    's8': 'Aspects pratiques',
  };

  static const _sectionIcons = <String, IconData>{
    's1': Icons.directions_transit_outlined,
    's2': Icons.apartment_outlined,
    's3': Icons.wb_sunny_outlined,
    's4': Icons.hearing_outlined,
    's5': Icons.build_outlined,
    's6': Icons.kitchen_outlined,
    's7': Icons.bed_outlined,
    's8': Icons.receipt_long_outlined,
  };

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
      questions.where((q) => _answers[q.id] != null).length;

  void _setAnswer(String id, dynamic value) =>
      setState(() => _answers[id] = value);

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
      transportType: strQ(kQTransportType),
      mobilityService: strQ(kQMobilityServices),
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
      // ── v2 : Luminosité ──
      luminosityScore: intQ(kQLuminosityLiving),
      visitTime: strQ(kQVisitTime),
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
      towelRadiatorSdb: boolQ(kQTowelRadiator),
      // ── v2 : Admin ──
      departureReason: strQ(kQDepartureReason),
      agencyFees: parseAmount(strQ(kQAgencyFees)),
      guaranteeDeposit: parseAmount(strQ(kQDeposit)),
      landTax: parseAmount(strQ(kQLandTax)),
      // ── v2 : Rénovation (achat uniquement) ──
      renovation: _isAchat ? _renovation : null,
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
        visitedAt: widget.existingVisit?.visitedAt,
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
        await VisitStorageService.add(visitWithScore);
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
                    'Pendant  ${_answeredIn(_questionsPendant)}/${_questionsPendant.length}',
              ),
              const Tab(text: 'Après'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionsTab(_questionsAvant),
          _buildQuestionsTab(_questionsPendant),
          _buildApresTab(),
        ],
      ),
    );
  }

  // ── Onglet questions (Avant / Pendant) ─────────────────────────────────────

  Widget _buildQuestionsTab(List<QuestionTemplate> questions) {
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
      padding: const EdgeInsets.only(
        top: DSpacing.sm,
        bottom: DSpacing.xxl,
      ),
      children: [
        for (final entry in grouped.entries) ...[
          _SectionHeader(
            section: entry.key,
            label: _sectionLabels[entry.key] ?? entry.key,
            icon: _sectionIcons[entry.key] ?? Icons.help_outline,
            answered: _answeredIn(entry.value),
            total: entry.value.length,
          ),
          for (final q in entry.value)
            QuestionCard(
              key: ValueKey(q.id),
              question: q,
              value: _answers[q.id],
              onChanged: (v) => _setAnswer(q.id, v),
            ),
          const SizedBox(height: DSpacing.sm),
        ],
      ],
    );
  }

  // ── Onglet Après ──────────────────────────────────────────────────────────

  Widget _buildApresTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: DSpacing.xxl),
      children: [
        // Questions "après" (coup de cœur, point rédhibitoire)
        if (_questionsApres.isNotEmpty) ...[
          _SectionHeader(
            section: 's8',
            label: 'Bilan & impressions',
            icon: Icons.rate_review_outlined,
            answered: _answeredIn(_questionsApres),
            total: _questionsApres.length,
          ),
          for (final q in _questionsApres)
            QuestionCard(
              key: ValueKey(q.id),
              question: q,
              value: _answers[q.id],
              onChanged: (v) => _setAnswer(q.id, v),
            ),
        ],

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

// ── Widget interne : en-tête de section ────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String section;
  final String label;
  final IconData icon;
  final int answered;
  final int total;

  const _SectionHeader({
    required this.section,
    required this.label,
    required this.icon,
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final complete = answered == total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSpacing.md,
        DSpacing.md,
        DSpacing.md,
        DSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: DoutangTheme.primary),
          const SizedBox(width: DSpacing.sm),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DoutangTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: complete
                  ? DoutangTheme.primarySurface
                  : DoutangTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: complete
                    ? DoutangTheme.primary
                    : DoutangTheme.border,
              ),
            ),
            child: Text(
              '$answered/$total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: complete
                    ? DoutangTheme.primary
                    : DoutangTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
