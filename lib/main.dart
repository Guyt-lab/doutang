import 'package:flutter/material.dart';

import 'screens/compare/compare_screen.dart';
import 'screens/listings/listings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/projects/projects_screen.dart';
import 'screens/visits/visits_screen.dart';
import 'services/project_service.dart';
import 'theme/app_routes.dart';
import 'theme/doutang_theme.dart';

void main() {
  runApp(const DoutangApp());
}

class DoutangApp extends StatelessWidget {
  const DoutangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doutang',
      theme: DoutangTheme.light,
      debugShowCheckedModeBanner: false,
      routes: Map.of(AppRoutes.routes)..remove(AppRoutes.listings),
      home: const _AppEntry(),
    );
  }
}

/// Vérifie au démarrage si un projet actif existe.
/// Si oui → MainScaffold. Sinon → ProjectsScreen.
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late final Future<bool> _hasActiveProject;

  @override
  void initState() {
    super.initState();
    _hasActiveProject = _checkActiveProject();
  }

  Future<bool> _checkActiveProject() async {
    final id = await ProjectService.getActiveId();
    if (id == null || id.isEmpty) return false;
    final projects = await ProjectService.loadAll();
    return projects.any((p) => p.id == id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasActiveProject,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data! ? const MainScaffold() : const ProjectsScreen();
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ListingsScreen(),
    VisitsScreen(),
    CompareScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Annonces',
    ),
    NavigationDestination(
      icon: Icon(Icons.door_front_door_outlined),
      selectedIcon: Icon(Icons.door_front_door),
      label: 'Visites',
    ),
    NavigationDestination(
      icon: Icon(Icons.compare_arrows_outlined),
      selectedIcon: Icon(Icons.compare_arrows),
      label: 'Comparer',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations,
        backgroundColor: Colors.white,
        indicatorColor: DoutangTheme.primarySurface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
