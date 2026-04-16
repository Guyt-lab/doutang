import 'package:flutter/material.dart';
import '../../theme/doutang_theme.dart';
import '../../theme/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(DSpacing.md),
        children: [
          // Avatar + nom
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: DoutangTheme.primarySurface,
                    child: const Text('M',
                        style: TextStyle(
                            fontSize: 22,
                            color: DoutangTheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: DSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Moi',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Profil local',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DSpacing.md),

          // Actions
          Card(
            child: Column(
              children: [
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
                  leading: const Icon(Icons.upload_outlined),
                  title: const Text('Exporter .doutang'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}, // TODO: FileService.export()
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Importer .doutang'),
                  subtitle: const Text('Fusionner avec un partenaire'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}, // TODO: FileService.import()
                ),
              ],
            ),
          ),
          const SizedBox(height: DSpacing.md),

          // Version
          Center(
            child: Text('Doutang v0.1.0',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class DesiderataScreen extends StatelessWidget {
  const DesiderataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes désidératas')),
      body: const Center(
        child: Text('Formulaire désidératas — Sprint 1 · #003'),
      ),
    );
  }
}
