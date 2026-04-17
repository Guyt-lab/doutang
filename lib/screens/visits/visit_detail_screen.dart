import 'package:flutter/material.dart';

import '../../data/default_questions.dart';
import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/renovation_answers.dart';
import '../../models/visit.dart';
import '../../services/profile_storage_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';

class VisitDetailScreen extends StatelessWidget {
  final Visit visit;
  final Listing listing;

  const VisitDetailScreen({
    super.key,
    required this.visit,
    required this.listing,
  });

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

  static const _feelingMap = <int, (String, String)>{
    1: ('😟', 'Pas du tout emballé'),
    2: ('😕', 'Peu enthousiaste'),
    3: ('😐', 'Mitigé'),
    4: ('😊', 'Enthousiaste'),
    5: ('😍', 'Coup de cœur !'),
  };

  Color _scoreColor(double s) {
    if (s >= 80) return DoutangTheme.scoreExcellent;
    if (s >= 60) return DoutangTheme.scoreGood;
    if (s >= 40) return DoutangTheme.scoreMid;
    if (s >= 20) return DoutangTheme.scoreLow;
    return DoutangTheme.scorePoor;
  }

  String _scoreLabel(double s) {
    if (s >= 80) return 'Excellent';
    if (s >= 60) return 'Très bien';
    if (s >= 40) return 'Bien';
    if (s >= 20) return 'Moyen';
    return 'Insuffisant';
  }

  String _formatDateFull(DateTime dt) {
    const months = [
      '',
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  /// Construit une map questionId → valeur de réponse pour l'affichage.
  Map<String, dynamic> _buildAnswerMap() {
    final a = visit.answers;
    final m = <String, dynamic>{};

    void put(String key, dynamic val) {
      if (val != null) m[key] = val;
    }

    void putStr(String key, String? val) {
      if (val != null && val.isNotEmpty) m[key] = val;
    }

    // s1 — Transports & Quartier
    put(kQTransportMinutes, a.transportScore);
    putStr(kQTransportType, a.transportType);
    putStr(kQMobilityServices, a.mobilityService);
    put(kQNoiseStreet, a.noiseScore ?? a.calme);
    put(kQNeighborhoodVibe, a.neighborhoodScore ?? a.quartier);
    put(kQSafetyFeeling, a.safetyScore);
    put(kQGreenSpaces, a.greenScore);
    // s2 — Immeuble
    put(kQBuildingCondition, a.commonAreasScore);
    put(kQElevatorPresent, a.elevatorOk ?? a.ascenseur);
    put(kQCave, a.caveOk ?? a.cave);
    put(kQBikeStorage, a.bikeStorage);
    put(kQSecureDoor, a.secureDoorOk ?? a.digicode);
    // s3 — Luminosité
    put(kQLuminosityLiving, a.luminosityScore ?? a.luminosite);
    putStr(kQVisitTime, a.visitTime);
    put(kQVisAVis, a.visAVisScore);
    put(kQDoubleGlazing, a.doubleVitrage);
    // s4 — Acoustique
    put(kQPhonicsFloors, a.phonicsScore);
    put(kQHumidityDetected, a.humidityDetected);
    put(kQHeatingDistribution, a.heatingDistributionScore ?? a.chauffage);
    put(kQThermalInsulation, a.thermalInsulationScore);
    // s5 — Équipements
    put(kQGeneralState, a.etatGeneral);
    put(kQElectricPanel, a.electricPanelOk);
    put(kQEarthGround, a.earthGroundOk);
    put(kQOutlets, a.outletsScore);
    put(kQWaterPressure, a.waterPressureOk);
    put(kQWaterQuality, a.waterQualityScore);
    put(kQMobileSignal, a.mobileSignalOk);
    put(kQVmc, a.vmcOk);
    // s6 — Cuisine & SDB
    put(kQKitchenLayout, a.cuisine);
    put(kQKitchenWorktop, a.kitchenWorktopScore);
    put(kQKitchenHood, a.hoodOk);
    put(kQWashingMachineSpace, a.washingMachineSpace);
    put(kQFridgeSpace, a.fridgeSpaceOk);
    put(kQBathroomSize, a.salleDeBain);
    put(kQTowelRadiator, a.towelRadiatorSdb);
    // s7 — Chambres
    put(kQStorageSpace, a.rangements);
    put(kQBalconyTerrace, a.balconOuTerrasse);
    // s8 — Admin / Bilan
    putStr(kQDepartureReason, a.departureReason);
    putStr(kQCoupDeCoeur, a.coupDeCoeur);
    putStr(kQPointRedhibitoire, a.pointRedhibitoire);

    return m;
  }

  /// Regroupe les réponses par section, ordonnées comme kDefaultQuestions.
  Map<String, List<({String text, dynamic value})>> _buildSectionedAnswers() {
    final answerMap = _buildAnswerMap();
    final result = <String, List<({String text, dynamic value})>>{};
    for (final q in kDefaultQuestions) {
      final val = answerMap[q.id];
      if (val != null) {
        result.putIfAbsent(q.section, () => []).add((text: q.text, value: val));
      }
    }
    return result;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sectionedAnswers = _buildSectionedAnswers();
    final color = _scoreColor(visit.score);
    final renovation = visit.answers.renovation;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _formatDateFull(visit.visitedAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: DoutangTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSpacing.md,
          DSpacing.md,
          DSpacing.md,
          DSpacing.xxl,
        ),
        children: [
          // ── Section 1 : Résumé ──────────────────────────────────────────
          _buildSummaryCard(context, color),

          const SizedBox(height: DSpacing.md),

          // ── Section 2 : Réponses par section ───────────────────────────
          if (sectionedAnswers.isNotEmpty) ...[
            _SectionTitle(
              icon: Icons.quiz_outlined,
              label: 'Réponses au questionnaire',
            ),
            const SizedBox(height: DSpacing.sm),
            ...sectionedAnswers.entries.map(
              (entry) => _SectionAnswerTile(
                label: _sectionLabels[entry.key] ?? entry.key,
                icon: _sectionIcons[entry.key] ?? Icons.help_outline,
                answers: entry.value,
              ),
            ),
          ],

          // ── Section 3 : Rénovation ─────────────────────────────────────
          if (renovation != null) ...[
            const SizedBox(height: DSpacing.md),
            _SectionTitle(
              icon: Icons.construction_outlined,
              label: 'Évaluation des travaux',
            ),
            const SizedBox(height: DSpacing.sm),
            _RenovationCard(renovation: renovation),
          ],

          // ── Section 4 : Actions ────────────────────────────────────────
          const SizedBox(height: DSpacing.lg),
          _buildActions(context),
        ],
      ),
    );
  }

