// visits_screen.dart
import 'package:flutter/material.dart';
import '../../theme/doutang_theme.dart';
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

class VisitQuestionnaireScreen extends StatelessWidget {
  const VisitQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visite en cours')),
      body: const Center(
        child: Text('Questionnaire swipe — Sprint 2 #005'),
      ),
    );
  }
}

class VisitSummaryScreen extends StatelessWidget {
  const VisitSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilan de visite')),
      body: const Center(
        child: Text('Bilan automatique — Sprint 2 #006'),
      ),
    );
  }
}
