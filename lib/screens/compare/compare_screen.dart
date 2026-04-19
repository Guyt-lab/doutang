import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/listing.dart';
import '../../models/profile.dart';
import '../../models/visit.dart';
import '../../services/listing_storage_service.dart';
import '../../services/profile_storage_service.dart';
import '../../services/project_service.dart';
import '../../services/score_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';
import '../../widgets/empty_state.dart';

// ── Enum vue ──────────────────────────────────────────────────────────────────

enum _CompareView { ranking, comparaison }

// ── Modèle interne ────────────────────────────────────────────────────────────

class _Entry {
  final Listing listing;
  final Visit? visit;
  final double finalScore;
  final double evalScore; // 0-100
  final double matchingScore; // 0-100
  final double feelingScore; // 0-100
  final List<Blocker> blockers;

  const _Entry({
    required this.listing,
    required this.visit,
    required this.finalScore,
    required this.evalScore,
    required this.matchingScore,
    required this.feelingScore,
    required this.blockers,
  });

  bool get hasVisit => visit != null;
  bool get hasBlockers => blockers.isNotEmpty;
}

// ── CompareScreen ─────────────────────────────────────────────────────────────

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  _CompareView _view = _CompareView.ranking;
  List<_Entry> _entries = [];
  UserProfile? _profile;
  bool _isLoading = true;

  // Vue comparaison
  final Set<String> _selected = {};
  bool _showTable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projectId = await ProjectService.getActiveId() ?? '';
    final results = await Future.wait([
      ProfileStorageService.load(projectId: projectId),
      ListingStorageService.load(projectId: projectId),
      VisitStorageService.load(projectId: projectId),
    ]);

    final profile = (results[0] as UserProfile?) ?? UserProfile(owner: 'Moi');
    final listings = results[1] as List<Listing>;
    final visits = results[2] as List<Visit>;

    final visitByListing = <String, Visit>{
      for (final v in visits) v.listingId: v,
    };

    final entries = listings.map((listing) {
      final visit = visitByListing[listing.id];
      final finalScore = ScoreService.calculateFinalScore(
          visit, listing.facts, profile, listing);
      final matchingRaw = ScoreService.calculateMatchingScore(listing, profile,
          facts: listing.facts);
      final evalScore = visit != null
          ? (ScoreService.calculateVisitScore(visit, profile,
                  config: profile.questionnaireConfig) /
              5.0 *
              100)
          : 0.0;
      final feelingScore =
          visit != null ? ((visit.feeling.clamp(1, 5) - 1) / 4.0 * 100) : 0.0;
      final blockers = visit != null
          ? ScoreService.detectBlockers(visit, profile)
          : <Blocker>[];
      return _Entry(
        listing: listing,
        visit: visit,
        finalScore: finalScore,
        evalScore: evalScore,
        matchingScore: matchingRaw * 100,
        feelingScore: feelingScore,
        blockers: blockers,
      );
    }).toList();

    // Tri : bloquants en bas, puis score décroissant.
    entries.sort((a, b) {
      if (a.hasBlockers != b.hasBlockers) return a.hasBlockers ? 1 : -1;
      return b.finalScore.compareTo(a.finalScore);
    });

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparer'),
        bottom: _entries.length >= 2
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<_CompareView>(
                    segments: const [
                      ButtonSegment(
                        value: _CompareView.ranking,
                        label: Text('Ranking'),
                        icon: Icon(Icons.leaderboard_outlined),
                      ),
                      ButtonSegment(
                        value: _CompareView.comparaison,
                        label: Text('Comparer'),
                        icon: Icon(Icons.compare_arrows),
                      ),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) {
                      setState(() {
                        _view = s.first;
                        _showTable = false;
                      });
                    },
                  ),
                ),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_entries.isEmpty) {
      return const EmptyState(
        icon: Icons.compare_arrows,
        title: 'Rien à comparer',
        subtitle: 'Ajoutez des annonces pour les comparer',
      );
    }
    if (_entries.length == 1) {
      return const EmptyState(
        icon: Icons.compare_arrows,
        title: 'Pas assez d\'annonces',
        subtitle: 'Ajoutez au moins 2 annonces pour comparer',
      );
    }
    return switch (_view) {
      _CompareView.ranking => _RankingView(
          entries: _entries,
          onTap: (e) => Navigator.pushNamed(
            context,
            AppRoutes.listingDetail,
            arguments: e.listing,
          ),
        ),
      _CompareView.comparaison => _CompareView2(
          entries: _entries,
          profile: _profile,
          selected: _selected,
          showTable: _showTable,
          onSelectionChanged: (id, checked) {
            setState(() {
              if (checked && _selected.length < 3) {
                _selected.add(id);
              } else if (!checked) {
                _selected.remove(id);
              }
            });
          },
          onCompare: () => setState(() => _showTable = true),
          onBack: () => setState(() => _showTable = false),
        ),
    };
  }
}