  // ── Section 1 : Résumé ─────────────────────────────────────────────────────

  Widget _buildSummaryCard(BuildContext context, Color color) {
    final (emoji, feelingLabel) =
        _feelingMap[visit.feeling] ?? _feelingMap[3]!;

    return Container(
      padding: const EdgeInsets.all(DSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: DRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${visit.score.round()}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 18,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _scoreLabel(visit.score),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: DSpacing.md),
          // Feeling
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSpacing.md,
              vertical: DSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DoutangTheme.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DoutangTheme.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: DSpacing.sm),
                Text(
                  feelingLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DoutangTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Coup de cœur
          if (visit.answers.coupDeCoeur?.isNotEmpty == true) ...[
            const SizedBox(height: DSpacing.sm),
            _NoteRow(
              icon: Icons.favorite_outline,
              color: DoutangTheme.primary,
              label: 'Coup de cœur',
              text: visit.answers.coupDeCoeur!,
            ),
          ],
          // Point rédhibitoire
          if (visit.answers.pointRedhibitoire?.isNotEmpty == true) ...[
            const SizedBox(height: DSpacing.sm),
            _NoteRow(
              icon: Icons.warning_amber_outlined,
              color: DoutangTheme.danger,
              label: 'Point rédhibitoire',
              text: visit.answers.pointRedhibitoire!,
            ),
          ],
        ],
      ),
    );
  }

  // ── Section 4 : Actions ────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _onModify(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier la visite'),
          ),
        ),
        const SizedBox(height: DSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _onDelete(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: DoutangTheme.danger,
              side: const BorderSide(color: DoutangTheme.danger),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer la visite'),
          ),
        ),
      ],
    );
  }

  Future<void> _onModify(BuildContext context) async {
    final profile = await ProfileStorageService.load();
    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.visitQuestionnaire,
      arguments: {
        'listing': listing,
        'profile': profile ?? UserProfile(owner: 'Moi'),
        'existingVisit': visit,
      },
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la visite ?'),
        content:
            const Text('Cette action est irréversible. La visite sera perdue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: DoutangTheme.danger,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await VisitStorageService.delete(visit.id);
    if (context.mounted) {
      Navigator.popUntil(context, ModalRoute.withName(AppRoutes.visits));
    }
  }
}

