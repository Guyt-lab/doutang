import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes visites')),
      body: const EmptyState(
        icon: Icons.door_front_door_outlined,
        title: 'Aucune visite',
        subtitle: 'Démarre une visite depuis\nle détail d\'une annonce',
      ),
    );
  }
}