// ── Vue Ranking ───────────────────────────────────────────────────────────────

class _RankingView extends StatelessWidget {
  const _RankingView({required this.entries, required this.onTap});

  final List<_Entry> entries;
  final void Function(_Entry) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(DSpacing.md),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: DSpacing.sm),
      itemBuilder: (context, i) => _RankCard(
        rank: i + 1,
        entry: entries[i],
        onTap: () => onTap(entries[i]),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.rank,
    required this.entry,
    required this.onTap,
  });

  final int rank;
  final _Entry entry;
  final VoidCallback onTap;

  Color get _rankColor => switch (rank) {
        1 => DoutangTheme.scoreExcellent,
        2 => DoutangTheme.primary,
        3 => DoutangTheme.accent,
        _ => DoutangTheme.textHint,
      };

  @override
  Widget build(BuildContext context) {
    final listing = entry.listing;
    final scoreColor = DoutangTheme.scoreColor(entry.finalScore / 20);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: DRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(DSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rang
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _rankColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSpacing.sm),
                  // Titre + adresse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (listing.address != null)
                          Text(
                            listing.address!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DSpacing.sm),
                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.finalScore.round()}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        '/100',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: DSpacing.sm),
              // Mini-barres
              _MiniBar(
                  label: 'Éval',
                  value: entry.evalScore,
                  color: DoutangTheme.primary),
              const SizedBox(height: 4),
              _MiniBar(
                  label: 'Matching',
                  value: entry.matchingScore,
                  color: DoutangTheme.primaryLight),
              const SizedBox(height: 4),
              _MiniBar(
                  label: 'Feeling',
                  value: entry.feelingScore,
                  color: DoutangTheme.accent),
              const SizedBox(height: DSpacing.sm),
              // Badges + prix/surface
              Row(
                children: [
                  if (entry.hasVisit)
                    _Badge('Visité ✓', DoutangTheme.scoreExcellent)
                  else
                    _Badge('Non visité — score estimé', DoutangTheme.textHint),
                  if (entry.hasBlockers) ...[
                    const SizedBox(width: DSpacing.xs),
                    _Badge('⚠ Bloquant', DoutangTheme.danger),
                  ],
                  const Spacer(),
                  if (listing.price != null)
                    Text(
                      '${(listing.price! / 1000).toStringAsFixed(0)}k€',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  if (listing.price != null && listing.surface != null)
                    Text(
                      ' · ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (listing.surface != null)
                    Text(
                      '${listing.surface!.round()} m²',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar(
      {required this.label, required this.value, required this.color});

  final String label;
  final double value; // 0-100
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: DoutangTheme.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: DSpacing.xs),
        SizedBox(
          width: 28,
          child: Text(
            '${value.round()}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Vue Comparaison ───────────────────────────────────────────────────────────

class _CompareView2 extends StatelessWidget {
  const _CompareView2({
    required this.entries,
    required this.profile,
    required this.selected,
    required this.showTable,
    required this.onSelectionChanged,
    required this.onCompare,
    required this.onBack,
  });

  final List<_Entry> entries;
  final UserProfile? profile;
  final Set<String> selected;
  final bool showTable;
  final void Function(String id, bool checked) onSelectionChanged;
  final VoidCallback onCompare;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (showTable) {
      final sel =
          entries.where((e) => selected.contains(e.listing.id)).toList();
      return _CompareTable(
        entries: sel,
        profile: profile,
        onBack: onBack,
      );
    }
    return _SelectionView(
      entries: entries,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      onCompare: onCompare,
    );
  }
}

class _SelectionView extends StatelessWidget {
  const _SelectionView({
    required this.entries,
    required this.selected,
    required this.onSelectionChanged,
    required this.onCompare,
  });

  final List<_Entry> entries;
  final Set<String> selected;
  final void Function(String, bool) onSelectionChanged;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final canCompare = selected.length >= 2;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(DSpacing.md),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: DSpacing.xs),
            itemBuilder: (context, i) {
              final e = entries[i];
              final id = e.listing.id;
              final isSelected = selected.contains(id);
              final isDisabled = !isSelected && selected.length >= 3;
              return CheckboxListTile(
                value: isSelected,
                onChanged: isDisabled
                    ? null
                    : (v) => onSelectionChanged(id, v ?? false),
                title: Text(
                  e.listing.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDisabled ? DoutangTheme.textHint : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${e.finalScore.round()}/100${e.hasVisit ? ' · Visité' : ' · Non visité'}',
                  style: TextStyle(
                      color: isDisabled
                          ? DoutangTheme.textHint
                          : DoutangTheme.textSecondary),
                ),
                secondary: e.hasBlockers
                    ? const Icon(Icons.warning_amber_rounded,
                        color: DoutangTheme.danger, size: 20)
                    : null,
                activeColor: DoutangTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DRadius.md)),
                tileColor: DoutangTheme.cardBg,
              );
            },
          ),
        ),
        if (canCompare)
          Padding(
            padding: const EdgeInsets.all(DSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCompare,
                icon: const Icon(Icons.compare_arrows),
                label: Text('Comparer ${selected.length} biens'),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Tableau de comparaison ────────────────────────────────────────────────────

class _CompareTable extends StatelessWidget {
  const _CompareTable({
    required this.entries,
    required this.profile,
    required this.onBack,
  });

  final List<_Entry> entries;
  final UserProfile? profile;
  final VoidCallback onBack;

  bool get _isAchat => profile?.criteria.projectType == 'achat';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DSpacing.md, vertical: DSpacing.sm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Retour à la sélection'),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                  DSpacing.md, 0, DSpacing.md, DSpacing.md),
              child: _buildTable(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final rows = _buildRows();
    final colCount = entries.length + 1;
    const labelWidth = 120.0;
    const cellWidth = 140.0;

    return Table(
      border: TableBorder.all(color: DoutangTheme.border, width: 0.5),
      columnWidths: {
        0: const FixedColumnWidth(labelWidth),
        for (int i = 1; i < colCount; i++) i: const FixedColumnWidth(cellWidth),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  List<TableRow> _buildRows() {
    final rows = <TableRow>[];

    // Header
    rows.add(_headerRow());

    // Prix
    rows.add(_numericRow(
      'Prix',
      entries.map((e) => e.listing.price).toList(),
      format: (v) => v != null ? '${(v / 1000).toStringAsFixed(0)}k€' : '—',
      bestIsLow: true,
    ));

    // Surface
    rows.add(_numericRow(
      'Surface',
      entries.map((e) {
        final s = e.listing.facts.surfaceTotal ?? e.listing.surface;
        return s;
      }).toList(),
      format: (v) => v != null ? '${v.round()} m²' : '—',
      bestIsLow: false,
    ));

    // DPE
    rows.add(_dpeRow());

    // Transports
    rows.add(_numericRow(
      'Transport',
      entries
          .map((e) => e.visit?.answers.transportMinutes?.toDouble())
          .toList(),
      format: (v) => v != null ? '${v.round()} min' : '—',
      bestIsLow: true,
    ));

    // Luminosité
    rows.add(_numericRow(
      'Luminosité',
      entries.map((e) => e.visit?.answers.luminosite?.toDouble()).toList(),
      format: (v) => v != null
          ? '${'★' * v.round()}${' ' * (5 - v.round())} (${v.round()}/5)'
          : '—',
      bestIsLow: false,
    ));

    // Calme
    rows.add(_numericRow(
      'Calme',
      entries.map((e) => e.visit?.answers.calme?.toDouble()).toList(),
      format: (v) => v != null
          ? '${'★' * v.round()}${' ' * (5 - v.round())} (${v.round()}/5)'
          : '—',
      bestIsLow: false,
    ));

    // Feeling
    rows.add(_numericRow(
      'Feeling',
      entries.map((e) => e.visit?.feeling.toDouble()).toList(),
      format: (v) => v != null ? '${'★' * v.round()} (${v.round()}/5)' : '—',
      bestIsLow: false,
    ));

    // Bloquants
    rows.add(_blockerRow());

    // Rénovation (achat seulement)
    if (_isAchat) {
      rows.add(_renovRow());
    }

    // Score final (ligne mise en évidence)
    rows.add(_scoreRow());

    return rows;
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: DoutangTheme.primary),
      children: [
        _cell('Critère',
            isLabel: true,
            labelBg: DoutangTheme.primary,
            textColor: Colors.white,
            bold: true),
        ...entries.map((e) => _cell(
              e.listing.title,
              textColor: Colors.white,
              bold: true,
              maxLines: 2,
            )),
      ],
    );
  }

  TableRow _numericRow(
    String label,
    List<double?> values, {
    required String Function(double?) format,
    required bool bestIsLow,
  }) {
    int? bestIdx;
    double? bestVal;
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      if (bestVal == null || (bestIsLow ? v < bestVal : v > bestVal)) {
        bestVal = v;
        bestIdx = i;
      }
    }

    return TableRow(
      children: [
        _cell(label, isLabel: true),
        ...List.generate(entries.length, (i) {
          final isBest = i == bestIdx && values[i] != null;
          return _cell(
            format(values[i]),
            highlight: isBest,
          );
        }),
      ],
    );
  }

  TableRow _dpeRow() {
    const order = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final dpes =
        entries.map((e) => e.listing.facts.dpe?.toUpperCase()).toList();

    int? bestIdx;
    int? bestRank;
    for (int i = 0; i < dpes.length; i++) {
      final d = dpes[i];
      if (d == null) continue;
      final rank = order.indexOf(d);
      if (rank == -1) continue;
      if (bestRank == null || rank < bestRank) {
        bestRank = rank;
        bestIdx = i;
      }
    }

    return TableRow(
      children: [
        _cell('DPE', isLabel: true),
        ...List.generate(entries.length, (i) {
          final isBest = i == bestIdx && dpes[i] != null;
          return _cell(dpes[i] ?? '—', highlight: isBest);
        }),
      ],
    );
  }

  TableRow _blockerRow() {
    return TableRow(
      children: [
        _cell('Bloquants', isLabel: true),
        ...entries.map((e) {
          if (e.visit == null) return _cell('—');
          if (!e.hasBlockers) {
            return _cell('✓', highlight: true);
          }
          return _cell(
            e.blockers.map((b) => b.message).join('\n'),
            textColor: DoutangTheme.danger,
          );
        }),
      ],
    );
  }

  TableRow _renovRow() {
    final budgets = entries.map((e) {
      final r = e.visit?.answers.renovation;
      if (r == null) return null;
      return switch (r.computedBudgetRange) {
        BudgetRange.none => 'Aucun',
        BudgetRange.under5k => '< 5k€',
        BudgetRange.between5and20k => '5-20k€',
        BudgetRange.above20k => '> 20k€',
      };
    }).toList();

    // Meilleur = aucun ou le moins de travaux
    const rankMap = {'Aucun': 0, '< 5k€': 1, '5-20k€': 2, '> 20k€': 3};
    int? bestIdx;
    int? bestRank;
    for (int i = 0; i < budgets.length; i++) {
      final b = budgets[i];
      if (b == null) continue;
      final rank = rankMap[b] ?? 4;
      if (bestRank == null || rank < bestRank) {
        bestRank = rank;
        bestIdx = i;
      }
    }

    return TableRow(
      children: [
        _cell('Rénovation', isLabel: true),
        ...List.generate(entries.length, (i) {
          final isBest = i == bestIdx && budgets[i] != null;
          return _cell(budgets[i] ?? '—', highlight: isBest);
        }),
      ],
    );
  }

  TableRow _scoreRow() {
    final scores = entries.map((e) => e.finalScore).toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFEDF7F0)),
      children: [
        _cell('Score final',
            isLabel: true, labelBg: const Color(0xFFEDF7F0), bold: true),
        ...entries.map((e) {
          final isBest = e.finalScore == maxScore;
          final color = DoutangTheme.scoreColor(e.finalScore / 20);
          return _cell(
            '${e.finalScore.round()}/100',
            bold: true,
            textColor: isBest ? DoutangTheme.scoreExcellent : color,
            highlight: isBest,
          );
        }),
      ],
    );
  }

  Widget _cell(
    String text, {
    bool isLabel = false,
    bool highlight = false,
    bool bold = false,
    Color? textColor,
    Color? labelBg,
    int maxLines = 3,
  }) {
    Color bg = Colors.transparent;
    if (isLabel) bg = labelBg ?? DoutangTheme.surface;
    if (highlight && !isLabel) bg = const Color(0xFFE8F5E9);

    return TableCell(
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(
            horizontal: DSpacing.sm, vertical: DSpacing.sm),
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: textColor ??
                (isLabel
                    ? DoutangTheme.textSecondary
                    : DoutangTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}
