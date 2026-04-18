import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/profile.dart';
import '../../models/project.dart';
import '../../services/profile_storage_service.dart';
import '../../services/project_service.dart';
import '../../theme/app_routes.dart';
import '../../theme/doutang_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProjectMeta? _project;
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projectId = await ProjectService.getActiveId() ?? '';
    final results = await Future.wait([
      ProjectService.getActive(),
      ProfileStorageService.load(projectId: projectId),
    ]);
    if (mounted) {
      setState(() {
        _project = results[0] as ProjectMeta?;
        _profile = results[1] as UserProfile?;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(DSpacing.md),
              children: [
                // Projet actif
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DSpacing.md),
                    child: Row(
                      children: [
                        if (_project != null)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(_project!.color)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Color(_project!.color), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _project!.name.isNotEmpty
                                    ? _project!.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(_project!.color),
                                ),
                              ),
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: DoutangTheme.primarySurface,
                            child: const Icon(Icons.folder_outlined,
                                color: DoutangTheme.primary),
                          ),
                        const SizedBox(width: DSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _project?.name ?? 'Aucun projet actif',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (_project != null)
                                Text(
                                  _projectSubtitle(_project!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DSpacing.sm),

                // Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.swap_horiz_outlined),
                        title: const Text('Changer de projet'),
                        subtitle: const Text('Accéder à tous vos projets'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.projects,
                          arguments: {'fromSwitch': true},
                        ).then((_) => _load()),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.tune),
                        title: const Text('Mes désidératas'),
                        subtitle: const Text('Budget, surface, critères'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.desiderata),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.checklist_outlined),
                        title: const Text('Configurer le questionnaire'),
                        subtitle:
                            const Text('Questions, filtres, questions custom'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.questionnaireConfig,
                          arguments: _profile ?? UserProfile(owner: 'Moi'),
                        ).then((_) => _load()),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.upload_outlined),
                        title: const Text('Exporter .doutang'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('Importer .doutang'),
                        subtitle: const Text('Fusionner avec un partenaire'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DSpacing.md),

                Center(
                  child: Text('Doutang v0.1.0',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
    );
  }

  String _projectSubtitle(ProjectMeta p) {
    final type = p.type == ProjectType.location ? 'Location' : 'Achat';
    final prop = switch (p.propertyType) {
      PropertyType.appartement => 'Appartement',
      PropertyType.maison => 'Maison',
      PropertyType.lesDeux => 'Appartement / Maison',
    };
    return '$type · $prop';
  }
}
