import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/visit.dart';
import '../../services/score_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';

/// Écran de bilan de visite.
///
/// Reçoit via [settings.arguments] un `Map<String, dynamic>` avec :
/// - `'visit'`    : [Visit] avec score calculé.
/// - `'listing'`  : [Listing] associé.
/// - `'blockers'` : `List<Blocker>` détectés par [ScoreService.detectBlockers].
///
/// Le bouton "Enregistrer" persiste la visite via [VisitStorageService.add]
/// puis retourne à l'écran des annonces.
class VisitSummaryScreen extends StatefulWidget {
  final Visit visit;
  final Listing listing;
  final List<Blocker> blockers;

  const VisitSummaryScreen({
    super.key,
    required this.visit,
    required this.listing,
    required this.blockers,
  });

  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  bool _isSaving = false;

  Future<void> _saveAndReturn() async {
    setState(() => _isSaving = true);
    try {
      await VisitStorageService.add(widget.visit);
      if (!mounted) return;
      Navigator.popUntil(
        context,
        ModalRoute.withName(AppRoutes.listings),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    final strengths = ScoreService.strengths(visit);
    final weaknesses = ScoreService.weaknesses(visit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan de visite'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSpacing.md,
          DSpacing.md,
          DSpacing.md,
          DSpacing.xxl,
        ),
        children: [
          // ── Score ──
          _ScoreCard(listing: widget.listing, score: visit.score),

          const SizedBox(height: DSpacing.md),

          // ── Ressenti ──
          _FeelingCard(feeling: visit.feeling),

          // ── Bloqueurs ──
          if (widget.blockers.isNotEmpty) ...[
            const SizedBox(height: DSpacing.md),
            ...widget.blockers.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: DSpacing.sm),
                  child: _BlockerCard(blocker: b),
                )),
          ],

          // ── Points forts / faibles ──
          if (strengths.isNotEmpty || weaknesses.isNotEmpty) ...[
            const SizedBox(height: DSpacing.md),
            _StrengthsCard(strengths: strengths, weaknesses: weaknesses),
          ],

          // ── Coup de cœur ──
          if (visit.answers.coupDeCoeur?.isNotEmpty == true) ...[
            const SizedBox(height: DSpacing.md),
            _NoteCard(
              icon: Icons.favorite_outline,
              color: DoutangTheme.primary,
              label: 'Coup de cœur',
              text: visit.answers.coupDeCoeur!,
            ),
          ],

          // ── Point rédhibitoire ──
          if (visit.answers.pointRedhibitoire?.isNotEmpty == true) ...[
            const SizedBox(height: DSpacing.md),
            _NoteCard(
              icon: Icons.warning_amber_outlined,
              color: DoutangTheme.danger,
              label: 'Point rédhibitoire',
              text: visit.answers.pointRedhibitoire!,
            ),
          ],

          // ── Bouton enregistrer ──
          const SizedBox(height: DSpacing.xl),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveAndReturn,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enregistrer & Retour aux annonces'),
          ),
        ],
      ),
    );
  }
}

// ── Score card ─────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final Listing listing;
  final double score;

  const _ScoreCard({required this.listing, required this.score});

  Color get _color {
    if (score >= 80) return DoutangTheme.scoreExcellent;
    if (score >= 60) return DoutangTheme.scoreGood;
    if (score >= 40) return DoutangTheme.scoreMid;
    if (score >= 20) return DoutangTheme.scoreLow;
    return DoutangTheme.scorePoor;
  }

  String get _label {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Très bien';
    if (score >= 40) return 'Bien';
    if (score >= 20) return 'Moyen';
    return 'Insuffisant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSpacing.lg),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: DRadius.card,
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            listing.title,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.round()}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: _color,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: _color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSpacing.xs),
          Text(
            _label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ressenti card ─────────────────────────────────────────────────────────

class _FeelingCard extends StatelessWidget {
  final int feeling;
  const _FeelingCard({required this.feeling});

  static const _map = <int, (String, String)>{
    1: ('😟', 'Pas du tout emballé'),
    2: ('😕', 'Peu enthousiaste'),
    3: ('😐', 'Mitigé'),
    4: ('😊', 'Enthousiaste'),
    5: ('😍', 'Coup de cœur !'),
  };

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = _map[feeling] ?? _map[3]!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSpacing.md,
        vertical: DSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: DSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ressenti global',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: DoutangTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bloqueur card ─────────────────────────────────────────────────────────

class _BlockerCard extends StatelessWidget {
  final Blocker blocker;
  const _BlockerCard({required this.blocker});

  static const _labels = <BlockerType, String>{
    BlockerType.transport: 'Trajet trop long',
    BlockerType.humidity: 'Humidité détectée',
    BlockerType.phonics: 'Isolation acoustique insuffisante',
    BlockerType.budget: 'Budget dépassé',
    BlockerType.surface: 'Surface insuffisante',
    BlockerType.rooms: 'Nombre de pièces insuffisant',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSpacing.md),
      decoration: BoxDecoration(
        color: DoutangTheme.danger.withValues(alpha: 0.06),
        borderRadius: DRadius.card,
        border: Border.all(
          color: DoutangTheme.danger.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.block_outlined,
            color: DoutangTheme.danger,
            size: 20,
          ),
          const SizedBox(width: DSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labels[blocker.type] ?? blocker.type.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DoutangTheme.danger,
                  ),
                ),
                if (blocker.message.isNotEmpty)
                  Text(
                    blocker.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DoutangTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Points forts / faibles card ────────────────────────────────────────────

class _StrengthsCard extends StatelessWidget {
  final List<String> strengths;
  final List<String> weaknesses;

  const _StrengthsCard({
    required this.strengths,
    required this.weaknesses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSpacing.md),
      decoration: BoxDecoration(
        color: DoutangTheme.cardBg,
        borderRadius: DRadius.card,
        border: Border.all(color: DoutangTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (strengths.isNotEmpty) ...[
            _ChipRow(
              label: 'Points forts',
              icon: Icons.thumb_up_outlined,
              color: DoutangTheme.primary,
              items: strengths,
            ),
          ],
          if (strengths.isNotEmpty && weaknesses.isNotEmpty)
            const SizedBox(height: DSpacing.sm),
          if (weaknesses.isNotEmpty)
            _ChipRow(
              label: 'Points faibles',
              icon: Icons.thumb_down_outlined,
              color: DoutangTheme.danger,
              items: weaknesses,
            ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ChipRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSpacing.xs),
        Wrap(
          spacing: DSpacing.xs,
          runSpacing: DSpacing.xs,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ── Note card (coup de cœur / point rédhibitoire) ─────────────────────────

class _NoteCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;

  const _NoteCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: DRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: DSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSpacing.sm),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: DoutangTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
