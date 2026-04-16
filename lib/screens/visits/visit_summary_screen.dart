import 'package:flutter/material.dart';

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
