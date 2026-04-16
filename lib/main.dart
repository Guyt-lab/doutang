import 'package:flutter/material.dart';
import 'theme/doutang_theme.dart';
import 'theme/app_routes.dart';
import 'screens/listings/listings_screen.dart';
import 'screens/visits/visits_screen.dart';
import 'screens/compare/compare_screen.dart';
import 'screens/profile/profile_screen.dart';

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
      home: const MainScaffold(),
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
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: _destinations,
        backgroundColor: Colors.white,
        indicatorColor: DoutangTheme.primarySurface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
