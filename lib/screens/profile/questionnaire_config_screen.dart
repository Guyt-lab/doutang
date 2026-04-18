import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/default_questions.dart';
import '../../models/enums.dart';
import '../../models/profile.dart';
import '../../models/question_template.dart';
import '../../services/profile_storage_service.dart';
import '../../services/project_service.dart';
import '../../theme/doutang_theme.dart';

const _uuid = Uuid();

// ── Labels partagés ──────────────────────────────────────────────────────────

const _sectionLabels = <String, String>{
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
  's8': 'Aspects pratiques',
};

const _filterLabels = <ProjectFilter, String>{
  ProjectFilter.appartement: 'Appt',
  ProjectFilter.maison: 'Maison',
  ProjectFilter.location: 'Location',
  ProjectFilter.achat: 'Achat',
};

const _filterColors = <ProjectFilter, Color>{
  ProjectFilter.appartement: Color(0xFF3D6FCC),
  ProjectFilter.maison: Color(0xFF2E8B57),
  ProjectFilter.location: Color(0xFFB07D2E),
  ProjectFilter.achat: Color(0xFF8B2EB0),
};

class QuestionnaireConfigScreen extends StatefulWidget {
  final UserProfile profile;

  const QuestionnaireConfigScreen({super.key, required this.profile});

  @override
  State<QuestionnaireConfigScreen> createState() =>
      _QuestionnaireConfigScreenState();
}

class _QuestionnaireConfigScreenState extends State<QuestionnaireConfigScreen> {
  late Set<String> _disabled;
  late List<QuestionTemplate> _custom;
  late Map<String, List<ProjectFilter>> _tagOverrides;

  bool _saving = false;

  // Filter chips state
  ProjectFilter? _activeFilter;