// ── Widgets privés ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: DoutangTheme.primary),
        const SizedBox(width: DSpacing.sm),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: DoutangTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;

  const _NoteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: DoutangTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionAnswerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<({String text, dynamic value})> answers;

  const _SectionAnswerTile({
    required this.label,
    required this.icon,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DSpacing.xs),
      child: ExpansionTile(
        leading: Icon(icon, size: 18, color: DoutangTheme.primary),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DoutangTheme.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DoutangTheme.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${answers.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DoutangTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: DSpacing.xs),
            const Icon(Icons.expand_more, color: DoutangTheme.textHint),
          ],
        ),
        children: answers
            .map(
              (a) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSpacing.md,
                  0,
                  DSpacing.md,
                  DSpacing.sm,
                ),
                child: _AnswerRow(text: a.text, value: a.value),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String text;
  final dynamic value;

  const _AnswerRow({required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: DoutangTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: DSpacing.sm),
        _buildValueWidget(),
      ],
    );
  }

  Widget _buildValueWidget() {
    if (value is int) {
      return _StarRow(score: value as int);
    }
    if (value is bool) {
      final yes = value as bool;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: yes
              ? DoutangTheme.primary.withValues(alpha: 0.1)
              : DoutangTheme.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          yes ? 'Oui' : 'Non',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: yes ? DoutangTheme.primary : DoutangTheme.danger,
          ),
        ),
      );
    }
    // String
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 13,
          color: DoutangTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int score;
  const _StarRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < score;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: filled ? DoutangTheme.accent : DoutangTheme.textHint,
        );
      }),
    );
  }
}

class _RenovationCard extends StatelessWidget {
  final RenovationAnswers renovation;

  const _RenovationCard({required this.renovation});

  static const _postes = <(String, RenovationLevel? Function(RenovationAnswers))>[
    ('Sols', _floors),
    ('Murs & peintures', _walls),
    ('Salle de bain', _bathroom),
    ('Cuisine', _kitchen),
    ('Électricité', _electric),
    ('Plomberie', _plumbing),
    ('Fenêtres', _windows),
    ('Chauffage', _heating),
  ];

  static RenovationLevel? _floors(RenovationAnswers r) => r.floors;
  static RenovationLevel? _walls(RenovationAnswers r) => r.walls;
  static RenovationLevel? _bathroom(RenovationAnswers r) => r.bathroom;
  static RenovationLevel? _kitchen(RenovationAnswers r) => r.kitchen;
  static RenovationLevel? _electric(RenovationAnswers r) => r.electric;
  static RenovationLevel? _plumbing(RenovationAnswers r) => r.plumbing;
  static RenovationLevel? _windows(RenovationAnswers r) => r.windows;
  static RenovationLevel? _heating(RenovationAnswers r) => r.heating;

  static String _levelLabel(RenovationLevel l) => switch (l) {
        RenovationLevel.none => 'Aucun',
        RenovationLevel.cosmetic => 'Cosmétique',
        RenovationLevel.important => 'Important',
        RenovationLevel.structural => 'Structurel',
      };

  static Color _levelColor(RenovationLevel l) => switch (l) {
        RenovationLevel.none => DoutangTheme.textHint,
        RenovationLevel.cosmetic => DoutangTheme.accent,
        RenovationLevel.important => DoutangTheme.scoreLow,
        RenovationLevel.structural => DoutangTheme.danger,
      };

  static String _budgetLabel(BudgetRange b) => switch (b) {
        BudgetRange.none => 'Aucun travaux',
        BudgetRange.under5k => '< 5 000 €',
        BudgetRange.between5and20k => '5 000 – 20 000 €',
        BudgetRange.above20k => '> 20 000 €',
      };

  @override
  Widget build(BuildContext context) {
    final budget = renovation.computedBudgetRange;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._postes.map((poste) {
              final (label, getter) = poste;
              final level = getter(renovation);
              if (level == null) return const SizedBox.shrink();
              final color = _levelColor(level);
              return Padding(
                padding: const EdgeInsets.only(bottom: DSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: DoutangTheme.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _levelLabel(level),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (budget != BudgetRange.none) ...[
              const Divider(height: DSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.euro_outlined,
                    size: 14,
                    color: DoutangTheme.textSecondary,
                  ),
                  const SizedBox(width: DSpacing.xs),
                  const Text(
                    'Budget estimé',
                    style: TextStyle(
                      fontSize: 13,
                      color: DoutangTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _budgetLabel(budget),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DoutangTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
            if (renovation.notes?.isNotEmpty == true) ...[
              const SizedBox(height: DSpacing.sm),
              Text(
                renovation.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: DoutangTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
