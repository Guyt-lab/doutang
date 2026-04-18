import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/renovation_answers.dart';
import '../theme/doutang_theme.dart';

/// Carte de saisie des travaux de rénovation par poste (projet achat uniquement).
///
/// Affiche 8 postes de rénovation. Chaque poste propose 4 niveaux :
/// Aucun / Cosmétique / Important / Structurel.
///
/// La fourchette budgétaire estimée est recalculée automatiquement via
/// [RenovationAnswers.computedBudgetRange] et affichée dans l'en-tête.
class RenovationCard extends StatefulWidget {
  final RenovationAnswers answers;
  final ValueChanged<RenovationAnswers> onChanged;

  const RenovationCard({
    super.key,
    required this.answers,
    required this.onChanged,
  });

  @override
  State<RenovationCard> createState() => _RenovationCardState();
}

class _RenovationCardState extends State<RenovationCard> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.answers.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Metadata ───────────────────────────────────────────────────────────────

  static const _rows = <(String, String)>[
    ('floors', 'Sols'),
    ('walls', 'Murs & plafonds'),
    ('bathroom', 'Salle de bain'),
    ('kitchen', 'Cuisine'),
    ('electric', 'Électricité'),
    ('plumbing', 'Plomberie'),
    ('windows', 'Fenêtres'),
    ('heating', 'Chauffage'),
  ];

  static const _levels = <(RenovationLevel, String, Color)>[
    (RenovationLevel.none, 'Aucun', DoutangTheme.primary),
    (RenovationLevel.cosmetic, 'Cosm.', Color(0xFF90BE6D)),
    (RenovationLevel.important, 'Imp.', DoutangTheme.accent),
    (RenovationLevel.structural, 'Struct.', DoutangTheme.danger),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────

  RenovationLevel? _getValue(String field) => switch (field) {
        'floors' => widget.answers.floors,
        'walls' => widget.answers.walls,
        'bathroom' => widget.answers.bathroom,
        'kitchen' => widget.answers.kitchen,
        'electric' => widget.answers.electric,
        'plumbing' => widget.answers.plumbing,
        'windows' => widget.answers.windows,
        'heating' => widget.answers.heating,
        _ => null,
      };

  RenovationAnswers _copyWith(String field, RenovationLevel? level) =>
      RenovationAnswers(
        floors: field == 'floors' ? level : widget.answers.floors,
        walls: field == 'walls' ? level : widget.answers.walls,
        bathroom: field == 'bathroom' ? level : widget.answers.bathroom,
        kitchen: field == 'kitchen' ? level : widget.answers.kitchen,
        electric: field == 'electric' ? level : widget.answers.electric,
        plumbing: field == 'plumbing' ? level : widget.answers.plumbing,
        windows: field == 'windows' ? level : widget.answers.windows,
        heating: field == 'heating' ? level : widget.answers.heating,
        notes: widget.answers.notes,
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final budget = widget.answers.computedBudgetRange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSpacing.md),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSpacing.md,
              DSpacing.md,
              DSpacing.md,
              DSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.construction_outlined,
                  color: DoutangTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: DSpacing.sm),
                Expanded(
                  child: Text(
                    'Évaluation des travaux',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (budget != BudgetRange.none) _BudgetBadge(budget: budget),
              ],
            ),
          ),

          // ── Légende niveaux ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSpacing.md,
              0,
              DSpacing.md,
              DSpacing.sm,
            ),
            child: Row(
              children: _levels.map((l) {
                return Padding(
                  padding: const EdgeInsets.only(right: DSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: l.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.$2,
                        style: const TextStyle(
                          fontSize: 11,
                          color: DoutangTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 0, color: DoutangTheme.border),

          // ── Lignes par poste ──
          ..._rows.map((row) => _buildRow(row.$1, row.$2)),

          const Divider(height: 0, color: DoutangTheme.border),

          // ── Notes libres ──
          Padding(
            padding: const EdgeInsets.all(DSpacing.md),
            child: TextField(
              controller: _notesController,
              maxLines: 2,
              onChanged: (v) => widget.onChanged(
                RenovationAnswers(
                  floors: widget.answers.floors,
                  walls: widget.answers.walls,
                  bathroom: widget.answers.bathroom,
                  kitchen: widget.answers.kitchen,
                  electric: widget.answers.electric,
                  plumbing: widget.answers.plumbing,
                  windows: widget.answers.windows,
                  heating: widget.answers.heating,
                  notes: v.trim().isEmpty ? null : v,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: DoutangTheme.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Notes sur les travaux (optionnel)…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: DoutangTheme.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String field, String label) {
    final current = _getValue(field);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: DoutangTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: _levels.map((l) {
                final isSelected = current == l.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onChanged(_copyWith(field, l.$1)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? l.$3.withValues(alpha: 0.12)
                            : DoutangTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? l.$3 : DoutangTheme.border,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l.$2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            color:
                                isSelected ? l.$3 : DoutangTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge budget estimé ────────────────────────────────────────────────────

class _BudgetBadge extends StatelessWidget {
  final BudgetRange budget;
  const _BudgetBadge({required this.budget});

  String get _label => switch (budget) {
        BudgetRange.none => 'Aucun',
        BudgetRange.under5k => '< 5 k€',
        BudgetRange.between5and20k => '5–20 k€',
        BudgetRange.above20k => '> 20 k€',
      };

  Color get _color => switch (budget) {
        BudgetRange.none => DoutangTheme.primary,
        BudgetRange.under5k => const Color(0xFF90BE6D),
        BudgetRange.between5and20k => DoutangTheme.accent,
        BudgetRange.above20k => DoutangTheme.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