  @override
  void initState() {
    super.initState();
    final cfg = widget.profile.questionnaireConfig;
    _disabled = Set.from(cfg.disabledQuestionIds);
    _custom = List.from(cfg.customQuestions);
    _tagOverrides = cfg.questionTagOverrides.map(
      (k, v) => MapEntry(k, List<ProjectFilter>.from(v)),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<ProjectFilter> _effectiveTags(QuestionTemplate q) =>
      _tagOverrides[q.id] ?? q.appliesTo;

  bool _matchesFilter(QuestionTemplate q) {
    if (_activeFilter == null) return true;
    final tags = _effectiveTags(q);
    if (tags.isEmpty) return true;
    return tags.contains(_activeFilter);
  }

  Map<String, List<QuestionTemplate>> _grouped() {
    final all =
        [...kDefaultQuestions, ..._custom].where(_matchesFilter).toList();
    final map = <String, List<QuestionTemplate>>{};
    for (final q in all) {
      map.putIfAbsent(q.section, () => []).add(q);
    }
    return map;
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      questionnaireConfig: widget.profile.questionnaireConfig.copyWith(
        disabledQuestionIds: _disabled,
        customQuestions: _custom,
        questionTagOverrides: _tagOverrides,
      ),
    );
    final projectId = await ProjectService.getActiveId() ?? '';
    await ProfileStorageService.save(updated, projectId: projectId);
    if (mounted) Navigator.pop(context);
  }

  // ── Tag editing ────────────────────────────────────────────────────────────

  void _toggleTag(String id, List<ProjectFilter> baseTags, ProjectFilter tag) {
    setState(() {
      final current = List<ProjectFilter>.from(_tagOverrides[id] ?? baseTags);
      if (current.contains(tag)) {
        current.remove(tag);
      } else {
        current.add(tag);
      }
      if (current == baseTags) {
        _tagOverrides.remove(id);
      } else {
        _tagOverrides[id] = current;
      }
    });
  }

  // ── Add custom question ────────────────────────────────────────────────────

  Future<void> _showAddDialog([QuestionTemplate? editing]) async {
    final textCtrl = TextEditingController(text: editing?.text ?? '');
    final hintCtrl = TextEditingController(text: editing?.hint ?? '');
    String section = editing?.section ?? 's1';
    QuestionType type = editing?.type ?? QuestionType.score;
    QuestionTiming timing = editing?.timing ?? QuestionTiming.pendant;
    final selectedTags = List<ProjectFilter>.from(editing?.appliesTo ?? []);
    final optionsCtrl = TextEditingController(
      text: editing?.options.join(', ') ?? '',
    );

    final result = await showModalBottomSheet<QuestionTemplate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: DSpacing.md,
            right: DSpacing.md,
            top: DSpacing.md,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + DSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editing == null
                      ? 'Nouvelle question'
                      : 'Modifier la question',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: DSpacing.md),
                TextField(
                  controller: textCtrl,
                  decoration: const InputDecoration(labelText: 'Libellé *'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: DSpacing.sm),
                TextField(
                  controller: hintCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Aide (optionnel)'),
                ),
                const SizedBox(height: DSpacing.md),
                // Section
                DropdownButtonFormField<String>(
                  initialValue: section,
                  decoration: const InputDecoration(labelText: 'Section'),
                  items: _sectionLabels.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setModal(() => section = v!),
                ),
                const SizedBox(height: DSpacing.md),
                // Type
                Text('Type de réponse',
                    style: Theme.of(ctx).textTheme.labelMedium),
                const SizedBox(height: DSpacing.xs),
                Wrap(
                  spacing: DSpacing.sm,
                  children: [
                    for (final t in [
                      QuestionType.score,
                      QuestionType.yesNo,
                      QuestionType.text,
                      QuestionType.multiChoice,
                    ])
                      ChoiceChip(
                        label: Text(_typeLabel(t)),
                        selected: type == t,
                        onSelected: (_) => setModal(() => type = t),
                      ),
                  ],
                ),
                if (type == QuestionType.multiChoice) ...[
                  const SizedBox(height: DSpacing.sm),
                  TextField(
                    controller: optionsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Options (séparées par des virgules)',
                    ),
                  ),
                ],
                const SizedBox(height: DSpacing.md),
                // Timing
                Text('Moment', style: Theme.of(ctx).textTheme.labelMedium),
                const SizedBox(height: DSpacing.xs),
                Wrap(
                  spacing: DSpacing.sm,
                  children: [
                    for (final t in QuestionTiming.values
                        .where((t) => t != QuestionTiming.flexible))
                      ChoiceChip(
                        label: Text(_timingLabel(t)),
                        selected: timing == t,
                        onSelected: (_) => setModal(() => timing = t),
                      ),
                  ],
                ),
                const SizedBox(height: DSpacing.md),
                // Tags
                Text('Applicable à',
                    style: Theme.of(ctx).textTheme.labelMedium),
                const SizedBox(height: DSpacing.xs),
                Wrap(
                  spacing: DSpacing.sm,
                  children: _filterLabels.entries
                      .map((e) => FilterChip(
                            label: Text(e.value),
                            selected: selectedTags.contains(e.key),
                            onSelected: (on) => setModal(() {
                              if (on) {
                                selectedTags.add(e.key);
                              } else {
                                selectedTags.remove(e.key);
                              }
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: DSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (textCtrl.text.trim().isEmpty) return;
                      final options = type == QuestionType.multiChoice
                          ? optionsCtrl.text
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList()
                          : <String>[];
                      Navigator.pop(
                        ctx,
                        QuestionTemplate(
                          id: editing?.id ?? 'custom_${_uuid.v4()}',
                          section: section,
                          text: textCtrl.text.trim(),
                          hint: hintCtrl.text.trim().isEmpty
                              ? null
                              : hintCtrl.text.trim(),
                          level: QuestionLevel.nice,
                          type: type,
                          timing: timing,
                          appliesTo: selectedTags,
                          isCustom: true,
                          options: options,
                        ),
                      );
                    },
                    child: Text(editing == null ? 'Ajouter' : 'Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (editing != null) {
          final idx = _custom.indexWhere((q) => q.id == editing.id);
          if (idx >= 0) _custom[idx] = result;
        } else {
          _custom.add(result);
        }
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped();
    final allSections = [
      ..._sectionLabels.keys.where((s) => grouped.containsKey(s)),
      ...grouped.keys.where((s) => !_sectionLabels.containsKey(s)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        tooltip: 'Ajouter une question',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Filter bar ──
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: DSpacing.md, vertical: 6),
              children: [
                _FilterChip(
                  label: 'Toutes',
                  selected: _activeFilter == null,
                  color: DoutangTheme.primary,
                  onTap: () => setState(() => _activeFilter = null),
                ),
                const SizedBox(width: DSpacing.sm),
                ..._filterLabels.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(right: DSpacing.sm),
                      child: _FilterChip(
                        label: e.value,
                        selected: _activeFilter == e.key,
                        color: _filterColors[e.key] ?? DoutangTheme.primary,
                        onTap: () => setState(() => _activeFilter =
                            _activeFilter == e.key ? null : e.key),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 0),
          // ── Question list ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                for (final section in allSections)
                  if (grouped.containsKey(section)) ...[
                    _SectionHeader(label: _sectionLabels[section] ?? section),
                    for (final q in grouped[section]!)
                      _QuestionTile(
                        question: q,
                        enabled: !_disabled.contains(q.id),
                        effectiveTags: _effectiveTags(q),
                        onToggle: (on) => setState(() {
                          if (on) {
                            _disabled.remove(q.id);
                          } else {
                            _disabled.add(q.id);
                          }
                        }),
                        onTagToggle: (tag) =>
                            _toggleTag(q.id, q.appliesTo, tag),
                        onEdit: q.isCustom ? () => _showAddDialog(q) : null,
                        onDelete: q.isCustom
                            ? () => setState(
                                () => _custom.removeWhere((c) => c.id == q.id))
                            : null,
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _typeLabel(QuestionType t) => switch (t) {
      QuestionType.score => '⭐ Note',
      QuestionType.yesNo => 'Oui/Non',
      QuestionType.text => 'Texte',
      QuestionType.multiChoice => 'Choix',
      QuestionType.photo => 'Photo',
    };

String _timingLabel(QuestionTiming t) => switch (t) {
      QuestionTiming.avant => 'Avant',
      QuestionTiming.pendant => 'Pendant',
      QuestionTiming.apres => 'Après',
      QuestionTiming.flexible => 'Flexible',
    };

// ── Internal widgets ─────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? color.withValues(alpha: 0.12) : DoutangTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? color : DoutangTheme.border,
              width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? color : DoutangTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(DSpacing.md, DSpacing.md, DSpacing.md, 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: DoutangTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final QuestionTemplate question;
  final bool enabled;
  final List<ProjectFilter> effectiveTags;
  final ValueChanged<bool> onToggle;
  final ValueChanged<ProjectFilter> onTagToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _QuestionTile({
    required this.question,
    required this.enabled,
    required this.effectiveTags,
    required this.onToggle,
    required this.onTagToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: DSpacing.md, vertical: 2),
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
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeThumbColor: DoutangTheme.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: enabled
                              ? DoutangTheme.textPrimary
                              : DoutangTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${_typeLabel(question.type)} · ${_timingLabel(question.timing)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: DoutangTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: DoutangTheme.textSecondary,
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: DoutangTheme.danger,
                    onPressed: onDelete,
                  ),
              ],
            ),
            // ── Tag chips ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSpacing.sm, 0, DSpacing.sm, DSpacing.sm),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _filterLabels.entries.map((e) {
                  final active = effectiveTags.contains(e.key);
                  final color = _filterColors[e.key] ?? DoutangTheme.primary;
                  return GestureDetector(
                    onTap: () => onTagToggle(e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? color.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? color : DoutangTheme.border,
                          width: active ? 1.2 : 0.8,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? color : DoutangTheme.textHint,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
