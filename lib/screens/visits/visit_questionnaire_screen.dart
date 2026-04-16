import 'package:flutter/material.dart';

class VisitQuestionnaireScreen extends StatelessWidget {
  const VisitQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visite en cours')),
      body: const Center(
        child: Text('Questionnaire swipe cards — Sprint 2 · #005'),
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
        child: Text('Bilan automatique — Sprint 2 · #006'),
      ),
    );
  }
}
