import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/project.dart';
import '../../services/listing_storage_service.dart';
import '../../services/project_service.dart';
import '../../services/visit_storage_service.dart';
import '../../theme/doutang_theme.dart';

/// 6 couleurs prédéfinies pour les projets.
const _kProjectColors = <int>[
  0xFF2D6A4F,
  0xFF264653,
  0xFF457B9D,
  0xFF6B4EFF,
  0xFFE63946,
  0xFFE9C46A,
];

class ProjectsScreen extends StatefulWidget {
  /// [fromSwitch] = true quand l'utilisateur arrive depuis le bouton switch
  /// de l'app (peut revenir en arrière). false = premier lancement.
  final bool fromSwitch;

  const ProjectsScreen({super.key, this.fromSwitch = false});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectMeta> _projects = [];
  Map<String, ({int listings, int visits})> _counts = {};
  String? _activeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await ProjectService.loadAll();
    final activeId = await ProjectService.getActiveId();

    final counts = await Future.wait(
      projects.map((p) async {
        final ls = await ListingStorageService.load(projectId: p.id);
        final vs = await VisitStorageService.load(projectId: p.id);
        return (id: p.id, listings: ls.length, visits: vs.length);
      }),
    );

    if (mounted) {
      setState(() {
        _projects = projects;
        _activeId = activeId;
        _counts = {
          for (final c in counts)
            c.id: (listings: c.listings, visits: c.visits),
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _selectProject(ProjectMeta project) async {
    await ProjectService.setActive(project.id);
    if (!mounted) return;
    if (widget.fromSwitch) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _deleteProject(ProjectMeta project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet ?'),
        content: Text(
          'Toutes les annonces et visites de "${project.name}" seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: DoutangTheme.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ProjectService.delete(project.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes projets'),
        automaticallyImplyLeading: widget.fromSwitch,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(DSpacing.md),
                  itemCount: _projects.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: DSpacing.sm),
                  itemBuilder: (context, i) {
                    final p = _projects[i];
                    return _ProjectCard(
                      project: p,
                      isActive: p.id == _activeId,
                      counts: _counts[p.id],
                      onTap: () => _selectProject(p),
                      onDelete: () => _deleteProject(p),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: DoutangTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau projet'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 64, color: DoutangTheme.textHint),
          const SizedBox(height: DSpacing.md),
          Text(
            'Aucun projet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: DSpacing.sm),
          const Text(
            'Crée ton premier projet de recherche',
            style: TextStyle(color: DoutangTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreateProjectSheet(
        onCreate: (name, type, propertyType, color) async {
          Navigator.pop(ctx);
          final project = await ProjectService.create(
            name: name,
            type: type,
            propertyType: propertyType,
            color: color,
          );
          await ProjectService.setActive(project.id);
          if (!mounted) return;
          if (widget.fromSwitch) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
    );
  }
}

// ── Card projet ────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectMeta project;
  final bool isActive;
  final ({int listings, int visits})? counts;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.isActive,
    required this.counts,
    required this.onTap,
    required this.onDelete,
  });

  static const _propertyLabel = {
    PropertyType.appartement: 'Appartement',
    PropertyType.maison: 'Maison',
    PropertyType.lesDeux: 'Appt / Maison',
  };

  @override
  Widget build(BuildContext context) {
    final color = Color(project.color);
    final typeLabel =
        project.type == ProjectType.location ? 'Location' : 'Achat';
    final propLabel = _propertyLabel[project.propertyType] ?? '';

    return Dismissible(
      key: ValueKey(project.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => false, // handled by onDelete button
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DSpacing.md),
        decoration: BoxDecoration(
          color: DoutangTheme.danger,
          borderRadius: DRadius.card,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: DRadius.card,
          child: Padding(
            padding: const EdgeInsets.all(DSpacing.md),
            child: Row(
              children: [
                // Indicateur couleur
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      project.name.isNotEmpty
                          ? project.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: DoutangTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: DoutangTheme.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Actif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: DoutangTheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$typeLabel · $propLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DoutangTheme.textSecondary,
                        ),
                      ),
                      if (counts != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${counts!.listings} annonce${counts!.listings != 1 ? 's' : ''}'
                          ' · ${counts!.visits} visite${counts!.visits != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: DoutangTheme.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: DoutangTheme.textHint, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet création ─────────────────────────────────────────────────

class _CreateProjectSheet extends StatefulWidget {
  final Future<void> Function(
          String name, ProjectType type, PropertyType propertyType, int color)
      onCreate;

  const _CreateProjectSheet({required this.onCreate});

  @override
  State<_CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<_CreateProjectSheet> {
  final _nameController = TextEditingController();
  ProjectType _type = ProjectType.location;
  PropertyType _propertyType = PropertyType.appartement;
  int _color = _kProjectColors[0];
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await widget.onCreate(name, _type, _propertyType, _color);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DSpacing.lg,
        right: DSpacing.lg,
        top: DSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + DSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nouveau projet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: DSpacing.lg),

          // Nom
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nom du projet',
              hintText: 'Ex : Location Paris 2026',
              prefixIcon: Icon(Icons.folder_outlined),
            ),
          ),
          const SizedBox(height: DSpacing.md),

          // Type location / achat
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ProjectType>(
              segments: const [
                ButtonSegment(
                    value: ProjectType.location,
                    label: Text('Location'),
                    icon: Icon(Icons.key_outlined)),
                ButtonSegment(
                    value: ProjectType.achat,
                    label: Text('Achat'),
                    icon: Icon(Icons.home_outlined)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          ),
          const SizedBox(height: DSpacing.md),

          // Type de bien
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PropertyType>(
              segments: const [
                ButtonSegment(
                    value: PropertyType.appartement, label: Text('Appt')),
                ButtonSegment(
                    value: PropertyType.maison, label: Text('Maison')),
                ButtonSegment(
                    value: PropertyType.lesDeux, label: Text('Les deux')),
              ],
              selected: {_propertyType},
              onSelectionChanged: (s) =>
                  setState(() => _propertyType = s.first),
            ),
          ),
          const SizedBox(height: DSpacing.md),

          // Sélecteur de couleur
          Row(
            children: _kProjectColors.map((c) {
              final selected = c == _color;
              return Padding(
                padding: const EdgeInsets.only(right: DSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: DoutangTheme.textPrimary, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSpacing.lg),

          // Bouton créer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Créer le projet'),
            ),
          ),
        ],
      ),
    );
  }
}
